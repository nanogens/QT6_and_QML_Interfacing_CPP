import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects

Item {
    id: listview4
    width: 1920
    height: 1080
    visible: true

    // Column width ratios (easily adjustable)
    property real col0Width: 0.20  // 25%
    property real col1Width: 0.60  // 50%
    property real col2Width: 0.20  // 25%

    // Debug toggle
    property bool showDebugOutlines: false

    // ADD THESE MISSING PROPERTIES:
    property real scaleFactor: 1.0
    property real refSize: 40
    property real generalFontSize: 16
    property string label_Instrument_SerialNumber: "SN-12345"
    property string label_Instrument_Usage: "Active"

    // ADD LINE PROPERTIES:
    property real lineOpacity: 0.7
    property real lineFadeStart: 0.3
    property real lineFadeIntensity: 0.1

    Rectangle {
        anchors.fill: parent
        color: "black"

        // Main Grid Layout
        GridLayout {
            id: mainGridLayout
            anchors.fill: parent
            columns: 3
            columnSpacing: 2
            rowSpacing: 2

            // Banner Component
            Component {
                id: bannerComponent
                Rectangle {
                    property alias text: bannerText.text
                    property alias fontSize: bannerText.font.pixelSize
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
                            pixelSize: Math.max(generalFontSize, (18 * listview4.scaleFactor))
                            family: "Arial"
                        }
                    }
                }
            }

            // === Column 0: 3 rows (30% width) ===
            Rectangle {
                id: col0row0
                Layout.column: 0
                Layout.row: 0
                Layout.preferredWidth: parent.width * col0Width
                Layout.fillHeight: true  // Changed from false to true
                Layout.maximumHeight: 400  // Optional: limit maximum height if needed

                // Visual styling
                gradient: Gradient {
                    GradientStop { position: 0.1; color: "#402211" }
                    GradientStop { position: 0.7; color: "#1a1a22" }
                }
                radius: 16 * scaleFactor
                border.color: showDebugOutlines ? "cyan" : "transparent"
                border.width: showDebugOutlines ? 2 : 0.5

                CellBox {
                    id: cellA
                    anchors.fill: parent
                    anchors.margins: 2 * scaleFactor

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(40 * scaleFactor, 30)  // Explicit height for header
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
                                onLoaded: {
                                    item.text = "Instrument Status"
                                    item.fontSize = 14 * scaleFactor
                                }
                            }
                        }

                        // Content Grid - Make this fill remaining space
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true  // This will take all remaining vertical space
                            columns: 2
                            rowSpacing: 5 * scaleFactor
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

            // Column 0, Row 1 - Ensure this also fills height properly
            Rectangle {
                id: col0row1
                Layout.column: 0
                Layout.row: 1
                Layout.preferredWidth: parent.width * col0Width
                Layout.fillHeight: true  // Changed from false to true
                Layout.maximumHeight: 400  // Optional: limit maximum height if needed

                // Visual styling
                gradient: Gradient {
                    GradientStop { position: 0.1; color: "#402211" }
                    GradientStop { position: 0.7; color: "#1a1a22" }
                }
                radius: 16 * scaleFactor
                border.color: showDebugOutlines ? "cyan" : "transparent"
                border.width: showDebugOutlines ? 2 : 0.5

                CellBox {
                    id: cellB
                    anchors.fill: parent
                    anchors.margins: 2 * scaleFactor

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(40 * scaleFactor, 30)  // Explicit height for header
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
                                onLoaded: {
                                    item.text = "Instrument Status"
                                    item.fontSize = 14 * scaleFactor
                                }
                            }
                        }

                        // Content Grid - Make this fill remaining space
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true  // This will take all remaining vertical space
                            columns: 2
                            rowSpacing: 5 * scaleFactor
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
                                id: button2Id
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

            // Column 0, Row 2 - Ensure this also fills height properly
            Rectangle {
                id: col0row2
                Layout.column: 0
                Layout.row: 2
                Layout.preferredWidth: parent.width * col0Width
                Layout.fillHeight: true  // Changed from false to true
                Layout.maximumHeight: 400  // Optional: limit maximum height if needed

                // Visual styling
                gradient: Gradient {
                    GradientStop { position: 0.1; color: "#402211" }
                    GradientStop { position: 0.7; color: "#1a1a22" }
                }
                radius: 16 * scaleFactor
                border.color: showDebugOutlines ? "cyan" : "transparent"
                border.width: showDebugOutlines ? 2 : 0.5

                CellBox {
                    id: cellC
                    anchors.fill: parent
                    anchors.margins: 2 * scaleFactor

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(40 * scaleFactor, 30)  // Explicit height for header
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
                                onLoaded: {
                                    item.text = "Instrument Status"
                                    item.fontSize = 14 * scaleFactor
                                }
                            }
                        }

                        // Content Grid - Make this fill remaining space
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true  // This will take all remaining vertical space
                            columns: 2
                            rowSpacing: 5 * scaleFactor
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
                                id: button3Id
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



            // Guage Cluster === Column 1: spans 3 rows (60% width) ===
            Rectangle {
                Layout.column: 1
                Layout.row: 0
                Layout.rowSpan: 3
                Layout.preferredWidth: parent.width * col1Width
                Layout.fillHeight: true
                color: "black"
                border.width: showDebugOutlines ? 1 : 0
                border.color: "darkgreen"

                Text {
                    text: "Col 1 (Spans 3 rows)\n" + (col1Width * 100).toFixed(0) + "%"
                    anchors.centerIn: parent
                    color: "white"
                }

                // Container for the gauge cluster
                Item {
                    id: gaugeCluster
                    anchors.fill: parent

                    /*
                    // Add temporary background and border
                    Rectangle {
                        anchors.fill: parent
                        color: "#20ff0000"
                        border.color: "red"
                        border.width: showDebugOutlines ? 3 : 0
                        z: 1000
                    }
                    */

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

                        console.log("=== Gap Debug Info ===")
                        console.log("Temp gauge left edge:", tempGauge.x)
                        console.log("Left line right edge:", leftExtendingLine.x + leftExtendingLine.width)
                        console.log("Gap size:", (leftExtendingLine.x + leftExtendingLine.width) - tempGauge.x)
                    }


                    // FIXED: Left extending line (from Temperature gauge)
                    Rectangle {
                        id: leftExtendingLine
                        height: 2
                        anchors {
                            left: parent.left
                            verticalCenter: tempGauge.verticalCenter
                        }
                        width: tempGauge.x + 25  // Added 25 pixels to bridge the gap
                        z: 4

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

                    // FIXED: Right extending line (from Conductivity gauge)
                    Rectangle {
                        id: rightExtendingLine
                        height: 2
                        anchors {
                            right: parent.right
                            verticalCenter: condGauge.verticalCenter
                        }
                        width: gaugeCluster.width - (condGauge.x + condGauge.width) + 25  // Added 25 pixels to bridge the gap
                        z: 4

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




            Rectangle {
                id: col2row0
                Layout.column: 2
                Layout.row: 0
                Layout.preferredWidth: parent.width * col0Width
                Layout.fillHeight: true  // Changed from false to true
                Layout.maximumHeight: 400  // Optional: limit maximum height if needed

                // Visual styling
                gradient: Gradient {
                    GradientStop { position: 0.1; color: "#402211" }
                    GradientStop { position: 0.7; color: "#1a1a22" }
                }
                radius: 16 * scaleFactor
                border.color: showDebugOutlines ? "cyan" : "transparent"
                border.width: showDebugOutlines ? 2 : 0.5

                CellBox {
                    id: cellD
                    anchors.fill: parent
                    anchors.margins: 2 * scaleFactor

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(40 * scaleFactor, 30)  // Explicit height for header
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
                                onLoaded: {
                                    item.text = "Instrument Status"
                                    item.fontSize = 14 * scaleFactor
                                }
                            }
                        }

                        // Content Grid - Make this fill remaining space
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true  // This will take all remaining vertical space
                            columns: 2
                            rowSpacing: 5 * scaleFactor
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
                                id: button4Id
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

            Rectangle {
                id: col2row1
                Layout.column: 2
                Layout.row: 1
                Layout.preferredWidth: parent.width * col0Width
                Layout.fillHeight: true  // Changed from false to true
                Layout.maximumHeight: 400  // Optional: limit maximum height if needed

                // Visual styling
                gradient: Gradient {
                    GradientStop { position: 0.1; color: "#402211" }
                    GradientStop { position: 0.7; color: "#1a1a22" }
                }
                radius: 16 * scaleFactor
                border.color: showDebugOutlines ? "cyan" : "transparent"
                border.width: showDebugOutlines ? 2 : 0.5

                CellBox {
                    id: cellE
                    anchors.fill: parent
                    anchors.margins: 2 * scaleFactor

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(40 * scaleFactor, 30)  // Explicit height for header
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
                                onLoaded: {
                                    item.text = "Instrument Status"
                                    item.fontSize = 14 * scaleFactor
                                }
                            }
                        }

                        // Content Grid - Make this fill remaining space
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true  // This will take all remaining vertical space
                            columns: 2
                            rowSpacing: 5 * scaleFactor
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
                                id: button5Id
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

            Rectangle {
                id: col2row2
                Layout.column: 2
                Layout.row: 2
                Layout.preferredWidth: parent.width * col0Width
                Layout.fillHeight: true  // Changed from false to true
                Layout.maximumHeight: 400  // Optional: limit maximum height if needed

                // Visual styling
                gradient: Gradient {
                    GradientStop { position: 0.1; color: "#402211" }
                    GradientStop { position: 0.7; color: "#1a1a22" }
                }
                radius: 16 * scaleFactor
                border.color: showDebugOutlines ? "cyan" : "transparent"
                border.width: showDebugOutlines ? 2 : 0.5

                CellBox {
                    id: cellF
                    anchors.fill: parent
                    anchors.margins: 2 * scaleFactor

                    ColumnLayout {
                        anchors.fill: parent
                        spacing: 0

                        // Header
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.preferredHeight: Math.max(40 * scaleFactor, 30)  // Explicit height for header
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
                                onLoaded: {
                                    item.text = "Instrument Status"
                                    item.fontSize = 14 * scaleFactor
                                }
                            }
                        }

                        // Content Grid - Make this fill remaining space
                        GridLayout {
                            Layout.fillWidth: true
                            Layout.fillHeight: true  // This will take all remaining vertical space
                            columns: 2
                            rowSpacing: 5 * scaleFactor
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
                                id: button6Id
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

        }

        // Column dividers
        Rectangle {
            width: 2
            height: parent.height
            x: parent.width * col0Width
            color: "white"
            opacity: showDebugOutlines ? 0.5 : 0
        }

        Rectangle {
            width: 2
            height: parent.height
            x: parent.width * (col0Width + col1Width)
            color: "white"
            opacity: showDebugOutlines ? 0.5 : 0
        }
    }
}
