#include "cppclass.h"

void CppClass::ProcessMsg(void)
{
    if(uart.status == FILLED_UART)
    {
        switch(uartshadow.messageid)
        {
        case VER_RESP_MSGID:
            Ver_Resp();
            uartshadow.messageid = 0;
            break;
        case STATUS_RESP_MSGID:
            Status_Resp();
            uartshadow.messageid = 0;
            break;




        case INSTRUMENT_RESP_MSGID:
            uartshadow.messageid = 0;
            break;
        default :
            uartshadow.messageid = 0;
            break;
        }
        uart.status = CLEAR_UART;
    }
}
