import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15

Item {
    id: listview2

    // Reference sizes for scaling (unchanged)
    readonly property real baseWidth: 1920
    readonly property real baseHeight: 1080
    property real scaleFactor: 1
    property real refSize: Math.max(40 * listview2.scaleFactor, 30)
    property real generalFontSize: 16 * scaleFactor
    property real dropdownFontSize: 12 * scaleFactor

    // Banner Component (unchanged)
    Component {
        id: bannerComponent
        Rectangle {
            property alias text: bannerText.text
            width: parent.width
            height: Math.max(40 * listview2.scaleFactor, 30)
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
                    leftMargin: 5 * listview2.scaleFactor
                }
                color: "black"
                font {
                    bold: true
                    pixelSize: Math.max(generalFontSize, (18 * listview2.scaleFactor))
                    family: "Arial"
                }
            }
        }
    }

    // Your properties
    property var instrumentModelTypes: ["Submersible_Mini_AZ", "Submersible_Mini_BZ", "Submersible_Mini_CZ"]
    property var instrumentBatteryTypes: ["Lithium CR2", "Alkaline", "Rechargeable Li-Ion", "External"]
    property var recordingModes: ["Continuous", "Scheduled", "Event-Triggered"]
    property var recordingSamplingRate: ["1 sec", "5 sec", "30 sec", "1 min", "5 min", "15 min", "30 min", "1 hour"]
    property var modeTypes: ["Continuous", "Average", "Burst", "Directional"]
    property var durationTime: ["60 mins", "120 mins", "240 mins", "480 mins", "720 mins"]
    property var intervalTime: ["1 min", "5 mins", "10 mins", "15 mins", "30 mins"]
    property var activationMethod : ["Switch", "Time", "Trigger"]

    property string currentinstrumentModelTypes: "Submersible_Mini_AZ"
    property string currentinstrumentBatteryTypes: "Alkaline"
    property string currentRecordingModes: "Continuous"
    property string currentSamplingRate: "1 sec"
    property string currentActivationMethod: "Switch"

    property var instrumentWiredConnection: ["RS-485", "Ethernet", "CAN"]
    property var instrumentPort: ["COM_1", "COM_2", "COM_3", "COM_4"]
    property var instrumentBaudRate: ["115200", "57600", "38400", "19200", "9600"]

    // Main Grid Layout
    GridLayout {
        anchors.fill: parent
        columns: 3
        rows: 3
        rowSpacing: refSize/5
        columnSpacing: refSize/5

        // Cell A - Instrument (Template for others)
        CellBox {
            id: cellA
            Layout.row: 0
            Layout.column: 0
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

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
                        onLoaded: item.text = "Instrument"
                    }
                }

                // Content Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }


                    // Row 1: Model
                    Label {
                        text: "  Model  . . . . . . . . . . . . ."
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
                    ComboBox {
                        id: modelComboBox
                        model: instrumentModelTypes
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.currentinstrumentModelTypes = currentText
                    }

                    // Row 2: Battery
                    Label {
                        text: "  Battery  . . . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: "Lithium CR2"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    ComboBox {
                        id: batteryComboBox
                        model: instrumentBatteryTypes
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.currentinstrumentBatteryTypes = currentText
                    }

                    // Row 3: Last communication
                    Label {
                        text: "  Last Communication"
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: "0 Days Ago"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    Label {
                        text: Instrument_lastCommunication
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    // Row 4: Serial number
                    Label {
                        text: "  Serial Number  . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 4
                        Layout.column: 0
                    }
                    Label {
                        text: "SZM-AZ-000001"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 4
                        Layout.column: 1
                    }
                    Label {
                        text: Instrument_serialNumber
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 4
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    // Spacer
                    Label { text: ""; Layout.row: 5; Layout.column: 0; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 5; Layout.column: 1; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 5; Layout.column: 2; Layout.fillHeight: true }

                    // Row 6: Buttons
                    Label { text: ""; Layout.row: 6; Layout.column: 0 }
                    Button {
                        id: button1Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 6
                        Layout.column: 1
                    }
                    Button {
                        id: button2Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 6
                        Layout.column: 2
                    }
                }
            }
        }

        // Cell B - Communications (same structure as A)
        CellBox {
            id: cellB
            Layout.row: 0
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0  // Changed to 0 to eliminate extra spacing

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/B_Communications.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Communications"
                    }
                }

                // Content Grid - 3 columns, multiple rows
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        text: "  Wired Connection  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "RS-485"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: wiredconnectionComboBox
                        model: instrumentWiredConnection
                        currentIndex: 0
                        implicitWidth: 200 * scaleFactor
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        onCurrentIndexChanged: listview2.instrumentWiredConnection = currentText
                    }

                    Label {
                        text: "  Port  . . . . . . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: "COM_3"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    ComboBox {
                        id: portComboBox
                        model: instrumentPort
                        currentIndex: 0
                        implicitWidth: 200 * scaleFactor
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        onCurrentIndexChanged: listview2.instrumentPort = currentText
                    }

                    Label {
                        text: "  Baud Rate  . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: "115200"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    ComboBox {
                        id: baudrateComboBox
                        model: instrumentBaudRate
                        currentIndex: 0
                        implicitWidth: 200 * scaleFactor
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        onCurrentIndexChanged: listview2.instrumentBaudRate = currentText
                    }


                    // Row 5: Empty spacer
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 0
                        Layout.fillHeight: true  // Pushes buttons to bottom
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 1
                        Layout.fillHeight: true
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 2
                        Layout.fillHeight: true
                    }

                    // Row 6: Buttons
                    Label {
                        text: ""
                        Layout.row: 5
                        Layout.column: 0
                    }
                    Button {
                        id: button3Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                        onClicked: {
                            var data = CppClass.getVariantListFromCpp()
                            data.forEach(function(element) {
                                console.log("Array item: " + element)
                            })
                        }
                    }
                    Button {
                        id: button4Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 2
                        onClicked: {
                            var selectedModel = modelComboBox.currentText;
                            var selectedBattery = batteryComboBox.currentText;
                            var arr = [selectedModel, selectedBattery];
                            var obj = {
                                model: selectedModel,
                                battery: selectedBattery
                            };
                            CppClass.passFromQmlToCpp(arr, obj);
                        }
                    }
                }
            }
        }

        // Cell C - Power (same structure)
        CellBox {
            id: cellC
            Layout.row: 0
            Layout.column: 2
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0  // Changed to 0 to eliminate extra spacing

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/C_Power.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Power"
                    }
                }

                // Content Grid - 3 columns, multiple rows
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Label {
                        text: "  Estimated Duration  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "28 days at current usage"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    Label {
                        text: ""  // don't think we need to fill it in with anything since we are reading from instrument, and no write is available
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "  Estimated Duration  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: "28 days at current usage"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    Label {
                        text: ""  // don't think we need to fill it in with anything since we are reading from instrument, and no write is available
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "  Power Remaining  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: "75% Remaining"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    Label {
                        text: ""  // don't think we need to fill it in with anything since we are reading from instrument, and no write is available
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillWidth: true
                    }


                    // Row 5: Empty spacer
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 0
                        Layout.fillHeight: true  // Pushes buttons to bottom
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 1
                        Layout.fillHeight: true
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 2
                        Layout.fillHeight: true
                    }

                    // Row 6: Buttons
                    Label {
                        text: ""
                        Layout.row: 5
                        Layout.column: 0
                    }
                    Button {
                        id: button5Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                        onClicked: {
                            var data = CppClass.getVariantListFromCpp()
                            data.forEach(function(element) {
                                console.log("Array item: " + element)
                            })
                        }
                    }
                    Button {
                        id: button6Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 2
                        onClicked: {
                            var selectedModel = modelComboBox.currentText;
                            var selectedBattery = batteryComboBox.currentText;
                            var arr = [selectedModel, selectedBattery];
                            var obj = {
                                model: selectedModel,
                                battery: selectedBattery
                            };
                            CppClass.passFromQmlToCpp(arr, obj);
                        }
                    }
                }
            }
        }

        // Cell D - Time (same structure)
        CellBox {
            id: cellD
            Layout.row: 1
            Layout.column: 0
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/D_Time.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Time"
                    }
                }

                // Content Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Row 1: Instrument Clock
                    Label {
                        text: "  Instrument Clock  . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "03:15:45"  // replace with variable
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    Label {
                        text: Time_instrumentClock  // replace with variable
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    // Row 2: Sync with Computer
                    Label {
                        text: "  Sync with Computer "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: "05:15:45"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    Label {
                        text: Time_syncwithComputer  // replace with variable
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    // Row : Time Zone
                    Label {
                        text: "  Time Zone "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: "UTC-4"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    Label {
                        text: Time_timeZone  // replace with variable
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    // Row : Empty spacer
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 0
                        Layout.fillHeight: true  // Pushes buttons to bottom
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 1
                        Layout.fillHeight: true
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 2
                        Layout.fillHeight: true
                    }

                    // Row 3: Buttons
                    Label { text: ""; Layout.row: 5; Layout.column: 0 }
                    Button {
                        id: buttonf1Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                    }
                    Button {
                        id: buttonf2Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 2
                    }
                }
            }
        }

        // Cell E - Recording (same structure)
        CellBox {
            id: cellE
            Layout.row: 1
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/E_Recording.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Recording"
                    }
                }

                // Content Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Row 1: Recording Mode
                    Label {
                        text: "  Recording Mode  . . "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: currentRecordingModes
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: recordingmodeComboBox
                        model: recordingModes
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.recordingModes = currentText
                    }

                    // Row 2: Sampling Rate
                    Label {
                        text: "  Sampling Rate  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: currentSamplingRate
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    ComboBox {
                        id: samplingrateComboBox
                        model: recordingSamplingRate
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.recordingSamplingRate = currentText
                    }

                    // Row : Time Zone
                    Label {
                        text: "  End Time  . . . . . "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: "05:18:22"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    Label {
                        text: ""
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    // Row : Empty spacer
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 0
                        Layout.fillHeight: true  // Pushes buttons to bottom
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 1
                        Layout.fillHeight: true
                    }
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 2
                        Layout.fillHeight: true
                    }

                    // Row : Buttons
                    Label { text: ""; Layout.row: 5; Layout.column: 0 }
                    Button {
                        id: buttonfc1Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                    }
                    Button {
                        id: buttonfc2Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 2
                    }
                }
            }
        }

        // Cell F - Notes
        CellBox {
            id: cellF
            Layout.row: 1
            Layout.column: 2
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0  // Changed to 0 to eliminate extra spacing

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/F_Notes.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Notes"
                    }
                }

                // Content Grid
                GridLayout
                {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 2
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/2
                    Layout.topMargin: 5 * scaleFactor
                    Layout.leftMargin: 15 * scaleFactor
                    Layout.rightMargin: 15 * scaleFactor
                    columnSpacing: generalFontSize * scaleFactor

                    // Row 0
                    Label {
                        text: "READ"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 0
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 1
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Replace your Label with this:
                    Flickable {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.5
                        contentWidth: width
                        contentHeight: textItem.height
                        clip: true
                        Layout.row: 1
                        Layout.column: 0
                        Text {
                            id: textItem
                            width: parent.width
                            wrapMode: Text.WordWrap
                            text: "\nA paragraph is a distinct unit of writing, typically composed of several sentences, that focuses on a single idea or topic. It serves to organize and structure written work, making it easier for readers to follow the author's train of thought. Each paragraph usually begins with an indent and should ideally contain a topic sentence that introduces the main idea, supported by details and examples.  "
                            font.bold: true
                            color: "lightgray"
                            font.pixelSize: generalFontSize * scaleFactor
                        }
                        //ScrollBar.vertical: ScrollBar {} // Optional scrollbar
                    }
                    ScrollView {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.5
                        Layout.row: 1
                        Layout.column: 1
                        TextArea {
                            anchors.fill: parent
                            placeholderText: 'Multi-line text editor...'
                            selectByMouse: true
                            persistentSelection: true
                        }
                    }

                    Button {
                        id: button1xId
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                        onClicked: {
                            var data = CppClass.getVariantListFromCpp()
                            data.forEach(function(element) {
                                console.log("Array item: " + element)
                            })
                        }
                        Layout.alignment: Qt.AlignCenter
                    }
                    Button
                    {
                        id: button2xId
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                        onClicked: {
                            var selectedModel = modelComboBox.currentText;
                            var selectedBattery = batteryComboBox.currentText;
                            var arr = [selectedModel, selectedBattery];
                            var obj = {
                                model: selectedModel,
                                battery: selectedBattery
                            };
                            CppClass.passFromQmlToCpp(arr, obj);
                        }
                        Layout.alignment: Qt.AlignCenter
                    }
                }
            }
        }

        // Cell G - Activation
        CellBox {
            id: cellG
            Layout.row: 2
            Layout.column: 0
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/G_Activation.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Activation"
                    }
                }

                // Content Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Row 1: Recording Mode
                    Label {
                        text: "  Activation Method  . . "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: currentActivationMethod
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: activationmethodComboBox
                        model: activationMethod
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.activationMethod = currentText
                    }

                    // Temporary
                    Label {
                        text: "  Activation Method  . . "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: currentActivationMethod
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    ComboBox {
                        id: activationmetxhodComboBox
                        model: activationMethod
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.activationMethod = currentText
                    }

                    // Row : Empty spacer
                    Label {
                        text: ""
                        Layout.row: 3
                        Layout.column: 0
                        Layout.fillHeight: true  // Pushes buttons to bottom
                    }
                    Label {
                        text: ""
                        Layout.row: 3
                        Layout.column: 1
                        Layout.fillHeight: true
                    }
                    Label {
                        text: ""
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillHeight: true
                    }

                    // Row : Buttons
                    Label { text: ""; Layout.row: 4; Layout.column: 0 }
                    Button {
                        id: buttonfec1Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 4
                        Layout.column: 1
                    }
                    Button {
                        id: buttonfec2Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 4
                        Layout.column: 2
                    }
                }
            }
        }

        // Cell H - Activation
        CellBox {
            id: cellH
            Layout.row: 2
            Layout.column: 1
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/H_Sampling.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Sampling"
                    }
                }

                // Content Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Row 1: Recording Mode
                    Label {
                        text: "  Activation Method  . . "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: currentActivationMethod
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: activationmethodComboBoxx
                        model: activationMethod
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.activationMethod = currentText
                    }


                    // Row : Empty spacer
                    Label {
                        text: ""
                        Layout.row: 2
                        Layout.column: 0
                        Layout.fillHeight: true  // Pushes buttons to bottom
                    }
                    Label {
                        text: ""
                        Layout.row: 2
                        Layout.column: 1
                        Layout.fillHeight: true
                    }
                    Label {
                        text: ""
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillHeight: true
                    }

                    // Row : Buttons
                    Label { text: ""; Layout.row: 3; Layout.column: 0 }
                    Button {
                        id: buttonfecd1Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    Button {
                        id: buttonfecd2Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                    }
                }
            }
        }

        // Cell I - Activation
        CellBox {
            id: cellI
            Layout.row: 2
            Layout.column: 2
            Layout.fillWidth: true
            Layout.fillHeight: true  // Critical for equal height
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header
                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    columnSpacing: 0

                    Image {
                        source: "qrc:/Octopus/images/I_Misc.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Miscelleneous"
                    }
                }

                // Content Grid
                GridLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    columns: 3
                    rowSpacing: 5 * scaleFactor
                    Layout.columnSpan: parent.width/3
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
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0
                        Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Row 1: Recording Mode
                    Label {
                        text: "  Activation Method  . . "
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: currentActivationMethod
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: activationmethodComboBoxxx
                        model: activationMethod
                        currentIndex: 0
                        implicitHeight: 26 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.activationMethod = currentText
                    }


                    // Row : Empty spacer
                    Label {
                        text: ""
                        Layout.row: 2
                        Layout.column: 0
                        Layout.fillHeight: true  // Pushes buttons to bottom
                    }
                    Label {
                        text: ""
                        Layout.row: 2
                        Layout.column: 1
                        Layout.fillHeight: true
                    }
                    Label {
                        text: ""
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillHeight: true
                    }

                    // Row : Buttons
                    Label { text: ""; Layout.row: 3; Layout.column: 0 }
                    Button {
                        id: buttonfecd1rId
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    Button {
                        id: buttonfecd2rId
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                    }
                }
            }
        }
    }
}
