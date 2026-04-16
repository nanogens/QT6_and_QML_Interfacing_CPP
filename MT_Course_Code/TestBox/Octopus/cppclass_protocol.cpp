#include "cppclass.h"
#include <QDateTime>
#include <QDate>
#include <QTime>
#include <QDebug>
#include <cmath>

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


// QML Page 2 ===============================================

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
    qDebug() << "  Usage:" << (instrument.usage[0] << 8) + instrument.usage[1];


    // Need to send a subset of the above data to QML front end (perhaps as a List?)
    // The subset includes device, serialnumber and usage.
    // How do i do this so that these 3 variables/strings can be updated on the QML side?

    // Create a QVariantMap and insert the data
    QVariantMap instrumentData;

    instrumentData["instrument_device"] = instrument.device;
    // Convert uint8_t array to const char* for QString::fromUtf8
    instrumentData["instrument_serialnumber"] = QString::fromUtf8(reinterpret_cast<const char*>(instrument.serialnumber), 13);
    instrumentData["instrument_usage"] = ((instrument.usage[0] << 8)
                                       + (instrument.usage[1]));

    qDebug() << "Emitting instrumentData:" << instrumentData;

    // Emit the signal to send the data to QML
    emit instrumentDataReceived(instrumentData);
}

void CppClass::Communication_Resp(void)
{
    communication.boxselection = uartshadow.payload[0];
    communication.reserved = uartshadow.payload[1];
    communication.connection = uartshadow.payload[2];
    communication.baudrate = uartshadow.payload[3];

    qDebug() << "Communication_Resp Bytes Stored!";

    qDebug() << "-- Communication_Resp (from MCU):";
    qDebug() << "  Box Selection:" << communication.boxselection;
    qDebug() << "  Reserved:" << communication.reserved;
    qDebug() << "  Connection:" << communication.connection;
    qDebug() << "  Baud Rate:" << communication.baudrate;

    // Create a QVariantMap and insert the data
    QVariantMap communicationData;

    communicationData["communication_connection"] = communication.connection;
    communicationData["communication_baudrate"] = communication.baudrate;

    qDebug() << "Emitting communicationData:" << communicationData;

    // Emit the signal to send the data to QML
    emit communicationDataReceived(communicationData);

}

void CppClass::Power_Resp(void)
{
    power.boxselection = uartshadow.payload[0];
    power.reserved = uartshadow.payload[1];
    power.batterytype = uartshadow.payload[2];
    power.duration[0] = uartshadow.payload[3];
    power.duration[1] = uartshadow.payload[4];
    power.powerremaining[0] = uartshadow.payload[5];
    power.powerremaining[1] = uartshadow.payload[6];

    qDebug() << "Power_Resp Bytes Stored!";

    qDebug() << "-- Power (from MCU):";
    qDebug() << "  Box Selection:" << power.boxselection;
    qDebug() << "  Reserved:" << power.reserved;
    qDebug() << "  Type:" << power.batterytype;
    qDebug() << "  Duration:" << (power.duration[0] << 8) + power.duration[1];
    qDebug() << "  Remaining:" << (power.powerremaining[0] << 8) + power.powerremaining[1];

    // Create a QVariantMap and insert the data
    QVariantMap powerData;
    powerData["power_batterytype"] = power.batterytype;
    powerData["power_duration"] = (power.duration[0] << 8) + power.duration[1];
    powerData["power_powerremaining"] = (power.powerremaining[0] << 8) + power.powerremaining[1];

    qDebug() << "Emitting powerData:" << powerData;

    // Emit the signal to send the data to QML
    emit powerDataReceived(powerData);
}

