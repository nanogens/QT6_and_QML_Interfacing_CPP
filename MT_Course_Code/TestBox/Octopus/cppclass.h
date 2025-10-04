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


// To store incoming Resp messages from MCU
struct Version
{
    uint8_t fw_version[2] = {0};
    uint8_t sw_version[2] = {0};
};

struct Status
{
    uint8_t reserved[4] = {0};
};

struct Instrument
{
    uint8_t reserved = 0;
    uint8_t boxselection = 0;
    uint8_t device = 0;
    uint8_t serialnumber[ARRAY_SERIALNUMBER_MAX] = {0};
    uint8_t usage[ARRAY_USAGE_MAX] = {0};
};

struct Communication
{
    uint8_t selection = 0;
    uint8_t connection = 0;
    uint8_t baudrate = 0;
};

struct Power
{
    uint8_t selection = 0;
    uint8_t batterytype = 0;
};

struct Activation
{
    uint8_t selection = 0;
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

    // Property binding
    Q_PROPERTY(bool running READ isRunning NOTIFY runningChanged)

    void setQmlRootObject(QObject *value);

signals:
    void runningChanged();
    void dataReceived(const QByteArray &data);
    void fileDataReady(const QVariantMap &metadata, const QVariantList &dataPoints);
    void newDataPointsAdded(const QVariantList &newPoints);

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

    Version version;
    Status status;
    Instrument instrument;
    Communication communication;
    Power power;
    Activation activation;
    Uart uart;
    Uartshadow uartshadow;

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
    void ProcessMsg();
    void IncomingByteCheck();
    void FalseHeader();
    bool Search_MsgID(uint8_t settingorquery, uint8_t messageidglobal);
    void Inits();

private:
    void startFileMonitoring(const QString& filePath);
    void stopFileMonitoring();
    void readFileContents();

private:
    void Ver_Resp();
    void Status_Resp();
    void Instrument_Resp();
};

#endif // CPPCLASS_H
