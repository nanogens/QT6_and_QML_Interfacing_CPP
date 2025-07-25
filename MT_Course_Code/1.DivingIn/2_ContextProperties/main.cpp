#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    // Set style if needed (uncomment one)
    // QQuickStyle::setStyle("Material");
    // QQuickStyle::setStyle("Universal");

    QQmlApplicationEngine engine;

    // Load the QML file from the qrc resource system
    const QUrl url(u"qrc:/ContextProperties/Main.qml"_qs);

    // Handle QML loading errors
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
                         if (!obj && url == objUrl)
                             QCoreApplication::exit(-1);
                     }, Qt::QueuedConnection);

    engine.load(url);

    return app.exec();
}
