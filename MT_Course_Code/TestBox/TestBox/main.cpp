// Copyright (C) 2023 The Qt Company Ltd.
// SPDX-License-Identifier: LicenseRef-Qt-Commercial OR BSD-3-Clause

#include <QApplication>
#include <QQmlApplicationEngine>
#include <QDir>
#include <QQmlEngine>
#include <QQuickView>

#include <QQuickStyle>  // Required for setting the style
#include <QDebug>

int main(int argc, char *argv[])
{
    // Qt Charts uses Qt Graphics View Framework for drawing, therefore QApplication must be used.
    QApplication app(argc, argv);


    // Set the Material style before loading QML
    // Try both methods
    qputenv("QT_QUICK_CONTROLS_STYLE", "Material");
    QQuickStyle::setStyle("Material");


    /*
    QQuickView viewer;
    viewer.setMinimumSize({600, 400});

    // The following are needed to make examples run without having to install the module
    // in desktop environments.
#ifdef Q_OS_WIN
    QString extraImportPath(QStringLiteral("%1/../../../../%2"));
#else
    QString extraImportPath(QStringLiteral("%1/../../../%2"));
#endif
    viewer.engine()->addImportPath(extraImportPath.arg(QGuiApplication::applicationDirPath(),
                                                       QString::fromLatin1("qml")));
    QObject::connect(viewer.engine(), &QQmlEngine::quit, &viewer, &QWindow::close);
    */


    QQmlApplicationEngine engine;

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);




    engine.load("qrc:/TestBox/Main.qml");


    //viewer.setTitle(QStringLiteral("Qt Charts QML Example Gallery"));
    //viewer.setSource(QUrl("qrc:/qml/Main.qml"));
    //viewer.setResizeMode(QQuickView::SizeRootObjectToView);
    //viewer.show();

    return app.exec();
}

