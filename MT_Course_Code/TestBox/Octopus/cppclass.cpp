#include "cppclass.h"
#include <QDebug>
#include <QColor>
#include <QDate>
#include <QThread>  // Add this line

// Structure Instantiation
Send Send1;
Instrument Instrument1;
Communication Communication1;
Power Power1;

CppClass::CppClass(QObject *parent) : QObject(parent)
{
    m_serialData.running = false;
}

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

void CppClass::setTransmitMode(bool transmitting)
{
    if (m_hPort == INVALID_HANDLE_VALUE) return;

    // Use RTS for transmit/receive control (modify if your hardware uses different)
    if (transmitting) {
        EscapeCommFunction(m_hPort, SETRTS);  // Assert RTS for transmit
    } else {
        EscapeCommFunction(m_hPort, CLRRTS);  // Deassert RTS for receive
    }
    QThread::usleep(1);  // Transceiver switching delay
}

void CppClass::readwriteThread()
{
    while (m_serialData.running)
    {
        // Check for outgoing data with minimal locking
        int localWritePos = 0;
        {
            std::unique_lock<std::mutex> lock(m_serialData.outgoingMutex);
            localWritePos = writePos; // Copy protected value
            writePos = 0; // Reset after copying to prevent race condition
            while (!m_serialData.outgoing.empty() && localWritePos < BUFFER_SIZE)
            {
                writeBuffer[localWritePos++] = m_serialData.outgoing.front();
                m_serialData.outgoing.pop();
            }
        }

        // If we have data to send
        if (localWritePos > 0)
        {
            // Switch to transmit mode
            setTransmitMode(true);

            // Small delay to ensure transceiver is ready (reduced from 1μs)
            QThread::usleep(50);

            DWORD bytesWritten;
            if (!WriteFile(m_hPort, writeBuffer, localWritePos, &bytesWritten, NULL))
            {
                qDebug() << "Write error:" << GetLastError();
            }
            else
            {
                qDebug() << "Sent" << bytesWritten << "bytes";
            }

            // Wait for transmission to complete (important for RS-485)
            // This ensures all bytes are physically transmitted before switching modes
            PurgeComm(m_hPort, PURGE_TXABORT | PURGE_TXCLEAR);

            // Reduced guard time
            QThread::usleep(100); // Guard time before reading

            // Switch back to receive mode
            setTransmitMode(false);
        }

        // Check for incoming data with timeout
        COMMTIMEOUTS timeouts = {0};
        timeouts.ReadIntervalTimeout = 1;  // Reduced timeout
        timeouts.ReadTotalTimeoutMultiplier = 1;
        timeouts.ReadTotalTimeoutConstant = 10;
        SetCommTimeouts(m_hPort, &timeouts);

        DWORD bytesRead;
        if (ReadFile(m_hPort, readBuffer, BUFFER_SIZE, &bytesRead, NULL))
        {
            if (bytesRead > 0)
            {
                // Process received data...
                std::lock_guard<std::mutex> lock(m_serialData.incomingMutex);
                for (DWORD i = 0; i < bytesRead; i++)
                {
                    m_serialData.incoming.push(readBuffer[i]);
                }
                emit dataReceived(QByteArray(readBuffer, bytesRead));

                // Temporary test -- Send raw byte array in response
                //static const char response[] = {0x31, 0x32, 0x33, 0x34};
                //sendData(QByteArray(response, sizeof(response)));
            }
        }
        else
        {
            DWORD err = GetLastError();
            if (err != ERROR_IO_PENDING && err != WAIT_TIMEOUT)
            {
                qDebug() << "Read error:" << err;
                break;
            }
        }

        // Reduced sleep time
        QThread::usleep(100);  // Reduced from 1000μs
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

    if(m_serialData.running == false)
    {
        m_serialData.running = true;
        //m_readThread = std::thread(&CppClass::readThread, this);
        //m_writeThread = std::thread(&CppClass::writeThread, this);
        m_readwriteThread = std::thread(&CppClass::readwriteThread, this);
    }
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

void CppClass::passFromQmlToCpp(QVariantList list/*array*/, QVariantMap map /*object*/)
{
    /*
    qDebug() << "Received variant list and map from QML";
    qDebug() << "List :";
    for( int i{0} ; i < list.size(); i++)
    {
        qDebug() << "List item :" << list.at(i).toString();
    }
    */

    // Print from QVariantList (array)
    if (!list.isEmpty()) {
        qDebug() << "First filename (from list):" << list[0].toString();
    }


    /*
    qDebug() << "Map :";
    for( int i{0} ; i < map.keys().size(); i++)
    {
        qDebug() << "Map item :" << map[map.keys().at(i)].toString();
    }
    */
}

void CppClass::passFromQmlToCpp2(const QVariantList &files)
{
    for (const QVariant &fileVariant : files) {
        QVariantMap file = fileVariant.toMap();
        QDateTime modified = QDateTime::fromMSecsSinceEpoch(
            file["lastModified"].toLongLong());

        qDebug() << "File:" << file["fileName"].toString()
                 << "Size:" << file["fileSizeBytes"].toLongLong() << "bytes"
                 << "Modified:" << modified.toString("yyyy-MM-dd hh:mm:ss");
    }
}

void CppClass::passFromQmlToCpp3(QVariantList list, QVariantMap map)
{
    int bytePos_index = 0;
    int x = 0;
    QByteArray byteArray;

    // Reset all errorcodes for boxes
    Instrument1.errorcode = 0;

    qDebug() << "Received variant list and map from QML";
    qDebug() << "List :";
    for( int i{0} ; i < list.size(); i++)
    {
        //qDebug() << "List item :" << list.at(i).toString();
        //if(i < 5) // protection max
        //{
        //qDebug() << "List item :" << list.at(i).toString().toUtf8();



        // The first string is the selection string.
        // Use it to determine what category the information came from
        // and what therefore needs to be processed.
        if(i == 0)
        {
            // Convert QString to char array
            byteArray = list.at(i).toString().toUtf8();

            x = byteArray.toInt();

            if (x == 1)
            {
                qDebug() << "MT ";
            }
        }
        else
        {
            /*
                for (char c : byteArray)
                {
                    writeBuffer[writePos_temp] = c;
                    writePos_temp++;
                }
                */

            switch (x)  // tell you which box was selected (accordingly extract info expected from each box)
            {
                case INSTRUMENT:
                    // Selection - since we are in here, we know the selection was 1 aka INSTRUMENT
                    //           - it should be zero i think?  maybe not
                    Instrument1.selection = INSTRUMENT;

                    // Device
                    if(i == 1)
                    {
                        Instrument1.device = ((list.at(i).toString().toUtf8()).toInt());
                        qDebug() << "Instrument.device : " << Instrument1.device;
                    }
                    // Serial Number
                    else if(i == 2)
                    {
                        byteArray = list.at(i).toString().toUtf8();
                        bytePos_index = 0;
                        for (char c : byteArray)
                        {
                            if(bytePos_index < ARRAY_SERIALNUMBER_MAX)
                            {
                                Instrument1.serialnumber[bytePos_index] = c;
                                bytePos_index++;
                                //writeBuffer[writePos_temp] = c;
                                //writePos_temp++;
                            }
                        }

                        // Check if insufficient number of characters
                        if(bytePos_index < ARRAY_SERIALNUMBER_MAX)
                        {
                            qDebug() << "Insufficient number of serial characters";
                            Instrument1.errorcode = 0;
                        }
                        else  // print it out
                        {
                            for(int s=0; s < bytePos_index; s++)
                            {
                                //qDebug() << Instrument1.serialnumber[s];
                            }
                            Instrument1.errorcode = 0;
                        }

                        // if everything is alright, we can send it
                        if((Instrument1.errorcode == 0) && (writePos == 0))
                        {
                            SendHeader(INSTRUMENT_SET_MSGLGT, INSTRUMENT_SET_MSGID);

                            AddByteToSend(0x00, false); // Reserved

                            AddByteToSend(Instrument1.selection, false); // Box Selection

                            qDebug() << "here0: " << Send1.writepos;

                            AddByteToSend(Instrument1.device, false); // Devices

                            qDebug() << "here1: " << Send1.writepos;

                            for(int r=0; r < ARRAY_SERIALNUMBER_MAX; r++)
                            {
                                AddByteToSend(Instrument1.serialnumber[r], false);
                            }



                            for(int m=0; m < Send1.writepos; m++)
                            {
                                qDebug() << writeBuffer[m];
                            }

                            qDebug() << "here2: " << Send1.writepos;

                            qDebug() << "crc: " << Send1.crcsend;

                            AddByteToSend(Send1.crcsend, true);

                            std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
                            writePos = Send1.writepos; // triggers send




                            // Send raw byte array
                            //static const char response[] = {0x31, 0x32, 0x33, 0x34};
                            //sendData(QByteArray(response, sizeof(response)));

                            qDebug() << "Bytes sent!";
                        }
                    }
                    break;

                case COMMUNICATIONS:
                    Communication1.selection = COMMUNICATIONS;

                    // Communications
                    if(i == 1)
                    {
                        Communication1.connection = ((list.at(i).toString().toUtf8()).toInt());
                        qDebug() << "Communication.connection : " << Communication1.connection;
                    }
                    else if(i == 2)
                    {
                        Communication1.baudrate = ((list.at(i).toString().toUtf8()).toInt());
                        qDebug() << "Communication.baudrate : " << Communication1.baudrate;
                    }
                    qDebug() << "2";
                    break;

                case POWER:
                    Power1.selection = POWER;

                    // Power
                    if(i == 1)
                    {
                        Power1.batterytype = ((list.at(i).toString().toUtf8()).toInt());
                        qDebug() << "Power.batterytype : " << Power1.batterytype;
                    }
                    qDebug() << "3";
                    break;

                case TIME:
                    break;

                case SAMPLING:
                    break;

                case NOTES:
                    break;

                case ACTIVATION:
                    break;

                case CLOUD:
                    break;

                case MISCELLENEOUS:
                    break;

                default:
                    qDebug() << "Error : x should have a value";
                    break;


            }
        }
        //}
    }
    //writePos = writePos_temp;

    /*
    qDebug() << "Map :";
    for( int i{0} ; i < map.keys().size(); i++)
    {
        qDebug() << "Map item :" << map[map.keys().at(i)].toString();
    }
    */
}

// Helper functions
void CppClass::AddByteToSend(uint8_t data, bool crc_yesno)
{
    writeBuffer[Send1.writepos] = data;
    if(crc_yesno == false)
    {
        Send1.crcsend += writeBuffer[Send1.writepos];
    }
    Send1.writepos += 1;
}

void CppClass::SendHeader(uint8_t msg_length, uint8_t msg_id)
{
    Send1.writepos = 0;
    Send1.crcsend = 0;
    AddByteToSend(DLE, false);
    AddByteToSend(STX, false);
    AddByteToSend(SOURCE, false); // 0x00
    AddByteToSend(DEST, false);   // 0x88  // note : source and dest are opposite on receiving end
    AddByteToSend(msg_length, false);
    AddByteToSend(msg_id, false);
}

void CppClass::passFromQmlToCpp3prev(QVariantList list, QVariantMap map)
{
    int writePos_temp = 0;

    qDebug() << "Received variant list and map from QML";
    qDebug() << "List :";
    for( int i{0} ; i < list.size(); i++)
    {
        //qDebug() << "List item :" << list.at(i).toString();
        //if(i < 5) // max
        {
            qDebug() << "List item :" << list.at(i).toString().toUtf8();

            // Convert QString to char array
            QByteArray byteArray = list.at(i).toString().toUtf8();

            // The first string is the selection string.
            // Use it to determine what category the information came from
            // and what therefore needs to be processed.
            if(i == 0)
            {
                int x = byteArray.toInt();
                if(x == 1)
                {
                    qDebug() << "MT ";
                }
            }

            for (char c : byteArray)
            {
                writeBuffer[writePos_temp] = c;

                //if(writePos_temp == 0)
                //{
                //qDebug() << c.toInt();
                //}
                writePos_temp++;
            }
        }
    }
    writePos = writePos_temp;

    /*
    qDebug() << "Map :";
    for( int i{0} ; i < map.keys().size(); i++)
    {
        qDebug() << "Map item :" << map[map.keys().at(i)].toString();
    }
    */
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


// --------------

void CppClass::openAndReadFile(const QString& filePath) {
    stopFileMonitoring();

    qDebug() << "Attempting to open file:" << filePath;

    m_dataFile.setFileName(filePath);
    if (!m_dataFile.open(QIODevice::ReadOnly | QIODevice::Text | QIODevice::ExistingOnly)) {
        qDebug() << "Failed to open file:" << filePath << "Error:" << m_dataFile.errorString();
        return;
    }

    // Try to detect encoding
    QTextStream stream(&m_dataFile);
    stream.setAutoDetectUnicode(true);
    QString testLine = stream.readLine();
    qDebug() << "First line test:" << testLine;
    m_dataFile.seek(0); // Reset to beginning

    m_currentFileData = FileData();
    m_lastFileSize = 0;

    // Read initial contents
    readFileContents();

    // Start monitoring for changes
    startFileMonitoring(filePath);
}

void CppClass::readFileContents() {
    if (!m_dataFile.isOpen()) {
        qDebug() << "File is not open for reading";
        return;
    }

    m_dataFile.seek(0);
    QTextStream stream(&m_dataFile);
    QString line;
    bool readingMetadata = true;
    bool foundMetadata = false;
    int lineNumber = 0;

    m_currentFileData = FileData(); // Reset data

    qDebug() << "Reading file contents...";

    while (!stream.atEnd()) {
        lineNumber++;
        line = stream.readLine().trimmed();
        qDebug() << "Line" << lineNumber << ":" << line;

        // Skip empty lines at the beginning
        if (line.isEmpty() && !foundMetadata) {
            qDebug() << "Skipping empty line at beginning";
            continue;
        }

        if (readingMetadata) {
            if (line.contains(":")) {
                foundMetadata = true;
                int colonIndex = line.indexOf(":");
                QString key = line.left(colonIndex).trimmed();
                QString value = line.mid(colonIndex + 1).trimmed();

                qDebug() << "Found metadata - Key:" << key << "Value:" << value;

                if (key == "Instrument_Device") m_currentFileData.metadata.device = value;
                else if (key == "Instrument_SerialNumber") m_currentFileData.metadata.serialNumber = value;
                else if (key == "Time_InstrumentClock") m_currentFileData.metadata.instrumentTime = value;
                else if (key == "Time_TimeZone") m_currentFileData.metadata.timeZone = value;
                else if (key == "Activation_ActivationMethod") m_currentFileData.metadata.activationMethod = value;
            }
            else if (line.isEmpty() && foundMetadata) {
                // Empty line after metadata indicates transition to data section
                qDebug() << "Transitioning from metadata to data section";
                readingMetadata = false;
            }
        }
        else {
            // Read data points - skip empty lines in data section
            if (line.isEmpty()) {
                qDebug() << "Skipping empty line in data section";
                continue;
            }

            QStringList values = line.split(",");
            qDebug() << "Data line split into:" << values;

            if (values.size() >= 3) {
                // Trim all values
                for (int i = 0; i < values.size(); i++) {
                    values[i] = values[i].trimmed();
                }

                DataPoint point;
                point.time = values[0];

                // Convert temperature and depth with validation
                bool tempOk, depthOk;
                point.temperature = values[1].toDouble(&tempOk);
                point.depth = values[2].toDouble(&depthOk);

                qDebug() << "Parsed point - Time:" << point.time
                         << "Temp:" << point.temperature << "(valid:" << tempOk << ")"
                         << "Depth:" << point.depth << "(valid:" << depthOk << ")";

                // Only add valid data points
                if (tempOk && depthOk && !point.time.isEmpty()) {
                    m_currentFileData.dataPoints.append(point);
                    qDebug() << "Added valid data point";
                } else {
                    qDebug() << "Skipping invalid data line:" << line;
                }
            } else {
                qDebug() << "Skipping malformed data line (expected 3+ values, got" << values.size() << "):" << line;
            }
        }
    }

    m_lastFileSize = m_dataFile.size();

    // Debug output
    qDebug() << "Read" << m_currentFileData.dataPoints.size() << "data points";
    if (!m_currentFileData.dataPoints.isEmpty()) {
        const DataPoint& first = m_currentFileData.dataPoints.first();
        const DataPoint& last = m_currentFileData.dataPoints.last();
        qDebug() << "First point - Time:" << first.time << "Temp:" << first.temperature << "Depth:" << first.depth;
        qDebug() << "Last point - Time:" << last.time << "Temp:" << last.temperature << "Depth:" << last.depth;
    }

    qDebug() << "Metadata:";
    qDebug() << "  Device:" << m_currentFileData.metadata.device;
    qDebug() << "  SN:" << m_currentFileData.metadata.serialNumber;
    qDebug() << "  Time:" << m_currentFileData.metadata.instrumentTime;
    qDebug() << "  TimeZone:" << m_currentFileData.metadata.timeZone;
    qDebug() << "  Activation:" << m_currentFileData.metadata.activationMethod;

    // Emit data to QML
    QVariantMap metadata;
    metadata["device"] = m_currentFileData.metadata.device;
    metadata["serialNumber"] = m_currentFileData.metadata.serialNumber;
    metadata["instrumentTime"] = m_currentFileData.metadata.instrumentTime;
    metadata["timeZone"] = m_currentFileData.metadata.timeZone;
    metadata["activationMethod"] = m_currentFileData.metadata.activationMethod;

    QVariantList dataPoints;
    for (const DataPoint& point : m_currentFileData.dataPoints) {
        QVariantMap pointMap;
        pointMap["time"] = point.time;
        pointMap["temperature"] = point.temperature;
        pointMap["depth"] = point.depth;
        dataPoints.append(pointMap);
    }

    emit fileDataReady(metadata, dataPoints);
}

void CppClass::startFileMonitoring(const QString& filePath) {
    m_fileMonitorTimer.stop();
    m_fileMonitorTimer.setInterval(1000); // Check every 1 second

    QObject::connect(&m_fileMonitorTimer, &QTimer::timeout, [this]() {
        if (m_dataFile.size() > m_lastFileSize) {
            // Read only new data
            m_dataFile.seek(m_lastFileSize);
            QTextStream stream(&m_dataFile);
            QString line;
            QVariantList newPoints;

            while (!stream.atEnd()) {
                line = stream.readLine().trimmed();

                // Skip empty lines and metadata lines
                if (line.isEmpty() || line.contains(":")) {
                    continue;
                }

                QStringList values = line.split(",");
                if (values.size() >= 3) {
                    // Trim all values
                    for (int i = 0; i < values.size(); i++) {
                        values[i] = values[i].trimmed();
                    }

                    DataPoint point;
                    point.time = values[0];

                    bool tempOk, depthOk;
                    point.temperature = values[1].toDouble(&tempOk);
                    point.depth = values[2].toDouble(&depthOk);

                    if (tempOk && depthOk && !point.time.isEmpty()) {
                        m_currentFileData.dataPoints.append(point);

                        QVariantMap pointMap;
                        pointMap["time"] = point.time;
                        pointMap["temperature"] = point.temperature;
                        pointMap["depth"] = point.depth;
                        newPoints.append(pointMap);
                    }
                }
            }

            m_lastFileSize = m_dataFile.size();
            if (!newPoints.isEmpty()) {
                qDebug() << "Added" << newPoints.size() << "new data points";
                emit newDataPointsAdded(newPoints);
            }
        }
    });

    m_fileMonitorTimer.start();
}

void CppClass::stopFileMonitoring() {
    m_fileMonitorTimer.stop();
    if (m_dataFile.isOpen()) {
        m_dataFile.close();
    }
}

// ------------------


void CppClass::startComm()
{
    setPortName("COM3");
    if(startCommunication(m_portName.toUtf8().constData()) == true)
    {
        emit runningChanged();  // Emit signal when status changes
    }
}

void CppClass::stopComm()
{
    stopCommunication();
    if (m_hPort != INVALID_HANDLE_VALUE)
    {
        CloseHandle(m_hPort);
        emit runningChanged();  // Emit signal when status changes
    }
}

bool CppClass::isRunning()
{
    return m_serialData.running;
}