void CppClass::Time_Resp()
{
    // Make sure these indices match your actual payload layout
    time.boxselection = uartshadow.payload[0];
    time.reserved = uartshadow.payload[1];
    time.instrclock_year = uartshadow.payload[2];
    time.instrclock_month = uartshadow.payload[3];
    time.instrclock_day = uartshadow.payload[4];
    time.instrclock_hour = uartshadow.payload[5];
    time.instrclock_minute = uartshadow.payload[6];
    time.instrclock_second = uartshadow.payload[7];
    time.instrclock_ampm = uartshadow.payload[8];
    time.instrclock_weekday = uartshadow.payload[9];

    qDebug() << "Time_Resp Bytes Stored!";
    qDebug() << "Year:" << time.instrclock_year;
    qDebug() << "Month:" << time.instrclock_month;
    qDebug() << "Day:" << time.instrclock_day;
    qDebug() << "Hour:" << time.instrclock_hour;
    qDebug() << "Minute:" << time.instrclock_minute;
    qDebug() << "Second:" << time.instrclock_second;
    qDebug() << "AM/PM:" << (time.instrclock_ampm == 1 ? "PM" : "AM");
    qDebug() << "Weekday:" << time.instrclock_weekday;

    // Create QVariantMap to send to QML
    QVariantMap timeData;
    timeData["year"] = time.instrclock_year;
    timeData["month"] = time.instrclock_month;
    timeData["day"] = time.instrclock_day;
    timeData["hour"] = time.instrclock_hour;
    timeData["minute"] = time.instrclock_minute;
    timeData["second"] = time.instrclock_second;
    timeData["ampm"] = time.instrclock_ampm;
    timeData["weekday"] = time.instrclock_weekday;

    emit timeDataReceived(timeData);
}

void CppClass::Sampling_Resp(void)
{
    sampling.boxselection = uartshadow.payload[0];
    sampling.reserved = uartshadow.payload[1];

    qDebug() << "Sampling_Resp Bytes Stored!";
}

void CppClass::Activation_Resp(void)
{
    activation.boxselection = uartshadow.payload[0];
    activation.reserved = uartshadow.payload[1];

    qDebug() << "Activation_Resp Bytes Stored!";
}

void CppClass::Notes_Resp(void)
{
    qDebug() << "Notes_Resp Bytes Stored!";
}

void CppClass::Cloud_Resp(void)
{
    qDebug() << "Cloud_Resp Bytes Stored!";
}



// QML Page 1 ===============================================


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
  ctd.reedswitch              = uartshadow.payload[9];


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

  // This function emits the state of the ring switch to the QML front end
  ringSwitch(ctd.reedswitch);

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

// QML Page 2 ===============================================

void CppClass::Instrument_Set(QVariantList &list, int i, QByteArray &byteArray)
{
    int bytePos_index = 0;

    instrument.boxselection = INSTRUMENT_SET_MSGID;  // Box Selection - 1 byte
    // Box - 1 byte
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
            error.errorcode = 1;
        }
        else  // print it out
        {
            //for(int s=0; s < bytePos_index; s++)
            //{
            //qDebug() << instrument.serialnumber[s];
            //}
            error.errorcode = 0;
        }

        // if everything is alright, we can send it
        if((error.errorcode == 0) && (writePos == 0))
        {
            SendHeader(INSTRUMENT_SET_MSGLGT, INSTRUMENT_SET_MSGID);
            AddByteToSend(instrument.boxselection, false); // Box Selection
            AddByteToSend(0x00, false); // Reserved (instrument.reserved)
            AddByteToSend(instrument.device, false); // Devices
            for(int r=0; r < MAX_INSTRUMENT_SERIALNUMBER_ARRAY; r++) // Serial
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
}

void CppClass::Time_Set(QVariantList &list, int i, QByteArray &byteArray)
{
    qDebug() << "In Time_Set() now...";

    // Get the time data from the list (i == 1 contains the QVariantMap)
    if(i == 1)
    {
        QVariantMap timeData = list.at(i).toMap();
        time.boxselection = TIME_SET_MSGID;
        time.reserved = 0x00;
        time.instrclock_year = timeData["Year"].toInt();
        time.instrclock_month = timeData["Month"].toInt();
        time.instrclock_day = timeData["Day"].toInt();
        time.instrclock_hour = timeData["Hour"].toInt();
        time.instrclock_minute = timeData["Minute"].toInt();
        time.instrclock_second = timeData["Second"].toInt();
        time.instrclock_ampm = timeData["AMPM"].toInt();
        time.instrclock_weekday = timeData["WeekDay"].toInt();

        qDebug() << "Year:" << time.instrclock_year;
        qDebug() << "Month:" << time.instrclock_month;
        qDebug() << "Day:" << time.instrclock_day;
        qDebug() << "Hour:" << time.instrclock_hour;
        qDebug() << "Minute:" << time.instrclock_minute;
        qDebug() << "Second:" << time.instrclock_second;
        qDebug() << "AM/PM:" << (time.instrclock_ampm == 1 ? "PM" : "AM");
        qDebug() << "Weekday" << (time.instrclock_weekday);

        if((error.errorcode == 0) && (writePos == 0))
        {
            SendHeader(TIME_SET_MSGLGT, TIME_SET_MSGID);
            AddByteToSend(time.boxselection, false); // Box Selection
            AddByteToSend(time.reserved, false);     // Reserved
            AddByteToSend(time.instrclock_year, false);
            AddByteToSend(time.instrclock_month, false);
            AddByteToSend(time.instrclock_day, false);
            AddByteToSend(time.instrclock_hour, false);
            AddByteToSend(time.instrclock_minute, false);
            AddByteToSend(time.instrclock_second, false);
            AddByteToSend(time.instrclock_ampm, false);
            AddByteToSend(time.instrclock_weekday, false);
            AddByteToSend(send.crcsend, true);

            std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
            writePos = send.writepos;

            qDebug() << "Time_Set bytes sent!";
        }
    }
}

