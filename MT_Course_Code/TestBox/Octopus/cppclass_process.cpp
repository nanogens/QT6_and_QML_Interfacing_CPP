#include "cppclass.h"

// Incoming RESP messages are stored into structures here for display in QML
void CppClass::ProcessIncomingMsg(void)
{
    if(uart.status == FILLED_UART)
    {
        switch(uartshadow.messageid)
        {
        case VERSION_RESP_MSGID:
            Version_Resp();
            uartshadow.messageid = 0;
            break;
        case STATUS_RESP_MSGID:
            Status_Resp();
            uartshadow.messageid = 0;
            break;
        case COMMUNICATION_RESP_MSGID:
            Communication_Resp();
            uartshadow.messageid = 0;
            break;



        case INSTRUMENT_RESP_MSGID:
            Instrument_Resp();
            uartshadow.messageid = 0;
            break;

        case CTD_READINGS_PROCESSED_RESP_MSGID:
            CTD_Readings_Processed_Resp();
            uartshadow.messageid = 0;
            break;

        default :
            uartshadow.messageid = 0;
            break;
        }
        uart.status = CLEAR_UART;
    }
}

void CppClass::ProcessOutgoingMsg(QVariantList list, QVariantMap map)
{
    QByteArray byteArray;
    int x = 0;
    int bytePos_index = 0;

    // Reset all errorcodes for boxes -- what is this for?
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
            qDebug() << "boxselection : " << x;

        }
        else
        {
            switch (x)  // tell you which box was selected (accordingly extract info expected from each box)
            {
            // SET
            case INSTRUMENT:
                instrument.boxselection = INSTRUMENT;  // Box Selection - 1 byte
                // Device - 1 byte
                if(i == 1)
                {
                    instrument.device = ((list.at(i).toString().toUtf8()).toInt());
                    qDebug() << "Instrument.device : " << instrument.device;
                }
                // Serial Number - 13 bytes
                else if(i == 2)
                {
                    byteArray = list.at(i).toString().toUtf8();
                    bytePos_index = 0;
                    for (char c : byteArray)
                    {
                        if(bytePos_index < MAX_INSTRUMENT_SERIAL_ARRAY)
                        {
                            instrument.serialnumber[bytePos_index] = c;
                            bytePos_index++;
                        }
                    }
                    // Check if insufficient number of characters
                    if(bytePos_index < MAX_INSTRUMENT_SERIAL_ARRAY)
                    {
                        qDebug() << "Insufficient number of serial characters";
                        error.errorcode = 1;
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
                        AddByteToSend(instrument.boxselection, false); // Box Selection
                        AddByteToSend(0x00, false); // Reserved (instrument.reserved)
                        AddByteToSend(instrument.device, false); // Devices
                        for(int r=0; r < MAX_INSTRUMENT_SERIAL_ARRAY; r++) // Serial
                        {
                            AddByteToSend(instrument.serialnumber[r], false);
                        }
                        for(int r=0; r < MAX_INSTRUMENT_USAGE_ARRAY; r++) // Usage (instrument.usage[r]
                        {
                            AddByteToSend(0x00, false);
                        }
                        AddByteToSend(send.crcsend, true);

                        // mutex lock the 485 line so we have exclusive control over it
                        std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
                        writePos = send.writepos; // triggers send

                        qDebug() << "Bytes sent!";
                    }
                }
                break;

            // QUERY
            case CTD_READINGS_PROCESSED_QUERY_MSGID:
                //ctdreadingprocessedquery.boxselection = CTD_READING_PROCESSED_QUERY;
                qDebug() << "In CTD_Readings_Processed_Query case";
                CTD_Readings_Processed_Query();
                break;

            default:
                qDebug() << "Error : x should have a value";
                break;
            }
        }


    }
}

