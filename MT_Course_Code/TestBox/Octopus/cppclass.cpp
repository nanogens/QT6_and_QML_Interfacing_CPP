#include "cppclass.h"
#include <QDebug>
#include <QColor>
#include <QDate>
#include <QThread>

CppClass::CppClass(QObject *parent) : QObject(parent)
{
    m_serialData.running = false;

    // Initialize all buffers and variables in constructor
    Inits();
}

CppClass::~CppClass() {
    stopCommunication();
    if (m_hPort != INVALID_HANDLE_VALUE) {
        CloseHandle(m_hPort);
    }
}

void CppClass::Inits(void)
{
    // Initialize buffers using local loop variables, not global counter
    for(int i = 0; i < BUFFER_SIZE; i++)
    {
        writeBuffer[i] = 0;
        readBuffer[i] = 0;
        readBufferShadow[i] = 0;
    }

    writePos = 0;
    bytesRead = 0;
    bytesReadShadow = 0;

    // Initialize counter structure
    counter.y0 = 0;
    counter.yi = 0;

    // Initialize send structure
    send.crcsend = 0;
    send.writepos = 0;

    // Initialize error structure
    error.errorcode = 0;




    // Initialize version structure
    version.reserved = 0;
    version.boxselection = 0;
    for(counter.y0 = 0; counter.y0 < MAX_VERSION_FW_ARRAY; counter.y0++)
    {
        version.fw_version[counter.y0] = 0;
    }
    for(counter.y0 = 0; counter.y0 < MAX_VERSION_SW_ARRAY; counter.y0++)
    {
        version.sw_version[counter.y0] = 0;
    }

    // Initialize status structure
    status.reserved = 0;
    status.boxselection = 0;
    for(counter.y0 = 0; counter.y0 < MAX_STATUS_RES_ARRAY; counter.y0++)
    {
        status.res[counter.y0] = 0;
    }

    // Initialize instrument structure
    instrument.reserved = 0;
    instrument.boxselection = 0;

    instrument.device = 0;
    for(counter.y0 = 0; counter.y0 < MAX_INSTRUMENT_SERIALNUMBER_ARRAY; counter.y0++)
    {
        instrument.serialnumber[counter.y0] = 0;
    }
    for(counter.y0 = 0; counter.y0 < MAX_INSTRUMENT_USAGE_ARRAY; counter.y0++)
    {
        instrument.usage[counter.y0] = 0;
    }

    // Initialize communication structure
    communication.reserved = 0;
    communication.boxselection = 0;
    communication.connection = 0;
    communication.baudrate = 0;

    // Initialize power structure
    power.reserved = 0;
    power.boxselection = 0;
    power.batterytype = 0;
    power.duration[0] = 0;
    power.duration[1] = 0;
    for(counter.y0 = 0; counter.y0 < MAX_POWER_POWERREMAINING_ARRAY; counter.y0++)
    {
        power.powerremaining[counter.y0] = 0;
    }

    // Initialize activation structure
    activation.reserved = 0;
    activation.boxselection = 0;


    // Initialize notes structure
    for(counter.y0 = 0; counter.y0 < MAX_NOTES_NOTE_ARRAY; counter.y0++)
    {
        notes.note[counter.y0] = 0;
    }

    // Initialize cloud structure
    for(counter.y0 = 0; counter.y0 < MAX_CLOUD_IP_ARRAY; counter.y0++)
    {
        cloud.ip[counter.y0] = 0;
    }
    for(counter.y0 = 0; counter.y0 < MAX_CLOUD_LOGIN_ARRAY; counter.y0++)
    {
        cloud.login[counter.y0] = 0;
    }
    for(counter.y0 = 0; counter.y0 < MAX_CLOUD_PW_ARRAY; counter.y0++)
    {
        cloud.pw[counter.y0] = 0;
    }


    // Initialize misc structure
    misc.stuff = 0;


    // Initialize uart structure
    uart.sent = 0;
    uart.crcsend = 0;
    for(counter.y0 = 0; counter.y0 < MAX_UART_ARRAY; counter.y0++)
    {
        uart.payload[counter.y0] = 0;
    }
    uart.status = CLEAR_UART;
    uart.got = 0;
    uart.messagelength = 0;
    uart.messageidglobal = 0;
    uart.crcmsg = 0;
    uart.crcset = 0;

    // Initialize uartshadow structure
    uartshadow.messageid = 0;
    for(counter.y0 = 0; counter.y0 < MAX_UART_ARRAY; counter.y0++)
    {
        uartshadow.payload[counter.y0] = 0;
    }
}

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

        DWORD bytesReadLocal;
        if (ReadFile(m_hPort, readBuffer, ACCEPT_1BYTE_AT_A_TIME_ONLY, &bytesReadLocal, NULL))  // ACCEPT_1BYTE_AT_A_TIME_ONLY = 1, it was BUFFER_SIZE
        {
            if (bytesReadLocal > 0)
            {
                // Process received data...
                std::lock_guard<std::mutex> lock(m_serialData.incomingMutex);
                for (DWORD i = 0; i < bytesReadLocal; i++)
                {
                    m_serialData.incoming.push(readBuffer[i]);
                }
                emit dataReceived(QByteArray(reinterpret_cast<const char*>(readBuffer), bytesReadLocal));

                // copy bytes to shadow buffer and get outta here
                bytesReadShadow = bytesReadLocal;
                for(counter.yi = 0; counter.yi < bytesReadShadow; counter.yi++)
                {
                    readBufferShadow[counter.yi] = readBuffer[counter.yi];
                }
                //qDebug() << readBufferShadow[0]; // test printout of bytes received
                IncomingByteCheck();
                ProcessIncomingMsg();
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

void CppClass::FalseHeader(void)
{
    if(readBufferShadow[0] == DLE)
    {
        uart.got = 1;
        qDebug() << "DLE";
    }
    else
    {
        uart.got = 0;
        uart.crcmsg = 0;
    }
}

void CppClass::IncomingByteCheck(void)
{
    if(uart.status != FILLED_UART)
    {
        if(uart.got == 0)
        {
            FalseHeader();
        }
        else if(uart.got == 1)
        {
            if(readBufferShadow[0] == STX)
            {
                uart.got = 2;
                qDebug() << "STX";
            }
            else
            {
                //FalseHeader();
            }
        }
        else if(uart.got == 2)
        {
            //qDebug() << "Just before checking DEST, value of readBufferShadow is : " << QString::number(readBufferShadow[0], 16);
            if(readBufferShadow[0] == DEST)
            {
                uart.got = 3;
                qDebug() << "DEST";
            }
            else
            {
                //FalseHeader();
            }
        }
        else if(uart.got == 3)
        {
            //qDebug() << "Just before checking SOURCE, value of readBufferShadow is : " << QString::number(readBufferShadow[0], 16);
            if(readBufferShadow[0] == SOURCE)
            {
                uart.got = 4;
                qDebug() << "SOURCE";
            }
            else
            {
                //FalseHeader();
            }
        }
        else if(uart.got == 4)  // message length
        {
            //qDebug() << "Just before checking messagelength, value of readBufferShadow is : " << QString::number(readBufferShadow[0], 16);
            // Make a function to check message length
            uart.messagelength = readBufferShadow[0];
            uart.got = 5;
            qDebug() << "Message LGT" << uart.messagelength;
        }
        else if(uart.got == 5)
        {
            //qDebug() << "Just before checking messageidglobal, value of readBufferShadow is : " << QString::number(readBufferShadow[0], 16);
            // Make a function to check message id
            uart.messageidglobal = readBufferShadow[0];
            uart.got = 6;
            qDebug() << "Message ID" << uart.messageidglobal;
        }

        /*
        // We probably do not need this.
        // Query -- should not even be here !!
        else if((uart.got == 6) && (Search_MsgID(QUERY, uart.messageidglobal) == true))
        {
            uart.crcmsg = readBufferShadow[0];

            if(uart.crcmsg == (DLE + STX + DEST + SOURCE + uart.messagelength + uart.messageidglobal) % 256)
            {
                uart.status = FILLED_UART; // immediately block it from re-entering this receive interrupt until present request is processed in main loop
                uartshadow.messageid = uart.messageidglobal;

                // Some indicator it passed the CRC.
                qDebug() << "QUERY SUCCESSFULLY RECEIVED!";
            }
            uart.got = 0;
            uart.crcmsg = 0;
        }
        */

        // Setting - next 2 blocks  (note: RESP should be renamed RESP, here and in the Search_MsgID function)
        else if(
            (Search_MsgID(RESP, uart.messageidglobal) == true) &&
            ((uart.got >= 6) && (uart.got < (uart.messagelength - 1)))
            )
        {
            if(((uart.got - 6) < MAX_UART_ARRAY) && ((uart.got - 6) >= 0)) // protection
            {
                uart.payload[uart.got-6] = readBufferShadow[0];
                //qDebug() << "Payload : " << uart.payload[uart.got-6];
                uart.got++;
            }
            else
            {
                uart.got = 0;
            }
        }

        else if(
            (uart.got <= (uart.messagelength - 1)) &&
            (Search_MsgID(RESP, uart.messageidglobal) == true)
            )
        {

            uart.crcmsg = readBufferShadow[0]; // the crc at the end of Set Working Parameters
            qDebug() << "CRCMSG : " << readBufferShadow[0];
            // it is DEST + SOURCE and not SOURCE + DEST because dest & source values are in relation to what we send not receive.
            uart.crcset = DLE + STX + DEST + SOURCE + uart.messagelength + uart.messageidglobal;

            for(counter.yi=0; counter.yi < (uart.messagelength - 7); counter.yi++)  // add up the incoming bytes in the incomingbuffer0 to check it against the crc
            {
                if(counter.yi < MAX_UART_ARRAY) // protection
                {
                    uart.crcset += uart.payload[counter.yi];
                }
            }

            qDebug() << "About to check CRC for SET msg";
            qDebug() << "Calculated CRC : " << uart.crcset;
            qDebug() << "Message CRC : " << uart.crcmsg;

            if(uart.crcset == uart.crcmsg) //uart.crcmsg)  // if it equals the crc of the message packet
            {
                uart.status = FILLED_UART; // immediately block it from reentering uart0 rx until request is processed in main loop
                // makes us reply host without making any setting if its outside range
                uart.got = 0;

                for(counter.yi=0; counter.yi < MAX_UART_ARRAY; counter.yi++)
                {
                    uartshadow.payload[counter.yi] = uart.payload[counter.yi];
                }
                uartshadow.messageid = uart.messageidglobal;
                qDebug() << "SETTING SUCCESSFULLY RECEIVED!";
            }
            else
            {
                uart.got = 0;
            }
        }
        else
        {
            uart.got = 0;
            uart.crcmsg = 0;
        }
    }
    else
    {
        uart.got = 0;
        uart.crcmsg = 0;
    }
}

bool CppClass::Search_MsgID(uint8_t settingorquery, uint8_t messageidglobal)
{
    // Something wrong with QUERY, RESP, SET -- CONFUSION !!
    if(settingorquery == RESP)
    {
        if(
            (messageidglobal == VERSION_RESP_MSGID) ||
            (messageidglobal == STATUS_RESP_MSGID) ||
            (messageidglobal == INSTRUMENT_RESP_MSGID) ||
            (messageidglobal == COMMUNICATION_RESP_MSGID) ||
            (messageidglobal == POWER_RESP_MSGID) ||
            (messageidglobal == TIMING_RESP_MSGID) ||
            (messageidglobal == SAMPLING_RESP_MSGID) ||
            (messageidglobal == ACTIVATION_RESP_MSGID) ||
            (messageidglobal == NOTES_RESP_MSGID) ||
            (messageidglobal == CLOUD_RESP_MSGID) ||
            (messageidglobal == MISC_RESP_MSGID) ||

            (messageidglobal == CTD_VARIABLES_RESP_MSGID) ||
            (messageidglobal == CTD_READINGS_RAW_RESP_MSGID) ||
            (messageidglobal == CTD_READINGS_PROCESSED_RESP_MSGID) ||
            (messageidglobal == SUBMERSIBLE_INFO_RESP_MSGID)
            )
        {
            //qDebug() << "RESP MessageID Found";
            return true;
        }
        qDebug() << "RESP MessageID Not Found";
        return false;
    }
    /* // settings would be outgoing not incoming
    else
    {
        if(
            (messageidglobal == STATUS_SET_MSGID) ||
            (messageidglobal == INSTRUMENT_SET_MSGID) ||
            (messageidglobal == COMMUNICATION_SET_MSGID) ||
            (messageidglobal == POWER_SET_MSGID) ||
            (messageidglobal == TIMING_SET_MSGID) ||
            (messageidglobal == SAMPLING_SET_MSGID) ||
            (messageidglobal == ACTIVITION_SET_MSGID) ||
            (messageidglobal == NOTES_SET_MSGID) ||
            (messageidglobal == CLOUD_SET_MSGID) ||
            (messageidglobal == MISC_SET_MSGID) ||

            (messageidglobal == CTD_VARIABLES_SET_MSGID) ||
            )
        {
            return true;
        }
        return false;
    }
    */
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
        m_readwriteThread = std::thread(&CppClass::readwriteThread, this);
    }
    return true;
}

void CppClass::stopCommunication() {
    m_serialData.running = false;

    if (m_readwriteThread.joinable())
    {
        m_readwriteThread.join();
    }
}

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
    error.errorcode = 0;

    qDebug() << "Received variant list and map from QML";
    qDebug() << "List :";
    for( int i{0} ; i < list.size(); i++)
    {
        // The first string is the selection string.
        // Use it to determine what category the information came from
        // and what therefore needs to be processed.
        if(i == 0)
        {
            // Convert QString to char array
            byteArray = list.at(i).toString().toUtf8();
            x = byteArray.toInt();
            qDebug() << "Selection detected:" << x;
        }
        else
        {
            switch (x)  // tell you which box was selected (accordingly extract info expected from each box)
            {
            case INSTRUMENT:
                // Selection - since we are in here, we know the selection was 1 aka INSTRUMENT
                instrument.boxselection = INSTRUMENT;

                // Device
                if(i == 1)
                {
                    instrument.device = ((list.at(i).toString().toUtf8()).toInt());
                    qDebug() << "Instrument.device : " << instrument.device;
                }
                // Serial Number
                else if(i == 2)
                {
                    byteArray = list.at(i).toString().toUtf8();
                    bytePos_index = 0;
                    for (char c : byteArray)
                    {
                        if(bytePos_index < MAX_INSTRUMENT_SERIALNUMBER_ARRAY)
                        {
                            instrument.serialnumber[bytePos_index] = c;
                            bytePos_index++;
                        }
                    }

                    // Check if insufficient number of characters
                    if(bytePos_index < MAX_INSTRUMENT_SERIALNUMBER_ARRAY)
                    {
                        qDebug() << "Insufficient number of serial characters";
                        error.errorcode = 0;
                    }
                    else  // print it out
                    {
                        for(int s=0; s < bytePos_index; s++)
                        {
                            //qDebug() << instrument.serialnumber[s];
                        }
                        error.errorcode = 0;
                    }

                    // if everything is alright, we can send it
                    if((error.errorcode == 0) && (writePos == 0))
                    {
                        SendHeader(INSTRUMENT_SET_MSGLGT, INSTRUMENT_SET_MSGID);

                        AddByteToSend(0x00, false); // Reserved

                        AddByteToSend(INSTRUMENT, false); // Box Selection

                        qDebug() << "here0: " << send.writepos;

                        AddByteToSend(instrument.device, false); // Devices

                        qDebug() << "here1: " << send.writepos;

                        for(int r=0; r < MAX_INSTRUMENT_SERIALNUMBER_ARRAY; r++)
                        {
                            AddByteToSend(instrument.serialnumber[r], false);
                        }

                        AddByteToSend(0x00, false); // Usage
                        AddByteToSend(0x00, false);

                        for(int m=0; m < send.writepos; m++)
                        {
                            qDebug() << writeBuffer[m];
                        }

                        qDebug() << "here2: " << send.writepos;

                        qDebug() << "crc: " << send.crcsend;

                        AddByteToSend(send.crcsend, true);

                        std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
                        writePos = send.writepos; // triggers send

                        qDebug() << "Bytes sent!";
                    }
                }
                break;

            case COMMUNICATIONS:
                communication.boxselection = COMMUNICATIONS;

                // Communications
                if(i == 1)
                {
                    communication.connection = ((list.at(i).toString().toUtf8()).toInt());
                    qDebug() << "Communication.connection : " << communication.connection;
                }
                else if(i == 2)
                {
                    communication.baudrate = ((list.at(i).toString().toUtf8()).toInt());
                    qDebug() << "Communication.baudrate : " << communication.baudrate;
                }
                qDebug() << "2";
                break;

            case POWER:
                power.boxselection = POWER;

                // Power
                if(i == 1)
                {
                    power.batterytype = ((list.at(i).toString().toUtf8()).toInt());
                    qDebug() << "Power.batterytype : " << power.batterytype;
                }
                qDebug() << "3";
                break;

            case TIME:
                break;

            case SAMPLING:
                break;

            case ACTIVATION:
                if(i == 1) {
                    // Process startDateTime
                    QString startDateTimeStr = list.at(i).toString();
                    qDebug() << "Start DateTime:" << startDateTimeStr;
                    // Add your date parsing logic here

                    QDateTime utcTime = QDateTime::fromString(startDateTimeStr, Qt::ISODate);
                    QDateTime localTime = utcTime.toLocalTime();
                    qDebug() << "Start DateTime (UTC):" << startDateTimeStr;
                    qDebug() << "Start DateTime (Local):" << localTime.toString("yyyy-MM-dd hh:mm:ss AP");
                }
                else if(i == 2) {
                    // Process endDateTime
                    QString endDateTimeStr = list.at(i).toString();
                    qDebug() << "End DateTime:" << endDateTimeStr;
                    // Add your date parsing logic here
                    QDateTime utcTime = QDateTime::fromString(endDateTimeStr, Qt::ISODate);
                    QDateTime localTime = utcTime.toLocalTime();
                    qDebug() << "End DateTime (UTC):" << endDateTimeStr;
                    qDebug() << "End DateTime (Local):" << localTime.toString("yyyy-MM-dd hh:mm:ss AP");
                }
                break;

            case NOTES:
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
    }
}

// Helper functions
void CppClass::AddByteToSend(uint8_t data, bool crc_yesno)
{
    writeBuffer[send.writepos] = data;
    if(crc_yesno == false)
    {
        send.crcsend += writeBuffer[send.writepos];
    }
    send.writepos += 1;
}

void CppClass::SendHeader(uint8_t msg_length, uint8_t msg_id)
{
    send.writepos = 0;
    send.crcsend = 0;
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
            writePos_temp++;
        }
    }
    writePos = writePos_temp;
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
