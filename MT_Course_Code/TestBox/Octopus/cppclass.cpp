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

    // Log / Graphing Init

    // Log_ShowFiles
    for(counter.y0 = 0; counter.y0 < FILENUM_ARRAY; counter.y0++)
    {
        logshowfiles.reserved[counter.y0] = 0;
    }
    for(counter.y0 = 0; counter.y0 < FILENUM_ARRAY; counter.y0++)
    {
        logshowfiles.fileindex[counter.y0] = 0;
    }
    for(counter.y0 = 0; counter.y0 < FILENUM_ARRAY; counter.y0++)
    {
        for(counter.y1 = 0; counter.y1 < FILENAME_ARRAY; counter.y1++)
        {
            logshowfiles.filename[counter.y0][counter.y1]; // 4, 8
        }
    }
    for(counter.y0 = 0; counter.y0 < FILENUM_ARRAY; counter.y0++)
    {
        for(counter.y1 = 0; counter.y1 < FILESIZE_ARRAY; counter.y1++)
        {
            logshowfiles.filesize[counter.y0][counter.y1]; // 4, 4
        }
    }
    for(counter.y0 = 0; counter.y0 < FILENUM_ARRAY; counter.y0++)
    {
        for(counter.y1 = 0; counter.y1 < FILEDATE_ARRAY; counter.y1++)
        {
            logshowfiles.filedate[counter.y0][counter.y1]; // 4, 8
        }
    }

    // Log_ShowFiles
    logreadspecificfile.whichfile = 0;
    logreadspecificfile.reserved = 0;

    // Log_Transmit
    // Set
    logtransmitdata.filenumber_s = 0;   // file list ranges from 0 to 3 indicating which file data is being requested
    logtransmitdata.sector_high_s = 0;  // the high byte of the sector from which the data has been requested (total of high and low byte is from 0 to 8191)
    logtransmitdata.sector_low_s = 0;   // the low byte of the sector from which the data has been requested
    logtransmitdata.page_s = 0;         // the page number from which the data has been requested (0 to 7)
    logtransmitdata.reserved0_s = 0;    // reserved for future use
    logtransmitdata.reserved1_s = 0;    // reserved for future use
    logtransmitdata.quadrant_s = 0;     // each page is divided into four 128 byte quadrants.  this tells you from which quadrant the data has been requested (0 to 3)

    // Resp
    logtransmitdata.filenumber_r = 0;   // file list ranges from 0 to 3 indicating which file data is being tranferred
    logtransmitdata.sector_high_r = 0;  // the high byte of the sector from which the data has been obtained (total of high and low byte is from 0 to 8191)
    logtransmitdata.sector_low_r = 0;   // the low byte of the sector from which the data has been obtained
    logtransmitdata.page_r = 0;         // the page number from which the data has been obtained (0 to 7)
    logtransmitdata.reserved0_r = 0;    // reserved for future use
    logtransmitdata.reserved1_r = 0;    // reserved for future use
    logtransmitdata.quadrant_r = 0;     // each page is divided into four 128 byte quadrants.  this tells you from which quadrant the data has been obtained (0 to 3)

    for(counter.y0 = 0; counter.y0 < QUADRANTS; counter.y0++)
    {
        for(counter.y1 = 0; counter.y1 < QUADRANTBYTES; counter.y1++)
        {
            logtransmitdata.pagedata_rq[counter.y0][counter.y1]; // 4, 128
        }
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

// Worker thread to handle reception and transmission of bytes to UART
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

        static QElapsedTimer readTimer;
        static int totalBytesRead = 0;

        DWORD bytesReadLocal;
        if (ReadFile(m_hPort, readBuffer, ACCEPT_1BYTE_AT_A_TIME_ONLY, &bytesReadLocal, NULL))
        {
            if (bytesReadLocal > 0)
            {
                readTimer.start();

                // Process each byte individually through the state machine
                for (DWORD i = 0; i < bytesReadLocal; i++)
                {
                    // Put single byte into shadow buffer
                    bytesReadShadow = 1;
                    readBufferShadow[0] = readBuffer[i];

                    // Process this one byte
                    IncomingByteCheck();
                    ProcessIncomingMsg();
                }

                int processTime = readTimer.elapsed();
                totalBytesRead += bytesReadLocal;

                if (processTime > 10) {
                    qDebug() << "Slow batch:" << bytesReadLocal << "bytes took" << processTime << "ms";
                }
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
        //qDebug() << "DLE";
    }
    else
    {
        uart.got = 0;
        uart.crcmsg = 0;
    }
}

// Routine intercepting incoming bytes (byte by byte analysis)
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
                //qDebug() << "STX";
            }
            else
            {
                FalseHeader();
            }
        }
        else if(uart.got == 2)
        {
            if(readBufferShadow[0] == DEST)
            {
                uart.got = 3;
                //qDebug() << "DEST";
            }
            else
            {
                FalseHeader();
            }
        }
        else if(uart.got == 3)
        {
            if(readBufferShadow[0] == SOURCE)
            {
                uart.got = 4;
                //qDebug() << "SOURCE";
            }
            else
            {
                FalseHeader();
            }
        }
        else if(uart.got == 4)  // message length
        {
            uart.messagelength = readBufferShadow[0];
            uart.got = 5;
            //qDebug() << "Message LGT" << uart.messagelength;
        }
        else if(uart.got == 5)
        {
            uart.messageidglobal = readBufferShadow[0];
            uart.got = 6;
            //qDebug() << "Message ID" << uart.messageidglobal;
        }
        // Setting - next 2 blocks
        else if(
            (Search_MsgID(RESP, uart.messageidglobal) == true) &&
            ((uart.got >= 6) && (uart.got < (uart.messagelength - 1)))
            )
        {
            if(((uart.got - 6) < MAX_UART_ARRAY) && ((uart.got - 6) >= 0))
            {
                uart.payload[uart.got-6] = readBufferShadow[0];
                uart.got++;
            }
            else
            {
                uart.got = 0;
            }
        }
        // CRC summation and check against packet CRC
        else if(
            (uart.got <= (uart.messagelength - 1)) &&
            (Search_MsgID(RESP, uart.messageidglobal) == true)
            )
        {
            uart.crcmsg = readBufferShadow[0];
            //qDebug() << "CRCMSG : " << readBufferShadow[0];
            uart.crcset = DLE + STX + DEST + SOURCE + uart.messagelength + uart.messageidglobal;

            for(counter.yi=0; counter.yi < (uart.messagelength - 7); counter.yi++)
            {
                if(counter.yi < MAX_UART_ARRAY)
                {
                    uart.crcset += uart.payload[counter.yi];
                }
            }

            //qDebug() << "About to check CRC for RESP msg";
            //qDebug() << "Calculated CRC : " << uart.crcset;
            //qDebug() << "Message CRC : " << uart.crcmsg;

            if(uart.crcset == uart.crcmsg)
            {
                uart.status = FILLED_UART;
                uart.got = 0;

                for(counter.yi=0; counter.yi < MAX_UART_ARRAY; counter.yi++)
                {
                    uartshadow.payload[counter.yi] = uart.payload[counter.yi];
                }
                uartshadow.messageid = uart.messageidglobal;
                qDebug() << "PACKET SUCCESSFULLY RECEIVED!";
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
            (messageidglobal == TIME_RESP_MSGID) ||
            (messageidglobal == SAMPLING_RESP_MSGID) ||
            (messageidglobal == ACTIVATION_RESP_MSGID) ||
            (messageidglobal == NOTES_RESP_MSGID) ||
            (messageidglobal == CLOUD_RESP_MSGID) ||
            (messageidglobal == MISC_RESP_MSGID) ||

            (messageidglobal == LOG_SHOWFILES_RESP_MSGID) ||
            (messageidglobal == LOG_READSPECIFICFILE_RESP_MSGID) ||
            (messageidglobal == LOG_TRANSMITDATA_RESP_MSGID) ||

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
    }
    else
    {
        return true;
    }
    return false;
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

/*
// Called from the QML when we need to send out query / setting
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
                        //qDebug() << "here0: " << send.writepos;
                        AddByteToSend(instrument.device, false); // Devices
                        for(int r=0; r < MAX_INSTRUMENT_SERIALNUMBER_ARRAY; r++) // Serial Number
                        {
                            AddByteToSend(instrument.serialnumber[r], false);
                        }
                        AddByteToSend(0x00, false); // Usage
                        AddByteToSend(0x00, false);
                        //for(int m=0; m < send.writepos; m++)
                        //{
                        //    qDebug() << writeBuffer[m];
                        //}

                        //qDebug() << "crc: " << send.crcsend;
                        AddByteToSend(send.crcsend, true);

                        // Queue it to be sent
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
*/

// Adds a byte to the queue that is to be sent.
// Note: The writeBuffer is only sent when triggered to do so (by setting writePos).
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
            /*
            if(x == 1)
            {
                qDebug() << "MT ";
            }
            */
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

    setPortName("COM3");  // COM5 for tablet
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
    setPortName("COM2"); // COM5 on tablet
    if(startCommunication(m_portName.toUtf8().constData()) == true)
    {
        emit runningChanged();  // Emit signal when status changes
    }
}

