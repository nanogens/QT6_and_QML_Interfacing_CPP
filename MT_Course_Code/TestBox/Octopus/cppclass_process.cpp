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




        case INSTRUMENT_RESP_MSGID:
            Instrument_Resp();
            uartshadow.messageid = 0;
            break;
        case COMMUNICATION_RESP_MSGID:
            Communication_Resp();
            uartshadow.messageid = 0;
            break;
        case TIMING_RESP_MSGID:
            Timing_Resp();
            uartshadow.messageid = 0;
            break;
        case SAMPLING_RESP_MSGID:
            Sampling_Resp();
            uartshadow.messageid = 0;
            break;
        case ACTIVATION_RESP_MSGID:
            Activation_Resp();
            uartshadow.messageid = 0;
            break;
        case NOTES_RESP_MSGID:
            Notes_Resp();
            uartshadow.messageid = 0;
            break;


        case CTD_READINGS_PROCESSED_RESP_MSGID:
            CTD_Readings_Processed_Resp();
            uartshadow.messageid = 0;
            break;

        case SUBMERSIBLE_INFO_RESP_MSGID:
            Submersible_Info_Resp();
            qDebug() << "In ProcessIncomingMsg(), in case SUBMERSIBLE_INFO_RESP_MSGID";
            uartshadow.messageid = 0;
            break;

        default :
            uartshadow.messageid = 0;
            break;
        }
        uart.status = CLEAR_UART;
    }
}

void CppClass::processOutgoingMsg(QVariantList list, QVariantMap map)
{
    QByteArray byteArray;
    int x = 0;


    // Reset all errorcodes.  Error codes checked prior to sending packet.
    error.errorcode = 0;

    for( int i{0} ; i < list.size(); i++)
    {
        // The first string is the selection string.
        // Use it to determine what category (box) the information came from
        // and what therefore needs to be processed.
        // Note: Box is stored in variable x which is then used in the else below.
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
                Instrument_Set(list, i, byteArray);
                break;

            // ------------------------------------------------------------------------

            // QUERY
            case CTD_READINGS_PROCESSED_QUERY_MSGID:
                CTD_Readings_Processed_Query();
                break;

            case INSTRUMENT_QUERY_MSGID:
                Instrument_Query();
                break;




            default:
                qDebug() << "Error : x should have a value";
                break;
            }
        }


    }
}

