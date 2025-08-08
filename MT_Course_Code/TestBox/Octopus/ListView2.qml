import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import QtCharts 2.15

Item {
    id: listview2

    // Component must be declared inside a parent item
    Component {
        id: bannerComponent
        Rectangle {
            property alias text: bannerText.text
            width: parent.width
            height: 30
            color: Qt.rgba(1, 0.75, 0, 1)

            Text {
                id: bannerText
                anchors {
                    left: parent.left
                    verticalCenter: parent.verticalCenter
                    leftMargin: 5
                }
                color: "black"
                font {
                    bold: true
                    pixelSize: 14
                    family: "Arial"
                }
            }
        }
    }

    // Your properties
    property var instrumentModelTypes: ["Submersible_Mini_AZ", "Submersible_Mini_BZ", "Submersible_Mini_CZ"]
    property var instrumentBatteryTypes: ["Alkaline", "Lithium", "Rechargeable Li-Ion", "External"]
    property var recordingModes: ["Continuous", "Scheduled", "Event-Triggered"]
    property var samplingRate: ["1 sec", "5 sec", "30 sec", "1 min", "5 min", "15 min", "30 min", "1 hour"]
    property var modeTypes: ["Continuous", "Average", "Burst", "Directional"]
    property var durationTime: ["60 mins", "120 mins", "240 mins", "480 mins", "720 mins"]
    property var intervalTime: ["1 min", "5 mins", "10 mins", "15 mins", "30 mins"]



    property string currentinstrumentModelTypes: "Submersible_Mini_AZ"
    property string currentinstrumentBatteryTypes: "Alkaline"

    GridLayout
    {
        anchors.fill: parent
        columns: 3
        rows: 3
        rowSpacing: 15
        columnSpacing: 15
        width: (parent.width)

        // First Column
        CellBox
        {
            id: cellA
            Layout.fillHeight: true
            title: 'A'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Instrument"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 3
                            rowSpacing: 5
                            columnSpacing: 12

                            // READ / WRITE row
                            Label { text: ""; font.bold: true }
                            Label { text: "READ"; font.bold: true; color: "lightgreen"}
                            Label { text: "WRITE"; font.bold: true; color: "lightgreen"; Layout.fillWidth: true }

                            // Model row
                            Label { text: "  Model  . . . . . . . . . . . . ."; font.bold: true }
                            Label { text: "Submersible Mini AZ"}
                            ComboBox
                            {
                                id: modelComboBox
                                model: instrumentModelTypes
                                currentIndex: 0
                                implicitWidth: 200
                                implicitHeight: 26
                                font.pixelSize: 12
                                onCurrentIndexChanged: listview2.currentinstrumentModelTypes = currentText
                            }

                            // Battery row
                            Label { text: "  Battery  . . . . . . . . . . . ."; font.bold: true }
                            Label { text: "Lithium CR2"}
                            ComboBox
                            {
                                id: batteryComboBox
                                model: instrumentBatteryTypes
                                currentIndex: 0
                                implicitWidth: 200
                                implicitHeight: 26
                                font.pixelSize: 12
                                onCurrentIndexChanged: listview2.currentinstrumentBatteryTypes = currentText
                            }

                            // Last Communication row
                            Label { text: "  Last communication"; font.bold: true }
                            Label { text: "0 Days Ago"}
                            Label { text: Instrument_lastCommunication; Layout.fillWidth: true }

                            // Current state row
                            Label { text: "  Serial Number  . . . . ."; font.bold: true }
                            Label { text: "SZM-AZ-000001"}
                            Label { text: Instrument_serialNumber; Layout.fillWidth: true }

                            // Read/Set buttons
                            Label { text: ""; font.bold: true }
                            Button
                            {
                                id: button1Id
                                font.pixelSize: 16
                                text: "Read Instrument"
                                implicitHeight: 40
                                implicitWidth: 200

                                onClicked:
                                {
                                    var data = CppClass.getVariantListFromCpp()
                                    data.forEach(function(element)
                                    {
                                        console.log("Array item: " + element)
                                    })
                                }
                            }

                            Button
                            {
                                id: button2Id
                                //implicitHeight: 30
                                font.pixelSize: 16
                                text: "Write Instrument"
                                implicitHeight: 40
                                implicitWidth: 200
                                onClicked:
                                {

                                    /*
                                    var arr = ['Africa','Asia',"Europe","North America","South America","Oceania","Antarctica"]
                                    var obj =
                                    {
                                        firstName:"John",
                                        lastName:"Doe",
                                        location:"Earth"
                                    }

                                    CppClass.passFromQmlToCpp(arr,obj);
                                    */

                                    // Get the selected values from the ComboBoxes
                                    var selectedModel = modelComboBox.currentText;
                                    var selectedBattery = batteryComboBox.currentText;

                                    console.log("Selected Model:", selectedModel);
                                    console.log("Selected Battery:", selectedBattery);

                                    // You can then pass these values to your C++ function
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

                Item { Layout.fillHeight: true }
            }
        }

        CellBox
        {
            id: cellB
            Layout.fillHeight: true
            title: 'B'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Communications (Wired)"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 5
                            columnSpacing: 10

                            Label { text: ""; font.bold: true }
                            Label { text: ""; Layout.fillWidth: true }

                            Label { text: "  Wired Connection:"; font.bold: true }
                            Label { text: Communications_wiredconnection; Layout.fillWidth: true }

                            Label { text: "  Port:"; font.bold: true }
                            Label { text: Communications_port; Layout.fillWidth: true }

                            Label { text: "  Baud Rate:"; font.bold: true }
                            Label { text: Communications_baudrate; Layout.fillWidth: true }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }

        // Continue for C-F...
        CellBox
        {
            id: cellC
            Layout.fillHeight: true
            title: 'C'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Power Configuration"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 5
                            columnSpacing: 10

                            Label { text: ""; font.bold: true }
                            Label { text: ""; Layout.fillWidth: true }

                            Label { text: "  Estimated Duration:"; font.bold: true }
                            Label { text: "  28 days at current usage" }

                            Label { text: "  Percentage Power Remaining:"; font.bold: true }
                            Label { text: "  75% Remaining"; horizontalAlignment: Text.AlignHCenter; color:"lightgreen" }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }


        CellBox
        {
            id: cellD
            Layout.fillHeight: true
            title: 'D'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Time Synchronization"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 5
                            columnSpacing: 10

                            Label { text: ""; font.bold: true }
                            Label { text: ""; Layout.fillWidth: true }

                            Label { text: "  Instrument Clock:"; font.bold: true }
                            Label { text: Time_instrumentclock; Layout.fillWidth: true }

                            Label { text: "  Sync with Computer:"; font.bold: true }
                            Label { text: Time_syncwithcomputer; Layout.fillWidth: true }

                            Label { text: "  Time Zone:"; font.bold: true }
                            Label { text: Time_timezone; Layout.fillWidth: true }
                        }
                    }
                }
                Item { Layout.fillHeight: true }
            }
        }




        CellBox
        {
            id: cellE
            Layout.fillHeight: true
            title: 'E'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Recording"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 5
                            columnSpacing: 10

                            Label { text: ""; font.bold: true }
                            Label { text: ""; Layout.fillWidth: true }

                            Label { text: "  Recording Mode:"; font.bold: true }
                            Label { text: Recording_mode; Layout.fillWidth: true }

                            Label { text: "  Sampling Interval:"; font.bold: true }
                            Label { text: Recording_samplinginterval; Layout.fillWidth: true }

                            Label { text: "  Start Time:"; font.bold: true }
                            Label { text: Recording_starttime; Layout.fillWidth: true }

                            Label { text: "  End Time:"; font.bold: true }
                            Label { text: Recording_endtime; Layout.fillWidth: true }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        CellBox
        {
            id: cellF
            Layout.fillHeight: true
            title: 'F'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Notes"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 5
                            columnSpacing: 10

                            Label { text: ""; font.bold: true }
                            Label { text: ""; Layout.fillWidth: true }

                            Label { text: "  Notes:"; font.bold: true }
                            Label { text: Notes_notes; Layout.fillWidth: true }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }

        CellBox
        {
            id: cellG
            Layout.fillHeight: true
            title: 'G'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Activation"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 2
                            rowSpacing: 5
                            columnSpacing: 10

                            Label { text: ""; font.bold: true }
                            Label { text: ""; Layout.fillWidth: true }

                            Label { text: "  Method:"; font.bold: true }
                            Label { text: Activation_method; Layout.fillWidth: true }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }









        // First Column
        CellBox
        {
            id: cellH
            Layout.fillHeight: true
            title: 'H'

            ColumnLayout
            {
                anchors.fill: parent
                spacing: 5

                Loader
                {
                    sourceComponent: bannerComponent
                    Layout.fillWidth: true
                    onLoaded: item.text = "Sampling"
                }

                Item
                {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 60

                    Column
                    {
                        anchors.fill: parent
                        spacing: 2

                        GridLayout
                        {
                            Layout.fillWidth: true
                            columns: 3
                            rowSpacing: 5
                            columnSpacing: 12

                            Label { text: ""; font.bold: true }
                            Label { text: "READ"; font.bold: true; color: "lightgreen"}
                            Label { text: "WRITE"; font.bold: true; color: "lightgreen"; Layout.fillWidth: true }

                            // Mode row
                            Label { text: "  Mode  . . . . . . . . . . . . . ."; font.bold: true }
                            Label { text: "Continuous"}
                            ComboBox
                            {
                                model: modeTypes
                                currentIndex: 0
                                implicitWidth: 200
                                implicitHeight: 26
                                font.pixelSize: 12
                                onCurrentIndexChanged: root.modeTypes = currentText
                            }

                            // Sampling Rate row
                            //Label { text: "  Last Communication:"; font.bold: true }
                            Label { text: "  Sampling Rate  . . . . . ."; font.bold: true }
                            Label { text: "1 Hz"}
                            ComboBox
                            {
                                model: samplingRate
                                currentIndex: 0
                                implicitWidth: 200
                                implicitHeight: 26
                                font.pixelSize: 12
                                onCurrentIndexChanged: root.samplingRate = currentText
                            }


                            // Duration row
                            Label { text: "  Duration Time  . . . . . ."; font.bold: true }
                            Label { text: "60 mins"}
                            ComboBox
                            {
                                model: durationTime
                                currentIndex: 0
                                implicitWidth: 200
                                implicitHeight: 26
                                font.pixelSize: 12
                                onCurrentIndexChanged: root.durationTime = currentText
                            }

                            // Interval row
                            Label { text: "  Interval Time  . . . . . . ."; font.bold: true }
                            Label { text: "1 min"}
                            ComboBox
                            {
                                model: intervalTime
                                currentIndex: 0
                                implicitWidth: 200
                                implicitHeight: 26
                                font.pixelSize: 12
                                onCurrentIndexChanged: root.intervalTime = currentText
                            }


                            // Read/Set buttons
                            Label { text: ""; font.bold: true }
                            Button
                            {
                                id: button3Id
                                font.pixelSize: 16

                                text: "Read Sampling"
                                implicitHeight: 40
                                implicitWidth: 200
                                //Layout.fillWidth: true  // Fill available width
                                //Layout.preferredWidth: (parent.width - parent.columnSpacing) / 2  // Half width minus spacing
                                onClicked:
                                {
                                    var data = CppClass.getVariantListFromCpp()
                                    data.forEach(function(element)
                                    {
                                        console.log("Array item: " + element)
                                    })
                                }
                            }

                            Button
                            {
                                id: button4Id
                                //implicitHeight: 30
                                font.pixelSize: 16
                                text: "Write Sampling"
                                implicitHeight: 40
                                implicitWidth: 200
                                //Layout.preferredWidth: (parent.width - parent.columnSpacing) / 2  // Half width minus spacing
                                onClicked:
                                {
                                    var data = CppClass.getVariantListFromCpp()
                                    data.forEach(function(element)
                                    {
                                        console.log("Array item: " + element)
                                    })
                                }
                            }
                        }
                    }
                }

                Item { Layout.fillHeight: true }
            }
        }














    }
}


