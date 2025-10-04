#include "cppclass.h"

void CppClass::Ver_Resp(void)
{
    version.fw_version[0] = uartshadow.payload[0];
    version.fw_version[1] = uartshadow.payload[1];
    version.sw_version[0] = uartshadow.payload[2];
    version.sw_version[1] = uartshadow.payload[3];

    qDebug() << "Ver_Resp Bytes Stored!";
}

void CppClass::Status_Resp(void)
{
    status.reserved[0] = uartshadow.payload[0];
    status.reserved[1] = uartshadow.payload[1];
    status.reserved[2] = uartshadow.payload[2];
    status.reserved[3] = uartshadow.payload[3];

    qDebug() << "Status_Resp Bytes Stored!";
}

void CppClass::Instrument_Resp(void)
{
    instrument.reserved         = uartshadow.payload[0];
    instrument.boxselection     = uartshadow.payload[1];
    instrument.device           = uartshadow.payload[2];
    instrument.serialnumber[0]  = uartshadow.payload[3];
    instrument.serialnumber[1]  = uartshadow.payload[4];
    instrument.serialnumber[2]  = uartshadow.payload[5];
    instrument.serialnumber[3]  = uartshadow.payload[6];
    instrument.serialnumber[4]  = uartshadow.payload[7];
    instrument.serialnumber[5]  = uartshadow.payload[8];
    instrument.serialnumber[6]  = uartshadow.payload[9];
    instrument.serialnumber[7]  = uartshadow.payload[10];
    instrument.serialnumber[8]  = uartshadow.payload[11];
    instrument.serialnumber[9]  = uartshadow.payload[12];
    instrument.serialnumber[10] = uartshadow.payload[13];
    instrument.serialnumber[11] = uartshadow.payload[14];
    instrument.serialnumber[12] = uartshadow.payload[15];
    instrument.usage[0]         = uartshadow.payload[16];
    instrument.usage[1]         = uartshadow.payload[17];

    qDebug() << "Instrument_Resp Bytes Stored!";
}


