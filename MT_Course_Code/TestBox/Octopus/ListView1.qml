import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15

Item {
    id: root
    //width: 1920
    //height: 1080

    property var supportedInstruments: ["RBR Concerto", "Van Essen TD-Diver"]
    property var batteryTypes: ["Alkaline", "Lithium", "Rechargeable Li-Ion", "External"]
    property var commModes: ["RS-232", "RS-485", "IrDA", "Wi-Fi", "Ethernet"]
    property var recordingModes: ["Continuous", "Scheduled", "Event-Triggered"]
    property var sampleIntervals: ["1 sec", "5 sec", "30 sec", "1 min", "5 min", "15 min", "30 min", "1 hour"]
    property string currentInstrument: "RBR Concerto"

    // Sample data for demonstration
    ListModel {
        id: recordModel
        ListElement { startTime: "2023-06-01 08:30"; duration: "36 hours"; samples: 4320; notes: "Coastal survey" }
        ListElement { startTime: "2023-06-03 14:00"; duration: "24 hours"; samples: 2880; notes: "Depth calibration" }
    }

    GridLayout {
        anchors.fill: parent
        columns: 1
        rows: 3
        rowSpacing: 5
        columnSpacing: 0

        // Row 1: Tab Bar
        TabBar {
            id: mainTabBar
            Layout.fillWidth: true
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignTop

            TabButton {
                text: "Configuration"
                width: implicitWidth
            }
            TabButton {
                text: "Instrument Status"
                width: implicitWidth
            }
            TabButton {
                text: "Data Operations"
                width: implicitWidth
            }
            TabButton {
                text: "Visualization"
                width: implicitWidth
            }
        }

        // Row 2: Tab Content
        StackLayout {
            id: contentStack
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: mainTabBar.currentIndex

            // CONFIGURATION TAB
            ScrollView {
                clip: true
                GridLayout {
                    width: root.width - 30
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 15

                    GroupBox {
                        title: "Instrument Selection"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            Label { text: "Instrument Type:" }
                            ComboBox {
                                model: supportedInstruments
                                currentIndex: 0
                                onCurrentIndexChanged: root.currentInstrument = currentText
                            }

                            Label { text: "Serial Number:" }
                            TextField { placeholderText: "Enter instrument S/N" }
                        }
                    }

                    GroupBox {
                        title: "Power Configuration"
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            Label { text: "Battery Type:" }
                            ComboBox { model: batteryTypes }

                            Label { text: "External Battery:" }
                            CheckBox { checked: false }

                            Label { text: "Battery Saver Mode:" }
                            CheckBox { checked: true }
                        }
                    }

                    GroupBox {
                        title: "Time Settings"
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            Label { text: "Instrument Clock:" }
                            TextField { text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss") }

                            Label { text: "Sync with Computer:" }
                            Button { text: "Synchronize Now" }

                            Label { text: "Time Zone:" }
                            ComboBox { model: ["UTC", "Local Time"] }
                        }
                    }

                    GroupBox {
                        title: "Recording Settings"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            Label { text: "Recording Mode:" }
                            ComboBox { model: recordingModes }

                            Label { text: "Sampling Interval:" }
                            ComboBox { model: sampleIntervals }

                            Label { text: "Start Time:" }
                            TextField { placeholderText: "YYYY-MM-DD HH:MM" }

                            Label { text: "End Time:" }
                            TextField { placeholderText: "YYYY-MM-DD HH:MM" }

                            Label {
                                text: "Depth Threshold:"
                                visible: root.currentInstrument === "RBR Concerto"
                            }
                            TextField {
                                placeholderText: "Trigger depth (m)"
                                visible: root.currentInstrument === "RBR Concerto"
                            }

                            Label { text: "Notes:" }
                            TextArea {
                                placeholderText: "Deployment notes"
                                Layout.rowSpan: 2
                                implicitHeight: 80
                            }
                        }
                    }

                    GroupBox {
                        title: "Communication Setup"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            Label { text: "Primary Mode:" }
                            ComboBox { model: commModes }

                            Label { text: "Port Settings:" }
                            ComboBox { model: ["COM1", "COM2", "COM3", "USB"] }

                            Label { text: "Baud Rate:" }
                            ComboBox { model: ["9600", "19200", "38400", "57600", "115200"] }

                            Label { text: "Wi-Fi SSID:" }
                            TextField { placeholderText: "Network name" }

                            Label { text: "Password:" }
                            TextField { echoMode: TextInput.Password }

                            Label { text: "Cloud Server:" }
                            TextField { placeholderText: "api.aquamonitor.com" }

                            Label { text: "Username:" }
                            TextField { placeholderText: "Cloud username" }

                            Label { text: "Password:" }
                            TextField { placeholderText: "Cloud password"; echoMode: TextInput.Password }
                        }
                    }

                    GroupBox {
                        title: "External Sensors"
                        Layout.columnSpan: 2
                        visible: root.currentInstrument === "RBR Concerto"
                        GridLayout {
                            columns: 4
                            CheckBox { text: "Oxygen Sensor"; checked: false }
                            CheckBox { text: "pH Sensor"; checked: false }
                            CheckBox { text: "Turbidity Sensor"; checked: false }
                            CheckBox { text: "Fluorescence Sensor"; checked: false }
                        }
                    }

                    GroupBox {
                        title: "Memory Management"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 2
                            Label { text: "Total Memory:" }
                            Label { text: "4,000,000 samples" }

                            Label { text: "Available:" }
                            Label { text: "2,500,000 samples" }

                            Label { text: "Storage Format:" }
                            ComboBox { model: ["Compressed Binary", "Raw Binary", "CSV"] }
                        }
                    }

                    RowLayout {
                        Layout.columnSpan: 2
                        Layout.alignment: Qt.AlignRight
                        Button { text: "Load Defaults"; highlighted: true }
                        Button { text: "Save Configuration"; highlighted: true }
                        Button {
                            text: "Deploy Settings"
                            highlighted: true
                            palette.button: "green"
                        }
                    }
                }
            }

            // STATUS TAB
            ScrollView {
                clip: true
                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 15

                    GroupBox {
                        title: "Instrument Status"
                        Layout.columnSpan: 2
                        GridLayout {
                            columns: 2
                            Label { text: "Model:"; font.bold: true }
                            Label {
                                text: root.currentInstrument === "RBR Concerto" ?
                                    "RBR Concerto CTD" : "Van Essen TD-Diver"
                            }

                            Label { text: "Firmware:"; font.bold: true }
                            Label { text: "v2.1.8" }

                            Label { text: "Last Communication:"; font.bold: true }
                            Label { text: Qt.formatDateTime(new Date(), "yyyy-MM-dd HH:mm:ss") }

                            Label { text: "Current State:"; font.bold: true }
                            Label { text: "Recording"; color: "green" }
                        }
                    }

                    GroupBox {
                        title: "Power Status"
                        Layout.fillWidth: true
                        ColumnLayout {
                            ProgressBar {
                                value: 0.75
                                Layout.fillWidth: true
                            }
                            Label { text: "75% Remaining"; horizontalAlignment: Text.AlignHCenter }

                            Label { text: "Estimated Duration:"; font.bold: true }
                            Label { text: "28 days at current usage" }
                        }
                    }

                    GroupBox {
                        title: "Memory Status"
                        Layout.fillWidth: true
                        ColumnLayout {
                            ProgressBar {
                                value: 0.35
                                Layout.fillWidth: true
                            }
                            Label { text: "35% Used"; horizontalAlignment: Text.AlignHCenter }

                            Label { text: "Available Storage:"; font.bold: true }
                            Label { text: "1,250,000 samples" }
                        }
                    }

                    GroupBox {
                        title: "Recording Status"
                        Layout.columnSpan: 2
                        GridLayout {
                            columns: 2
                            Label { text: "Start Time:"; font.bold: true }
                            Label { text: "2023-06-10 14:30:00" }

                            Label { text: "Elapsed Time:"; font.bold: true }
                            Label { text: "36 hours, 22 minutes" }

                            Label { text: "Samples Collected:"; font.bold: true }
                            Label { text: "4,320" }

                            Label { text: "Next Sample:"; font.bold: true }
                            Label { text: "2023-06-12 03:00:00" }
                        }
                    }

                    GroupBox {
                        title: "Sensor Status"
                        Layout.columnSpan: 2
                        GridLayout {
                            columns: 4
                            Label { text: "Sensor"; font.bold: true }
                            Label { text: "Status"; font.bold: true }
                            Label { text: "Current Value"; font.bold: true }
                            Label { text: "Calibration"; font.bold: true }

                            Label { text: "Pressure" }
                            Label { text: "OK"; color: "green" }
                            Label { text: "15.62 dbar" }
                            Label { text: "2023-05-15" }

                            Label { text: "Temperature" }
                            Label { text: "OK"; color: "green" }
                            Label { text: "18.7 °C" }
                            Label { text: "2023-05-15" }

                            Label {
                                text: "Conductivity"
                                visible: root.currentInstrument === "RBR Concerto"
                            }
                            Label {
                                text: "OK"; color: "green"
                                visible: root.currentInstrument === "RBR Concerto"
                            }
                            Label {
                                text: "42.1 mS/cm"
                                visible: root.currentInstrument === "RBR Concerto"
                            }
                            Label {
                                text: "2023-05-15"
                                visible: root.currentInstrument === "RBR Concerto"
                            }
                        }
                    }
                }
            }

            // DATA OPERATIONS TAB
            ScrollView {
                clip: true
                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 15

                    GroupBox {
                        title: "Data Records"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.preferredHeight: 300
                        ColumnLayout {
                            anchors.fill: parent
                            TableView {
                                id: recordTable
                                model: recordModel
                                Layout.fillWidth: true
                                Layout.fillHeight: true
                                clip: true

                                delegate: RowLayout {
                                    Label { text: startTime; Layout.preferredWidth: 150 }
                                    Label { text: duration; Layout.preferredWidth: 100 }
                                    Label { text: samples; Layout.preferredWidth: 80 }
                                    Label { text: notes; Layout.fillWidth: true }
                                }

                                ScrollBar.vertical: ScrollBar {}
                            }

                            RowLayout {
                                Button { text: "Retrieve All Data" }
                                Button { text: "Download Selected" }
                                Button { text: "Erase Selected"; palette.button: "red" }
                                Button { text: "Erase All Records"; palette.button: "red" }
                                Item { Layout.fillWidth: true }
                                Button { text: "Add Note"; icon.source: "qrc:/icons/note.svg" }
                            }
                        }
                    }

                    GroupBox {
                        title: "Data Export"
                        Layout.fillWidth: true
                        ColumnLayout {
                            RadioButton { text: "CSV Format"; checked: true }
                            RadioButton { text: "NetCDF Format" }
                            RadioButton { text: "Binary Format" }
                            CheckBox { text: "Include Metadata" }
                            Button { text: "Export Selected"; Layout.fillWidth: true }
                        }
                    }

                    GroupBox {
                        title: "Data Import"
                        Layout.fillWidth: true
                        ColumnLayout {
                            Button { text: "Import from File"; Layout.fillWidth: true }
                            Button { text: "Import from Cloud"; Layout.fillWidth: true }
                            CheckBox { text: "Merge with existing data" }
                        }
                    }

                    GroupBox {
                        title: "Record Notes"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        ColumnLayout {
                            TextArea {
                                placeholderText: "Add notes about this dataset"
                                Layout.fillWidth: true
                                Layout.preferredHeight: 100
                            }
                            Button {
                                text: "Save Notes"
                                Layout.alignment: Qt.AlignRight
                            }
                        }
                    }
                }
            }

            // VISUALIZATION TAB
            ScrollView {
                clip: true
                GridLayout {
                    columns: 2
                    columnSpacing: 20
                    rowSpacing: 15

                    GroupBox {
                        title: "Visualization Controls"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        GridLayout {
                            columns: 4
                            Label { text: "Dataset:" }
                            ComboBox {
                                model: ["Current Deployment", "2023-06-01 Survey", "2023-05-20 Calibration"]
                                Layout.preferredWidth: 200
                            }

                            Label { text: "Parameter:" }
                            ComboBox {
                                model: root.currentInstrument === "RBR Concerto" ?
                                    ["Depth", "Temperature", "Conductivity", "Salinity"] :
                                    ["Depth", "Temperature"]
                                Layout.preferredWidth: 150
                            }

                            Label { text: "Time Range:" }
                            ComboBox {
                                model: ["Full Deployment", "Last 24h", "Custom"]
                                Layout.preferredWidth: 150
                            }

                            Button { text: "Refresh Data" }
                        }
                    }

                    GroupBox {
                        title: "Data Visualization"
                        Layout.columnSpan: 2
                        Layout.fillWidth: true
                        Layout.preferredHeight: 400
                        ChartView {
                            id: chart
                            anchors.fill: parent
                            antialiasing: true
                            legend.visible: true
                            theme: ChartView.ChartThemeLight

                            DateTimeAxis {
                                id: axisX
                                format: "MMM dd hh:mm"
                                titleText: "Time"
                            }

                            ValueAxis {
                                id: axisY
                                min: 0
                                max: 100
                                titleText: "Depth (m)"
                            }

                            LineSeries {
                                name: "Depth"
                                axisX: axisX
                                axisY: axisY
                                XYPoint { x: new Date('2023-06-10T14:30:00').getTime(); y: 5 }
                                XYPoint { x: new Date('2023-06-10T15:00:00').getTime(); y: 12 }
                                XYPoint { x: new Date('2023-06-10T15:30:00').getTime(); y: 8 }
                                XYPoint { x: new Date('2023-06-10T16:00:00').getTime(); y: 15 }
                            }

                            LineSeries {
                                name: "Temperature"
                                axisX: axisX
                                axisYRight: ValueAxis {
                                    //orientation: Qt.AlignRight
                                    min: 10
                                    max: 30
                                    titleText: "Temp (°C)"
                                }
                                XYPoint { x: new Date('2023-06-10T14:30:00').getTime(); y: 18.2 }
                                XYPoint { x: new Date('2023-06-10T15:00:00').getTime(); y: 17.8 }
                                XYPoint { x: new Date('2023-06-10T15:30:00').getTime(); y: 17.5 }
                                XYPoint { x: new Date('2023-06-10T16:00:00').getTime(); y: 16.9 }
                            }
                        }
                    }

                    GroupBox {
                        title: "Depth Profile"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        ChartView {
                            anchors.fill: parent
                            antialiasing: true
                            BarSeries {
                                axisY: BarCategoryAxis { categories: ["00:00", "04:00", "08:00", "12:00", "16:00", "20:00"] }
                                BarSet { label: "Depth"; values: [5, 12, 8, 15, 10, 7] }
                            }
                        }
                    }

                    GroupBox {
                        title: "Temperature Profile"
                        Layout.fillWidth: true
                        Layout.preferredHeight: 200
                        ChartView {
                            anchors.fill: parent
                            antialiasing: true
                            LineSeries {
                                name: "Temperature"
                                XYPoint { x: 0; y: 18.2 }
                                XYPoint { x: 4; y: 17.8 }
                                XYPoint { x: 8; y: 17.5 }
                                XYPoint { x: 12; y: 18.1 }
                                XYPoint { x: 16; y: 19.2 }
                                XYPoint { x: 20; y: 18.5 }
                            }
                        }
                    }

                    GroupBox {
                        title: "Export Visualization"
                        Layout.columnSpan: 2
                        RowLayout {
                            Button { text: "Save as PNG" }
                            Button { text: "Save as PDF" }
                            Button { text: "Copy to Clipboard" }
                            CheckBox { text: "Include Annotations" }
                        }
                    }
                }
            }
        }

        // Row 3: Status Bar
        ToolBar
        {
            Layout.fillWidth: true
            Layout.preferredHeight: 25
            Label {
                anchors.fill: parent
                text: {
                    if(root.currentInstrument === "RBR Concerto")
                        return "Connected to RBR Concerto | Battery: 75% | Memory: 35% used | Sensors: 3 active";
                    else
                        return "Connected to Van Essen TD-Diver | Battery: 75% | Memory: 35% used | Sensors: 2 active";
                }
                elide: Text.ElideMiddle
                verticalAlignment: Text.AlignVCenter
                padding: 5
            }
        }
    }
}

