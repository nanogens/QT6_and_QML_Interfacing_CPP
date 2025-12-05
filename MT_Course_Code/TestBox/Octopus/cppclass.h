#ifndef CPPCLASS_H
#define CPPCLASS_H

#include "Defines.h"

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QtQml/qqmlregistration.h>

#include <windows.h>
#include <thread>
#include <mutex>
#include <atomic>
#include <queue>
#include <condition_variable>
#include <QFile>
#include <QTextStream>
#include <QTimer>

// Forward declarations instead of including full headers when possible:cite[6]
struct DataPoint {
    QString time;
    double temperature;
    double depth;
};

struct FileMetadata {
    QString device;
    QString serialNumber;
    QString instrumentTime;
    QString timeZone;
    QString activationMethod;
};

struct FileData {
    FileMetadata metadata;
    QVector<DataPoint> dataPoints;
};

// Structures as proper class members rather than global variables
struct Counter
{
    uint8_t y0 = 0;
    uint8_t yi = 0;
};

struct Send
{
    uint8_t crcsend = 0;
    uint8_t writepos = 0;
};

struct Error
{
    uint8_t errorcode = 0;
};


// To store incoming Resp messages from MCU and outgoing Set messages from Viewer
struct Version
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    uint8_t fw_version[MAX_VERSION_FW_ARRAY] = {0};
    uint8_t sw_version[MAX_VERSION_SW_ARRAY] = {0};
};

struct Status
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    uint8_t res[MAX_STATUS_RES_ARRAY] = {0};
};


// From QML page 2 =====================================================

struct Instrument
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    uint8_t device = 0;
    uint8_t serialnumber[MAX_INSTRUMENT_SERIALNUMBER_ARRAY] = {0};
    uint8_t usage[MAX_INSTRUMENT_USAGE_ARRAY] = {0};
};

struct Communication
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    uint8_t connection = 0;
    uint8_t baudrate = 0;
};

struct Power
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    uint8_t batterytype = 0;
    uint8_t duration[MAX_POWER_DURATION_ARRAY] = {0};
    uint8_t powerremaining[MAX_POWER_POWERREMAINING_ARRAY] = {0};
};

struct Timing
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    uint8_t compclock_year = 0;    // 0-99 (00-99)
    uint8_t compclock_month = 0;  // 1-12
    uint8_t compclock_day = 0;     // 1-31
    uint8_t compclock_hour = 0;    // 0-23 (24-hour format)
    uint8_t compclock_minute = 0;  // 0-59
    uint8_t compclock_second = 0;  // 0-59
    uint8_t compclock_ampm = 0;    // 0=AM, 1=PM (optional, since we're using 24-hour)
    // Additional variables for full year and weekday
    uint8_t compclock_full_year[MAX_TIMING_COMPCLOCK_FULLYEAR_ARRAY] = {0}; // Full year (2025)
    uint8_t compclock_weekday = 0;    // 1=Monday, 7=Sunday

    uint8_t instrclock_year = 0;
    uint8_t instrclock_month = 0;
    uint8_t instrclock_day = 0;
    uint8_t instrclock_hour = 0;
    uint8_t instrclock_minute = 0;
    uint8_t instrclock_second = 0;
    uint8_t instrclock_ampm = 0;  // 0=AM, 1=PM
    // Additional variables for full year and weekday
    uint8_t instrclock_full_year[MAX_TIMING_INSTRCLOCK_FULLYEAR_ARRAY] = {0}; // Full year (2025)
    uint8_t instrclock_weekday = 0;    // 1=Monday, 7=Sunday
};

struct Sampling
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    uint8_t mode = 0;
    uint8_t rate = 0;
};

struct Activation
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;

    // Start Date
    uint8_t start_year = 0;    // 0-99 (00-99)
    uint8_t start_month = 0;  // 1-12
    uint8_t start_day = 0;     // 1-31
    uint8_t start_hour = 0;    // 0-23 (24-hour format)
    uint8_t start_minute = 0;  // 0-59
    uint8_t start_second = 0;  // 0-59
    uint8_t start_ampm = 0;    // 0=AM, 1=PM (optional, since we're using 24-hour)
    // Additional variables for full year and weekday
    uint8_t start_read_full_year[MAX_ACTIVATION_START_FULLYEAR_ARRAY] = {0}; // Full year (2025)
    uint8_t start_read_weekday = 0;    // 1=Monday, 7=Sunday

    // End Date
    uint8_t end_year = 0;    // 0-99 (00-99)
    uint8_t end_month = 0;  // 1-12
    uint8_t end_day = 0;     // 1-31
    uint8_t end_hour = 0;    // 0-23 (24-hour format)
    uint8_t end_minute = 0;  // 0-59
    uint8_t end_second = 0;  // 0-59
    uint8_t end_ampm = 0;    // 0=AM, 1=PM (optional, since we're using 24-hour)
    // Additional variables for full year and weekday
    uint8_t end_read_full_year[MAX_ACTIVATION_END_FULLYEAR_ARRAY] = {0}; // Full year (2025)
    uint8_t end_read_weekday = 0;    // 1=Monday, 7=Sunday

    uint8_t event = 0;
    uint8_t value = 0;
};

