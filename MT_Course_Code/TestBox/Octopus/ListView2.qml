// MT reworked for _instrument, _start, _end.  Calendar shows up correctly


import QtQuick 2.15
import QtQuick.Controls
import QtQuick.Layouts 1.15
import QtCharts 2.15

import QtQuick.Controls.Basic
import QtQuick.Controls.Material

Item {
    id: listview2
    anchors.fill: parent  // Critical: Make Item fill the entire window

    // Define statements (must match Defines.h)
    readonly property int iNSTRUMENT: 0      // Cell A
    readonly property int cOMMUNICATIONS: 1  // B
    readonly property int pOWER: 2           // C
    readonly property int tIME: 3            // D
    readonly property int sAMPLING: 4        // E
    readonly property int aCTIVATION: 5      // F
    readonly property int nOTES: 6           // G
    readonly property int cLOUD: 7           // H
    readonly property int mISCELLENEOUS: 8   // I

    readonly property int aRRAY_SERIALNUMBER_MAX: 13
    readonly property int aRRAY_IP_MAX: 11
    readonly property int aRRAY_LOGIN_MAX: 13


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

    // cellC - Power
    property var model_Power_BatteryType_ComboBox: ["Internal_Lithium", "Internal_Alkaline", "External"]
    property string current_Power_BatteryType: "Internal_Alkaline"

    // cellD - Sampling
    property var model_Sampling_Mode_ComboBox: ["Scheduled_Continuous", "Scheduled_Fixed", "Event_Triggered"]
    property string current_Sampling_Mode: "Scheduled_Continuous"
    property var model_Sampling_Rate_ComboBox: ["1 sec", "5 sec", "30 sec", "1 min", "5 min", "15 min", "30 min", "1 hour"]
    property string current_Sampling_Rate: "1 sec"

    // cellH - Activation
    property var model_Activation_Event_ComboBox: ["Depth", "Temperature", "Ring Switch"]
    property string current_Activation_Power: "Depth"
    // we make sure its the same so we know the user has not set either -- which he has to do.
    property date startDateTime: new Date()
    property date endDateTime: startDateTime

    // cellD - Time
    property date syncDateTime : new Date()
    property bool syncEnabled : false
    property date instrumentDateTime : new Date()




    property var instrumentBatteryTypes: ["Lithium CR2", "Alkaline", "Rechargeable Li-Ion", "External"]
    property var samplingModes: ["Continuous", "Scheduled", "Event-Triggered"]
    property var samplingSamplingRate: ["1 sec", "5 sec", "30 sec", "1 min", "5 min", "15 min", "30 min", "1 hour"]
    property var durationTime: ["60 mins", "120 mins", "240 mins", "480 mins", "720 mins"]
    property var intervalTime: ["1 min", "5 mins", "10 mins", "15 mins", "30 mins"]
    property var activationMethod : ["Switch", "Time", "Trigger"]


    property string currentinstrumentBatteryTypes: "Alkaline"
    property string currentRecordingModes: "Continuous"

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

                    // Row 2 : Serial number
                    Label {
                        text: "  Serial Number  . . . . ."
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
                    TextField {
                        id: text_Instrument_SerialNumber
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        maximumLength: aRRAY_SERIALNUMBER_MAX
                        onEditingFinished: console.log("Entered:", text)
                        placeholderText: {
                            if (id_Instrument_Device_ComboBox.currentIndex === 0) {
                                return "SZM-AZ-XXXXXX"
                            } else if (id_Instrument_Device_ComboBox.currentIndex === 1) {
                                return "SZM-BZ-XXXXXX"
                            } else if (id_Instrument_Device_ComboBox.currentIndex === 2) {
                                return "SZM-CZ-XXXXXX"
                            } else {
                                return "XXX-XX-XXXXXX"
                            }
                        }
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
                    Label {
                        text: ""
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillWidth: true
                    }

                    // Row 4 : Spacer
                    Label { text: ""; Layout.row: 4; Layout.column: 0; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 4; Layout.column: 1; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 4; Layout.column: 2; Layout.fillHeight: true }

                    // Row 5 : Buttons
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
                            var selection = "0";
                            var selected_Instrument_Device = id_Instrument_Device_ComboBox.currentIndex;
                            var selected_Instrument_Serial_Number = text_Instrument_SerialNumber.text;
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
                        text: label_Communication_Connection
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
                        text: label_Communication_BaudRate
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
                            var selection = "1";
                            var selected_Communication_Connection = id_Communication_Connection_ComboBox.currentIndex;
                            var selected_Communication_BaudRate = id_Communication_BaudRate_ComboBox.currentIndex;
                            var arr = [selection, selected_Communication_Connection, selected_Communication_BaudRate];
                            var obj = {
                                Selection : selection,
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


                    // Row : Battery Type
                    Label {
                        text: "  Battery Type  . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: label_Power_BatteryType
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: id_Power_BatteryType_ComboBox
                        model: model_Power_BatteryType_ComboBox
                        currentIndex: 0
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.current_Power_BatteryType = currentText
                    }

                    // Row : Duration
                    Label {
                        text: "  Duration  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        text: label_Power_Duration // "28 days at current usage"
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

                    // Row : Power Remaining
                    Label {
                        text: "  Power Remaining  . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    Label {
                        text: label_Power_PowerRemaining
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

                    // Row 4: Empty spacer
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
                            var selection = "2";
                            var selected_Power_BatteryType = id_Power_BatteryType_ComboBox.currentIndex;
                            var arr = [selection, selected_Power_BatteryType];
                            var obj = {
                                Selection : selection,
                                Power_Connection: selected_Power_BatteryType
                            };
                            CppClass.passFromQmlToCpp3(arr, obj);
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

                    // Row 1 : Computer Time
                    Label {
                        text: "  Computer Time . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        id: label_Time_ComputerTime
                        text: (startDateTime ? startDateTime.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP") : "Not set")
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1; Layout.column: 1
                    }


                    // Row 2: Instrument Clock
                    Label {
                        text: "  Instrument Clock  . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 0
                    }
                    Label {
                        id: label_Time_SetDateTimeInstrument  // update for Set Date/Time (see block below) also occurs here
                        text: (syncDateTime ? syncDateTime.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP") : "Not set")
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2; Layout.column: 1
                    }
                    /*
                    Button {
                        text: "Sync to Computer Clock"
                        implicitHeight: 34 * scaleFactor
                        font.pixelSize: 14 * scaleFactor
                        Layout.row: 2; Layout.column: 2
                        Layout.fillWidth: true
                        onClicked:
                        {
                            syncDateTime = new Date();
                            label_Time_SetDateTimeInstrument.text = syncDateTime.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP");
                        }
                    }
                    */
                    CheckBox {
                        id: syncCheckBox
                        text: "Sync to Computer Clock"
                        implicitHeight: 34 * scaleFactor
                        font.pixelSize: 14 * scaleFactor
                        Layout.row: 2; Layout.column: 2
                        Layout.fillWidth: true
                        checked: syncEnabled  // Bind to the global property

                        onCheckedChanged: {
                            // Update the global property when user interacts with checkbox
                            syncEnabled = checked;

                            if (checked) {
                                syncDateTime = new Date();
                                label_Time_SetDateTimeInstrument.text = syncDateTime.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP");
                            }
                        }
                    }

                    // Row 3: Set Date/Time (Instrument)
                    Label {
                        text: ""
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 0
                    }
                    /*
                    Label {
                        id: label_Time_SetDateTimeInstrument
                        text: ""
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3; Layout.column: 1
                    }
                    */
                    Button {
                        text: "Set Date/Time (Instrument)"
                        implicitHeight: 34 * scaleFactor
                        font.pixelSize: 14 * scaleFactor
                        Layout.row: 3; Layout.column: 2
                        Layout.fillWidth: true
                        onClicked:
                        {
                            genericDateTimePopup.open()
                            genericDateTimePopup.mode = "Instrument"
                        }
                    }

                    // Row 4 : Empty spacer
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

                    // Row 5: Buttons
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
                        text: label_Sampling_Mode
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    ComboBox {
                        id: id_Sampling_Mode_ComboBox
                        model: model_Sampling_Mode_ComboBox
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
                        text: label_Sampling_Rate
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2
                        Layout.column: 1
                    }
                    ComboBox {
                        id: id_Sampling_Rate_ComboBox
                        model: model_Sampling_Rate_ComboBox
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
                        onClicked: {
                            var selection = "4";
                            var selected_Sampling_Mode = id_Sampling_Mode_ComboBox.currentIndex;
                            var selected_Sampling_Rate = id_Sampling_Rate_ComboBox.currentIndex;
                            var arr = [selection, selected_Sampling_Mode, selected_Sampling_Rate];
                            var obj = {
                                Selection : selection,
                                Sampling_Mode : selected_Sampling_Mode,
                                Sampling_Rate : selected_Sampling_Rate
                            };
                            CppClass.passFromQmlToCpp3(arr, obj);
                        }
                    }
                }
            }
        }

        // Cell F - Activation
        CellBox {
            id: cellF
            Layout.row: 1
            Layout.column: 2
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.minimumWidth: parent.width/3 - refSize/5
            Layout.preferredWidth: parent.width/3 - refSize/5
            Layout.preferredHeight: parent.height/3

            property string startDateTime: ""
            property string endDateTime: ""
            property var selectedEvents: []
            property date currentStartDate: new Date()
            property date currentEndDate: new Date()

            ColumnLayout {
                anchors.fill: parent
                spacing: 0

                // Header (unchanged)
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
                    Layout.topMargin: 5 * scaleFactor

                    // Row 0 - Headers
                    Label { text: ""; Layout.row: 0; Layout.column: 0; Layout.fillWidth: true }
                    Label {
                        text: "READ"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0; Layout.column: 1
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    Label {
                        text: "WRITE"
                        font.bold: true
                        color: "lightgreen"
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 0; Layout.column: 2
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Row 1: Scheduled Time - Start
                    Label {
                        text: "  Scheduled (Start) . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1; Layout.column: 0
                    }
                    Label {
                        id: label_Activation_ScheduledStart
                        text: (startDateTime ? startDateTime.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP") : "Not set")
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1; Layout.column: 1
                    }
                    Button {
                        text: "Set Date/Time (Start)"
                        implicitHeight: 34 * scaleFactor
                        font.pixelSize: 14 * scaleFactor
                        Layout.row: 1; Layout.column: 2
                        Layout.fillWidth: true
                        onClicked:
                        {
                            genericDateTimePopup.open()
                            genericDateTimePopup.mode = "Start"
                        }
                    }

                    // Row 2: Scheduled Time - End
                    Label {
                        text: "  Scheduled (End) . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2; Layout.column: 0
                    }
                    Label {
                        id: label_Activation_ScheduledEnd
                        text: (endDateTime ? endDateTime.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP") : "Not set")
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 2; Layout.column: 1
                    }
                    Button {
                        text: "Set Date/Time (End)"
                        implicitHeight: 34 * scaleFactor
                        font.pixelSize: 14 * scaleFactor
                        Layout.row: 2; Layout.column: 2
                        Layout.fillWidth: true
                        onClicked:
                        {
                            genericDateTimePopup.open()
                            genericDateTimePopup.mode = "End"
                        }
                    }

                    // Row 3: Event
                    Label {
                        text: "  Event . . . . . . . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3; Layout.column: 0
                    }
                    Label {
                        text: label_Activation_Event
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 1
                    }
                    ComboBox {
                        id: id_Activation_Event
                        model: model_Activation_Event_ComboBox
                        currentIndex: 0
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 3
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.activationEvent = currentText
                    }

                    // Row 4 : Event Trigger
                    Label {
                        text: "  Event Trigger . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 4
                        Layout.column: 0
                    }
                    Label {
                        text: text_Activation_EventTrigger
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 4
                        Layout.column: 1
                    }
                    ComboBox {
                        id: id_Activation_EventTrigger
                        //model: model_Activation_EventTrigger_ComboBox  // look at line below
                        model: 71 // Values from 0 to 70
                        currentIndex: 0
                        implicitHeight: 28 * scaleFactor
                        font.pixelSize: dropdownFontSize * scaleFactor
                        Layout.row: 4
                        Layout.column: 2
                        Layout.fillWidth: true
                        Layout.preferredWidth: 200 * scaleFactor
                        onCurrentIndexChanged: listview2.activationEventTrigger = currentText
                        popup.contentItem.implicitHeight: Math.min(200, popup.contentItem.contentHeight)  // to constrain texbox size
                    }

                    // Spacer rows and buttons (unchanged)
                    Label { text: ""; Layout.row: 5; Layout.column: 0; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 5; Layout.column: 1; Layout.fillHeight: true }
                    Label { text: ""; Layout.row: 5; Layout.column: 2; Layout.fillHeight: true }

                    Label { text: ""; Layout.row: 6; Layout.column: 0 }
                    Button {
                        id: button13d
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 6; Layout.column: 1
                    }
                    Button {
                        id: button14Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 6; Layout.column: 2
                        onClicked: {
                            var selection = "6";

                            // Convert Date objects to strings for transmission
                            var startDateTimeStr = startDateTime ?
                                        startDateTime.toISOString() : "";
                            var endDateTimeStr = endDateTime ?
                                        endDateTime.toISOString() : "";

                            // Or if you prefer timestamps (milliseconds since epoch)
                            var startTimestamp = startDateTime ?
                                        startDateTime.getTime() : 0;
                            var endTimestamp = endDateTime ?
                                        endDateTime.getTime() : 0;

                            // Send as array
                            var arr = [selection, startDateTimeStr, endDateTimeStr];

                            // Send as object with more detailed properties
                            var obj = {
                                Selection : selection,
                                StartDateTime: startDateTimeStr,
                                EndDateTime: endDateTimeStr,
                                StartTimestamp: startTimestamp,
                                EndTimestamp: endTimestamp,
                                StartYear: startDateTime ? startDateTime.getFullYear() : 0,
                                StartMonth: startDateTime ? startDateTime.getMonth() + 1 : 0, // Months are 0-indexed in JS
                                StartDay: startDateTime ? startDateTime.getDate() : 0,
                                StartHour: startDateTime ? startDateTime.getHours() : 0,
                                StartMinute: startDateTime ? startDateTime.getMinutes() : 0,
                                StartSecond: startDateTime ? startDateTime.getSeconds() : 0
                                // Add similar properties for end date if needed
                            };
                            CppClass.passFromQmlToCpp3(arr, obj);
                        }
                    }
                }
            }
        }

        // Cell G - Notes
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
                        id: scrollView  // ← Add this ID
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.preferredWidth: parent.width * 0.5
                        Layout.row: 1
                        Layout.column: 1
                        TextArea {
                            id: scroll_Notes_ScrollView
                            width: scrollView.width  // Match ScrollView's width
                            placeholderText: 'Multi-line text editor...'
                            selectByMouse: true
                            persistentSelection: true
                            wrapMode: Text.Wrap   // Ensures text wraps to next line

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
                            var selection = "5";
                            var selected_Notes_Text = id_Notes_Text_ComboBox.currentIndex;
                            var arr = [selection, selected_Notes_Text];
                            var obj = {
                                Selection : selection,
                                Sampling_Notes_Text : selected_Notes_Text,
                            };
                            CppClass.passFromQmlToCpp3(arr, obj);
                        }
                        Layout.alignment: Qt.AlignCenter
                    }
                }
            }
        }

        // Cell H - Cloud
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
                        maximumLength: aRRAY_IP_MAX
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
                        text: "Manish" // current_Cloud_Login
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
                        maximumLength: aRRAY_LOGIN_MAX
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
                        text: "Qwerty" // current_Cloud_Password
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

        // Cell I - Miscellenous
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
                        text: "  Some Stuff . . . . . . . . ."
                        font.bold: true
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 0
                    }
                    Label {
                        text: "ABC" // current_Miscellenous_SomeStuff
                        font.pixelSize: generalFontSize * scaleFactor
                        Layout.row: 1
                        Layout.column: 1
                    }
                    TextField {
                        id: input_Miscellenous_SomeStuff
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
                    Label { text: ""; Layout.row: 5; Layout.column: 0 }
                    Button {
                        id: button17Id
                        text: "Read Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 1
                    }
                    Button {
                        id: button18Id
                        text: "Write Instrument"
                        implicitHeight: 40 * scaleFactor
                        implicitWidth: 200 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        Layout.row: 5
                        Layout.column: 2
                        onClicked:
                        {
                            var selection = "8";
                            var selected_Miscelleneous_SomeStuff = input_Miscellenous_SomeStuff.text;
                            var arr = [selection, selected_Miscelleneous_SomeStuff];
                            var obj = {
                                Selection : selection,
                                Miscelleneous_SomeStuff: selected_Miscelleneous_SomeStuff
                            };
                            CppClass.passFromQmlToCpp3(arr, obj);
                        }
                    }
                }
            }
        }

        // Used in Cell D (Time - Instrument) and Cell F (Activation - Start, End)
        Popup {
            id: genericDateTimePopup
            modal: true
            focus: true
            closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
            width: 600 * scaleFactor
            height: 520 * scaleFactor
            padding: 10 * scaleFactor
            x: (parent.width - width) / 2
            y: (parent.height - height) / 2

            // Store the currently selected date as a property
            property date currentSelectedDate: new Date()
            property string mode: "Instrument" // Add this property

            ColumnLayout {
                anchors.fill: parent
                spacing: 5 * scaleFactor

                // Header with current selection - FIXED
                Label {
                    text: "Select " + genericDateTimePopup.mode + " Date"
                    font.bold: true
                    font.pixelSize: 18 * scaleFactor
                    Layout.alignment: Qt.AlignHCenter
                    Layout.bottomMargin: 5 * scaleFactor
                    color: "lightgreen"
                }

                // Calendar navigation - FIXED references
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 5 * scaleFactor

                    Button {
                        text: "Previous"
                        implicitWidth: 120 * scaleFactor
                        implicitHeight: 40 * scaleFactor
                        onClicked: {
                            var newDate = new Date(datesGrid.currentYear, datesGrid.currentMonth - 1, 1)
                            datesGrid.currentMonth = newDate.getMonth()
                            datesGrid.currentYear = newDate.getFullYear()
                            datesGrid.updateCalendar()
                        }
                    }

                    Label {
                        text: Qt.locale().monthName(datesGrid.currentMonth) + " " + datesGrid.currentYear
                        font.bold: true
                        font.pixelSize: 15 * scaleFactor
                        Layout.fillWidth: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    Button {
                        text: "Next"
                        implicitWidth: 120 * scaleFactor
                        implicitHeight: 40 * scaleFactor
                        onClicked: {
                            var newDate = new Date(datesGrid.currentYear, datesGrid.currentMonth + 1, 1)
                            datesGrid.currentMonth = newDate.getMonth()
                            datesGrid.currentYear = newDate.getFullYear()
                            datesGrid.updateCalendar()
                        }
                    }
                }

                // Calendar view - FIXED references
                Column {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 250 * scaleFactor
                    spacing: 0

                    // Day of week headers
                    Row {
                        width: parent.width
                        height: 30 * scaleFactor
                        spacing: 0

                        Repeater {
                            model: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                            Label {
                                width: parent.width / 7
                                height: parent.height
                                text: modelData
                                font.bold: true
                                font.pixelSize: 12 * scaleFactor
                                horizontalAlignment: Text.AlignHCenter
                                verticalAlignment: Text.AlignVCenter
                            }
                        }
                    }

                    // Dates grid - FIXED references
                    Grid {
                        id: datesGrid
                        width: parent.width
                        height: parent.height - 30 * scaleFactor
                        columns: 7
                        rows: 6
                        spacing: 0

                        property int currentYear: genericDateTimePopup.currentSelectedDate.getFullYear()
                        property int currentMonth: genericDateTimePopup.currentSelectedDate.getMonth()
                        property int selectedDay: genericDateTimePopup.currentSelectedDate.getDate()
                        property var calendarDays: []
                        property int visibleRows: 5

                        Repeater {
                            model: datesGrid.visibleRows * 7

                            Rectangle {
                                width: datesGrid.width / 7
                                height: datesGrid.height / datesGrid.visibleRows
                                property int day: index < datesGrid.calendarDays.length ? datesGrid.calendarDays[index] : 0
                                property bool isCurrentMonth: day > 0
                                property bool isSelected: isCurrentMonth && day === datesGrid.selectedDay
                                property bool isToday: isCurrentMonth && day === new Date().getDate() &&
                                                       datesGrid.currentMonth === new Date().getMonth() &&
                                                       datesGrid.currentYear === new Date().getFullYear()

                                color: isSelected ? Material.primary : (isToday ? "#e3f2fd" : "transparent")
                                border.color: "#eeeeee"
                                border.width: 1

                                Label {
                                    anchors.centerIn: parent
                                    text: isCurrentMonth ? day : ""
                                    font.pixelSize: 14 * scaleFactor
                                    font.bold: isSelected || isToday
                                    color: isSelected ? "white" : (isCurrentMonth ? "black" : "#cccccc")
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    enabled: isCurrentMonth
                                    onClicked: {
                                        datesGrid.selectedDay = day
                                        genericDateTimePopup.currentSelectedDate =
                                                new Date(datesGrid.currentYear,
                                                         datesGrid.currentMonth,
                                                         day)
                                    }
                                }
                            }
                        }

                        function updateCalendar() {
                            var daysArray = []
                            var firstOfMonth = new Date(currentYear, currentMonth, 1)
                            var lastOfMonth = new Date(currentYear, currentMonth + 1, 0)
                            var firstDay = firstOfMonth.getDay()
                            var daysInMonth = lastOfMonth.getDate()

                            for (var i = 0; i < firstDay; i++) {
                                daysArray.push(0)
                            }

                            for (var j = 1; j <= daysInMonth; j++) {
                                daysArray.push(j)
                            }

                            var totalCellsNeeded = firstDay + daysInMonth
                            var rowsNeeded = Math.ceil(totalCellsNeeded / 7)
                            visibleRows = Math.max(5, rowsNeeded)

                            var totalCells = visibleRows * 7
                            while (daysArray.length < totalCells) {
                                daysArray.push(0)
                            }

                            calendarDays = daysArray
                        }

                        Component.onCompleted: {
                            currentYear = new Date().getFullYear()
                            currentMonth = new Date().getMonth()
                            selectedDay = new Date().getDate()
                            updateCalendar()
                        }
                    }
                }

                // Time selection with AM/PM
                GridLayout {
                    columns: 8
                    rowSpacing: 5 * scaleFactor
                    columnSpacing: 5 * scaleFactor
                    Layout.fillWidth: true

                    Label {
                        text: ""
                        font.pixelSize: 6 * scaleFactor
                        font.bold: true
                        Layout.row: 0; Layout.column: 2
                        Layout.columnSpan: 4
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Select " + genericDateTimePopup.mode + " Time" // FIXED
                        font.pixelSize: 18 * scaleFactor
                        font.bold: true
                        Layout.row: 1; Layout.column: 2
                        Layout.columnSpan: 4
                        Layout.alignment: Qt.AlignHCenter
                        color: "lightgreen"
                    }

                    Label {
                        text: ""
                        font.pixelSize: 6 * scaleFactor
                        font.bold: true
                        Layout.row: 2; Layout.column: 2
                        Layout.columnSpan: 4
                        Layout.alignment: Qt.AlignHCenter
                    }

                    Label {
                        text: "Hour:"
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 0
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                    SpinBox {
                        id: hourSpin
                        from: 1; to: 12; value: (genericDateTimePopup.currentSelectedDate.getHours() % 12) || 12 // FIXED
                        editable: true
                        implicitHeight: 30 * scaleFactor
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 1
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Minute:"
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 2
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                    SpinBox {
                        id: minuteSpin
                        from: 0; to: 59; value: genericDateTimePopup.currentSelectedDate.getMinutes() // FIXED
                        editable: true
                        implicitHeight: 30 * scaleFactor
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 3
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "Second:"
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 4
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                    SpinBox {
                        id: secondSpin
                        from: 0; to: 59; value: genericDateTimePopup.currentSelectedDate.getSeconds() // FIXED
                        editable: true
                        implicitHeight: 30 * scaleFactor
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 5
                        Layout.fillWidth: true
                    }

                    Label {
                        text: "AM/PM:"
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 6
                        Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    }
                    ComboBox {
                        id: amPmCombo
                        model: ["AM", "PM"]
                        currentIndex: genericDateTimePopup.currentSelectedDate.getHours() >= 12 ? 1 : 0 // FIXED
                        implicitHeight: 30 * scaleFactor
                        font.pixelSize: 12 * scaleFactor
                        Layout.row: 3; Layout.column: 7
                        Layout.fillWidth: true
                    }
                }

                // Selected date display
                Label {
                    text: "Selected: " + genericDateTimePopup.currentSelectedDate.toLocaleDateString(Qt.locale(), "yyyy-MM-dd") + // FIXED
                          " " + getFormattedTime()
                    font.pixelSize: 12 * scaleFactor
                    Layout.alignment: Qt.AlignHCenter
                    Layout.topMargin: 5 * scaleFactor

                    function getFormattedTime() {
                        var hour = hourSpin.value
                        var minute = minuteSpin.value.toString().padStart(2, '0')
                        var second = secondSpin.value.toString().padStart(2, '0')
                        var ampm = amPmCombo.currentText
                        return hour + ":" + minute + ":" + second + " " + ampm
                    }
                }

                // Buttons Row - Centered - FIXED
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 15 * scaleFactor
                    Layout.topMargin: 0 * scaleFactor

                    Button {
                        text: "Cancel"
                        implicitWidth: 100 * scaleFactor
                        implicitHeight: 40 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        onClicked: genericDateTimePopup.close()
                    }

                    Button {
                        text: "Set " + genericDateTimePopup.mode + " Date and Time" // FIXED
                        implicitWidth: 230 * scaleFactor
                        implicitHeight: 40 * scaleFactor
                        font.pixelSize: 16 * scaleFactor
                        onClicked: {
                            var hour24 = hourSpin.value
                            if (amPmCombo.currentIndex === 1 && hour24 < 12) {
                                hour24 += 12
                            } else if (amPmCombo.currentIndex === 0 && hour24 === 12) {
                                hour24 = 0
                            }

                            var newDate = new Date(datesGrid.currentYear, datesGrid.currentMonth, datesGrid.selectedDay,
                                                   hour24, minuteSpin.value, secondSpin.value)

                            // Update the appropriate date property based on mode
                            if (genericDateTimePopup.mode === "Instrument") {
                                instrumentDateTime = newDate
                                label_Time_SetDateTimeInstrument.text = newDate.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP")
                            } else if (genericDateTimePopup.mode === "Start") {
                                startDateTime = newDate
                                label_Activation_ScheduledStart.text = newDate.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP")
                            } else if (genericDateTimePopup.mode === "End") {
                                endDateTime = newDate
                                label_Activation_ScheduledEnd.text = newDate.toLocaleString(Qt.locale(), "yyyy-MM-dd hh:mm:ss AP")
                            }

                            // set the "Sync to Computer Clock" checkbox to false
                            // since we are using a custom time (i.e. Set Date/Time (Instrument))
                            syncEnabled = false;

                            console.log(genericDateTimePopup.mode + " date/time set to:", newDate)
                            genericDateTimePopup.close() // FIXED: was genericTimePopup
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
    }
}