// QML Page 3 ===============================================

void CppClass::Log_ShowFiles_Query()
{
  error.errorcode = 0;

  qDebug() << "In Log_Showfiles_Query() now...";

  // if everything is alright, we can send it
  if((error.errorcode == 0) && (writePos == 0))
  {
    SendHeader(LOG_SHOWFILES_QUERY_MSGLGT, LOG_SHOWFILES_QUERY_MSGID);
    AddByteToSend(send.crcsend, true);

    // mutex lock the 485 line so we have exclusive control over it
    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    writePos = send.writepos; // triggers send

    qDebug() << "Bytes sent!";
  }
}

void CppClass::Log_ShowFiles_Resp()
{
    for(counter.y0 = 0; counter.y0 < FILENUM_ARRAY; counter.y0++)
    {
        // Calculate offset for this file's data (22 bytes per file)
        int offset = counter.y0 * 22;  // 1 reserved + 1 fileindex + 8 filename + 4 filesize + 8 filedate = 22

        // reserved (this is the status byte - should be 0x99 for occupied)
        logshowfiles.reserved[counter.y0] = uartshadow.payload[offset + 0];
        // fileindex
        logshowfiles.fileindex[counter.y0] = uartshadow.payload[offset + 1];
        // filename
        logshowfiles.filename[counter.y0][0] = uartshadow.payload[offset + 2];
        logshowfiles.filename[counter.y0][1] = uartshadow.payload[offset + 3];
        logshowfiles.filename[counter.y0][2] = uartshadow.payload[offset + 4];
        logshowfiles.filename[counter.y0][3] = uartshadow.payload[offset + 5];
        logshowfiles.filename[counter.y0][4] = uartshadow.payload[offset + 6];
        logshowfiles.filename[counter.y0][5] = uartshadow.payload[offset + 7];
        logshowfiles.filename[counter.y0][6] = uartshadow.payload[offset + 8];
        logshowfiles.filename[counter.y0][7] = uartshadow.payload[offset + 9];
        // filesize (total page records)
        logshowfiles.filesize[counter.y0][0] = uartshadow.payload[offset + 10];
        logshowfiles.filesize[counter.y0][1] = uartshadow.payload[offset + 11];
        logshowfiles.filesize[counter.y0][2] = uartshadow.payload[offset + 12];
        logshowfiles.filesize[counter.y0][3] = uartshadow.payload[offset + 13];
        // filedate
        logshowfiles.filedate[counter.y0][0] = uartshadow.payload[offset + 14];
        logshowfiles.filedate[counter.y0][1] = uartshadow.payload[offset + 15];
        logshowfiles.filedate[counter.y0][2] = uartshadow.payload[offset + 16];
        logshowfiles.filedate[counter.y0][3] = uartshadow.payload[offset + 17];
        logshowfiles.filedate[counter.y0][4] = uartshadow.payload[offset + 18];
        logshowfiles.filedate[counter.y0][5] = uartshadow.payload[offset + 19];
        logshowfiles.filedate[counter.y0][6] = uartshadow.payload[offset + 20];
        logshowfiles.filedate[counter.y0][7] = uartshadow.payload[offset + 21];
    }
    qDebug() << "Log_ShowFiles_Resp!";

    // After parsing all files, send to QML
    sendDeviceFileListToQML();
}