struct Notes
{
    uint8_t note[MAX_NOTES_NOTE_ARRAY] = {0};
};

struct Cloud
{
    uint8_t ip[MAX_CLOUD_IP_ARRAY] = {0};
    uint8_t login[MAX_CLOUD_LOGIN_ARRAY] = {0};
    uint8_t pw[MAX_CLOUD_PW_ARRAY] = {0};
};

struct Misc
{
    uint8_t stuff;
};

// From QML page 1 =====================================================
struct CTD
{
    uint16_t value = 0;
    uint8_t boxselection = 0;
    uint8_t reserved = 0;
    uint8_t depth[2] = {0};
    uint8_t temperature[2] = {0};
    uint8_t conductivity[2] = {0};
    uint8_t reserved1 = 0;
    uint8_t reserved2 = 0;
};

struct SubmersibleInfo
{
    uint8_t boxselection = 0;
    uint8_t reserved = 0;

    uint8_t instrument_device = 0;
    uint8_t instrument_serialnumber[MAX_INSTRUMENT_SERIALNUMBER_ARRAY] = {0};
    uint8_t instrument_usage[MAX_INSTRUMENT_USAGE_ARRAY] = {0};

    uint8_t memory_total[MAX_MEMORY_TOTAL_ARRAY] = {0};
    uint8_t memory_used[MAX_MEMORY_USED_ARRAY] = {0};

    uint8_t configuration_surfacepressure[MAX_CONFIGURATION_SURFACEPRESSURE_ARRAY] = {0};

    uint8_t battery_cell = 0;
    uint8_t battery_type = 0;
    uint8_t battery_hours[2] = {0};

    uint8_t messages_received[4] = {0};
    uint8_t messages_sent[4] = {0};

    uint8_t schedule_tablettime_year;
    uint8_t schedule_tablettime_month;
    uint8_t schedule_tablettime_day;
    uint8_t schedule_tablettime_hour;
    uint8_t schedule_tablettime_minute;
    uint8_t schedule_tablettime_second;
    uint8_t schedule_tablettime_ampm;

    uint8_t schedule_devicetime_year;
    uint8_t schedule_devicetime_month;
    uint8_t schedule_devicetime_day;
    uint8_t schedule_devicetime_hour;
    uint8_t schedule_devicetime_minute;
    uint8_t schedule_devicetime_second;
    uint8_t schedule_devicetime_ampm;

    uint8_t schedule_upcomingrecordingtime_year;
    uint8_t schedule_upcomingrecordingtime_month;
    uint8_t schedule_upcomingrecordingtime_day;
    uint8_t schedule_upcomingrecordingtime_hour;
    uint8_t schedule_upcomingrecordingtime_minute;
    uint8_t schedule_upcomingrecordingtime_second;
    uint8_t schedule_upcomingrecordingtime_ampm;
};






struct Uart
{
    uint8_t sent = 0;
    uint8_t crcsend = 0;
    uint8_t payload[MAX_UART_ARRAY] = {0};
    uint8_t status = 0;
    uint8_t got = 0;
    uint8_t messagelength = 0;
    uint8_t messageidglobal = 0;
    uint8_t crcmsg = 0;
    uint8_t crcset = 0;
};

struct Uartshadow
{
    uint8_t messageid = 0;
    uint8_t payload[MAX_UART_ARRAY] = {0};
};

class CppClass : public QObject
{
    Q_OBJECT

public:
    explicit CppClass(QObject *parent = nullptr);
    ~CppClass();

    // Public interface
    bool startCommunication(const char* portName);
    void stopCommunication();
    void sendData(const QByteArray &data);
    void setPortName(const QString& portName);
    void setTransmitMode(bool transmitting);
    void AddByteToSend(uint8_t data, bool crc_yesno);
    void SendHeader(uint8_t msg_length, uint8_t msg_id);
    bool isRunning();