void CppClass::ringSwitch(bool active)
{
    emit ringStateChanged(active);
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

QVariantList CppClass::processDeviceFileData(const QVariantList &rawData, double surfacePressure)
{
    QVariantList processedPoints;

    // Convert QVariantList to QByteArray
    QByteArray data;
    data.reserve(rawData.size());
    for (const QVariant &byte : rawData) {
        data.append((char)byte.toInt());
    }

    qDebug() << "Total raw data size:" << data.size() << "bytes";
    qDebug() << "Expected pages:" << ceil(data.size() / 512.0);

    // Step 1: Extract calibration coefficients from page 0, record 0
    // Search for RLE (0x77) and RTX (0x76) markers
    uint16_t C[7] = {0};  // C0 through C6
    bool calibrationFound = false;

    for (int i = 0; i < data.size() - 30; i++) {
        if ((uint8_t)data[i] == RLE && (uint8_t)data[i + 1] == RTX) {
            // Found page header, extract calibration from bytes 16-29
            C[0] = ((uint8_t)data[i + 16] << 8) | (uint8_t)data[i + 17];
            C[1] = ((uint8_t)data[i + 18] << 8) | (uint8_t)data[i + 19];
            C[2] = ((uint8_t)data[i + 20] << 8) | (uint8_t)data[i + 21];
            C[3] = ((uint8_t)data[i + 22] << 8) | (uint8_t)data[i + 23];
            C[4] = ((uint8_t)data[i + 24] << 8) | (uint8_t)data[i + 25];
            C[5] = ((uint8_t)data[i + 26] << 8) | (uint8_t)data[i + 27];
            C[6] = ((uint8_t)data[i + 28] << 8) | (uint8_t)data[i + 29];

            calibrationFound = true;
            qDebug() << "Calibration coefficients found:" << C[0] << C[1] << C[2] << C[3] << C[4] << C[5] << C[6];
            break;
        }
    }

    if (!calibrationFound) {
        qDebug() << "ERROR: Could not find calibration coefficients in data";
        return processedPoints;
    }

    // Step 2: Parse all pages, skip headers, extract records based on page header record count
    int offset = 0;
    int bytesPerPage = 512;
    int headerSize = 32;  // First 32 bytes of each page is metadata
    int recordSize = 32;
    int totalRecordsProcessed = 0;

    while (offset + bytesPerPage <= data.size()) {
        qDebug() << "Processing page at offset:" << offset;

        // Read the record count from the page header (byte 5 of the page)
        uint8_t totalRecordsInPage = (uint8_t)data[offset + 5];
        // Subtract 1 for the header record itself to get data records
        int dataRecordsInPage = totalRecordsInPage - 1;

        qDebug() << "Total records in page:" << totalRecordsInPage << "Data records:" << dataRecordsInPage;

        // Skip the page header (first 32 bytes)
        int dataOffset = offset + headerSize;

        // Process only the valid data records in this page
        for (int i = 0; i < dataRecordsInPage; i++) {
            int recordStart = dataOffset + (i * recordSize);

            // Check if we have enough data for a full record
            if (recordStart + recordSize > data.size()) {
                break;
            }

            // Extract time components (bytes 0-7 of record)
            uint8_t year = (uint8_t)data[recordStart + 0];
            uint8_t month = (uint8_t)data[recordStart + 1];
            uint8_t day = (uint8_t)data[recordStart + 2];
            uint8_t hour = (uint8_t)data[recordStart + 3];
            uint8_t minute = (uint8_t)data[recordStart + 4];
            uint8_t second = (uint8_t)data[recordStart + 5];
            uint8_t ampm = (uint8_t)data[recordStart + 6];
            uint8_t weekday = (uint8_t)data[recordStart + 7];

            // Format time string
            int hour12 = hour % 12;
            if (hour12 == 0) hour12 = 12;
            QString ampmStr = (ampm == 1) ? "PM" : "AM";
            QString timeStr = QString("%1:%2:%3 %4")
                                  .arg(hour12, 2, 10, QChar('0'))
                                  .arg(minute, 2, 10, QChar('0'))
                                  .arg(second, 2, 10, QChar('0'))
                                  .arg(ampmStr);

            // Extract raw ADC values (bytes 8-11 for D1, bytes 14-17 for D2)
            uint32_t D1 = ((uint32_t)(uint8_t)data[recordStart + 8] << 24) |
                          ((uint32_t)(uint8_t)data[recordStart + 9] << 16) |
                          ((uint32_t)(uint8_t)data[recordStart + 10] << 8) |
                          (uint32_t)(uint8_t)data[recordStart + 11];

            uint32_t D2 = ((uint32_t)(uint8_t)data[recordStart + 14] << 24) |
                          ((uint32_t)(uint8_t)data[recordStart + 15] << 16) |
                          ((uint32_t)(uint8_t)data[recordStart + 16] << 8) |
                          (uint32_t)(uint8_t)data[recordStart + 17];

            // Apply MS5837 formulas using 64-bit integers
            int64_t dT = D2 - ((int64_t)C[5] << 8);
            int64_t TEMP = 2000 + (dT * C[6]) / 8388608LL;

            int64_t OFF = ((int64_t)C[2] << 16) + (C[4] * dT) / 128;
            int64_t SENS = ((int64_t)C[1] << 15) + (C[3] * dT) / 256;

            int64_t P = (((D1 * SENS) / 2097152LL) - OFF) / 8192LL;

            // Convert to final units
            double temperature = TEMP / 100.0;      // °C
            double pressure_mbar = P / 10.0;        // mbar

            // Calculate depth
            double depth = (pressure_mbar - surfacePressure) * 0.010197;  // meters
            if (depth < 0) depth = 0;

            // Conductivity placeholder (0 for now)
            double conductivity = 0.0;

            // Add to result, when creating the point:
            QVariantMap point;
            point["time"] = timeStr;
            point["temperature"] = temperature;
            point["depth"] = depth;
            point["pressure_mbar"] = pressure_mbar;  // Add this line
            point["conductivity"] = conductivity;
            processedPoints.append(point);

            totalRecordsProcessed++;
        }

        offset += bytesPerPage;
    }

    qDebug() << "Processed" << totalRecordsProcessed << "data records";
    return processedPoints;
}

QVariantList CppClass::processDeviceFileDataWithBarometer(const QVariantList &rawData, const QVariantList &barometerData)
{
    QVariantList processedPoints;

    // Convert QVariantList to QByteArray
    QByteArray data;
    data.reserve(rawData.size());
    for (const QVariant &byte : rawData) {
        data.append((char)byte.toInt());
    }

    qDebug() << "Total raw data size:" << data.size() << "bytes";
    qDebug() << "Barometer data size:" << barometerData.size() << "readings";

    // If no barometer data, return empty list
    if (barometerData.isEmpty()) {
        qDebug() << "WARNING: No barometer data provided!";
        return processedPoints;
    }

    // Step 1: Extract calibration coefficients from page 0, record 0
    uint16_t C[7] = {0};
    bool calibrationFound = false;

    for (int i = 0; i < data.size() - 30; i++) {
        if ((uint8_t)data[i] == RLE && (uint8_t)data[i + 1] == RTX) {
            C[0] = ((uint8_t)data[i + 16] << 8) | (uint8_t)data[i + 17];
            C[1] = ((uint8_t)data[i + 18] << 8) | (uint8_t)data[i + 19];
            C[2] = ((uint8_t)data[i + 20] << 8) | (uint8_t)data[i + 21];
            C[3] = ((uint8_t)data[i + 22] << 8) | (uint8_t)data[i + 23];
            C[4] = ((uint8_t)data[i + 24] << 8) | (uint8_t)data[i + 25];
            C[5] = ((uint8_t)data[i + 26] << 8) | (uint8_t)data[i + 27];
            C[6] = ((uint8_t)data[i + 28] << 8) | (uint8_t)data[i + 29];

            calibrationFound = true;
            qDebug() << "Calibration coefficients found:" << C[0] << C[1] << C[2] << C[3] << C[4] << C[5] << C[6];
            break;
        }
    }

    if (!calibrationFound) {
        qDebug() << "ERROR: Could not find calibration coefficients in data";
        return processedPoints;
    }

    // Parse barometer data into a map for quick lookup
    QMap<QDateTime, double> barometerMap;
    for (const QVariant &item : barometerData) {
        QVariantMap entry = item.toMap();
        QDateTime timestamp = entry["timestamp"].toDateTime();
        double pressure = entry["pressure"].toDouble();
        barometerMap[timestamp] = pressure;
        qDebug() << "Barometer reading in map:" << timestamp << pressure;
    }

    // Get first and last barometer timestamps for edge case handling
    QDateTime firstBaroTime;
    QDateTime lastBaroTime;
    double firstBaroPressure = 1013.25;
    double lastBaroPressure = 1013.25;

    if (!barometerMap.isEmpty()) {
        firstBaroTime = barometerMap.firstKey();
        lastBaroTime = barometerMap.lastKey();
        firstBaroPressure = barometerMap.first();
        lastBaroPressure = barometerMap.last();
        qDebug() << "Barometer range:" << firstBaroTime << "to" << lastBaroTime;
    }

    // Step 2: Parse all pages
    int offset = 0;
    int bytesPerPage = 512;
    int headerSize = 32;
    int recordSize = 32;
    int totalRecordsProcessed = 0;

    while (offset + bytesPerPage <= data.size()) {
        uint8_t totalRecordsInPage = (uint8_t)data[offset + 5];
        int dataRecordsInPage = totalRecordsInPage - 1;

        qDebug() << "Processing page at offset:" << offset << "Records in page:" << dataRecordsInPage;

        int dataOffset = offset + headerSize;

        for (int i = 0; i < dataRecordsInPage; i++) {
            int recordStart = dataOffset + (i * recordSize);

            if (recordStart + recordSize > data.size()) {
                break;
            }

            // Extract time components
            uint8_t year = (uint8_t)data[recordStart + 0];
            uint8_t month = (uint8_t)data[recordStart + 1];
            uint8_t day = (uint8_t)data[recordStart + 2];
            uint8_t hour = (uint8_t)data[recordStart + 3];
            uint8_t minute = (uint8_t)data[recordStart + 4];
            uint8_t second = (uint8_t)data[recordStart + 5];
            uint8_t ampm = (uint8_t)data[recordStart + 6];
            uint8_t weekday = (uint8_t)data[recordStart + 7];

            // Create QDateTime for this record
            QDateTime recordTime;
            recordTime.setDate(QDate(2000 + year, month, day));
            int hour24 = hour;
            if (ampm == 1 && hour != 12) hour24 += 12;
            else if (ampm == 0 && hour == 12) hour24 = 0;
            recordTime.setTime(QTime(hour24, minute, second));

            // Format time string for output
            int hour12 = hour % 12;
            if (hour12 == 0) hour12 = 12;
            QString ampmStr = (ampm == 1) ? "PM" : "AM";
            QString timeStr = QString("%1:%2:%3 %4")
                                  .arg(hour12, 2, 10, QChar('0'))
                                  .arg(minute, 2, 10, QChar('0'))
                                  .arg(second, 2, 10, QChar('0'))
                                  .arg(ampmStr);

            // Extract raw ADC values (bytes 8-11 for D1, bytes 14-17 for D2)
            uint32_t D1 = ((uint32_t)(uint8_t)data[recordStart + 8] << 24) |
                          ((uint32_t)(uint8_t)data[recordStart + 9] << 16) |
                          ((uint32_t)(uint8_t)data[recordStart + 10] << 8) |
                          (uint32_t)(uint8_t)data[recordStart + 11];

            uint32_t D2 = ((uint32_t)(uint8_t)data[recordStart + 14] << 24) |
                          ((uint32_t)(uint8_t)data[recordStart + 15] << 16) |
                          ((uint32_t)(uint8_t)data[recordStart + 16] << 8) |
                          (uint32_t)(uint8_t)data[recordStart + 17];

            // Apply MS5837 formulas using 64-bit integers
            int64_t dT = D2 - ((int64_t)C[5] << 8);
            int64_t TEMP = 2000 + (dT * C[6]) / 8388608LL;

            int64_t OFF = ((int64_t)C[2] << 16) + (C[4] * dT) / 128;
            int64_t SENS = ((int64_t)C[1] << 15) + (C[3] * dT) / 256;

            int64_t P = (((D1 * SENS) / 2097152LL) - OFF) / 8192LL;

            double temperature = TEMP / 100.0;
            double instrumentPressure_mbar = P / 10.0;

            // Find closest barometer reading with edge case handling
            double barometerPressure_mbar = 1013.25; // Default fallback

            if (!barometerMap.isEmpty()) {
                // Case 1: Instrument record is before first barometer reading
                if (recordTime < firstBaroTime) {
                    barometerPressure_mbar = firstBaroPressure;
                    if (totalRecordsProcessed < 20) {
                        qDebug() << "Record before barometer start - using first barometer reading:"
                                 << barometerPressure_mbar << "at" << firstBaroTime;
                    }
                }
                // Case 2: Instrument record is after last barometer reading
                else if (recordTime > lastBaroTime) {
                    barometerPressure_mbar = lastBaroPressure;
                    if (totalRecordsProcessed < 20) {
                        qDebug() << "Record after barometer end - using last barometer reading:"
                                 << barometerPressure_mbar << "at" << lastBaroTime;
                    }
                }
                // Case 3: Instrument record is within barometer timeframe - find closest
                else {
                    QDateTime closestTime;
                    qint64 minDiff = LLONG_MAX;
                    for (auto it = barometerMap.begin(); it != barometerMap.end(); ++it) {
                        qint64 diff = qAbs(it.key().toMSecsSinceEpoch() - recordTime.toMSecsSinceEpoch());
                        if (diff < minDiff) {
                            minDiff = diff;
                            closestTime = it.key();
                            barometerPressure_mbar = it.value();
                        }
                    }
                    // Print debug for first few records only
                    if (totalRecordsProcessed < 20) {
                        qDebug() << "Record time:" << recordTime << "Closest barometer:" << closestTime
                                 << "Diff(ms):" << minDiff << "Pressure:" << barometerPressure_mbar;
                    }
                }
            } else {
                qDebug() << "No barometer data available - using standard pressure: 1013.25 mbar";
            }

            // Calculate depth with barometer compensation
            double waterPressure_mbar = instrumentPressure_mbar - barometerPressure_mbar;
            double depth = waterPressure_mbar * 0.010197;
            if (depth < 0) depth = 0;

            double conductivity = 0.0;

            // Add to result
            QVariantMap point;
            point["time"] = timeStr;
            point["temperature"] = temperature;
            point["depth"] = depth;
            point["pressure_mbar"] = instrumentPressure_mbar;
            point["conductivity"] = conductivity;
            processedPoints.append(point);

            totalRecordsProcessed++;
        }

        offset += bytesPerPage;
    }

    qDebug() << "Processed" << totalRecordsProcessed << "data records with barometer compensation";
    return processedPoints;
}

bool CppClass::loadBarometerFile(const QString &filePath)
{
    qDebug() << "Loading barometer file:" << filePath;

    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qDebug() << "Failed to open barometer file:" << file.errorString();
        emit barometerDataLoaded(QVariantList()); // Emit empty list on error
        return false;
    }

    QTextStream stream(&file);
    QString line = stream.readLine(); // Skip header line

    QVariantList barometerData;

    while (!stream.atEnd()) {
        line = stream.readLine().trimmed();
        if (line.isEmpty()) continue;

        QStringList parts = line.split(",");
        if (parts.size() >= 2) {
            QDateTime timestamp = QDateTime::fromString(parts[0].trimmed(), "yyyy-MM-dd HH:mm:ss");
            double pressure = parts[1].trimmed().toDouble();

            QVariantMap entry;
            entry["timestamp"] = timestamp;
            entry["pressure"] = pressure;
            barometerData.append(entry);

            qDebug() << "Barometer reading:" << timestamp << pressure;
        }
    }

    file.close();

    // Check for empty barometer data
    if (barometerData.isEmpty()) {
        qDebug() << "ERROR: Barometer file has no valid readings";
        emit barometerDataLoaded(QVariantList()); // Emit empty list
        return false;
    }

    // Store barometer data for later use
    m_barometerData = barometerData;

    // EMIT THE SIGNAL to notify QML that barometer data is loaded
    emit barometerDataLoaded(barometerData);

    qDebug() << "Loaded" << barometerData.size() << "barometer readings";
    return true;
}