void CppClass::Log_ReadSpecificFile_Set(uint8_t fileIndex)
{
    error.errorcode = 0;

    qDebug() << "In Log_ReadSpecificFile_Set() now, downloading file index:" << fileIndex;

    // if everything is alright, we can send it
    if((error.errorcode == 0) && (writePos == 0))
    {
        SendHeader(LOG_READSPECIFICFILE_SET_MSGLGT, LOG_READSPECIFICFILE_SET_MSGID);
        AddByteToSend(fileIndex, false);  // Send the actual file index
        AddByteToSend(send.crcsend, true);

        // mutex lock the 485 line so we have exclusive control over it
        std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
        writePos = send.writepos; // triggers send

        qDebug() << "Bytes sent!";
    }
}

void CppClass::Log_ReadSpecificFile_Resp()
{
    uint8_t fileNumber = uartshadow.payload[0];
    uint8_t quadrant = uartshadow.payload[1];

    static QElapsedTimer timer;
    static bool timerStarted = false;

    // On first quadrant (quadrant 0), start timer
    if (quadrant == 0 && !timerStarted) {
        timer.start();
        timerStarted = true;
    }

    // Extract the 128-byte quadrant data
    QByteArray quadrantData;
    quadrantData.reserve(QUADRANTBYTES);
    for (int i = 0; i < QUADRANTBYTES; i++) {
        quadrantData.append(uartshadow.payload[2 + i]);
    }

    // Check if this is a new file or continuing previous
    if (m_metadataBuffer.fileNumber != fileNumber) {
        m_metadataBuffer = FileMetadataBuffer();
        m_metadataBuffer.fileNumber = fileNumber;
        timerStarted = false;  // Reset for new file
        if (quadrant == 0) {
            timer.start();
            timerStarted = true;
        }
    }

    // Store this quadrant
    m_metadataBuffer.quadrants[quadrant] = quadrantData;
    m_metadataBuffer.received[quadrant] = true;

    // Check if we have all 4 quadrants
    bool allReceived = true;
    for (int i = 0; i < QUADRANTS; i++) {
        if (!m_metadataBuffer.received[i]) {
            allReceived = false;
            break;
        }
    }

    if (allReceived) {
        #ifdef ENABLE_TIMING_DEBUG
        qDebug() << "Time to receive all 4 quadrants:" << timer.elapsed() << "ms";
        #endif

        QByteArray fullMetadata;
        fullMetadata.reserve(512);
        for (int i = 0; i < QUADRANTS; i++) {
            fullMetadata.append(m_metadataBuffer.quadrants[i]);
        }

        uint8_t statusByte = (fullMetadata.size() > 0) ? (uint8_t)fullMetadata[0] : FILE_SLOT_EMPTY;
        bool isValid = (statusByte == FILE_SLOT_OCCUPIED);

        emit deviceFileMetadataReceived(fileNumber, isValid, fullMetadata);

        m_metadataBuffer = FileMetadataBuffer();
        timerStarted = false;
    }
}

void CppClass::Log_TransmitData_Set(uint8_t fileIndex, uint16_t pageNumber, uint8_t quadrant)
{
    error.errorcode = 0;

    // Calculate sector and page based on file index and page number
    // For file 0: sectors 3 – 258 (256 sectors total)
    // For file 1: sectors 259 – 514 (256 sectors)
    // For file 2: sectors 515 – 770 (256 sectors)
    // For file 3: sectors 771 – 1023 (256 sectors)
    //
    // Each sector has 8 pages (512 bytes each)
    // So total pages per file = 1024 sectors * 8 pages = 8192 pages
    // Total number of bytes = 8192 pages * 512 bytes = 4,194,304 bytes
    // Total number of bits = 4,194,304 * 8 = 33,554,432 bits or 32 Mbits

    uint32_t startSector = 0;
    switch(fileIndex) {
    case 0: startSector = 3; break;
    case 1: startSector = 259; break;
    case 2: startSector = 515; break;
    case 3: startSector = 771; break;
    default: startSector = 3; break;
    }

    // Calculate sector and page within sector
    uint32_t sectorOffset = pageNumber / 8;
    uint32_t pageInSector = pageNumber % 8;
    uint32_t actualSector = startSector + sectorOffset;

    qDebug() << "In Log_TransmitData_Set() now, file:" << fileIndex
             << "page:" << pageNumber
             << "quadrant:" << quadrant
             << "sector:" << actualSector
             << "page_in_sector:" << pageInSector;

    if((error.errorcode == 0) && (writePos == 0))
    {
        SendHeader(LOG_TRANSMITDATA_SET_MSGLGT, LOG_TRANSMITDATA_SET_MSGID);
        AddByteToSend(fileIndex, false);                          // filenumber_s
        AddByteToSend((actualSector >> 8) & 0xFF, false);         // sector_high_s
        AddByteToSend(actualSector & 0xFF, false);                // sector_low_s
        AddByteToSend(pageInSector, false);                       // page_s
        AddByteToSend(0, false);                                  // reserved0_s
        AddByteToSend(0, false);                                  // reserved1_s
        AddByteToSend(quadrant, false);                           // quadrant_s
        AddByteToSend(send.crcsend, true);

        std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
        writePos = send.writepos;

        qDebug() << "Bytes sent!";
    }
}

