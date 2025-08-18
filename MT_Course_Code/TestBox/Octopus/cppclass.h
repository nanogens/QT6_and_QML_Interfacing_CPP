#ifndef CPPCLASS_H
#define CPPCLASS_H

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


// In your C++ header file
//#include <QObject>
//#include <QString>
//#include <QVariant>
//#include <QVariantList>
//#include <QDateTime>
//#include <QMetaType>  // Required for Q_DECLARE_METATYPE

/*
// MT added
struct FileInfo {
    QString fileName;
    qint64 fileSize; // in bytes
    QDateTime lastModified;

    // Convert to QVariantMap for QML
    QVariantMap toVariant() const {
        return {
            {"fileName", fileName},
            {"fileSize", fileSize},
            {"lastModified", lastModified}
        };
    }
};
*/

//Q_DECLARE_METATYPE(FileInfo)

class CppClass : public QObject
{
    Q_OBJECT
public:
    explicit CppClass(QObject *parent = nullptr);
    ~CppClass();

    Q_INVOKABLE void passFromQmlToCpp(QVariantList list, QVariantMap map);
    Q_INVOKABLE void passFromQmlToCpp2(const QVariantList &files);
    Q_INVOKABLE QVariantList getVariantListFromCpp();
    Q_INVOKABLE QVariantMap getVariantMapFromCpp();
    //Q_INVOKABLE void processFiles(const QString& directory, const QVariantList& fileInfos); // MT added
    void setQmlRootObject(QObject *value);

    // Public interface
    bool startCommunication(const char* portName);
    void stopCommunication();
    void sendData(const QByteArray &data);
    void setPortName(const QString& );

    // Additions
    void setTransmitMode(bool transmitting);

private:
    QString m_portName;


signals:
    void dataReceived(const QByteArray &data);

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

    HANDLE openCommPort(const char* portName, DWORD baudRate = CBR_115200);
    void readThread();
    void writeThread();
    void readwriteThread();
    void processReceivedData();

    // Member variables
    HANDLE m_hPort = INVALID_HANDLE_VALUE;
    SerialData m_serialData;
    std::thread m_readThread;
    std::thread m_writeThread;
    std::thread m_readwriteThread;
    std::mutex m_portMutex;
    QObject* qmlRootObject = nullptr;

};

#endif // CPPCLASS_H