QVariantMap CppClass::calculateBarometerOverlap(const QVariantList &instrumentRecords, const QVariantList &barometerData)
{
    QVariantMap result;
    result["warningMessage"] = "";
    result["hasFullOverlap"] = false;
    result["overlapPercentage"] = 0.0;

    if (instrumentRecords.isEmpty() || barometerData.isEmpty()) {
        result["warningMessage"] = "No barometer data available for overlap calculation";
        return result;
    }

    // Get first and last barometer times
    QVariantMap firstBaro = barometerData.first().toMap();
    QVariantMap lastBaro = barometerData.last().toMap();

    QDateTime firstBaroTime = firstBaro["timestamp"].toDateTime();
    QDateTime lastBaroTime = lastBaro["timestamp"].toDateTime();

    // For instrument records, we only have time strings (no date)
    // So we need to create QDateTime using the barometer date as reference
    QDate baroDate = firstBaroTime.date();

    // Parse instrument times and find min/max
    QDateTime firstInstrumentTime;
    QDateTime lastInstrumentTime;
    bool firstSet = false;

    for (const QVariant &record : instrumentRecords) {
        QVariantMap point = record.toMap();
        QString timeStr = point["time"].toString();

        // Parse time string like "10:10:10 AM" or "10:10:10 PM"
        QTime time = QDateTime::fromString(timeStr, "h:mm:ss AP").time();
        if (time.isValid()) {
            QDateTime fullDateTime(baroDate, time);

            if (!firstSet) {
                firstInstrumentTime = fullDateTime;
                lastInstrumentTime = fullDateTime;
                firstSet = true;
            } else {
                if (fullDateTime < firstInstrumentTime) firstInstrumentTime = fullDateTime;
                if (fullDateTime > lastInstrumentTime) lastInstrumentTime = fullDateTime;
            }
        }
    }

    if (!firstSet) {
        result["warningMessage"] = "Unable to parse instrument timestamps";
        return result;
    }

    // Calculate overlap
    QDateTime overlapStart = (firstInstrumentTime > firstBaroTime) ? firstInstrumentTime : firstBaroTime;
    QDateTime overlapEnd = (lastInstrumentTime < lastBaroTime) ? lastInstrumentTime : lastBaroTime;

    qint64 instrumentDuration = firstInstrumentTime.msecsTo(lastInstrumentTime);
    qint64 overlapDuration = overlapStart.msecsTo(overlapEnd);

    double overlapPercent = 0.0;
    if (instrumentDuration > 0) {
        overlapPercent = (double)overlapDuration / instrumentDuration * 100.0;
    }

    // Ensure overlap percentage is never negative
    if (overlapPercent < 0) {
        overlapPercent = 0;
    }

    // Debug output
    qDebug() << "Instrument range:" << firstInstrumentTime << "to" << lastInstrumentTime;
    qDebug() << "Barometer range:" << firstBaroTime << "to" << lastBaroTime;
    qDebug() << "Overlap duration:" << overlapDuration << "ms, Instrument duration:" << instrumentDuration << "ms";
    qDebug() << "Overlap percentage:" << overlapPercent;

    result["overlapPercentage"] = overlapPercent;

    // Determine warning message and status icon
    if (overlapPercent >= 99.0) {
        result["hasFullOverlap"] = true;
        result["warningMessage"] = "";
        result["overlapStatus"] = "✓ Complete overlap (100%)";
    } else if (overlapPercent <= 0.0) {
        result["hasFullOverlap"] = false;
        result["warningMessage"] = "⚠️ No overlap between barometer and instrument data. Using closest available readings (first/last barometer values).";
        result["overlapStatus"] = QString("✗ No overlap (%1%)").arg(qRound(overlapPercent));
    } else if (overlapPercent < 50.0) {
        result["hasFullOverlap"] = false;
        result["warningMessage"] = QString("⚠️ Barometer data only partially overlaps recording (%1% overlap). Using closest available readings.").arg(qRound(overlapPercent));
        result["overlapStatus"] = QString("⚠️ Partial overlap (%1%)").arg(qRound(overlapPercent));
    } else if (overlapPercent < 99.0) {
        result["hasFullOverlap"] = false;
        result["warningMessage"] = QString("ℹ️ Barometer data partially overlaps recording (%1% overlap). Using closest available readings.").arg(qRound(overlapPercent));
        result["overlapStatus"] = QString("ℹ️ Partial overlap (%1%)").arg(qRound(overlapPercent));
    }

    // Also add overlap percentage to result
    result["overlapPercentage"] = overlapPercent;
    result["overlapPercentageRounded"] = qRound(overlapPercent);

    return result;
}
