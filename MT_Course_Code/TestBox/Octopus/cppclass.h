#ifndef CPPCLASS_H
#define CPPCLASS_H

#include <QObject>
#include <QVariantList>
#include <QVariantMap>
#include <QVariantList>
#include <QtQml/qqmlregistration.h>

class CppClass : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool switchEnabled READ switchEnabled NOTIFY switchEnabledChanged)
public:
    explicit CppClass(QObject *parent = nullptr);

    Q_INVOKABLE void passFromQmlToCpp(QVariantList list, QVariantMap map);
    Q_INVOKABLE QVariantList getVariantListFromCpp();
    Q_INVOKABLE QVariantMap getVariantMapFromCpp();

    void setQmlRootObject(QObject *value);

signals:

    void switchEnabledChanged();

public slots:
    void triggerJSCall();

private:
    QObject * qmlRootObject;



// MT added
public:
    bool switchEnabled() const { return m_switchEnabled; }

private:
    bool m_switchEnabled;
};

#endif // CPPCLASS_H
