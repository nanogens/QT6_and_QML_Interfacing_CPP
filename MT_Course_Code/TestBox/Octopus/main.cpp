// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QApplication>
#include <QDir>
#include <QQmlApplicationEngine>
#include <QQmlEngine>
#include <QQuickView>

#include <QDebug>
#include <QQuickStyle> // Required for setting the style

#include <QQmlContext>
#include "cppclass.h"

int main(int argc, char *argv[])
{
    // Qt Charts uses Qt Graphics View Framework for drawing, therefore QApplication must be used.
    QApplication app(argc, argv);

    // Set the Material style before loading QML
    // Try both methods
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    QQuickStyle::setStyle("Material");


    QQmlApplicationEngine engine;

    CppClass cppclass;
    engine.rootContext()->setContextProperty("CppClass", &cppclass);



    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    const QUrl url(u"qrc:/Octopus/Main.qml"_qs);
    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    } else {
        cppclass.setQmlRootObject(engine.rootObjects().first());
    }

    return app.exec();
}
