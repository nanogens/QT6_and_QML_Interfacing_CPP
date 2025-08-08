#include "cppclass.h"
#include <QDebug>
#include <QColor>
#include <QDate>
#include <QThread>  // Add this line

CppClass::CppClass(QObject *parent) : QObject(parent) {}

CppClass::~CppClass() {
    stopCommunication();
    if (m_hPort != INVALID_HANDLE_VALUE) {
        CloseHandle(m_hPort);
    }
}


// ---------------------



HANDLE CppClass::openCommPort(const char* portName, DWORD baudRate)
{
    std::wstring widePortName = L"\\\\.\\" + std::wstring(portName, portName + strlen(portName));

    HANDLE hSerial = CreateFileW(
        widePortName.c_str(),
        GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        FILE_ATTRIBUTE_NORMAL,
        NULL
        );

    if (hSerial == INVALID_HANDLE_VALUE) {
        qDebug() << "Error opening serial port. Error code:" << GetLastError();
        return INVALID_HANDLE_VALUE;
    }

    DCB dcbSerialParams = {0};
    dcbSerialParams.DCBlength = sizeof(dcbSerialParams);

    if (!GetCommState(hSerial, &dcbSerialParams))
    {
        qDebug() << "Error getting COM port state";
        CloseHandle(hSerial);
        return INVALID_HANDLE_VALUE;
    }

    dcbSerialParams.BaudRate = baudRate;
    dcbSerialParams.ByteSize = 8;
    dcbSerialParams.StopBits = ONESTOPBIT;
    dcbSerialParams.Parity = NOPARITY;
    dcbSerialParams.fDtrControl = DTR_CONTROL_DISABLE;
    dcbSerialParams.fRtsControl = RTS_CONTROL_DISABLE;

    if (!SetCommState(hSerial, &dcbSerialParams))
    {
        qDebug() << "Error setting COM port state";
        CloseHandle(hSerial);
        return INVALID_HANDLE_VALUE;
    }

    COMMTIMEOUTS timeouts = {0};
    timeouts.ReadIntervalTimeout = 50;
    timeouts.ReadTotalTimeoutConstant = 50;
    timeouts.ReadTotalTimeoutMultiplier = 10;
    timeouts.WriteTotalTimeoutConstant = 50;
    timeouts.WriteTotalTimeoutMultiplier = 10;

    if (!SetCommTimeouts(hSerial, &timeouts))
    {
        qDebug() << "Error setting timeouts";
        CloseHandle(hSerial);
        return INVALID_HANDLE_VALUE;
    }

    return hSerial;
}

void CppClass::readThread()
{
    const int BUFFER_SIZE = 256;
    char buffer[BUFFER_SIZE];
    DWORD bytesRead;
    QByteArray receivedData;

    while (m_serialData.running)
    {
        if (ReadFile(m_hPort, buffer, BUFFER_SIZE, &bytesRead, NULL))
        {
            if (bytesRead > 0)
            {
                std::lock_guard<std::mutex> lock(m_serialData.incomingMutex);

                // Store all received bytes
                for (DWORD i = 0; i < bytesRead; i++)
                {
                    m_serialData.incoming.push(buffer[i]);
                }

                // Print all received bytes
                qDebug() << "Received" << bytesRead << "byte(s):";
                for (DWORD i = 0; i < bytesRead; i++)
                {
                    qDebug() << "  Byte" << i << ":"
                             << "Dec:" << static_cast<int>(buffer[i])
                             << "Hex: 0x" << Qt::hex << (static_cast<int>(buffer[i]) & 0xFF)
                             << "Char: '" << ((buffer[i] >= 32 && buffer[i] < 127) ? buffer[i] : '.') << "'";
                }

                emit dataReceived(QByteArray(buffer, bytesRead));

                // Send raw byte array
                //static const char response[] = {0x31, 0x32, 0x33, 0x34};
                //sendData(QByteArray(response, sizeof(response)));
            }
        }
        // ... error handling remains the same ...
    }
}

void CppClass::writeThread()
{
    const int BUFFER_SIZE = 256;
    char writeBuffer[BUFFER_SIZE];
    int bufferPos = 0;

    while (m_serialData.running)
    {
        std::unique_lock<std::mutex> lock(m_serialData.outgoingMutex);

        // Wait for data if buffer is empty
        if (m_serialData.outgoing.empty())
        {
            m_serialData.cv.wait(lock);
        }

        // Fill the write buffer
        while (!m_serialData.outgoing.empty() && bufferPos < BUFFER_SIZE) {
            writeBuffer[bufferPos++] = m_serialData.outgoing.front();
            m_serialData.outgoing.pop();
        }
        lock.unlock();

        // Send the entire buffer at once
        if (bufferPos > 0)
        {
            DWORD bytesWritten;
            if (!WriteFile(m_hPort, writeBuffer, bufferPos, &bytesWritten, NULL))
            {
                qDebug() << "Write error:" << GetLastError();
            }
            else
            {
                qDebug() << "Sent" << bytesWritten << "bytes";
            }
            bufferPos = 0;
        }
    }
}

void CppClass::setTransmitMode(bool transmitting)
{
    if (m_hPort == INVALID_HANDLE_VALUE) return;

    // Use RTS for transmit/receive control (modify if your hardware uses different)
    if (transmitting) {
        EscapeCommFunction(m_hPort, SETRTS);  // Assert RTS for transmit
    } else {
        EscapeCommFunction(m_hPort, CLRRTS);  // Deassert RTS for receive
    }
    QThread::usleep(50);  // Transceiver switching delay
}

