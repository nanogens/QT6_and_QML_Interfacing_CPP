cmake_minimum_required(VERSION 3.16)

project(2-ContextProperties VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Qml Charts)


qt_standard_project_setup()

qt_add_executable(appContextProperties
    main.cpp
)

qt_add_qml_module(appContextProperties
    URI ContextProperties
    VERSION 1.0
    QML_FILES Main.qml
    SOURCES
    QML_FILES
    QML_FILES LargeChartView.qml
    QML_FILES CellBox.qml
    QML_FILES SideNavButton.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appContextProperties PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.app2-ContextProperties
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appContextProperties
    PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::QuickTemplates2
    Qt6::Charts
    Qt6::QuickWidgets
)

include(GNUInstallDirs)
install(TARGETS appContextProperties
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
