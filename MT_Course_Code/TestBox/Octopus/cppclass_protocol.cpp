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
    status.boxselection = uartshadow.payload[0];
    status.reserved = uartshadow.payload[1];
    status.res[0] = uartshadow.payload[2];
    status.res[1] = uartshadow.payload[3];

    qDebug() << "Status_Resp Bytes Stored!";
}

void CppClass::Instrument_Resp(void)
{
    instrument.boxselection     = uartshadow.payload[0];
    instrument.reserved         = uartshadow.payload[1];
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

    qDebug() << "-- Instrument_Resp (from MCU):";
    qDebug() << "  Box Selection:" << instrument.boxselection;
    qDebug() << "  Reserved:" << instrument.reserved;
    qDebug() << "  Device:" << instrument.device;
    qDebug() << "  Serial Number:" << instrument.serialnumber;
    qDebug() << "  Usage:" << instrument.usage;


    // Need to send a subset of the above data to QML front end (perhaps as a List?)
    // The subset includes device, serialnumber and usage.
    // How do i do this so that these 3 variables/strings can be updated on the QML side?

    // Create a QVariantMap and insert the data
    QVariantMap instrumentData;
    instrumentData["device"] = instrument.device;
    // Convert uint8_t array to const char* for QString::fromUtf8
    instrumentData["serialnumber"] = QString::fromUtf8(reinterpret_cast<const char*>(instrument.serialnumber), 13);
    instrumentData["usage"] = QString::fromUtf8(reinterpret_cast<const char*>(instrument.usage), 2);

    qDebug() << "Emitting instrumentData:" << instrumentData;

    // Emit the signal to send the data to QML
    emit instrumentDataReceived(instrumentData);
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

void CppClass::CTD_Readings_Processed_Resp(void)
{
  ctd.boxselection            = uartshadow.payload[0];
  ctd.reserved                = uartshadow.payload[1];
  ctd.depth[0]                = uartshadow.payload[2];
  ctd.depth[1]                = uartshadow.payload[3];
  ctd.temperature[0]          = uartshadow.payload[4];
  ctd.temperature[1]          = uartshadow.payload[5];
  ctd.conductivity[0]         = uartshadow.payload[6];
  ctd.conductivity[1]         = uartshadow.payload[7];
  ctd.reserved1               = uartshadow.payload[8];
  ctd.reserved2               = uartshadow.payload[9];


  // Pressure (mbar) to Depth (m) calculation
  //float pressure_mbar = 0;
  //float surface_pressure_mbar = 0;
  //float water_pressure_pa = (pressure_mbar - surface_pressure_mbar) * MBAR_TO_PA;
  //float depth_m = water_pressure_pa / (FRESHWATER_DENSITY * GRAVITY);
  //int32_t depth_cm_x100 = (int32_t)(depth_m * 10000.0f); // MT changed from 10000.0f to 1.0f for now  // meters × 10000 = cm × 100


  // Create a QVariantMap and insert the data
  QVariantMap ctdreadingsprocessedData;

  ctdreadingsprocessedData["depth"] = (float)((float)((ctd.depth[0] << 8) + ctd.depth[1]) / 10000.0);
  ctdreadingsprocessedData["temp"] = (float)(((ctd.temperature[0] << 8) + ctd.temperature[1]) / 10.0);
  ctdreadingsprocessedData["cond"] = ((ctd.conductivity[0] << 8) + ctd.conductivity[1]);

  qDebug() << "Emitting ctdreadingsprocessedData:" << ctdreadingsprocessedData;

  // Emit the signal to send the data to QML
  emit ctdreadingsprocessedDataReceived(ctdreadingsprocessedData);  

  qDebug() << "CTD_Readings_Processed_Resp Bytes Stored!";
}

void CppClass::Submersible_Info_Resp(void)
{
    submersibleinfo.boxselection                       = uartshadow.payload[0];
    submersibleinfo.reserved                           = uartshadow.payload[1];

    submersibleinfo.instrument_device                  = uartshadow.payload[2];

    submersibleinfo.instrument_serialnumber[0]         = uartshadow.payload[3];
    submersibleinfo.instrument_serialnumber[1]         = uartshadow.payload[4];
    submersibleinfo.instrument_serialnumber[2]         = uartshadow.payload[5];
    submersibleinfo.instrument_serialnumber[3]         = uartshadow.payload[6];
    submersibleinfo.instrument_serialnumber[4]         = uartshadow.payload[7];
    submersibleinfo.instrument_serialnumber[5]         = uartshadow.payload[8];
    submersibleinfo.instrument_serialnumber[6]         = uartshadow.payload[9];
    submersibleinfo.instrument_serialnumber[7]         = uartshadow.payload[10];
    submersibleinfo.instrument_serialnumber[8]         = uartshadow.payload[11];
    submersibleinfo.instrument_serialnumber[9]         = uartshadow.payload[12];
    submersibleinfo.instrument_serialnumber[10]        = uartshadow.payload[13];
    submersibleinfo.instrument_serialnumber[11]        = uartshadow.payload[14];
    submersibleinfo.instrument_serialnumber[12]        = uartshadow.payload[15];

    submersibleinfo.instrument_usage[0]                = uartshadow.payload[16]; // note: same reserved variable as above (2nd byte)
    submersibleinfo.instrument_usage[1]                = uartshadow.payload[17]; // note: same reserved variable as above (2nd byte)

    submersibleinfo.memory_total[0]                    = uartshadow.payload[18];
    submersibleinfo.memory_total[1]                    = uartshadow.payload[19];
    submersibleinfo.memory_used[0]                     = uartshadow.payload[20];
    submersibleinfo.memory_used[1]                     = uartshadow.payload[21];

    submersibleinfo.reserved                           = uartshadow.payload[22]; // note: same reserved variable as above (2nd byte)
    submersibleinfo.reserved                           = uartshadow.payload[23]; // note: same reserved variable as above (2nd byte)

    submersibleinfo.configuration_surfacepressure[0]   = uartshadow.payload[24];
    submersibleinfo.configuration_surfacepressure[1]   = uartshadow.payload[25];

    submersibleinfo.reserved                           = uartshadow.payload[26]; // note: same reserved variable as above (2nd byte)
    submersibleinfo.reserved                           = uartshadow.payload[27]; // note: same reserved variable as above (2nd byte)

    submersibleinfo.battery_cell                       = uartshadow.payload[28];
    submersibleinfo.battery_type                       = uartshadow.payload[29];
    submersibleinfo.battery_hours[0]                   = uartshadow.payload[30];
    submersibleinfo.battery_hours[1]                   = uartshadow.payload[31];

    submersibleinfo.reserved                           = uartshadow.payload[32]; // note: same reserved variable as above (2nd byte)
    submersibleinfo.reserved                           = uartshadow.payload[33]; // note: same reserved variable as above (2nd byte)

    submersibleinfo.messages_received[0]               = uartshadow.payload[34];
    submersibleinfo.messages_received[1]               = uartshadow.payload[35];
    submersibleinfo.messages_received[2]               = uartshadow.payload[36];
    submersibleinfo.messages_received[3]               = uartshadow.payload[37];

    submersibleinfo.messages_sent[0]                   = uartshadow.payload[38];
    submersibleinfo.messages_sent[1]                   = uartshadow.payload[39];
    submersibleinfo.messages_sent[2]                   = uartshadow.payload[40];
    submersibleinfo.messages_sent[3]                   = uartshadow.payload[41];

    submersibleinfo.reserved                           = uartshadow.payload[42]; // note: same reserved variable as above (2nd byte)
    submersibleinfo.reserved                           = uartshadow.payload[43]; // note: same reserved variable as above (2nd byte)

    submersibleinfo.schedule_tablettime_year                    = uartshadow.payload[44];
    submersibleinfo.schedule_tablettime_month                   = uartshadow.payload[45];
    submersibleinfo.schedule_tablettime_day                     = uartshadow.payload[46];
    submersibleinfo.schedule_tablettime_hour                    = uartshadow.payload[47];
    submersibleinfo.schedule_tablettime_minute                  = uartshadow.payload[48];
    submersibleinfo.schedule_tablettime_second                  = uartshadow.payload[49];
    submersibleinfo.schedule_tablettime_ampm                    = uartshadow.payload[50];

    submersibleinfo.schedule_devicetime_year                    = uartshadow.payload[51];
    submersibleinfo.schedule_devicetime_month                   = uartshadow.payload[52];
    submersibleinfo.schedule_devicetime_day                     = uartshadow.payload[53];
    submersibleinfo.schedule_devicetime_hour                    = uartshadow.payload[54];
    submersibleinfo.schedule_devicetime_minute                  = uartshadow.payload[55];
    submersibleinfo.schedule_devicetime_second                  = uartshadow.payload[56];
    submersibleinfo.schedule_devicetime_ampm                    = uartshadow.payload[57];

    submersibleinfo.schedule_upcomingrecordingtime_year         = uartshadow.payload[58];
    submersibleinfo.schedule_upcomingrecordingtime_month        = uartshadow.payload[59];
    submersibleinfo.schedule_upcomingrecordingtime_day          = uartshadow.payload[60];
    submersibleinfo.schedule_upcomingrecordingtime_hour         = uartshadow.payload[61];
    submersibleinfo.schedule_upcomingrecordingtime_minute       = uartshadow.payload[62];
    submersibleinfo.schedule_upcomingrecordingtime_second       = uartshadow.payload[63];
    submersibleinfo.schedule_upcomingrecordingtime_ampm         = uartshadow.payload[64];

    submersibleinfo.reserved                           = uartshadow.payload[65]; // note: same reserved variable as above (2nd byte)
    submersibleinfo.reserved                           = uartshadow.payload[66]; // note: same reserved variable as above (2nd byte)


    // Create a QVariantMap and insert the data
    QVariantMap submersibleinfoprocessedData;

    // Instruments --------------------------------------------------------------------------------
    submersibleinfoprocessedData["instrument_device"] = submersibleinfo.instrument_device;
    QString serialnumberStr;
    for(int i = 0; i < MAX_INSTRUMENT_SERIALNUMBER_ARRAY; i++) {
        serialnumberStr.append(QChar(submersibleinfo.instrument_serialnumber[i]));
    }
    submersibleinfoprocessedData["instrument_serialnumber"] = serialnumberStr;
    submersibleinfoprocessedData["instrument_usage"] = ((submersibleinfo.instrument_usage[0] << 8)
                                                     + (submersibleinfo.instrument_usage[1]));

    // Memory --------------------------------------------------------------------------------------
    submersibleinfoprocessedData["memory_total"] = ((submersibleinfo.memory_total[0] << 8)
                                                        + (submersibleinfo.memory_total[1]));
    submersibleinfoprocessedData["memory_used"] = ((submersibleinfo.memory_used[0] << 8)
                                                + (submersibleinfo.memory_used[1]));


    // Configuration -------------------------------------------------------------------------------
    submersibleinfoprocessedData["surface_pressure"] = ((submersibleinfo.configuration_surfacepressure[0] << 8)
                                                     + (submersibleinfo.configuration_surfacepressure[1]));

    // Battery -------------------------------------------------------------------------------------
    submersibleinfoprocessedData["battery_cell"] = submersibleinfo.battery_cell;
    submersibleinfoprocessedData["battery_type"] = submersibleinfo.battery_type;
    submersibleinfoprocessedData["battery_usage"] = ((submersibleinfo.battery_hours[0] << 8)
                                                     + (submersibleinfo.battery_hours[1]));

    // Message Traffic -----------------------------------------------------------------------------
    submersibleinfoprocessedData["messages_received"] = ((submersibleinfo.messages_received[0] << 24)
                                                      + (submersibleinfo.messages_received[1] << 16)
                                                      + (submersibleinfo.messages_received[2] << 8)
                                                      + (submersibleinfo.messages_received[3]));
    submersibleinfoprocessedData["messages_sent"] = ((submersibleinfo.messages_sent[0] << 24)
                                                         + (submersibleinfo.messages_sent[1] << 16)
                                                         + (submersibleinfo.messages_sent[2] << 8)
                                                         + (submersibleinfo.messages_sent[3]));

    // Time - Schedule_TableTime --------------------------------------------------------------------
    // Format: 2025-12-01 02:58:13 PM
    QString formattedTime = QString::asprintf("%04u-%02u-%02u %02u:%02u:%02u %s",
                                              submersibleinfo.schedule_tablettime_year,
                                              submersibleinfo.schedule_tablettime_month,
                                              submersibleinfo.schedule_tablettime_day,
                                              submersibleinfo.schedule_tablettime_hour,
                                              submersibleinfo.schedule_tablettime_minute,
                                              submersibleinfo.schedule_tablettime_second,
                                              submersibleinfo.schedule_tablettime_ampm ? "PM" : "AM"); // Assuming 0=AM, 1=PM or similar
    // Add to QVariantMap
    submersibleinfoprocessedData["schedule_tablettime"] = formattedTime;


    // Time - Schedule_DeviceTime --------------------------------------------------------------------
    QString deviceTimeFormatted = QString::asprintf("%04u-%02u-%02u %02u:%02u:%02u %s",
                                                    submersibleinfo.schedule_devicetime_year,
                                                    submersibleinfo.schedule_devicetime_month,
                                                    submersibleinfo.schedule_devicetime_day,
                                                    submersibleinfo.schedule_devicetime_hour,
                                                    submersibleinfo.schedule_devicetime_minute,
                                                    submersibleinfo.schedule_devicetime_second,
                                                    (submersibleinfo.schedule_devicetime_ampm == 0 || submersibleinfo.schedule_devicetime_ampm == 'A') ? "AM" : "PM");
    submersibleinfoprocessedData["schedule_devicetime"] = deviceTimeFormatted;

    // Time - Schedule_UpcomingRecordingTime ----------------------------------------------------------
    QString upcomingTimeFormatted = QString::asprintf("%04u-%02u-%02u %02u:%02u:%02u %s",
                                                      submersibleinfo.schedule_upcomingrecordingtime_year,
                                                      submersibleinfo.schedule_upcomingrecordingtime_month,
                                                      submersibleinfo.schedule_upcomingrecordingtime_day,
                                                      submersibleinfo.schedule_upcomingrecordingtime_hour,
                                                      submersibleinfo.schedule_upcomingrecordingtime_minute,
                                                      submersibleinfo.schedule_upcomingrecordingtime_second,
                                                      (submersibleinfo.schedule_upcomingrecordingtime_ampm == 0 || submersibleinfo.schedule_upcomingrecordingtime_ampm == 'A') ? "AM" : "PM");
    submersibleinfoprocessedData["schedule_upcomingrecordingtime"] = upcomingTimeFormatted;


    qDebug() << "Emitting submersibleinfoprocessedData:" << submersibleinfoprocessedData;

    // Emit the signal to send the data to QML
    emit submersibleinfoprocessedDataReceived(submersibleinfoprocessedData);


    qDebug() << "Submersible_Info_Resp Bytes Stored!";
}

// ================================

void CppClass::CTD_Readings_Processed_Query(void)
{
  SendHeader(CTD_READINGS_PROCESSED_QUERY_MSGLGT, CTD_READINGS_PROCESSED_QUERY_MSGID);
  AddByteToSend(send.crcsend, true);

  std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
  writePos = send.writepos; // triggers send

  qDebug() << "CTD_Readings_Processed_Query Sent!";
}