    // Q_INVOKABLE methods
    Q_INVOKABLE void passFromQmlToCpp(QVariantList list, QVariantMap map);
    Q_INVOKABLE void passFromQmlToCpp2(const QVariantList &files);
    Q_INVOKABLE void passFromQmlToCpp3(QVariantList list, QVariantMap map);
    Q_INVOKABLE void passFromQmlToCpp3prev(QVariantList list, QVariantMap map);
    Q_INVOKABLE QVariantList getVariantListFromCpp();
    Q_INVOKABLE QVariantMap getVariantMapFromCpp();
    Q_INVOKABLE void openAndReadFile(const QString& filePath);
    Q_INVOKABLE void startComm();
    Q_INVOKABLE void stopComm();
    Q_INVOKABLE void processOutgoingMsg(QVariantList list, QVariantMap map);

    // Property binding
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)

    void setQmlRootObject(QObject *value);

signals:
    void runningChanged();
    void dataReceived(const QByteArray &data);
    void fileDataReady(const QVariantMap &metadata, const QVariantList &dataPoints);
    void newDataPointsAdded(const QVariantList &newPoints);

signals:
    // Declare a signal that emits the QVariantMap
    void instrumentDataReceived(const QVariantMap &data);
    void communicationDataReceived(const QVariantMap &data);
    void powerDataReceived(const QVariantMap &data);
    void timingDataReceived(const QVariantMap &data);
    void samplingDataReceived(const QVariantMap &data);
    void activationDataReceived(const QVariantMap &data);
    void notesDataReceived(const QVariantMap &data);
    void cloudDataReceived(const QVariantMap &data);


    void ctdreadingsprocessedDataReceived(const QVariantMap &data);
    void submersibleinfoprocessedDataReceived(const QVariantMap &data);

public slots:
    void triggerJSCall();

private:
    // Serial communication
    struct SerialData {
        std::queue<char> incoming;
        std::queue<char> outgoing;
        std::mutex incomingMutex;
        std::mutex outgoingMutex;
        std::condition_variable cv;
        std::atomic<bool> running{false};
    };

    // Private member variables replacing globals:cite[4]
    uint8_t  writeBuffer[BUFFER_SIZE] = {0};
    int writePos = 0;
    uint8_t  readBuffer[BUFFER_SIZE] = {0};
    DWORD bytesRead = 0;
    uint8_t  readBufferShadow[BUFFER_SIZE] = {0};
    DWORD bytesReadShadow = 0;

    // Structure instances as member variables
    Counter counter;
    Send send;
    Error error;

    // Structure instantiation
    Uart uart;
    Uartshadow uartshadow;

    Version version;
    Status status;
    Instrument instrument;
    Communication communication;
    Power power;
    Timing timing;
    Sampling sampling;
    Activation activation;
    Notes notes;
    Cloud cloud;
    Misc misc;

    // page 1 QML
    CTD ctd;
    SubmersibleInfo submersibleinfo;


    // Existing private members
    HANDLE m_hPort = INVALID_HANDLE_VALUE;
    SerialData m_serialData;
    std::thread m_readwriteThread;
    std::mutex m_portMutex;
    QObject* qmlRootObject = nullptr;
    QFile m_dataFile;
    FileData m_currentFileData;
    QTimer m_fileMonitorTimer;
    qint64 m_lastFileSize = 0;
    QString m_portName;

    // Private methods
    HANDLE openCommPort(const char* portName, DWORD baudRate = CBR_115200);
    void readwriteThread();
    void ProcessIncomingMsg();
    //void ProcessOutgoingMsg(QVariantList list, QVariantMap map);
    void IncomingByteCheck();
    void FalseHeader();
    bool Search_MsgID(uint8_t settingorquery, uint8_t messageidglobal);
    void Inits();

private:
    void startFileMonitoring(const QString& filePath);
    void stopFileMonitoring();
    void readFileContents();

private:
    void Version_Resp();
    void Status_Resp();

    void Instrument_Set(QVariantList& list, int i, QByteArray& byteArray);


    void Instrument_Resp();
    void Communication_Resp();
    void Power_Resp();
    void Timing_Resp();
    void Sampling_Resp();
    void Activation_Resp();
    void Notes_Resp();
    void Cloud_Resp();

public:
    void CTD_Readings_Processed_Query();

public:
    void CTD_Readings_Processed_Resp();
    void Submersible_Info_Resp();

public:
    void Instrument_Query();
    void Communication_Query();
    void Power_Query();
    void Timing_Query();
    void Sampling_Query();
    void Activation_Query();
    void Notes_Query();
    void Cloud_Query();
    void Misc_Query();
};

#endif // CPPCLASS_H
