#include "cppclass.h"

void CppClass::Version_Resp(void)
{
    version.reserved = uartshadow.payload[0];
    version.boxselection = uartshadow.payload[1];
    version.fw_version[0] = uartshadow.payload[2];
    version.fw_version[1] = uartshadow.payload[3];
    version.sw_version[0] = uartshadow.payload[4];
    version.sw_version[1] = uartshadow.payload[5];

    qDebug() << "Version_Resp Bytes Stored!";
}

void CppClass::Status_Resp(void)
{
    status.reserved = uartshadow.payload[0];
    status.boxselection = uartshadow.payload[1];
    status.res[0] = uartshadow.payload[2];
    status.res[1] = uartshadow.payload[3];

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

void CppClass::Communication_Resp(void)
{
    communication.reserved = uartshadow.payload[0];
    communication.boxselection = uartshadow.payload[1];
    communication.connection = uartshadow.payload[2];
    communication.baudrate = uartshadow.payload[3];

    qDebug() << "Communication_Resp Bytes Stored!";
}

void CppClass::Power_Resp(void)
{
    power.reserved = uartshadow.payload[0];
    power.boxselection = uartshadow.payload[1];
    power.batterytype = uartshadow.payload[2];
    power.duration[0] = uartshadow.payload[3];
    power.duration[1] = uartshadow.payload[4];
    power.powerremaining[0] = uartshadow.payload[5];
    power.powerremaining[1] = uartshadow.payload[6];

    qDebug() << "Power_Resp Bytes Stored!";
}

void CppClass::Timing_Resp(void)
{
    timing.reserved = uartshadow.payload[0];
    timing.boxselection = uartshadow.payload[1];

    qDebug() << "Time_Resp Bytes Stored!";
}

void CppClass::Sampling_Resp(void)
{
    sampling.reserved = uartshadow.payload[0];
    sampling.boxselection = uartshadow.payload[1];

    qDebug() << "Sampling_Resp Bytes Stored!";
}

void CppClass::Activation_Resp(void)
{
    activation.reserved = uartshadow.payload[0];
    activation.boxselection = uartshadow.payload[1];

    qDebug() << "Activation_Resp Bytes Stored!";
}
