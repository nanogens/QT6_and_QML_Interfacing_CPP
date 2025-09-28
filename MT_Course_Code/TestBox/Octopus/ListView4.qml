// ListView4.qml
import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtCharts 2.15

import QtQuick.Controls.Basic
import QtQuick.Controls.Material
import Qt5Compat.GraphicalEffects

Item {
    id: listview4
    width: 1920
    height: 1080

    // Reference sizes for scaling
    readonly property real baseWidth: 1920
    readonly property real baseHeight: 1080
    property real scaleFactor: 1
    property real refSize: Math.max(40 * listview4.scaleFactor, 30)
    property real generalFontSize: 16 * scaleFactor
    property real dropdownFontSize: 12 * scaleFactor

    // Customizable line properties
    property real lineOpacity: 0.5
    property real lineFadeStart: 0.4
    property real lineFadeIntensity: 0.1


    // Main Grid Layout
    GridLayout {
        anchors.fill: parent
        columns: 2
        rows: 1
        rowSpacing: refSize/5
        columnSpacing: refSize/5


        // Banner Component (unchanged)
        Component {
            id: bannerComponent
            Rectangle {
                property alias text: bannerText.text
                property alias fontSize: bannerText.font.pixelSize // Expose font size
                width: parent.width
                height: Math.max(40 * listview4.scaleFactor, 30)
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: "#FFBF00" }
                    GradientStop { position: 0.95; color: "#FFD351" }
                    GradientStop { position: 1.0; color: "#FFE082" }
                }
                Text {
                    id: bannerText
                    anchors {
                        left: parent.left
                        verticalCenter: parent.verticalCenter
                        leftMargin: 5 * listview4.scaleFactor
                    }
                    color: "black"
                    font {
                        bold: true
                        pixelSize: Math.max(generalFontSize, (18 * listview4.scaleFactor)) // Increased size
                        family: "Arial"
                    }
                }
            }
        }


        // Container for the left text area
        Rectangle {
            id: leftText
            width: 400
            height: 300
            anchors.left: parent

            /*
            // Add temporary background and border
            Rectangle {
                anchors.fill: parent
                color: "#20ff0000"
                border.color: "red"
                border.width: 3
                z: 1000
            }
            */

            Layout.row: 0
            Layout.column: 0

            // Add subtle gradient background
            gradient: Gradient {
                GradientStop { position: 0.1; color: "#402211" }  // Bronze
                GradientStop { position: 0.7; color: "#1a1a22" }  // Dark slate
            }
            radius: 16 * scaleFactor  // Optional: subtle rounded corners
            border.color: tempGauge.progressStartColor  // Optional: subtle border
            border.width: 1




            CellBox {
                id: cellA
                anchors.fill: parent
                anchors.margins: 2 * scaleFactor  // Add small margin so content doesn't touch edges

                ColumnLayout {
                    anchors.fill: parent
                    spacing: 0

                    // Header
                    GridLayout {
                        Layout.fillWidth: true
                        columns: 2
                        columnSpacing: 0

                        Image {
                            source: "qrc:/Octopus/images/A_Instrument.png"
                            Layout.preferredWidth: refSize
                            Layout.preferredHeight: refSize
                        }
                        Loader {
                            sourceComponent: bannerComponent
                            Layout.fillWidth: true
                            onLoaded:
                            {
                                item.text = "Instrument"
                                item.font.pixelSize = 14
                            }
                        }
                    }

                    // Content Grid (rest of your existing Cell A content remains exactly the same)
                    GridLayout {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        columns: 2
                        rowSpacing: 5 * scaleFactor
                        Layout.columnSpan: parent.width/2
                        Layout.topMargin: 5 * scaleFactor

                        // Row 0
                        Label {
                            text: "";
                            Layout.row: 0;
                            Layout.column: 0
                            Layout.fillWidth: true
                        }
                        Label {
                            text: "READ"
                            font.bold: true
                            color: "lightgreen"
                            font.pixelSize: generalFontSize * scaleFactor
                            Layout.row: 0
                            Layout.column: 1
                            Layout.fillWidth: true
                            horizontalAlignment: Text.AlignHCenter
                        }


                        // Row 1: Device
                        Label {
                            text: "  Device  . ."
                            font.bold: true
                            font.pixelSize: generalFontSize * scaleFactor
                            Layout.row: 1
                            Layout.column: 0
                        }
                        Label {
                            text: "Submersible Mini AZ"
                            font.pixelSize: generalFontSize * scaleFactor
                            Layout.row: 1
                            Layout.column: 1
                        }


                        // Row 2 : Serial number
                        Label {
                            text: "  Serial Number  ."
                            font.bold: true
                            font.pixelSize: generalFontSize * scaleFactor
                            Layout.row: 2
                            Layout.column: 0
                        }
                        Label {
                            text: label_Instrument_SerialNumber
                            font.pixelSize: generalFontSize * scaleFactor
                            Layout.row: 2
                            Layout.column: 1
                        }

                        // Row 3 : Usage
                        Label {
                            text: "  Usage  . . . . . . . . . . . . ."
                            font.bold: true
                            font.pixelSize: generalFontSize * scaleFactor
                            Layout.row: 3
                            Layout.column: 0
                        }
                        Label {
                            text: label_Instrument_Usage
                            font.pixelSize: generalFontSize * scaleFactor
                            Layout.row: 3
                            Layout.column: 1
                        }

                        // Row 4 : Spacer
                        Label { text: ""; Layout.row: 4; Layout.column: 0; Layout.fillHeight: true }
                        Label { text: ""; Layout.row: 4; Layout.column: 1; Layout.fillHeight: true }

                        // Row 5 : Buttons
                        Label { text: ""; Layout.row: 5; Layout.column: 0 }
                        Button {
                            id: button1Id
                            text: "Button"
                            implicitHeight: 40 * scaleFactor
                            implicitWidth: 150 * scaleFactor
                            font.pixelSize: 16 * scaleFactor
                            Layout.row: 5
                            Layout.column: 1
                        }
                    }

                }
            }


        }


        // Container for the gauge cluster
        Item {
            id: gaugeCluster
            width: Layout.fillWidth
            height: Layout.fillHeight
            anchors.centerIn: parent

            // Add temporary background and border
            Rectangle {
                anchors.fill: parent
                color: "#20ff0000"
                border.color: "red"
                border.width: 3
                z: 1000
            }

            // Debug output
            Component.onCompleted: {
                console.log("=== Line Debug Info ===")
                console.log("Left line width:", leftExtendingLine.width)
                console.log("Right line width:", rightExtendingLine.width)
                console.log("Temp gauge x:", tempGauge.x)
                console.log("Temp gauge width:", tempGauge.width)
                console.log("Cond gauge x:", condGauge.x)
                console.log("Cond gauge width:", condGauge.width)
                console.log("GaugeCluster width:", gaugeCluster.width)
                console.log("Calculated left width:", tempGauge.x - (tempGauge.width / 2))
                console.log("Calculated right width:", listview4.width - (condGauge.x + condGauge.width / 2))
            }

            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: false
            Layout.fillHeight: true

            // Left extending line (from Temperature gauge)
            Rectangle {
                id: leftExtendingLine
                height: 2
                x: 0
                width: (listview4.width / 2) - 730
                y: listview4.height / 2 - height/2
                anchors {
                    right: tempGauge.left
                    rightMargin: -tempGauge.width / 2
                    verticalCenter: tempGauge.verticalCenter
                }

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(tempGauge.progressStartColor.r, tempGauge.progressStartColor.g, tempGauge.progressStartColor.b, 0)
                    }
                    GradientStop {
                        position: 1.0 - lineFadeStart
                        color: Qt.rgba(tempGauge.progressStartColor.r, tempGauge.progressStartColor.g, tempGauge.progressStartColor.b, lineOpacity)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(tempGauge.progressStartColor.r, tempGauge.progressStartColor.g, tempGauge.progressStartColor.b, 0)
                    }
                }

                layer.enabled: true
                layer.effect: Glow {
                    radius: 15
                    samples: 24
                    color: tempGauge.progressStartColor
                    spread: 0.4
                    transparentBorder: true
                }
            }

            // Right extending line (from Conductivity gauge)
            Rectangle {
                id: rightExtendingLine
                height: 2
                x: (listview4.width / 2) + 300
                width: leftExtendingLine.width
                y: listview4.height / 2 - height/2
                anchors {
                    left: condGauge.right
                    leftMargin: -condGauge.width / 2
                    verticalCenter: condGauge.verticalCenter
                }

                gradient: Gradient {
                    GradientStop {
                        position: 0.0
                        color: Qt.rgba(condGauge.progressStartColor.r, condGauge.progressStartColor.g, condGauge.progressStartColor.b, lineOpacity)
                    }
                    GradientStop {
                        position: lineFadeStart
                        color: Qt.rgba(condGauge.progressStartColor.r, condGauge.progressStartColor.g, condGauge.progressStartColor.b, lineOpacity)
                    }
                    GradientStop {
                        position: 1.0
                        color: Qt.rgba(condGauge.progressStartColor.r, condGauge.progressStartColor.g, condGauge.progressStartColor.b, 0)
                    }
                }

                layer.enabled: true
                layer.effect: Glow {
                    radius: 15
                    samples: 24
                    color: condGauge.progressStartColor
                    spread: 0.4
                    transparentBorder: true
                }
            }

            // Temperature gauge
            Text {
                text: "TEMPERATURE"
                anchors {
                    bottom: tempGauge.top
                    bottomMargin: 10
                    horizontalCenter: tempGauge.horizontalCenter
                }
                font.pixelSize: 20
                font.bold: true
                color: "#ff8c00"
                z: tempGauge.z + 1
            }

            ListView4_CircularGuage {
                id: tempGauge
                width: 320
                height: 320
                anchors {
                    verticalCenter: parent.verticalCenter
                    right: depthGauge.left
                    rightMargin: -80
                }
                value: 50
                minValue: 0
                maxValue: 70
                unit: "°C"
                progressStartColor: "gold"
                progressEndColor: "tomato"
                z: 2
            }

            // Depth gauge
            Text {
                id: depthTitle
                text: "DEPTH"
                anchors {
                    bottom: depthGauge.top
                    bottomMargin: 15
                    horizontalCenter: depthGauge.horizontalCenter
                }
                font.pixelSize: 28
                font.bold: true
                color: "#00a8ff"
                z: depthGauge.z + 1
            }

            ListView4_CircularGuage {
                id: depthGauge
                width: 500
                height: 500
                anchors.centerIn: parent
                value: 150
                minValue: 0
                maxValue: 150
                unit: "m"
                progressStartColor: "springgreen"
                progressEndColor: "deepskyblue"
                z: 3
            }

            // Conductivity gauge
            Text {
                text: "CONDUCTIVITY"
                anchors {
                    bottom: condGauge.top
                    bottomMargin: 10
                    horizontalCenter: condGauge.horizontalCenter
                }
                font.pixelSize: 20
                font.bold: true
                color: "#ff6b9d"
                z: condGauge.z + 1
            }

            ListView4_CircularGuage {
                id: condGauge
                width: 320
                height: 320
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: depthGauge.right
                    leftMargin: -80
                }
                value: 120
                minValue: 0
                maxValue: 2000
                unit: "mS/cm"
                progressStartColor: "#FF6EC7"
                progressEndColor: "#8A2BE2"
                z: 2
            }
        }
    }
}
