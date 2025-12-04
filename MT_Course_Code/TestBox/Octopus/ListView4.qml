import QtQuick
import QtQuick.Layouts
import QtQuick.Controls

import Qt5Compat.GraphicalEffects

Item {
    id: listview4
    width: 1920
    height: 1080
    visible: true

    // Define statements (must match Defines.h)
    readonly property int cTD_READINGS_PROCESSED_QUERY_MSGID: 0x26 // if you change it in #defines, change it here too

    // Column width ratios (easily adjustable)
    property real col0Width: 0.20  // 25%
    property real col1Width: 0.60  // 50%
    property real col2Width: 0.20  // 25%

    // Debug toggle
    property bool showDebugOutlines: false

    // Visuals
    property real scaleFactor: 1.0
    property real refSize: 40
    property real generalFontSize: 18
    // for the list (text) below each of the 3 guages
    property real listFontSize: 20  // Change this value to adjust font size on all 3 lists

    // ADD LINE PROPERTIES:
    property real lineOpacity: 0.7
    property real lineFadeStart: 0.3
    property real lineFadeIntensity: 0.1

    property bool selectMainControl: true // true for Option A, false for Option B

    // ADD READING HISTORY PROPERTIES
    property int maxReadings: 6
    property ListModel tempReadings: ListModel {}
    property ListModel depthReadings: ListModel {}
    property ListModel condReadings: ListModel {}

    // Track previous values to detect changes
    property real prevTempValue: 0
    property real prevDepthValue: 0
    property real prevCondValue: 0

    // Stream button state
    property bool streamActive: false
    property bool packetReceived: false  // Track if valid packets are being received
    property int packetTimeoutMs: 2000   // Timeout for considering packets stale



    // Add this with your other properties
    property bool isConnected: false  // Track if RS-485 is connected

    // Label initialization
    property string label_Instrument_SerialNumber: "N/A"
    property string label_Instrument_Usage: "N/A"
    property string label_Instrument_Device: "N/A"
    property string label_Memory_Total: "N/A"
    property string label_Memory_Used: "N/A"
    property string label_Configuration_SurfacePressure: "N/A"
    property string label_Messages_Received: "N/A"
    property string label_Messages_Sent: "N/A"
    property string label_Reserved_Reserved: "N/A"
    property string label_Battery_Cell: "N/A"
    property string label_Battery_Type: "N/A"
    property string label_Battery_Usage: "N/A"
    property string label_Time_Computer: "N/A"
    property string label_Time_Device: "N/A"
    property string label_Time_UpcomingRec: "N/A"

    property real cellboxTitleFontSize: 20 * scaleFactor

    property bool pageActive: false

    // Timer for periodic RS-485 messages
    Timer {
        id: rs485Timer
        interval: 1000 // 1 second
        repeat: true
        running: false
        property int triggerCount: 0

        onTriggered: {
            if (streamActive)
            {
              sendCTDReadingsProcessedQuery(); // sent every (interval) seconds
            }
        }
    }

    // Timer for packet timeout detection
    Timer {
        id: packetTimeoutTimer
        interval: packetTimeoutMs
        repeat: false
        running: false
        onTriggered: {
            packetReceived = false;
            console.log("Packet timeout - no valid packets received");
        }
    }

    // Function to send CTD Readings Processed Query
    function sendCTDReadingsProcessedQuery() {
        var selection = cTD_READINGS_PROCESSED_QUERY_MSGID;
        var reserved = 0;
        var arr = [selection, reserved];
        var obj = {
            Selection: selection,
            Reserved: reserved
        };

        console.log("Sending periodic CTD Readings Processed Query");
        CppClass.ProcessOutgoingMsg(arr, obj);
    }

    // Function to handle stream button click
    function handleStreamButtonClick() {
        // Only allow streaming if connected
        if (!isConnected) {
            console.log("Cannot start stream - not connected to RS-485 network");
            return;
        }

        streamActive = !streamActive;
        console.log("Stream button clicked. Active:", streamActive);

        if (streamActive) {
            // Clear all reading lists when starting a new stream
            tempReadings.clear();
            depthReadings.clear();
            condReadings.clear();
            console.log("Cleared all reading lists - starting fresh stream");

            // Reset packet state to false when starting new stream
            packetReceived = false; // Add this line

            // Start periodic messaging and reading updates
            rs485Timer.start();
            updateTimer.running = true; // Start reading updates
            // Reset packet received state and start timeout timer
            packetTimeoutTimer.start();
            console.log("Started periodic RS-485 messages and reading updates");
        }
        else
        {
            // Stop periodic messaging and timeout timer
            rs485Timer.stop();
            packetTimeoutTimer.stop();
            updateTimer.running = false; // Stop reading updates
            packetReceived = false;
            console.log("Stopped periodic RS-485 messages and reading updates");
        }

        // Send initial command to inform backend of stream state
        var selection = cTD_READINGS_PROCESSED_QUERY_MSGID;
        var reserved = 0;
        var streamState = streamActive ? 1 : 0; // Send stream state as additional parameter
        var arr = [selection, reserved, streamState];
        var obj = {
            Selection: selection,
            Reserved: reserved,
            StreamActive: streamActive
        };

        CppClass.ProcessOutgoingMsg(arr, obj);
    }

    // Function to add new readings when gauge values change
    function updateReadingLists() {
        // Only add readings if stream is active
        if (!streamActive) {
            return;
        }

        // Update temperature readings if value changed
        //if (tempGauge.value !== prevTempValue) {
            addReading(tempReadings, tempGauge.value, tempGauge.unit);
            prevTempValue = tempGauge.value;
        //}

        // Update depth readings if value changed
        //if (depthGauge.value !== prevDepthValue) {
            addReading(depthReadings, depthGauge.value, depthGauge.unit);
            prevDepthValue = depthGauge.value;
        //}

        // Update conductivity readings if value changed
        //if (condGauge.value !== prevCondValue) {
            addReading(condReadings, condGauge.value, condGauge.unit);
            prevCondValue = condGauge.value;
        //}
    }

    function addReading(model, value, unit) {
        // Insert at beginning (most recent first)
        model.insert(0, {"value": value, "unit": unit});

        // Remove oldest if exceeds max
        if (model.count > maxReadings) {
            model.remove(maxReadings);
        }
    }

    // Function to handle connection state changes
    function setConnectionState(connected) {
        console.log("=== setConnectionState called ===");
        console.log("Before - isConnected:", isConnected, "streamActive:", streamActive);

        isConnected = connected;
        console.log("After - isConnected:", isConnected, "streamActive:", streamActive);
        console.log("RS-485 connection state:", connected ? "Connected" : "Disconnected");

        // Force reset streaming state whenever connection changes
        resetStreamState();
    }

    // Add this function to ListView4.qml
    function resetStreamState() {
        console.log("=== resetStreamState called ===");
        console.log("Before reset - streamActive:", streamActive);

        streamActive = false;
        rs485Timer.stop();
        packetTimeoutTimer.stop();
        updateTimer.running = false;
        packetReceived = false;

        console.log("After reset - streamActive:", streamActive);
        console.log("Resetting stream state to default");
    }

    // Add this function to detect page activation
    function checkPageActivation() {
        // Try to find the StackLayout parent
        var parentItem = parent;
        var foundStack = null;

        while (parentItem && !foundStack) {
            if (parentItem.objectName === "contentStack" ||
                (parentItem.hasOwnProperty && parentItem.hasOwnProperty("currentIndex"))) {
                foundStack = parentItem;
            } else {
                parentItem = parentItem.parent;
            }
        }

        if (foundStack) {
            // ListView4 is index 0, ListView2 is index 1, ListView3 is index 2
            pageActive = (foundStack.currentIndex === 0);
            //console.log("Page activation check: pageActive =", pageActive, "currentIndex =", foundStack.currentIndex);

            // Auto-stop streaming if page becomes inactive
            if (!pageActive && streamActive) {
                console.log("Auto-stopping stream due to page deactivation");
                resetStreamState();
            }
        }
    }

    // Add this to monitor parent StackLayout changes
    Timer {
        id: pageCheckTimer
        interval: 100
        running: true
        repeat: true
        onTriggered: checkPageActivation()
    }

    // Also check when component becomes visible
    onVisibleChanged: {
        console.log("ListView4 visible changed to:", visible);
        if (!visible && streamActive) {
            console.log("ListView4 became invisible - stopping stream");
            resetStreamState();
        }
    }



    // Add this to ListView4.qml to sync with CppClass.running
    Connections {
        target: CppClass
        function onRunningChanged() {
            isConnected = CppClass.running;
            console.log("CppClass.running changed to:", CppClass.running);

            // If communication stopped, force stop streaming
            if (!CppClass.running && streamActive) {
                console.log("Communication stopped - forcing stream to deactivate");
                // Don't call handleStreamButtonClick() - directly reset the state
                streamActive = false;
                rs485Timer.stop();
                packetTimeoutTimer.stop();
                updateTimer.running = false;
                packetReceived = false;
                console.log("Stream forcibly deactivated due to disconnection");
            }
        }
    }

    // Timer to periodically check for gauge value changes - only when stream is active
    Timer {
        id: updateTimer
        interval: 1000 // Check every 1000ms for gauge updates
        running: streamActive // Only run when stream is active
        repeat: true
        onTriggered: updateReadingLists()
    }

    // Initialize with current gauge values
    Component.onCompleted: {
        // Add initial readings from current gauge values
        addReading(tempReadings, tempGauge.value, tempGauge.unit);
        addReading(depthReadings, depthGauge.value, depthGauge.unit);
        addReading(condReadings, condGauge.value, condGauge.unit);

        prevDepthValue = depthGauge.value;
        prevTempValue = tempGauge.value;
        prevCondValue = condGauge.value;
    }

    Rectangle {
        anchors.fill: parent
        color: "black"

        // Function to handle incoming data from C++ - for Instrument
        function onCTDReadingsProcessedDataReceived(data)
        {
            console.log("CTDReadingsProcessedDataReceived data received in QML:", JSON.stringify(data));

            // Update the properties that are bound to your labels
            depthGauge.value = data.depth || 0;
            tempGauge.value = data.temp || 0;
            condGauge.value = data.cond || 0;

            // Mark that we received a valid packet and restart timeout timer
            if (streamActive) {
                packetReceived = !packetReceived; // Toggle the state
                packetTimeoutTimer.restart();
                console.log("Valid packet received - toggling stream button state. New state:", packetReceived);
            }

            // Optional: Log the updates for debugging
            console.log("Updated depthGuage.value:", depthGauge.value);
            console.log("Updated tempGuage.value:", tempGauge.value);
            console.log("Updated condGuage.value:", condGauge.value);
        }

        function onSubmersibleInfoProcessedDataReceived(data)
        {
            console.log("SubmersibleInfoProcessedDataReceived data received in QML:", JSON.stringify(data));

            // Update the properties that are bound to your labels

            // Instrument - Device
            if (data.instrument_device !== undefined) {
                label_Instrument_Device = data.instrument_device;
            } else {
                label_Instrument_Device = "N/A";
            }
            // Instrument - Serial Number
            if (data.instrument_serialnumber !== undefined) {
                label_Instrument_SerialNumber = data.instrument_serialnumber;  // Direct assignment for strings
            } else {
                label_Instrument_SerialNumber = "N/A";
            }
            // Instrument - Usage
            if (data.instrument_usage !== undefined) {
                label_Instrument_Usage = data.instrument_usage;
            } else {
                label_Instrument_Usage = "N/A";
            }


            // Memory - Total
            if (data.memory_total !== undefined) {
                label_Memory_Total = data.memory_total;
            } else {
                label_Memory_Total = "N/A";
            }
            // Memory - Used
            if (data.memory_used !== undefined) {
                label_Memory_Used = data.memory_used;
            } else {
                label_Memory_Used = "N/A";
            }

            // Configuration - Surface Pressure
            if (data.surface_pressure !== undefined) {
                label_Configuration_SurfacePressure = data.surface_pressure;
            } else {
                label_Configuration_SurfacePressure = "N/A";
            }

            // Battery - Cell
            if (data.battery_cell !== undefined) {
                label_Battery_Cell = data.battery_cell.toFixed(1);  // Example : Need to convert to cell type string
            } else {
                label_Battery_Cell = "N/A";
            }
            // Battery - Type
            if (data.battery_type !== undefined) {
                label_Battery_Type = data.battery_type.toFixed(1) + " V";  // Example: "3.7 V"
            } else {
                label_Battery_Type = "N/A";
            }
            // Battery - Usage
            if (data.battery_type !== undefined) {
                label_Battery_Usage = data.battery_type.toFixed(1) + " h";  // Example: "5.2 h"
            } else {
                label_Battery_Usage = "N/A";
            }




            // Messages - Received
            if (data.messages_received !== undefined) {
                label_Messages_Received = data.messages_received.toFixed(0);  // Example: 234234
            } else {
                label_Messages_Received = "N/A";
            }
            // Messages - Sent
            if (data.messages_sent !== undefined) {
                label_Messages_Sent = data.messages_sent.toFixed(0);  // Example: 234234
            } else {
                label_Messages_Sent = "N/A";
            }
            if (data.messages_received !== undefined) {
                label_Messages_Received = data.messages_received.toFixed(0);  // Example: 234234
            } else {
                label_Messages_Received = "N/A";
            }

            // Time - Computer (Tablet)
            if (data.schedule_tablettime !== undefined) {
                label_Time_Computer = data.schedule_tablettime;  // Direct assignment for strings
            } else {
                label_Time_Computer = "N/A";
            }
            // Time - Device
            if (data.schedule_tablettime !== undefined) {
                label_Time_Device = data.schedule_tablettime;  // Direct assignment for strings
            } else {
                label_Time_Device = "N/A";
            }
            // Time - Upcoming Rec
            if (data.schedule_tablettime !== undefined) {
                label_Time_UpcomingRec = data.schedule_tablettime;  // Direct assignment for strings
            } else {
                label_Time_UpcomingRec = "N/A";
            }

            // Mark that we received a valid packet and restart timeout timer
            if (streamActive) {
                packetReceived = !packetReceived; // Toggle the state
                packetTimeoutTimer.restart();
                console.log("Valid packet received - updating stream button state. New state:", packetReceived);
            }

            console.log("Updated label_Battery_BatteryCell:", label_Battery_BatteryCell);
        }


        Component.onCompleted:
        {
            // Connect the C++ signal to your QML function
            CppClass.ctdreadingsprocessedDataReceived.connect(onCTDReadingsProcessedDataReceived);
            CppClass.submersibleinfoprocessedDataReceived.connect(onSubmersibleInfoProcessedDataReceived);
            console.log("Connected to C++ signals");
        }

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

            // Column 0: Row 0
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
                                    item.text = "(0) Instrument Status"
                                    item.fontSize = cellboxTitleFontSize
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
                                text: "  Device  . . . . . . . . . . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 0
                            }
                            Label {
                                text: label_Instrument_Device
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 1
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

                                onClicked: {
                                    var selection = cTD_READINGS_PROCESSED_QUERY_MSGID;
                                    var reserved = 0;
                                    var selected_Instrument_Serial_Number = 0;
                                    var arr = [selection,reserved];
                                    var obj =
                                    {
                                        Selection : selection,
                                        Reserved: reserved
                                    };
                                    //CppClass.passFromQmlToCpp3(arr, obj);
                                    CppClass.ProcessOutgoingMsg(arr,obj);
                                }
                            }
                        }
                    }
                }
            }

            // Column 0, Row 1
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
                                    item.text = "(1) Logger Memory"
                                    item.fontSize = cellboxTitleFontSize
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


                            // Row 1: Total Memory
                            Label {
                                text: "  Total Memory  . . . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 0
                            }
                            Label {
                                text: label_Memory_Total
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 1
                            }


                            // Row 2 : Used Memory
                            Label {
                                text: "  Used Memory  . . . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 0
                            }
                            Label {
                                text: label_Memory_Used
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 1
                            }

                            // Row 3 : Unassigned


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

            // Column 0, Row 2
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
                                    item.text = "(2) Configuration"
                                    item.fontSize = cellboxTitleFontSize
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


                            // Row 1: Surface Pressure
                            Label {
                                text: "  Surface Pressure  . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 0
                            }
                            Label {
                                text: label_Configuration_SurfacePressure
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 1
                            }

                            /*
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
                            */

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



            // Column 1, Row 0 to 2  -- Guage Cluster
            Rectangle {
                Layout.column: 1
                Layout.row: 0
                Layout.rowSpan: 3
                Layout.preferredWidth: parent.width * col1Width
                Layout.fillHeight: true
                color: "black"
                border.width: showDebugOutlines ? 1 : 0
                border.color: "darkgreen"

                /*
                Text {
                    text: "Col 1 (Spans 3 rows)\n" + (col1Width * 100).toFixed(0) + "%"
                    anchors.centerIn: parent
                    color: "white"
                }
                */

                // Stream Button - Positioned in upper right corner of gauge cluster
                MouseArea {
                    id: streamButton
                    width: 175
                    height: 56
                    anchors {
                        top: parent.top
                        topMargin: 20
                        right: parent.right
                        rightMargin: 30
                    }

                    onClicked: {
                        handleStreamButtonClick();
                    }

                    Image {
                        id: streamButtonImage
                        anchors.fill: parent
                        source: {
                            // Always show deactivate button if not connected, regardless of streamActive state
                            if (!isConnected) {
                                return "qrc:/Octopus/images/Stream_Deactivate_Button.png";
                            }

                            if (!streamActive) {
                                return "qrc:/Octopus/images/Stream_Deactivate_Button.png";
                            } else {
                                // When active, show different images based on packet reception
                                return packetReceived ?
                                    "qrc:/Octopus/images/Stream_ActivateToggle_Button.png" :
                                    "qrc:/Octopus/images/Stream_Activate_Button.png";
                            }
                        }
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    // Add hover effect
                    states: State {
                        name: "hovered"
                        when: streamButton.containsMouse
                        PropertyChanges {
                            target: streamButtonImage
                            scale: 1.05
                        }
                    }

                    transitions: Transition {
                        NumberAnimation { property: "scale"; duration: 100 }
                    }
                }

                // OPTION 1: PNG Image Display (shows when streaming is NOT active)
                Item {
                    id: pngDisplay
                    anchors.fill: parent
                    visible: !streamActive  // Show when streaming is NOT active

                    Image {
                        id: dataCollectorImage
                        source: "qrc:/Octopus/images/Data_Collector_Render.png"
                        anchors.centerIn: parent
                        width: Math.min(parent.width * 0.8, 600)  // 80% of parent width, max 600px
                        height: width * (sourceSize.height / sourceSize.width)  // Maintain aspect ratio
                        fillMode: Image.PreserveAspectFit
                        smooth: true

                        // Optional: Add a text label below the image
                        Text {
                            anchors {
                                top: parent.bottom
                                horizontalCenter: parent.horizontalCenter
                                topMargin: 20
                            }
                            text: "Ready to Stream"
                            font.pixelSize: 24
                            font.bold: true
                            color: "lightgreen"
                        }
                    }
                }

                // Option A: Container for the gauge cluster
                Item {
                    id: gaugeCluster
                    anchors.fill: parent
                    visible: streamActive && selectMainControl // Show when streaming active AND selectMainControl is true

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
                        value: 90
                        minValue: -30
                        maxValue: 90
                        unit: "°C"
                        progressStartColor: "gold"
                        progressEndColor: "tomato"
                        z: 2
                        aboveLimitThreshold: 85   // Warn when temperature exceeds 60°C
                        belowLimitThreshold: -25   // Warn when temperature drops below 10°C
                    }
                    // Temperature readings list
                    Column {
                        id: tempReadingsList
                        anchors {
                            top: tempGauge.bottom
                            topMargin: 10
                            horizontalCenter: tempGauge.horizontalCenter
                        }
                        width: tempGauge.width * 0.8
                        spacing: 2
                        z: 2

                        Repeater {
                            model: tempReadings
                            delegate: Text {
                                text: value.toFixed(1) + " " + unit
                                font.pixelSize: listFontSize
                                font.bold: index === 0
                                color: Qt.rgba(1, 1, 1, 1.0 - (index / (maxReadings * 1.5)))
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                        }
                    }
                    Image {
                        source: "qrc:/Octopus/images/Temperature1_Icon.png"

                        // Set the desired X and Y position for the center of the image
                        x: 194
                        y: 542

                        // Set the scaled width and height
                        width: 90
                        height: 90

                        // Ensure smooth scaling
                        smooth: true
                        z: 3
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
                        value: 160
                        minValue: -10
                        maxValue: 160
                        unit: "m"
                        progressStartColor: "springgreen"
                        progressEndColor: "deepskyblue"
                        z: 3
                        aboveLimitThreshold: 155  // Warn when depth exceeds 155m
                        belowLimitThreshold: -5    // Warn when depth is below -5m
                        decimalPlaces: 2
                    }

                    // Depth readings list
                    Column {
                        id: depthReadingsList
                        anchors {
                            top: depthGauge.bottom
                            topMargin: 10
                            horizontalCenter: depthGauge.horizontalCenter
                        }
                        width: depthGauge.width * 0.8
                        spacing: 2
                        z: 3

                        Repeater {
                            model: depthReadings
                            delegate: Text {
                                text: value.toFixed(2) + " " + unit  // Change ONLY this to toFixed(2)
                                font.pixelSize: listFontSize
                                font.bold: index === 0
                                color: Qt.rgba(1, 1, 1, 1.0 - (index / (maxReadings * 1.5)))
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                        }
                    }

                    Image {
                        source: "qrc:/Octopus/images/Depth1_Icon.png"

                        // Set the desired X and Y position for the center of the image
                        x: 513
                        y: 613

                        // Set the scaled width and height
                        width: 111
                        height: 111

                        // Ensure smooth scaling
                        smooth: true
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
                        value: 2000
                        minValue: -10
                        maxValue: 2000
                        unit: "mS/cm"
                        progressStartColor: "#FF6EC7"
                        progressEndColor: "#8A2BE2"
                        z: 2
                        aboveLimitThreshold: 1990 // Warn when conductivity exceeds 1800 mS/cm
                        belowLimitThreshold: 0  // Warn when conductivity drops below 100 mS/cm
                    }
                    // Conductivity readings list
                    Column {
                        id: condReadingsList
                        anchors {
                            top: condGauge.bottom
                            topMargin: 10
                            horizontalCenter: condGauge.horizontalCenter
                        }
                        width: condGauge.width * 0.8
                        spacing: 2
                        z: 2

                        Repeater {
                            model: condReadings
                            delegate: Text {
                                text: value.toFixed(1) + " " + unit
                                font.pixelSize: listFontSize
                                font.bold: index === 0
                                color: Qt.rgba(1, 1, 1, 1.0 - (index / (maxReadings * 1.5)))
                                horizontalAlignment: Text.AlignHCenter
                                width: parent.width
                            }
                        }
                    }
                    Image {
                        source: "qrc:/Octopus/images/Conductivity1_Icon.png"

                        // Set the desired X and Y position for the center of the image
                        x: 855
                        y: 542

                        // Set the scaled width and height
                        width: 90
                        height: 90

                        // Ensure smooth scaling
                        smooth: true
                        z: 3
                    }
                }


                // Option B: Experimental : Rotating carousel
                Item {
                    id: scalableWrapper
                    visible: !selectMainControl // Show when selectMainControl is false
                    // Control properties
                    property real controlX: 150
                    property real controlY: 250
                    property real controlScale: 3.0
                    property real baseWidth: 300
                    property real baseHeight: 150

                    // Center the control in the parent column
                    //anchors.centerIn: parent

                    // Scaled dimensions
                    width: baseWidth * controlScale
                    height: baseHeight * controlScale
                    x: controlX
                    y: controlY

                    Rectangle {
                        id: controlRoot
                        anchors.fill: parent
                        color: "black"

                        ListModel {
                            id: nameModel
                            ListElement { file: "qrc:/Octopus/images/Spectra_Bladder_Mini.png"; name: "Mini" }
                            ListElement { file: "qrc:/Octopus/images/Spectra_Bladder_Sil_1.png"; name: "Sil 1" }
                            ListElement { file: "qrc:/Octopus/images/Spectra_Bladder_Sil_2.png"; name: "Sil 2" }
                            //ListElement { file: "qrc:/Octopus/images/Spectra_Hydro_Pro.png"; name: "Hydro Pro" }
                            ListElement { file: "qrc:/Octopus/images/Data_Collector_Render.png"; name: "Data Collector" }
                        }

                        Component {
                            id: nameDelegate
                            Column {
                                opacity: PathView.opacity
                                z: PathView.z
                                scale: PathView.scale

                                Image {
                                    id: delegateImage
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    source: model.file
                                    width: controlRoot.height * 0.4
                                    height: controlRoot.height * 0.4
                                    smooth: true
                                    mipmap: true
                                    fillMode: Image.PreserveAspectFit
                                    sourceSize.width: controlRoot.height * 0.8
                                    sourceSize.height: controlRoot.height * 0.8
                                }

                                Text {
                                    id: delegateText
                                    text: model.name
                                    font.pixelSize: controlRoot.height * 0.03
                                    font.bold: true
                                    color: "lightgreen"
                                    anchors.horizontalCenter: parent.horizontalCenter
                                }
                            }
                        }

                        PathView {
                            anchors.fill: parent
                            model: nameModel
                            delegate: nameDelegate
                            focus: true

                            path: Path {
                                // Front - center bottom
                                startX: controlRoot.width / 2
                                startY: controlRoot.height * 2/3
                                PathAttribute { name: "opacity"; value: 1.0 }
                                PathAttribute { name: "scale"; value: 2.5 }  // Control front item size here
                                PathAttribute { name: "z"; value: 0 }

                                // Left curve
                                PathCubic {
                                    x: controlRoot.width / 6
                                    y: controlRoot.height / 3
                                    control1X: controlRoot.width / 3
                                    control1Y: controlRoot.height * 2/3
                                    control2X: controlRoot.width / 6
                                    control2Y: controlRoot.height / 2
                                }
                                PathAttribute { name: "opacity"; value: 0.75 }
                                PathAttribute { name: "scale"; value: 0.75 }
                                PathAttribute { name: "z"; value: -1 }

                                // Top curve
                                PathCubic {
                                    x: controlRoot.width / 2
                                    y: controlRoot.height / 7
                                    control1X: controlRoot.width / 6
                                    control1Y: controlRoot.height / 4
                                    control2X: controlRoot.width / 3
                                    control2Y: controlRoot.height / 7
                                }
                                PathAttribute { name: "opacity"; value: 0.35 }
                                PathAttribute { name: "scale"; value: 0.35 }
                                PathAttribute { name: "z"; value: -2 }

                                // Right curve
                                PathCubic {
                                    x: controlRoot.width * 5/6
                                    y: controlRoot.height / 3
                                    control1X: controlRoot.width * 2/3
                                    control1Y: controlRoot.height / 7
                                    control2X: controlRoot.width * 5/6
                                    control2Y: controlRoot.height / 4
                                }
                                PathAttribute { name: "opacity"; value: 0.75 }
                                PathAttribute { name: "scale"; value: 0.75 }
                                PathAttribute { name: "z"; value: -1 }

                                // Return to front
                                PathCubic {
                                    x: controlRoot.width / 2
                                    y: controlRoot.height * 2/3
                                    control1X: controlRoot.width * 5/6
                                    control1Y: controlRoot.height / 2
                                    control2X: controlRoot.width * 2/3
                                    control2Y: controlRoot.height * 2/3
                                }
                            }

                            Keys.onLeftPressed: decrementCurrentIndex()
                            Keys.onRightPressed: incrementCurrentIndex()
                        }
                    }
                }
            }



            // Column 2, Row 0
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
                                    item.text = "(3) Internal Battery"
                                    item.fontSize = cellboxTitleFontSize
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


                            // Row 1: Battery Cell
                            Label {
                                text: "  Battery Cell  . . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 0
                            }
                            Label {
                                text: label_Battery_Cell
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 1
                            }


                            // Row 2 : Battery Type
                            Label {
                                text: "  Battery Type  . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 0
                            }
                            Label {
                                text: label_Battery_Type
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 1
                            }

                            // Row 3 : Usage
                            Label {
                                text: "  Usage  . . . . . . . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 3
                                Layout.column: 0
                            }
                            Label {
                                text: label_Battery_Usage
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

            // Column 2, Row 1
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
                                    item.text = "(4) Message Traffic"
                                    item.fontSize = cellboxTitleFontSize
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


                            // Row 1:
                            Label {
                                text: "  Messages Rcvd  ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 0
                            }
                            Label {
                                text: label_Messages_Received
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 1
                            }


                            // Row 2 : Message Sent
                            Label {
                                text: "  Messages Sent  . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 0
                            }
                            Label {
                                text: label_Messages_Sent
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 1
                            }

                            /*
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
                            */

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

            // Column 2, Row 2
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
                                    item.text = "(5) Time"
                                    item.fontSize = cellboxTitleFontSize
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


                            // Row 1: Computer/Tablet Time
                            Label {
                                text: "  Computer  . . . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 0
                            }
                            Label {
                                text: label_Time_Computer
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 1
                                Layout.column: 1
                            }

                            // Row 2 : Device Time
                            Label {
                                text: "  Device  . . . . . . . ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 0
                            }
                            Label {
                                text: label_Time_Device
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 2
                                Layout.column: 1
                            }

                            // Row 3 : Usage
                            Label {
                                text: "  Upcoming Rec  ."
                                font.bold: true
                                font.pixelSize: generalFontSize * scaleFactor
                                Layout.row: 3
                                Layout.column: 0
                            }
                            Label {
                                text: label_Time_UpcomingRec
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
