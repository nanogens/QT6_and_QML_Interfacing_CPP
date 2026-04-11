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
    readonly property int lOG_TRANSMITDATA_SET_MSGID: 0x54

    // Source selection state
    property string selectedSource: ""  // "", "device", "local", "cloud"
    property var currentFileList: []     // Store current files from active source
    property var selectedFileData: null   // Currently selected file data

    // Show status in file details area
    property string downloadStatus: ""

    // Download state properties
    property bool isDownloading: false
    property int currentDownloadFileIndex: -1

    // To accumulate page data in QML
    property int totalQuadrantsToDownload: 0
    property int downloadedQuadrants: 0
    property int currentPage: 0
    property int currentQuadrant: 0
    property var currentPageData: []  // Store 4 quadrants for current page
    property var currentDownloadData: []  // Store complete pages

    // Graph related properties
    property var currentDataPoints: []  // Store current data for replotting

    // requestQuadrant retry tracking
    property int retryCount: 0
    property int maxRetries: 3
    property int pendingFileIndex: -1
    property int pendingPage: -1
    property int pendingQuadrant: -1

    anchors.fill: parent
    columns: 2
    rows: 1

    // Timer for timeout handling
    Timer {
        id: quadrantTimeout
        interval: 5000  // Increase from 2000 to 5000ms (5 seconds)
        repeat: false
        onTriggered: {
            if (isDownloading && pendingFileIndex !== -1) {
                console.log("Timeout - retrying quadrant. Pending:", pendingPage, pendingQuadrant);
                retryCount++;
                if (retryCount < maxRetries) {
                    requestQuadrant(pendingFileIndex, pendingPage, pendingQuadrant);
                } else {
                    console.log("Max retries exceeded - download failed");
                    cancelDownload();
                }
            }
        }
    }

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

        // Always request fresh device files from instrument
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
            // Calculate total pages needed for this file (512 bytes per page)
            var fileSizeBytes = deviceFiles[i].fileSizeBytes;
            var quadrantsNeeded = Math.ceil(fileSizeBytes / 128);  // 128 bytes per quadrant

            var fileInfo = {
                fileName: deviceFiles[i].fileName,
                fileSize: formatFileSize(fileSizeBytes),
                fileSizeBytes: fileSizeBytes,
                totalQuadrants: quadrantsNeeded,  // Store total quadrants
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
                totalQuadrants: quadrantsNeeded,  // Keep naming consistent
                fileDateTimeTimestamp: fileInfo.fileDateTimeTimestamp
            };
            fileListModel.append(displayInfo);
        }

        currentFileList = filesData;
        console.log("Device file list updated with", fileListModel.count, "files");
    }

    function clearAndSetSource(source) {
        console.log("Clearing ListView and setting source to:", source);

        // Clear current selection
        fileListView.currentIndex = -1;
        selectedFileData = null;

        // Clear file details area
        fileDetailsText.text = "No file selected";

        // Clear the graph when switching sources
        clearGraph();

        // Clear file list model and cached data
        fileListModel.clear();
        currentFileList = [];

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
        if (!points || points.length === 0) {
            console.log("No points to chart");
            clearGraph();  // Add this line
            return;
        }

        // Store for replotting when checkboxes change
        currentDataPoints = points;

        // Clear existing data
        depthSeries.clear();
        temperatureSeries.clear();
        conductivitySeries.clear();

        var minTime = Number.MAX_VALUE;
        var maxTime = Number.MIN_VALUE;
        var minDepth = Number.MAX_VALUE;
        var maxDepth = Number.MIN_VALUE;
        var minTemp = Number.MAX_VALUE;
        var maxTemp = Number.MIN_VALUE;
        var minCond = Number.MAX_VALUE;
        var maxCond = Number.MIN_VALUE;

        for (var i = 0; i < points.length; i++) {
            var point = points[i];
            var timeMinutes = timeStringToMinutes(point.time);
            var depth = point.depth;
            var temp = point.temperature;
            var cond = point.conductivity;

            if (showDepthCheckBox.checked) {
                depthSeries.append(timeMinutes, depth);
            }
            if (showTempCheckBox.checked) {
                temperatureSeries.append(timeMinutes, temp);
            }
            if (showCondCheckBox.checked) {
                conductivitySeries.append(timeMinutes, cond);
            }

            minTime = Math.min(minTime, timeMinutes);
            maxTime = Math.max(maxTime, timeMinutes);
            minDepth = Math.min(minDepth, depth);
            maxDepth = Math.max(maxDepth, depth);
            minTemp = Math.min(minTemp, temp);
            maxTemp = Math.max(maxTemp, temp);
            minCond = Math.min(minCond, cond);
            maxCond = Math.max(maxCond, cond);
        }

        // Update axes with padding
        axisX.min = Math.max(0, minTime - 5);
        axisX.max = maxTime + 5;

        if (showDepthCheckBox.checked && minDepth !== Number.MAX_VALUE) {
            axisYDepth.min = Math.max(0, minDepth - 5);
            axisYDepth.max = maxDepth + 5;
            axisYDepth.visible = true;
        } else {
            axisYDepth.visible = false;
        }

        if (showTempCheckBox.checked && minTemp !== Number.MAX_VALUE) {
            axisYTemp.min = Math.max(-40, minTemp - 2);
            axisYTemp.max = Math.min(85, maxTemp + 2);
            axisYTemp.visible = true;
        } else {
            axisYTemp.visible = false;
        }

        if (showCondCheckBox.checked && minCond !== Number.MAX_VALUE) {
            axisYCond.min = Math.max(0, minCond - 2);
            axisYCond.max = maxCond + 2;
            axisYCond.visible = true;
        } else {
            axisYCond.visible = false;
        }
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

    // Start downloading a device file
    function startDeviceFileDownload(fileIndex, fileName) {
        if (isDownloading) {
            console.log("Download already in progress, canceling first");
            cancelDownload();
        }

        // Find the selected file to get total pages
        var selectedFile = null;
        for (var i = 0; i < currentFileList.length; i++) {
            if (currentFileList[i].fileIndex === fileIndex) {
                selectedFile = currentFileList[i];
                break;
            }
        }

        if (!selectedFile) {
            console.log("Error: Could not find file with index", fileIndex);
            return;
        }

        isDownloading = true;
        currentDownloadFileIndex = fileIndex;
        downloadedQuadrants = 0;
        totalQuadrantsToDownload = selectedFile.totalQuadrants;
        currentPage = 0;
        currentQuadrant = 0;
        currentPageData = [];
        currentDownloadData = [];  // // Clear previous download data, Store complete pages

        // Update UI
        downloadProgress.visible = true;
        downloadStatusText.visible = true;
        downloadStatusText.text = "Downloading " + fileName + "...";
        downloadStatusText.color = "#4CAF50";
        fileDetailsText.text = "Downloading: " + fileName + " (0/" + totalQuadrantsToDownload + " quadrants)";  // Change this
        loadButton.enabled = false;
        loadButton.text = "Downloading...";
        downloadProgress.value = 0;

        // Start the download process - Request first quadrant
        requestQuadrant(fileIndex, 0, 0);  // page 0, quadrant 0
    }

    // Request a specific page of the device file
    function requestDeviceFilePage(fileIndex, pageNumber) {
        requestQuadrant(fileIndex, pageNumber, 0);  // Start with quadrant 0
    }

    // Cancel ongoing download
    function cancelDownload() {
        isDownloading = false;
        currentDownloadFileIndex = -1;
        downloadedQuadrants = 0;

        // Stop timeout timer
        quadrantTimeout.stop();

        // Reset retry tracking
        retryCount = 0;
        pendingFileIndex = -1;
        pendingPage = -1;
        pendingQuadrant = -1;

        downloadProgress.visible = false;
        downloadStatusText.visible = false;
        fileDetailsText.text = "Download cancelled";
        loadButton.enabled = true;
        loadButton.text = "Download & Graph";
    }

    function requestQuadrant(fileIndex, pageNumber, quadrantNumber) {
        console.log("Sending request for quadrant:", quadrantNumber, "page:", pageNumber);
        console.log("downloadedQuadrants:", downloadedQuadrants, "totalQuadrantsToDownload:", totalQuadrantsToDownload);

        var requestTime = Date.now();
        console.log("[" + requestTime + "] Requesting page:", pageNumber, "quadrant:", quadrantNumber);

        pendingFileIndex = fileIndex;
        pendingPage = pageNumber;
        pendingQuadrant = quadrantNumber;

        var arr = [lOG_TRANSMITDATA_SET_MSGID, fileIndex, pageNumber, quadrantNumber];
        CppClass.processOutgoingMsg(arr, {});
    }

    function finishDeviceFileDownload() {
        // Assemble all pages into complete file data
        var completeFileData = [];
        for (var i = 0; i < totalQuadrantsToDownload; i++) {  // Change this
            if (currentDownloadData[i]) {
                completeFileData = completeFileData.concat(currentDownloadData[i]);
            }
        }

        // Parse the complete file data
        var fileContent = parseDeviceFileData(completeFileData);

        // Graph the data
        if (fileContent && fileContent.points) {
            updateChart(fileContent.points);

            // Update metadata display
            if (fileContent.metadata) {
                //deviceInfo.text = fileContent.metadata.device + " - " + fileContent.metadata.serialNumber;
                //timeInfo.text = fileContent.metadata.instrumentTime + " " + fileContent.metadata.timeZone;
            }
        }

        // Reset UI
        isDownloading = false;
        currentDownloadFileIndex = -1;
        currentDownloadData = [];
        downloadProgress.visible = false;
        downloadStatusText.visible = false;
        downloadStatusText.text = "";
        fileDetailsText.text = "Download complete: " + selectedFileData.fileName;
        loadButton.enabled = true;
        loadButton.text = "Download & Graph";
    }

    function parseDeviceFileData(rawData) {
        // Convert raw byte array to text and parse
        var text = "";
        for (var i = 0; i < rawData.length; i++) {
            text += String.fromCharCode(rawData[i]);
        }

        // Parse metadata and CSV data (same as local file parsing)
        var lines = text.split('\n');
        var metadata = {};
        var dataPoints = [];
        var readingMetadata = true;

        for (var line of lines) {
            line = line.trim();
            if (line === "") continue;

            if (readingMetadata && line.indexOf(":") !== -1) {
                var colonIndex = line.indexOf(":");
                var key = line.substring(0, colonIndex).trim();
                var value = line.substring(colonIndex + 1).trim();
                metadata[key] = value;
            } else if (line.indexOf(",") !== -1) {
                readingMetadata = false;
                var parts = line.split(",");
                if (parts.length >= 3) {
                    dataPoints.push({
                        time: parts[0].trim(),
                        temperature: parseFloat(parts[1]),
                        depth: parseFloat(parts[2])
                    });
                }
            }
        }

        return {
            metadata: metadata,
            points: dataPoints
        };
    }

    function handleDeviceFilePageReceived(fileIndex, pageNumber, quadrantNumber, pageData) {
        var receiveTime = Date.now();
        console.log("[" + receiveTime + "] Received quadrant:", quadrantNumber, "for page:", pageNumber);

        if (!isDownloading || currentDownloadFileIndex !== fileIndex) return;

        // Stop timeout timer
        quadrantTimeout.stop();
        console.log("Timer stopped");

        // Reset retry count on successful receive
        retryCount = 0;

        // Store quadrant in current page buffer
        currentPageData[quadrantNumber] = pageData;
        downloadedQuadrants++;
        currentQuadrant = quadrantNumber;

        // Update progress
        var progress = (downloadedQuadrants / totalQuadrantsToDownload) * 100;
        downloadProgress.value = progress;

        // Check if we have all 4 quadrants for current page
        if (currentPageData.length === 4) {
            // Assemble complete page (512 bytes)
            var completePage = [];
            for (var i = 0; i < 4; i++) {
                completePage = completePage.concat(currentPageData[i]);
            }
            currentDownloadData[currentPage] = completePage;
            currentPageData = [];
            currentPage++;

            // Check if download complete
            if (downloadedQuadrants >= totalQuadrantsToDownload) {
                finishDeviceFileDownload();
                return;
            }
        }

        // Request next quadrant
        var nextQuadrant = (currentQuadrant + 1) % 4;
        var nextPage = currentPage;
        if (nextQuadrant === 0) nextPage++;

        console.log("Requesting next quadrant:", nextQuadrant, "page:", nextPage);
        requestQuadrant(fileIndex, nextPage, nextQuadrant);
    }

    function clearGraph() {
        // Clear all series
        depthSeries.clear();
        temperatureSeries.clear();
        conductivitySeries.clear();

        // Clear stored data points
        currentDataPoints = [];

        // Reset axes to default ranges
        axisX.min = 0;
        axisX.max = 200;
        axisYDepth.min = 0;
        axisYDepth.max = 100;
        axisYTemp.min = 0;
        axisYTemp.max = 30;
        axisYCond.min = 0;
        axisYCond.max = 60;

        console.log("Graph cleared");
    }

    function resetToDefaultState() {
        console.log("Resetting to default state");

        // Reset source selection
        selectedSource = "";

        // Clear file list and selection
        fileListModel.clear();
        currentFileList = [];
        selectedFileData = null;
        fileListView.currentIndex = -1;

        // Clear file details area
        fileDetailsText.text = "No file selected";

        // Hide load button
        loadButton.visible = false;
        loadButton.enabled = true;
        loadButton.text = "Download & Graph";

        // Clear any ongoing download
        if (isDownloading) {
            cancelDownload();
        }
        isDownloading = false;
        currentDownloadFileIndex = -1;
        downloadedQuadrants = 0;
        totalQuadrantsToDownload = 0;
        currentPage = 0;
        currentQuadrant = 0;
        currentPageData = [];
        currentDownloadData = [];

        // Reset retry tracking
        retryCount = 0;
        pendingFileIndex = -1;
        pendingPage = -1;
        pendingQuadrant = -1;

        // Clear the graph
        clearGraph();

        // Reset button visual states
        updateButtonStates();

        // Reset folder model (clear any cached folder)
        folderModel.folder = "";

        console.log("Reset complete");
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

        onDeviceFilePageReceived: function(fileIndex, sectorNumber, pageNumber, quadrantNumber, pageData) {
            handleDeviceFilePageReceived(fileIndex, pageNumber, quadrantNumber, pageData);
        }

        onFileDataReady: function(metadata, dataPoints) {
            console.log("=== onFileDataReady called ===");

            if (dataPoints.length === 0) {
                console.log("WARNING: No data points to display!");
                return;
            }

            // Remove these two lines - deviceInfo and timeInfo no longer exist
            // deviceInfo.text = metadata.device + " - " + metadata.serialNumber;
            // timeInfo.text = metadata.instrumentTime + " " + metadata.timeZone;

            console.log("Calling updateChart with", dataPoints.length, "points");
            updateChart(dataPoints);
        }

        onDeviceFileMetadataReceived: function(fileIndex, isValid, metadata) {
            console.log("Metadata received for file:", fileIndex, "isValid:", isValid);
            if (isValid) {
                fileDetailsText.text = "File " + fileIndex + ": Has valid data";
            } else {
                fileDetailsText.text = "File " + fileIndex + ": Empty slot";
            }
        }
    }

    // Left Column - File Operations and Details
    ColumnLayout {
        id: leftColumn
        Layout.fillWidth: true
        Layout.fillHeight: true
        spacing: 10

        // File Operations Box - now fits content tightly
        CellBox {
            title: 'File Operations'
            Layout.fillWidth: true
            Layout.preferredHeight: implicitHeight  // Let it size to content
            Layout.maximumHeight: parent.height * 0.5  // Cap at 50% if needed

            ColumnLayout {
                anchors.fill: parent
                spacing: 10

                // Source selection buttons
                RowLayout {
                    spacing: 10
                    Layout.fillWidth: true

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
                                // Already in local mode - refresh by reopening the dialog
                                // Clear current state first
                                clearAndSetSource("local");
                                // Open dialog to select a (potentially different) folder
                                folderDialog.open();
                            }
                        }
                    }

                    Button {
                        id: cloudButton
                        property bool selected: false
                        text: "Cloud"
                        Layout.fillWidth: true
                        implicitHeight: 40
                        enabled: false

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
                        }
                    }
                }

                // File List View - fixed height based on content
                ListView {
                    id: fileListView
                    currentIndex: -1
                    Layout.fillWidth: true
                    implicitHeight: contentHeight + 10  // Height based on content
                    Layout.maximumHeight: 300
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

                                fileDetailsText.text = "Selected: " + selectedFile.fileName;

                                if (selectedFile.source === "local") {
                                    loadButton.visible = true;
                                    loadButton.text = "Load & Graph";
                                } else if (selectedFile.source === "device") {
                                    loadButton.visible = true;
                                    loadButton.text = "Download & Graph";
                                    requestDeviceFile(selectedFile.fileIndex);
                                }

                                console.log("Selected file:", selectedFile.fileName, "from source:", selectedFile.source);
                            }
                        }
                    }

                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }

        // File Details Area - now gets more space
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true  // Takes remaining vertical space
            Layout.minimumHeight: 150
            color: "#2a2a2a"
            border.color: "#555555"
            border.width: 1
            radius: 6

            Column {
                anchors.fill: parent
                anchors.margins: 10
                spacing: 8

                Text {
                    text: "File Details"
                    font.bold: true
                    font.pixelSize: 18
                    color: "#FFA500"
                }

                Rectangle {
                    width: parent.width
                    height: 1
                    color: "#555555"
                }

                Text {
                    id: fileDetailsText
                    text: "No file selected"
                    font.pixelSize: 16
                    color: "#cccccc"
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                // Progress bar for device file download
                ProgressBar {
                    id: downloadProgress
                    width: parent.width
                    visible: false
                    from: 0
                    to: 100
                    value: 0
                }

                Text {
                    id: downloadStatusText
                    text: ""
                    font.pixelSize: 14
                    color: "#4CAF50"
                    visible: false
                    wrapMode: Text.WordWrap
                    width: parent.width
                }
            }
        }

        // Load Button (below File Details)
        Button {
            id: loadButton
            text: "Download & Graph"
            Layout.fillWidth: true
            implicitHeight: 50  // Increased from 40
            visible: false

            contentItem: Text {
                text: parent.text
                font.pixelSize: 22  // Increased from 18
                font.bold: true
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: parent.enabled ? "#4CAF50" : "#cccccc"
                radius: 6  // Slightly larger radius for taller button
            }

            onClicked: {
                if (selectedFileData) {
                    if (selectedFileData.source === "local") {
                        console.log("Loading local file:", selectedFileData.fullPath);
                        loadLocalFile(selectedFileData.fullPath);
                    } else if (selectedFileData.source === "device") {
                        console.log("Starting download of device file with index:", selectedFileData.fileIndex);
                        startDeviceFileDownload(selectedFileData.fileIndex, selectedFileData.fileName);
                    }
                } else {
                    console.log("No file selected!");
                }
            }
        }
    }

    // Right Column - Graph
    CellBox {
        id: graphCellBox
        Layout.rowSpan: 2
        Layout.minimumWidth: 700
        title: 'Graph'
        Layout.preferredWidth: height

        ColumnLayout {
            anchors.fill: parent
            spacing: 2

            // Parameter selection row - acts as legend
            RowLayout {
                spacing: 25
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 0
                Layout.bottomMargin: 2

                CheckBox {
                    id: showDepthCheckBox
                    text: "Depth"
                    checked: true
                    font.pixelSize: 20
                    font.bold: true

                    indicator: Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        x: 0
                        y: parent.height / 2 - height / 2
                        radius: 4
                        border.color: "#cccccc"
                        border.width: 2
                        color: "transparent"

                        // White check mark (outline style)
                        Text {
                            text: "✓"
                            color: "#ffffff"
                            font.pixelSize: 18
                            anchors.centerIn: parent
                            visible: showDepthCheckBox.checked
                        }
                    }

                    contentItem: Text {
                        text: showDepthCheckBox.text
                        font: showDepthCheckBox.font
                        color: "#1f77b4"
                        leftPadding: 32
                        verticalAlignment: Text.AlignVCenter
                    }

                    onCheckedChanged: {
                        if (currentDataPoints.length > 0) {
                            updateChart(currentDataPoints);
                        }
                    }
                }

                CheckBox {
                    id: showTempCheckBox
                    text: "Temperature"
                    checked: true
                    font.pixelSize: 20
                    font.bold: true

                    indicator: Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        x: 0
                        y: parent.height / 2 - height / 2
                        radius: 4
                        border.color: "#cccccc"
                        border.width: 2
                        color: "transparent"

                        Text {
                            text: "✓"
                            color: "#ffffff"
                            font.pixelSize: 18
                            anchors.centerIn: parent
                            visible: showTempCheckBox.checked
                        }
                    }

                    contentItem: Text {
                        text: showTempCheckBox.text
                        font: showTempCheckBox.font
                        color: "#ff7f0e"
                        leftPadding: 32
                        verticalAlignment: Text.AlignVCenter
                    }

                    onCheckedChanged: {
                        if (currentDataPoints.length > 0) {
                            updateChart(currentDataPoints);
                        }
                    }
                }

                CheckBox {
                    id: showCondCheckBox
                    text: "Conductivity"
                    checked: false
                    font.pixelSize: 20
                    font.bold: true

                    indicator: Rectangle {
                        implicitWidth: 24
                        implicitHeight: 24
                        x: 0
                        y: parent.height / 2 - height / 2
                        radius: 4
                        border.color: "#cccccc"
                        border.width: 2
                        color: "transparent"

                        Text {
                            text: "✓"
                            color: "#ffffff"
                            font.pixelSize: 18
                            anchors.centerIn: parent
                            visible: showCondCheckBox.checked
                        }
                    }

                    contentItem: Text {
                        text: showCondCheckBox.text
                        font: showCondCheckBox.font
                        color: "#2ca02c"
                        leftPadding: 32
                        verticalAlignment: Text.AlignVCenter
                    }

                    onCheckedChanged: {
                        if (currentDataPoints.length > 0) {
                            updateChart(currentDataPoints);
                        }
                    }
                }
            }

            TabBar {
                id: bar
                width: parent.width
                implicitHeight: 36
                Layout.bottomMargin: 2
                TabButton {
                    text: 'Plot'
                    font.pixelSize: 16
                }
                visible: false // This hides the entire Toolbar.  If we need it later, we can
            }

            StackLayout {
                id: chartStack
                width: parent.width
                height: parent.height - bar.height - 45
                currentIndex: bar.currentIndex

                ChartView {
                    id: chartView
                    width: parent.width
                    height: parent.height
                    theme: ChartView.ChartThemeDark
                    antialiasing: true
                    legend.visible: false  // Legend removed

                    // X-Axis (Time)
                    ValueAxis {
                        id: axisX
                        titleText: "Time (minutes)"
                        titleFont: Qt.font({ family: "Arial", pointSize: 18, bold: true })
                        labelsFont: Qt.font({ family: "Arial", pointSize: 16 })
                        min: 0
                        max: 200
                        labelFormat: "%.0f"
                    }

                    // Left Y-Axis (Depth)
                    ValueAxis {
                        id: axisYDepth
                        titleText: "Depth (m)"
                        titleFont: Qt.font({ family: "Arial", pointSize: 18, bold: true })
                        labelsFont: Qt.font({ family: "Arial", pointSize: 16 })
                        min: 0
                        max: 100
                        visible: showDepthCheckBox.checked
                    }

                    // Right Y-Axis (Temperature)
                    ValueAxis {
                        id: axisYTemp
                        titleText: "Temperature (°C)"
                        titleFont: Qt.font({ family: "Arial", pointSize: 18, bold: true })
                        labelsFont: Qt.font({ family: "Arial", pointSize: 16 })
                        min: 0
                        max: 30
                        visible: showTempCheckBox.checked
                    }

                    // Additional Right Y-Axis (Conductivity)
                    ValueAxis {
                        id: axisYCond
                        titleText: "Conductivity (mS/cm)"
                        titleFont: Qt.font({ family: "Arial", pointSize: 18, bold: true })
                        labelsFont: Qt.font({ family: "Arial", pointSize: 16 })
                        min: 0
                        max: 60
                        visible: showCondCheckBox.checked
                    }

                    LineSeries {
                        id: depthSeries
                        name: "Depth"
                        axisX: axisX
                        axisY: axisYDepth
                        color: "#1f77b4"
                        width: 3
                        visible: showDepthCheckBox.checked
                    }

                    LineSeries {
                        id: temperatureSeries
                        name: "Temperature"
                        axisX: axisX
                        axisYRight: axisYTemp
                        color: "#ff7f0e"
                        width: 3
                        style: Qt.DashLine
                        visible: showTempCheckBox.checked
                    }

                    LineSeries {
                        id: conductivitySeries
                        name: "Conductivity"
                        axisX: axisX
                        axisYRight: axisYCond
                        color: "#2ca02c"
                        width: 3
                        style: Qt.DotLine
                        visible: showCondCheckBox.checked
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
