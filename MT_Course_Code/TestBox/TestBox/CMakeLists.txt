cmake_minimum_required(VERSION 3.16)

project(TestBox VERSION 0.1 LANGUAGES CXX)

set(CMAKE_AUTOMOC ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Charts Core Gui Qml Quick QuickControls2)


qt_add_executable(appTestBox
    main.cpp
)

qt_add_qml_module(appTestBox
    URI TestBox
    VERSION 1.0
    QML_FILES
        Main.qml
        QML_FILES CellBox.qml LargeChartView.qml SideNavButton.qml
        RESOURCES images/baseline-category-24px.svg images/baseline-menu-24px.svg images/baseline-more_vert-24px.svg
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appTestBox PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appTestBox
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appTestBox
    PUBLIC
        Qt::Charts
        Qt::Core
        Qt::Gui
        Qt::Qml
        Qt::Quick
        Qt::QuickControls2  # <-- This enables QQuickStyle
    )


include(GNUInstallDirs)
install(TARGETS appTestBox
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