void CppClass::Instrument_Query(void)
{
  SendHeader(INSTRUMENT_QUERY_MSGLGT, INSTRUMENT_QUERY_MSGID);
  AddByteToSend(send.crcsend, true);

  std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
  writePos = send.writepos; // triggers send

  qDebug() << "Instrument_Query Sent!";
}

void CppClass::Communication_Query(void)
{
  SendHeader(COMMUNICATION_QUERY_MSGLGT, COMMUNICATION_QUERY_MSGID);
  AddByteToSend(send.crcsend, true);

  std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
  writePos = send.writepos; // triggers send

  qDebug() << "Communication_Query Sent!";
}

void CppClass::Power_Query(void)
{
  SendHeader(COMMUNICATION_QUERY_MSGLGT, COMMUNICATION_QUERY_MSGID);
  AddByteToSend(send.crcsend, true);

  std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
  writePos = send.writepos; // triggers send

  qDebug() << "Communication_Query Sent!";
}

void CppClass::Time_Query(void)
{
    SendHeader(TIME_QUERY_MSGLGT, TIME_QUERY_MSGID);
    AddByteToSend(send.crcsend, true);

    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    writePos = send.writepos; // triggers send

    qDebug() << "Time_Query Sent!";
}

void CppClass::Sampling_Query(void)
{
    SendHeader(SAMPLING_QUERY_MSGLGT, SAMPLING_QUERY_MSGID);
    AddByteToSend(send.crcsend, true);

    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    writePos = send.writepos; // triggers send

    qDebug() << "Sampling_Query Sent!";
}

void CppClass::Activation_Query(void)
{
    SendHeader(ACTIVATION_QUERY_MSGLGT, ACTIVATION_QUERY_MSGID);
    AddByteToSend(send.crcsend, true);

    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    writePos = send.writepos; // triggers send

    qDebug() << "Activation_Query Sent!";
}

void CppClass::Notes_Query(void)
{
    SendHeader(NOTES_QUERY_MSGLGT, NOTES_QUERY_MSGID);
    AddByteToSend(send.crcsend, true);

    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    writePos = send.writepos; // triggers send

    qDebug() << "Notes_Query Sent!";
}

void CppClass::Cloud_Query(void)
{
    SendHeader(CLOUD_QUERY_MSGLGT, CLOUD_QUERY_MSGID);
    AddByteToSend(send.crcsend, true);

    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    writePos = send.writepos; // triggers send

    qDebug() << "Cloud_Query Sent!";
}

void CppClass::Misc_Query(void)
{
    SendHeader(MISC_QUERY_MSGLGT, MISC_QUERY_MSGID);
    AddByteToSend(send.crcsend, true);

    std::lock_guard<std::mutex> lock(m_serialData.outgoingMutex);
    writePos = send.writepos; // triggers send

    qDebug() << "Misc_Query Sent!";
}


