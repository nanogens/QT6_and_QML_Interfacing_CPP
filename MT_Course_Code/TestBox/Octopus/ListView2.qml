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

    // Global property
    property string selection: ""

    // Your properties
    // cellA - Instrument
    property var model_Instrument_Device_ComboBox: ["Submersible_Mini_AZ", "Submersible_Mini_BZ", "Submersible_Mini_CZ"]
    property string current_Instrument_Device: "Submersible_Mini_AZ"


    // cellB - Communications - (to surface module)
    property var model_Communication_Connection_ComboBox: ["RS-485", "IrDA"]
    property string current_Communication_Connection: "RS-485"

    property var model_Communication_BaudRate_ComboBox: ["115200", "57600", "38400", "19200", "9600"]
    property string current_Communication_BaudRate: "115200"





    property var instrumentBatteryTypes: ["Lithium CR2", "Alkaline", "Rechargeable Li-Ion", "External"]
    property var samplingModes: ["Continuous", "Scheduled", "Event-Triggered"]
    property var samplingSamplingRate: ["1 sec", "5 sec", "30 sec", "1 min", "5 min", "15 min", "30 min", "1 hour"]
    property var durationTime: ["60 mins", "120 mins", "240 mins", "480 mins", "720 mins"]
    property var intervalTime: ["1 min", "5 mins", "10 mins", "15 mins", "30 mins"]
    property var activationMethod : ["Switch", "Time", "Trigger"]


    property string currentinstrumentBatteryTypes: "Alkaline"
    property string currentRecordingModes: "Continuous"
    property string currentSamplingRate: "1 sec"
    property string currentActivationMethod: "Switch"




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


                    // Row 1: Device
                    Label {
                        text: "  Device  . . . . . . . . . . . . ."
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
                        id: id_Instrument_Device_ComboBox
                        model: model_Instrument_Device_ComboBox
                        currentIndex: 0
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.current_Instrument_Device = currentText
                    }

                    // Row : Serial number
                    Label {
                        text: "  Serial Number  . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: "SZM-AZ-000001"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    TextField {
                        id: input_Instrument_SerialNumber
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        maximumLength: 13
                        onEditingFinished: console.log("Entered:", text)
                    }
                    /*
                    Label {
                        text: Instrument_SerialNumber
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                    }
                    */

                    // Row : Usage
                    Label {
                        text: "  Usage  . . . . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: "52 Hours"
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

                    // Spacer
                    Label { text: ""; Layout.row: 4; Layout.column: 0; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 4; Layout.column: 1; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 4; Layout.column: 2; Layout.fillHeight: true }

                    // Row : Buttons
                    Label { text: ""; Layout.row: 5; Layout.column: 0 }
                    Button {
                        id: button1Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                    }
                    Button {
                        id: button2Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 2                            
                        onClicked: {
                            var selection = "1";
                            var selected_Instrument_Device = current_Instrument_Device;
                            var selected_Instrument_Serial_Number = input_Instrument_SerialNumber.text;
                            var arr = [selection, selected_Instrument_Device, selected_Instrument_Serial_Number];
                            var obj = {
                                Selection : selection,
                                Instrument_Device: selected_Instrument_Device,
                                Instrument_Serial_Number: selected_Instrument_Serial_Number
                            };
                            CppClass.passFromQmlToCpp3(arr, obj);
                        }
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

                    // Row : Cable Link
                    Label {
                        text: "  Connection  . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "RS-485" //var_Communication_Connection
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: id_Communication_Connection_ComboBox
                        model: model_Communication_Connection_ComboBox
                        currentIndex: 0
                        implicitWidth: 200 * scaleFactor
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        onCurrentIndexChanged: current_Communication_Connection = model[currentIndex]
                    }

                    // Row : Baud Rate
                    Label {
                        text: "  Baud Rate  . . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: "115200" //var_Communication_BaudRate
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    ComboBox {
                        id: id_Communication_BaudRate_ComboBox
                        model: model_Communication_BaudRate_ComboBox
                        currentIndex: 0
                        implicitWidth: 200 * scaleFactor
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        onCurrentIndexChanged: current_Communication_BaudRate = model[currentIndex]
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
                    Label {
                        text: ""
                        Layout.row: 4
                        Layout.column: 0
                    }
                    Button {
                        id: button3Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 4
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
                        Layout.row: 4
                        Layout.column: 2
                        onClicked: {
                            var selected_Communication_Connection = current_Communication_Connection; //model_Communication_Connection_ComboBox.currentText;
                            var selected_Communication_BaudRate = current_Communication_BaudRate; //model_Communication_BaudRate_ComboBox.currentText;
                            var arr = [selected_Communication_Connection, selected_Communication_BaudRate];
                            var obj = {
                                Communication_Connection: selected_Communication_Connection,
                                Communication_BaudRate: selected_Communication_BaudRate
                            };
                            CppClass.passFromQmlToCpp3(arr, obj);
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
                        text: "  Battery Type  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "Lithium CR2" // var_Power_BatteryType
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
                        text: "  Duration  . ."
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

                    // Row : Buttons
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
                        id: button7Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                    }
                    Button {
                        id: button8Id
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

        // Cell E - Sampling (same structure)
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
                        text: "  Sampling Mode  . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: currentSamplingModes
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: samplingmodeComboBox
                        model: samplingModes
                        currentIndex: 0
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.samplingModes = currentText
                    }

                    // Row 2: Sampling Rate
                    Label {
                        text: "  Sampling Rate  . . . . . ."
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
                        model: samplingSamplingRate
                        currentIndex: 0
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.samplingSamplingRate = currentText
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
                        id: button9Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                    }
                    Button {
                        id: button10Id
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
                            text: "\nGeneral notes regarding the logger can go in here.  Identity, ownership, last battery change, anomalies and other info.  It serves to inform the user."
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
                            id: id_Notes_ScrollView
                            anchors.fill: parent
                            placeholderText: 'Multi-line text editor...'
                            selectByMouse: true
                            persistentSelection: true
                            wrapMode: Text.Wrap   // Ensures text wraps to next line
                            width: scrollView.width  // Match ScrollView's width
                            property int maxChars: 64
                            // Limit to 64 characters
                            Keys.onPressed: (event) =>
                            {
                                // Block new input if max length reached (but allow deletions/backspace)
                                if (text.length >= maxChars && event.key !== Qt.Key_Backspace && event.key !== Qt.Key_Delete)
                                {
                                    event.accepted = true;  // Ignore key press
                                }
                            }
                        }
                    }

                    Button {
                        id: button11Id
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
                        id: button12Id
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
                        id: button13d
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 4
                        Layout.column: 1
                    }
                    Button {
                        id: button14Id
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

        // cell
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
                        source: "qrc:/Octopus/images/J_Cloud.png"
                        Layout.preferredWidth: refSize
                        Layout.preferredHeight: refSize
                    }
                    Loader {
                        sourceComponent: bannerComponent
                        Layout.fillWidth: true
                        onLoaded: item.text = "Cloud"
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


                    // Row 1:
                    Label {
                        text: "  IP  . . . . . . . . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "192.168.0.105" // current_Cloud_IP
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    TextField {
                        id: id_Cloud_IP
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        maximumLength: 13
                        onEditingFinished: console.log("Entered:", text)
                    }

                    // Row 2:
                    Label {
                        text: "  Login  . . . . . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: "Manish" // current_Cloud_IP
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    TextField {
                        id: id_Cloud_Login
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        maximumLength: 13
                        onEditingFinished: console.log("Entered:", text)
                    }

                    // Row 3:
                    Label {
                        text: "  Password  . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: "Qwerty123" // current_Cloud_Password
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    TextField {
                        id: id_Cloud_Password
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        maximumLength: 13
                        onEditingFinished: console.log("Entered:", text)
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
                        id: button15Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                    }
                    Button {
                        id: button16Id
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
                        text: "  Some Stuff  . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "Stuff"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    TextField {
                        id: id_Miscelleneous_Stuff
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        maximumLength: 13
                        onEditingFinished: console.log("Entered:", text)
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
                        id: button17Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    Button {
                        id: button18Id
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



    Popup {
        id: normalPopup
        ColumnLayout {
            anchors.fill: parent
            Label {
                text: 'Normal Popup'
            }
            CheckBox {
                text: 'E-mail'
            }
            CheckBox {
                text: 'Calendar'
            }
            CheckBox {
                text: 'Contacts'
            }
        }
    }

    Popup {
        id: modalPopup
        modal: true
        ColumnLayout {
            anchors.fill: parent
            Label {
                text: 'Modal Popup'
            }
            CheckBox {
                text: 'E-mail'
            }
            CheckBox {
                text: 'Calendar'
            }
            CheckBox {
                text: 'Contacts'
            }
        }
    }

    Dialog {
        id: dialog
        title: 'Dialog'
        Label {
            text: 'The standard dialog.'
        }
        footer: DialogButtonBox {
            standardButtons: DialogButtonBox.Ok | DialogButtonBox.Cancel
        }
    }

}




