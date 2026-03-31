// ListView3.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Dialogs

GridLayout {
    // Define message IDs (must match Defines.h)
    readonly property int lOG_QUERY_SHOWFILES_MSGID: 0x50
    readonly property int lOG_SET_READSPECIFICFILE_MSGID: 0x52

    // Source selection state
    property string selectedSource: ""  // "", "device", "local", "cloud"
    property var currentFileList: []     // Store current files from active source
    property var selectedFileData: null   // Currently selected file data

    anchors.fill: parent
    flow: GridLayout.TopToBottom
    rows: 2

    // Local Folder Dialog
    FolderDialog {
        id: folderDialog
        title: "Please choose a directory"
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {
            var path = selectedFolder.toString().replace(/^(file:\/{3})/, "");
            console.log("Selected directory:", path);

            // Clear current state and set source to local
            clearAndSetSource("local");

            // Force refresh by first clearing the folderModel
            folderModel.folder = "";
            fileListModel.clear();

            // Small delay to ensure model clears before setting new folder
            Qt.callLater(function() {
                folderModel.folder = selectedFolder;
            });
        }
    }

    // Folder Model for local files
    FolderListModel {
        id: folderModel
        showDirs: false
        nameFilters: ["*.txt"]
        showDotAndDotDot: false
        showOnlyReadable: true

        onCountChanged: {
            if (selectedSource === "local" && count > 0) {
                console.log("Found", count, "text files in local directory");
                updateLocalFileList();
            }
        }
    }

    // ListModel for the ListView
    ListModel {
        id: fileListModel
    }

    // Device file handling
    function triggerDeviceDialog() {
        console.log("Device button clicked: Requesting file list from instrument");

        // Clear current state and set source to device
        clearAndSetSource("device");

        // Send request to C++ for device files
        var selection = lOG_QUERY_SHOWFILES_MSGID;
        var dummybyte = 0;
        var arr = [selection, dummybyte];
        var obj = {
            Selection: selection,
            dummybyte: dummybyte
        };
        CppClass.processOutgoingMsg(arr, obj);
    }

    // Update local file list with sorting by date (latest first)
    function updateLocalFileList() {
        fileListModel.clear();
        var filesData = [];

        // Collect all files first
        for (var i = 0; i < folderModel.count; i++) {
            var fileModified = new Date(folderModel.get(i, "fileModified"));
            var fileSizeBytes = folderModel.get(i, "fileSize");

            var fileInfo = {
                fileName: folderModel.get(i, "fileName"),
                fileSize: formatFileSize(fileSizeBytes),
                fileSizeBytes: fileSizeBytes,
                fileModified: fileModified,
                fileModifiedTimestamp: fileModified.getTime(),
                source: "local",
                fullPath: folderModel.folder.toString().replace(/^(file:\/{3})/, "") + "/" + folderModel.get(i, "fileName")
            };

            filesData.push(fileInfo);
        }

        // Sort by date (latest first)
        filesData.sort(function(a, b) {
            return b.fileModifiedTimestamp - a.fileModifiedTimestamp;
        });

        // Add to model
        for (var j = 0; j < filesData.length; j++) {
            var displayInfo = {
                fileName: filesData[j].fileName,
                fileSize: filesData[j].fileSize,
                timeClosed: formatFileTime(filesData[j].fileModified),
                source: "local",
                fullPath: filesData[j].fullPath,
                fileModifiedTimestamp: filesData[j].fileModifiedTimestamp,
                fileSizeBytes: filesData[j].fileSizeBytes
            };
            fileListModel.append(displayInfo);
        }

        currentFileList = filesData;
        console.log("Local file list updated with", fileListModel.count, "files");
    }

    // Update device file list from C++ data
    function updateDeviceFileList(deviceFiles) {
        fileListModel.clear();
        var filesData = [];

        for (var i = 0; i < deviceFiles.length; i++) {
            var fileInfo = {
                fileName: deviceFiles[i].fileName,
                fileSize: formatFileSize(deviceFiles[i].fileSizeBytes),
                fileSizeBytes: deviceFiles[i].fileSizeBytes,
                fileDateTime: deviceFiles[i].fileDateTime,
                fileDateTimeTimestamp: deviceFiles[i].fileDateTimeTimestamp,
                fileIndex: deviceFiles[i].fileIndex,
                source: "device"
            };

            filesData.push(fileInfo);

            var displayInfo = {
                fileName: fileInfo.fileName,
                fileSize: fileInfo.fileSize,
                timeClosed: formatDeviceDateTime(fileInfo.fileDateTime),
                source: "device",
                fileIndex: fileInfo.fileIndex,
                fileDateTimeTimestamp: fileInfo.fileDateTimeTimestamp
            };
            fileListModel.append(displayInfo);
        }

        currentFileList = filesData;
        console.log("Device file list updated with", fileListModel.count, "files");
    }

    // Clear ListView and reset state
    function clearAndSetSource(source) {
        console.log("Clearing ListView and setting source to:", source);

        // Clear current selection
        fileListView.currentIndex = -1;
        selectedFileData = null;

        // Clear file details area
        fileDetailsText.text = "No file selected";

        // Clear file list model
        fileListModel.clear();

        // Set new source
        selectedSource = source;

        // Update button visual states
        updateButtonStates();
    }

    // Update visual states of source buttons
    function updateButtonStates() {
        deviceButton.selected = (selectedSource === "device");
        localButton.selected = (selectedSource === "local");
        cloudButton.selected = (selectedSource === "cloud");
    }

    // Format file size for display
    function formatFileSize(bytes) {
        if (bytes < 1024) return bytes + " B";
        else if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " KB";
        else return (bytes / 1048576).toFixed(1) + " MB";
    }

    // Format file time for local files
    function formatFileTime(fileTime) {
        var date = new Date(fileTime);
        return date.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm:ss");
    }

    // Format device date/time (parse from instrument format)
    function formatDeviceDateTime(dateTimeObj) {
        if (!dateTimeObj) return "Unknown";
        // Assuming dateTimeObj has year, month, day, hour, minute, second
        var year = 2000 + (dateTimeObj.year || 0);
        var month = (dateTimeObj.month || 1);
        var day = (dateTimeObj.day || 1);
        var hour = (dateTimeObj.hour || 0);
        var minute = (dateTimeObj.minute || 0);
        var second = (dateTimeObj.second || 0);

        // Handle AM/PM if present
        if (dateTimeObj.ampm !== undefined && dateTimeObj.ampm === 1 && hour < 12) {
            hour += 12;
        }

        var date = new Date(year, month - 1, day, hour, minute, second);
        return date.toLocaleString(Qt.locale(), "yyyy-MM-dd HH:mm:ss");
    }

    // Load and graph a local file
    function loadLocalFile(filePath) {
        console.log("=== loadLocalFile called with path:", filePath);
        CppClass.openAndReadFile(filePath);
    }

    // Request device file download
    function requestDeviceFile(fileIndex) {
        console.log("Requesting device file with index:", fileIndex);
        var selection = lOG_SET_READSPECIFICFILE_MSGID;
        var arr = [selection, fileIndex];
        var obj = {
            Selection: selection,
            FileIndex: fileIndex
        };
        CppClass.processOutgoingMsg(arr, obj);
    }

    // Helper function to convert time strings to plotable values
    function timeStringToMinutes(timeStr) {
        var parts = timeStr.split(":");
        if (parts.length === 3) {
            var hours = parseInt(parts[0]);
            var minutes = parseInt(parts[1]);
            var seconds = parseInt(parts[2]);
            return hours * 60 + minutes + seconds / 60;
        }
        return 0;
    }

    // Update chart with data points
    function updateChart(points) {
        console.log("=== updateChart called with", points.length, "points ===");

        if (!points || points.length === 0) {
            console.log("No points to chart");
            return;
        }

        // Log first few points
        for (var i = 0; i < Math.min(3, points.length); i++) {
            console.log("Point", i, ":", points[i].time, points[i].depth, points[i].temperature);
        }

        // Clear existing data
        depthSeries.clear();
        temperatureSeries.clear();

        if (points.length === 0) {
            console.log("No points to chart");
            return;
        }

        var minTime = Number.MAX_VALUE;
        var maxTime = Number.MIN_VALUE;
        var minDepth = Number.MAX_VALUE;
        var maxDepth = Number.MIN_VALUE;
        var minTemp = Number.MAX_VALUE;
        var maxTemp = Number.MIN_VALUE;

        // Add points and find ranges
        for (var i = 0; i < points.length; i++) {
            var point = points[i];
            var timeMinutes = timeStringToMinutes(point.time);
            var depth = point.depth;
            var temp = point.temperature;

            depthSeries.append(timeMinutes, depth);
            temperatureSeries.append(timeMinutes, temp);

            // Update ranges
            minTime = Math.min(minTime, timeMinutes);
            maxTime = Math.max(maxTime, timeMinutes);
            minDepth = Math.min(minDepth, depth);
            maxDepth = Math.max(maxDepth, depth);
            minTemp = Math.min(minTemp, temp);
            maxTemp = Math.max(maxTemp, temp);
        }

        // Set axis ranges with some padding
        axisX.min = Math.max(0, minTime - 5);
        axisX.max = maxTime + 5;

        axisYDepth.min = Math.max(0, minDepth - 5);
        axisYDepth.max = maxDepth + 5;

        axisYTemp.min = Math.max(-40, minTemp - 2);
        axisYTemp.max = Math.min(85, maxTemp + 2);

        console.log("Chart updated - Time range:", minTime.toFixed(1), "to", maxTime.toFixed(1), "minutes");
        console.log("Depth range:", minDepth.toFixed(1), "to", maxDepth.toFixed(1), "m");
        console.log("Temperature range:", minTemp.toFixed(1), "to", maxTemp.toFixed(1), "°C");
    }

    function addToChart(newPoints) {
        console.log("Adding", newPoints.length, "new points to chart");

        for (var i = 0; i < newPoints.length; i++) {
            var point = newPoints[i];
            var timeMinutes = timeStringToMinutes(point.time);

            depthSeries.append(timeMinutes, point.depth);
            temperatureSeries.append(timeMinutes, point.temperature);
        }
    }

    // Connections to C++ backend
    Connections {
        target: CppClass

        onTestSignal: function(message) {
            console.log("*** TEST SIGNAL RECEIVED:", message);
        }

        // Note: Now it's onDeviceFileListReady (single "on" from QML)
        onDeviceFileListReady: function(deviceFiles) {
            console.log("=== DEVICE FILE LIST READY SIGNAL RECEIVED in QML ===");
            console.log("Current selectedSource:", selectedSource);
            console.log("Device files count:", deviceFiles ? deviceFiles.length : 0);

            if (selectedSource === "device") {
                console.log("Updating device file list...");
                updateDeviceFileList(deviceFiles);
            } else {
                console.log("Ignoring device files - current source is:", selectedSource);
            }
        }

        onDeviceFileDownloaded: function(fileData) {
            console.log("Device file downloaded, loading for graphing");
            if (fileData && fileData.points) {
                updateChart(fileData.points);
            }
        }

        onFileDataReady: function(metadata, dataPoints) {
            console.log("=== onFileDataReady called ===");
            console.log("Metadata received:", JSON.stringify(metadata, null, 2));
            console.log("Data points count:", dataPoints.length);

            if (dataPoints.length === 0) {
                console.log("WARNING: No data points to display!");
                return;
            }

            deviceInfo.text = metadata.device + " - " + metadata.serialNumber;
            timeInfo.text = metadata.instrumentTime + " " + metadata.timeZone;

            console.log("Calling updateChart with", dataPoints.length, "points");
            updateChart(dataPoints);
        }
    }

    // Left Column - File Operations
    CellBox {
        title: 'File Operations'
        ColumnLayout {
            anchors.fill: parent

            GridLayout {
                columns: 1
                columnSpacing: 20
                rowSpacing: 10
                Layout.alignment: Qt.AlignTop

                // Source selection buttons
                RowLayout {
                    spacing: 10

                    Button {
                        id: deviceButton
                        property bool selected: false
                        text: "Device"
                        Layout.fillWidth: true
                        implicitHeight: 40

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 20
                            font.bold: deviceButton.selected
                            color: deviceButton.selected ? "#FFA500" : "#FFFFFF"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (selectedSource !== "device") {
                                triggerDeviceDialog();
                            } else {
                                // Refresh device list if same button clicked again
                                triggerDeviceDialog();
                            }
                        }
                    }

                    Button {
                        id: localButton
                        property bool selected: false
                        text: "Local"
                        Layout.fillWidth: true
                        implicitHeight: 40

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 20
                            font.bold: localButton.selected
                            color: localButton.selected ? "#FFA500" : "#FFFFFF"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            if (selectedSource !== "local") {
                                folderDialog.open();
                            } else {
                                // Refresh local file list if same button clicked again
                                if (folderModel.folder.toString() !== "") {
                                    clearAndSetSource("local");
                                    Qt.callLater(function() {
                                        folderModel.folder = folderModel.folder;
                                    });
                                } else {
                                    folderDialog.open();
                                }
                            }
                        }
                    }

                    Button {
                        id: cloudButton
                        property bool selected: false
                        text: "Cloud"
                        Layout.fillWidth: true
                        implicitHeight: 40
                        enabled: false  // Disabled for now

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 20
                            font.bold: cloudButton.selected
                            color: cloudButton.selected ? "#FFA500" : "#888888"
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                        }

                        onClicked: {
                            console.log("Cloud button clicked - not implemented yet");
                            // Future implementation
                        }
                    }
                }

                // File List View
                ListView {
                    id: fileListView
                    currentIndex: -1
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.minimumHeight: 300
                    clip: true
                    spacing: 2
                    model: fileListModel

                    delegate: Rectangle {
                        width: fileListView.width
                        height: 60
                        color: fileListView.currentIndex === index ? "#d4e6f1" : (index % 2 ? "#f5f5f5" : "white")
                        border.color: fileListView.currentIndex === index ? "#3498db" : "#e0e0e0"
                        radius: 2

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 10

                            Column {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    text: fileName
                                    font.bold: true
                                    font.pixelSize: 20
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: source === "device" ? "Instrument File" : "Text File"
                                    font.pixelSize: 18
                                    color: "#666"
                                    elide: Text.ElideRight
                                }
                            }

                            Column {
                                Layout.alignment: Qt.AlignRight
                                spacing: 2

                                Text {
                                    text: fileSize
                                    font.pixelSize: 18
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    text: timeClosed
                                    font.pixelSize: 18
                                    color: "#666"
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                fileListView.currentIndex = index;
                                var selectedFile = fileListModel.get(index);
                                selectedFileData = selectedFile;

                                // Update file details area
                                fileDetailsText.text = "Selected: " + selectedFile.fileName;

                                // For local files, show Load button and optionally auto-load
                                if (selectedFile.source === "local") {
                                    loadButton.visible = true;
                                    loadButton.text = "Load & Graph";
                                    // Auto-load local files (or keep manual? I'll make it manual but you can change)
                                    // loadLocalFile(selectedFile.fullPath);
                                }
                                // For device files, show Load button for manual download
                                else if (selectedFile.source === "device") {
                                    loadButton.visible = true;
                                    loadButton.text = "Download & Graph";
                                }

                                console.log("Selected file:", selectedFile.fileName, "from source:", selectedFile.source);
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }

                // File Details Area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 80
                    color: "#f0f0f0"
                    border.color: "#cccccc"
                    radius: 4

                    Column {
                        anchors.fill: parent
                        anchors.margins: 10
                        spacing: 5

                        Text {
                            text: "File Details"
                            font.bold: true
                            font.pixelSize: 18
                            color: "#333333"
                        }

                        Text {
                            id: fileDetailsText
                            text: "No file selected"
                            font.pixelSize: 16
                            color: "#666666"
                            wrapMode: Text.WordWrap
                        }
                    }
                }

                // Load Button (appears when file is selected)
                Button {
                    id: loadButton
                    text: "Load & Graph"
                    Layout.fillWidth: true
                    implicitHeight: 40
                    visible: false

                    contentItem: Text {
                        text: parent.text
                        font.pixelSize: 18
                        font.bold: true
                        color: "#FFFFFF"
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                    }

                    background: Rectangle {
                        color: parent.enabled ? "#4CAF50" : "#cccccc"
                        radius: 4
                    }

                    onClicked: {
                        if (selectedFileData) {
                            if (selectedFileData.source === "local") {
                                console.log("Loading local file:", selectedFileData.fullPath);
                                loadLocalFile(selectedFileData.fullPath);
                            } else if (selectedFileData.source === "device") {
                                console.log("Downloading device file with index:", selectedFileData.fileIndex);
                                requestDeviceFile(selectedFileData.fileIndex);
                            }
                        } else {
                            console.log("No file selected!");
                        }
                    }
                }
            }
        }
    }

    // Right Column - Graph
    CellBox {
        Layout.rowSpan: 2
        Layout.minimumWidth: 700
        title: 'Graph'
        Layout.preferredWidth: height

        ColumnLayout {
            anchors.fill: parent

            Text {
                id: deviceInfo
                text: "Device: "
                color: "white"
                font.pixelSize: 20
            }

            Text {
                id: timeInfo
                text: "Time: "
                color: "white"
                font.pixelSize: 18
            }

            TabBar {
                id: bar
                width: parent.width
                TabButton {
                    text: 'Area'
                }
            }

            StackLayout {
                width: parent.width
                height: parent.height - y
                anchors.top: bar.bottom
                currentIndex: bar.currentIndex

                ChartView {
                    id: chartView
                    width: 1600
                    height: 800
                    theme: ChartView.ChartThemeDark
                    antialiasing: true
                    legend.visible: false

                    ValueAxis {
                        id: axisX
                        titleText: "Time (minutes)"
                        min: 0
                        max: 200
                        labelFormat: "%.0f"
                        labelsFont: Qt.font({ family: "Arial", pointSize: 12, bold: true })
                        titleFont: Qt.font({ family: "Arial", pointSize: 14, bold: true })
                    }

                    ValueAxis {
                        id: axisYDepth
                        titleText: "Depth (m)"
                        min: 0
                        max: 100
                        labelFormat: "%.0f"
                        labelsFont: Qt.font({ family: "Arial", pointSize: 12, bold: true })
                        titleFont: Qt.font({ family: "Arial", pointSize: 14, bold: true })
                    }

                    ValueAxis {
                        id: axisYTemp
                        titleText: "Temperature (°C)"
                        min: 0
                        max: 30
                        labelFormat: "%.1f"
                        labelsFont: Qt.font({ family: "Arial", pointSize: 12, bold: true })
                        titleFont: Qt.font({ family: "Arial", pointSize: 14, bold: true })
                    }

                    LineSeries {
                        id: depthSeries
                        name: "Depth"
                        axisX: axisX
                        axisY: axisYDepth
                        color: "#1f77b4"
                        width: 2
                    }

                    LineSeries {
                        id: temperatureSeries
                        name: "Temperature"
                        axisX: axisX
                        axisYRight: axisYTemp
                        color: "#ff7f0e"
                        width: 2
                        style: Qt.DashLine
                    }
                }
            }
        }
    }

    Popup {
        id: normalPopup
        ColumnLayout {
            anchors.fill: parent
            Label { text: 'Normal Popup' }
            CheckBox { text: 'E-mail' }
            CheckBox { text: 'Calendar' }
            CheckBox { text: 'Contacts' }
        }
    }

    Popup {
        id: modalPopup
        modal: true
        ColumnLayout {
            anchors.fill: parent
            Label { text: 'Modal Popup' }
            CheckBox { text: 'E-mail' }
            CheckBox { text: 'Calendar' }
            CheckBox { text: 'Contacts' }
        }
    }

    Dialog {
        id: dialog
        title: 'Dialog'
        Label { text: 'The standard dialog.' }
        footer: DialogButtonBox {
            standardButtons: DialogButtonBox.Ok | DialogButtonBox.Cancel
        }
    }
}