void CppClass::sendDeviceFileListToQML()
{
    emit testSignal("sendDeviceFileListToQML called");

    QVariantList deviceFilesList;

    for (int i = 0; i < FILENUM_ARRAY; i++) {
        // First, check if this file slot is occupied (0x99 marker)
        // The marker is at byte 0 of the 128-byte quadrant
        uint8_t statusByte = logshowfiles.reserved[i];  // First byte of the quadrant

        // Skip if not occupied (marker is not 0x99)
        if (statusByte != FILE_SLOT_OCCUPIED) {
            qDebug() << "Device File" << i << "is not occupied (status:" << statusByte << ") - skipping";
            continue;
        }

        // Parse total page records (previously called fileSize)
        uint32_t totalPageRecords = 0;
        totalPageRecords |= (logshowfiles.filesize[i][0] << 24);
        totalPageRecords |= (logshowfiles.filesize[i][1] << 16);
        totalPageRecords |= (logshowfiles.filesize[i][2] << 8);
        totalPageRecords |= (logshowfiles.filesize[i][3]);

        // Parse filename (ASCII, 8 bytes)
        QString fileName;
        for (int j = 0; j < FILENAME_ARRAY; j++) {
            if (logshowfiles.filename[i][j] != 0) {
                fileName += QChar(logshowfiles.filename[i][j]);
            }
        }
        fileName = fileName.trimmed();

        // Parse file date
        int year = logshowfiles.filedate[i][0];
        int month = logshowfiles.filedate[i][1];
        int day = logshowfiles.filedate[i][2];
        int hour = logshowfiles.filedate[i][3];
        int minute = logshowfiles.filedate[i][4];
        int second = logshowfiles.filedate[i][5];
        int ampm = logshowfiles.filedate[i][6];

        // Convert from 12-hour format to 24-hour format
        if (hour > 12) {
            hour = hour - 12;
        }
        if (ampm == 1) {
            if (hour != 12) {
                hour += 12;
            }
        } else {
            if (hour == 12) {
                hour = 0;
            }
        }

        // Create date/time
        QDateTime fileDateTime;
        fileDateTime.setDate(QDate(year, month, day));
        if (QTime(hour, minute, second).isValid()) {
            fileDateTime.setTime(QTime(hour, minute, second));
        } else {
            qDebug() << "Warning: Invalid time for file" << i << ":"
                     << hour << ":" << minute << ":" << second << "AM/PM=" << ampm;
            fileDateTime.setTime(QTime(0, 0, 0));
        }

        // Create QVariantMap for this file
        QVariantMap fileInfo;
        fileInfo["fileName"] = fileName;
        fileInfo["totalPageRecords"] = (qint64)totalPageRecords;
        fileInfo["fileIndex"] = i;
        fileInfo["source"] = "device";
        fileInfo["isValid"] = true;  // We already checked the 0x99 marker

        // Create a sub-map for date/time
        QVariantMap dateTimeMap;
        dateTimeMap["year"] = year;
        dateTimeMap["month"] = month;
        dateTimeMap["day"] = day;
        dateTimeMap["hour"] = hour;
        dateTimeMap["minute"] = minute;
        dateTimeMap["second"] = second;
        dateTimeMap["ampm"] = ampm;
        fileInfo["fileDateTime"] = dateTimeMap;
        fileInfo["fileDateTimeTimestamp"] = fileDateTime.toMSecsSinceEpoch();

        deviceFilesList.append(fileInfo);

        qDebug() << "Device File" << i << ":"
                 << "Name=" << fileName
                 << "Total Page Records=" << totalPageRecords
                 << "Date=" << fileDateTime.toString("yyyy-MM-dd HH:mm:ss");
    }

    qDebug() << "Sending" << deviceFilesList.size() << "device files to QML";
    qDebug() << "=== ABOUT TO EMIT deviceFileListReady signal ===";
    qDebug() << "Number of files to send:" << deviceFilesList.size();

    emit deviceFileListReady(deviceFilesList);

    qDebug() << "=== Signal emitted successfully ===";
}

void CppClass::Log_TransmitData_Resp()
{
    uint8_t fileNumber = uartshadow.payload[0];
    uint8_t sectorHigh = uartshadow.payload[1];
    uint8_t sectorLow = uartshadow.payload[2];
    uint8_t pageNumber = uartshadow.payload[3];
    uint8_t reserved1 = uartshadow.payload[4];
    uint8_t reserved0 = uartshadow.payload[5];
    uint8_t quadrant = uartshadow.payload[6];

    uint16_t sector = (sectorHigh << 8) | sectorLow;

    // Extract the 128-byte quadrant data
    QByteArray quadrantData;
    quadrantData.reserve(128);  // Pre-allocate memory
    for (int i = 0; i < 128; i++) {
        quadrantData.append(uartshadow.payload[7 + i]);
    }

    // COMMENT OUT these debug prints - they are VERY slow!
    // qDebug() << "Log_TransmitData_Resp: File" << fileNumber
    //          << "Sector" << sector << "Page" << pageNumber
    //          << "Quadrant" << quadrant << "Data size:" << quadrantData.size();

    // Convert to QVariantList for QML
    QVariantList pageDataList;
    pageDataList.reserve(128);  // Pre-allocate memory
    for (int i = 0; i < quadrantData.size(); i++) {
        pageDataList.append((int)(unsigned char)quadrantData[i]);
    }

    emit deviceFilePageReceived(fileNumber, sector, pageNumber, quadrant, pageDataList);
}