void CppClass::readwriteThread()
{
    const int BUFFER_SIZE = 256;
    char readBuffer[BUFFER_SIZE];
    char writeBuffer[BUFFER_SIZE];
    DWORD bytesRead;
    int writePos = 0;

    while (m_serialData.running)
    {
        // First check for outgoing data
        {
            std::unique_lock<std::mutex> lock(m_serialData.outgoingMutex);
            while (!m_serialData.outgoing.empty() && writePos < BUFFER_SIZE) {
                writeBuffer[writePos++] = m_serialData.outgoing.front();
                m_serialData.outgoing.pop();
            }
        }

        // If we have data to send
        if (writePos > 0)
        {
            // Switch to transmit mode
            setTransmitMode(true);

            DWORD bytesWritten;
            if (!WriteFile(m_hPort, writeBuffer, writePos, &bytesWritten, NULL))
            {
                qDebug() << "Write error:" << GetLastError();
            }
            else
            {
                qDebug() << "Sent" << bytesWritten << "bytes";
                writePos = 0;
            }

            // Switch back to receive mode
            setTransmitMode(false);
            QThread::usleep(100); // Guard time before reading
        }

        // Then check for incoming data
        if (ReadFile(m_hPort, readBuffer, BUFFER_SIZE, &bytesRead, NULL))
        {
            if (bytesRead > 0)
            {
                std::lock_guard<std::mutex> lock(m_serialData.incomingMutex);

                // Store all received bytes
                for (DWORD i = 0; i < bytesRead; i++)
                {
                    m_serialData.incoming.push(readBuffer[i]);
                }

                // Print all received bytes
                qDebug() << "Received" << bytesRead << "byte(s):";
                for (DWORD i = 0; i < bytesRead; i++)
                {
                    qDebug() << "  Byte" << i << ":"
                             << "Dec:" << static_cast<int>(readBuffer[i])
                             << "Hex: 0x" << Qt::hex << (static_cast<int>(readBuffer[i]) & 0xFF)
                             << "Char: '" << ((readBuffer[i] >= 32 && readBuffer[i] < 127) ? readBuffer[i] : '.') << "'";
                }

                emit dataReceived(QByteArray(readBuffer, bytesRead));

                // Send raw byte array
                static const char response[] = {0x31, 0x32, 0x33, 0x34};
                sendData(QByteArray(response, sizeof(response)));
            }
        }
        else
        {
            DWORD err = GetLastError();
            if (err != ERROR_IO_PENDING)
            {
                qDebug() << "Read error:" << err;
                break;
            }
        }

        // Small sleep to prevent CPU overuse
        QThread::usleep(1000);
    }
}

void CppClass::sendData(const QByteArray &data)
{
    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    for (char c : data)
    {
        m_serialData.outgoing.push(c);
    }
    m_serialData.cv.notify_one();
}

// Serial Communication Implementation
bool CppClass::startCommunication(const char* portName)
{
    std::lock_guard<std::mutex> lock(m_portMutex);

    m_hPort = openCommPort(portName);
    if (m_hPort == INVALID_HANDLE_VALUE) {
        return false;
    }

    m_serialData.running = true;
    //m_readThread = std::thread(&CppClass::readThread, this);
    //m_writeThread = std::thread(&CppClass::writeThread, this);
    m_readwriteThread = std::thread(&CppClass::readwriteThread, this);

    return true;
}

void CppClass::stopCommunication() {
    m_serialData.running = false;

    /*
    if (m_readThread.joinable())
    {
        m_readThread.join();
    }
    if (m_writeThread.joinable())
    {
        m_writeThread.join();
    }
    */
    if (m_readwriteThread.joinable())
    {
        m_readwriteThread.join();
    }
}



// --------------

void CppClass::passFromQmlToCpp(QVariantList list, QVariantMap map) {
    qDebug() << "Received variant list and map from QML";
    // ... (keep your existing QML code) ...
}

// Add a setter for the port name
void CppClass::setPortName(const QString& portName)
{
    m_portName = portName;
}

QVariantList CppClass::getVariantListFromCpp()
{
    QVariantList list;
    list << 123.3 << QColor(Qt::cyan) << "Qt is great" << 10;

    setPortName("COM3");
    startCommunication(m_portName.toUtf8().constData());
    return list;
}

QVariantMap CppClass::getVariantMapFromCpp() {
    QVariantMap map;
    map.insert("movie","Game of Thrones");
    map.insert("names", "John Snow");
    map.insert("role","Main Character");
    map.insert("release", QDate(2011, 4, 17));
    return map;
}

void CppClass::setQmlRootObject(QObject *value) {
    qmlRootObject = value;
}

void CppClass::triggerJSCall()
{
    qDebug() << "Calling JS";
    QVariantList list;//array
    list << 123.3 << QColor(Qt::cyan) << "Qt is great" << 10;


    QVariantMap map;//object
    map.insert("movie","Game of Thrones");
    map.insert("names", "John Snow");
    map.insert("role","Main Character");
    map.insert("release", QDate(2011, 4, 17));



    QMetaObject::invokeMethod(qmlRootObject, "arrayObjectFunc",
                              Q_ARG(QVariant, QVariant::fromValue(list)),
                              Q_ARG(QVariant, QVariant::fromValue(map)));
    qDebug() << "Called JS";

}




