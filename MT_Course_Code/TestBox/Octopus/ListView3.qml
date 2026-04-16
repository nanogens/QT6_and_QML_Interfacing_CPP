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
    property var pendingDownloadData: null  // Store downloaded data before surface pressure selection

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

    // Pending download info (before pressure selection)
    property int pendingDownloadFileIndex: -1
    property string pendingDownloadFileName: ""
    property var pendingDownloadSelectedFile: null
    property real pendingSurfacePressure: 1013.25
    property string pendingPressureSource: "Standard"

    // barometric pressure compensation dialog
    property var barometerData: []  // Stores {timestamp, pressure} from C++

    // Surface pressure indicator
    property string currentPressureMethod: "Standard"
    property real currentPressureValue: 1013.25
    property var rawSensorData: []  // Store raw data for re-calculation
    property bool isAdjustingPressure: false

    property var rawPressureData: []  // Store {time, temperature, pressure_mbar, conductivity}
    property var persistentRawData: null  // Store raw downloaded data permanently

    property string barometerOverlapWarning: ""  // Empty = no warning
    property string barometerOverlapStatus: ""  // e.g., "✓ Complete overlap (100%)", "⚠️ Partial overlap (50%)"

    property bool isEmptyBarometerFallback: false  // Track if we're using empty barometer fallback

    property int autoZeroSeconds: 5  // Default 5 seconds


    anchors.fill: parent
    columns: 2
    rows: 1

    // Timer for timeout handling
    Timer {
        id: quadrantTimeout
        interval: 5000
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

    // Barometer File Dialog
    FileDialog {
        id: baroFileDialog
        title: "Select Barometer File"
        nameFilters: ["Barometer files (*.bar)", "CSV files (*.csv)", "All files (*)"]
        onAccepted: {
            baroFilePathField.text = selectedFile.toString().replace(/^(file:\/{3})/, "");
            console.log("Selected barometer file:", baroFilePathField.text);
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
            // ONLY check the 0x99 marker - skip if not occupied
            if (!deviceFiles[i].isValid) {
                console.log("Skipping file slot", deviceFiles[i].fileIndex, "- not occupied (no 0x99 marker)");
                continue;
            }

            // The value is total page records INCLUDING page headers
            var totalPageRecords = deviceFiles[i].totalPageRecords;

            // Calculate pages used (each page holds 16 page records including 1 header)
            var pageCount = Math.ceil(totalPageRecords / 16);

            // Calculate actual data records (exclude the 1 header per page)
            var fileDataRecords = totalPageRecords - pageCount;

            // Calculate total quadrants needed (based on total bytes, not records)
            var totalBytes = pageCount * 512;
            var quadrantsToDownload = totalBytes / 128;

            var fileInfo = {
                fileName: deviceFiles[i].fileName,
                totalPageRecords: totalPageRecords,
                fileDataRecords: fileDataRecords,
                pageCount: pageCount,
                quadrantsToDownload: quadrantsToDownload,
                fileDateTime: deviceFiles[i].fileDateTime,
                fileDateTimeTimestamp: deviceFiles[i].fileDateTimeTimestamp,
                fileIndex: deviceFiles[i].fileIndex,
                isValid: deviceFiles[i].isValid,
                source: "device"
            };

            filesData.push(fileInfo);

            var displayInfo = {
                fileName: fileInfo.fileName,
                recordCount: fileInfo.fileDataRecords + " data records",
                timeClosed: formatDeviceDateTime(fileInfo.fileDateTime),
                source: "device",
                fileIndex: fileInfo.fileIndex,
                quadrantsToDownload: quadrantsToDownload,
                totalPageRecords: totalPageRecords,
                pageCount: pageCount,
                isValid: fileInfo.isValid,
                fileDateTimeTimestamp: fileInfo.fileDateTimeTimestamp
            };
            fileListModel.append(displayInfo);
        }

        currentFileList = filesData;
        console.log("Device file list updated with", fileListModel.count, "files");
    }

    function clearAndSetSource(source) {
        console.log("Clearing ListView and setting source to:", source);

        // Ensure cancel button is hidden when switching sources
        cancelButton.visible = false;
        loadButton.visible = false;

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

        // Reset barometer-related properties
        barometerOverlapWarning = "";
        barometerOverlapStatus = "";
        isEmptyBarometerFallback = false;
        barometerData = [];

        // Reset pressure method to default
        currentPressureMethod = "Standard";
        currentPressureValue = 1013.25;

        // Clear raw data
        rawSensorData = [];
        rawPressureData = [];
        persistentRawData = null;
        currentDataPoints = [];

        // Hide adjust pressure button
        adjustPressureButton.visible = false;

        // Set new source
        selectedSource = source;

        // Update button visual states
        updateButtonStates();

        console.log("Source changed to:", source, "- UI reset complete");
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

        // Extract components
        var year = 2000 + (dateTimeObj.year || 0);
        var month = (dateTimeObj.month || 1);
        var day = (dateTimeObj.day || 1);
        var hour = (dateTimeObj.hour || 0);
        var minute = (dateTimeObj.minute || 0);
        var second = (dateTimeObj.second || 0);
        var ampm = dateTimeObj.ampm;

        // Format hour for display (12-hour format)
        var displayHour = hour;
        var ampmStr = "";

        if (ampm !== undefined) {
            // Convert 24-hour to 12-hour for display
            if (hour === 0 || hour === 12) {
                displayHour = 12;
            } else {
                displayHour = hour % 12;
            }
            ampmStr = (ampm === 1) ? " PM" : " AM";
        }

        // Format the date string with AM/PM
        var date = new Date(year, month - 1, day, hour, minute, second);
        var dateStr = date.toLocaleString(Qt.locale(), "yyyy-MM-dd");
        var timeStr = displayHour.toString().padStart(2, '0') + ":" +
                      minute.toString().padStart(2, '0') + ":" +
                      second.toString().padStart(2, '0') + ampmStr;

        return dateStr + " " + timeStr;
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

    // Convert time string (e.g., "6:41:24 PM") to elapsed minutes since midnight
    function timeToElapsedMinutes(timeStr) {
        // Parse format like "6:41:24 PM" or "06:41:24"
        var parts = timeStr.split(":");
        if (parts.length >= 2) {
            var hours = parseInt(parts[0]);
            var minutes = parseInt(parts[1]);
            var seconds = 0;
            var isPM = false;

            // Extract seconds (may have AM/PM attached)
            var secondPart = parts[2];
            if (secondPart) {
                var secondParts = secondPart.split(" ");
                seconds = parseInt(secondParts[0]);
                if (secondParts.length > 1 && secondParts[1] === "PM") {
                    isPM = true;
                }
            }

            // Convert to 24-hour format
            if (isPM && hours !== 12) {
                hours += 12;
            } else if (!isPM && hours === 12) {
                hours = 0;
            }

            // Convert to minutes
            return hours * 60 + minutes + seconds / 60;
        }
        return 0;
    }

    // Update chart with data points
    function updateChart(points) {
        if (!points || points.length === 0) {
            console.log("No points to chart");
            clearGraph();
            return;
        }

        // Store for replotting when checkboxes change
        currentDataPoints = points;

        // Clear existing data
        depthSeries.clear();
        temperatureSeries.clear();
        conductivitySeries.clear();

        // Get first timestamp as reference
        var firstTimeMinutes = timeToElapsedMinutes(points[0].time);

        // Determine if we should use seconds (duration < 1 minute)
        var lastTimeMinutes = timeToElapsedMinutes(points[points.length - 1].time);
        var totalDurationMinutes = lastTimeMinutes - firstTimeMinutes;
        var useSeconds = (totalDurationMinutes < 1);

        var minTime = 0;  // First point is always 0
        var maxTime = 0;
        var minDepth = Number.MAX_VALUE;
        var maxDepth = Number.MIN_VALUE;
        var minTemp = Number.MAX_VALUE;
        var maxTemp = Number.MIN_VALUE;
        var minCond = Number.MAX_VALUE;
        var maxCond = Number.MIN_VALUE;

        for (var i = 0; i < points.length; i++) {
            var point = points[i];
            var elapsedMinutes = timeToElapsedMinutes(point.time) - firstTimeMinutes;

            // Convert to seconds if needed
            var timeValue = useSeconds ? elapsedMinutes * 60 : elapsedMinutes;
            var depth = point.depth;
            var temp = point.temperature;
            var cond = point.conductivity;

            if (showDepthCheckBox.checked) {
                depthSeries.append(timeValue, depth);
            }
            if (showTempCheckBox.checked) {
                temperatureSeries.append(timeValue, temp);
            }
            if (showCondCheckBox.checked) {
                conductivitySeries.append(timeValue, cond);
            }

            maxTime = Math.max(maxTime, timeValue);
            minDepth = Math.min(minDepth, depth);
            maxDepth = Math.max(maxDepth, depth);
            minTemp = Math.min(minTemp, temp);
            maxTemp = Math.max(maxTemp, temp);
            minCond = Math.min(minCond, cond);
            maxCond = Math.max(maxCond, cond);
        }

        // Set axis ranges with padding
        axisX.min = Math.max(0, minTime - (useSeconds ? 5 : 5));
        axisX.max = maxTime + (useSeconds ? 5 : 5);

        // Set axis title based on unit
        if (useSeconds) {
            axisX.titleText = "Time (seconds)";
            axisX.labelFormat = "%.0f";
        } else {
            axisX.titleText = "Time (minutes)";
            axisX.labelFormat = "%.1f";
        }

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

        var durationDisplay = useSeconds ? (maxTime).toFixed(0) + " seconds" : (maxTime).toFixed(1) + " minutes";
        console.log("Chart updated - Duration:", durationDisplay);
    }

    function addToChart(newPoints) {
        console.log("Adding", newPoints.length, "new points to chart");

        for (var i = 0; i < newPoints.length; i++) {
            var point = newPoints[i];
            var timeMinutes = timeToElapsedMinutes(point.time);  // Change this line

            depthSeries.append(timeMinutes, point.depth);
            temperatureSeries.append(timeMinutes, point.temperature);
        }
    }

    // Start downloading a device file (shows pressure dialog first)
    function startDeviceFileDownload(fileIndex, fileName) {
        if (isDownloading) {
            console.log("Download already in progress, canceling first");
            cancelDownload();
        }

        // Clear persistent data when starting a new download
        clearPersistentData();

        // Find the selected file to get quadrants to download
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

        // Store pending download info
        pendingDownloadFileIndex = fileIndex;
        pendingDownloadFileName = fileName;
        pendingDownloadSelectedFile = selectedFile;

        // Show the surface pressure dialog BEFORE downloading
        surfacePressureDialog.open();
    }

    // Request a specific page of the device file
    function requestDeviceFilePage(fileIndex, pageNumber) {
        requestQuadrant(fileIndex, pageNumber, 0);  // Start with quadrant 0
    }

    // Cancel ongoing download
    function cancelDownload(clearPersistent = false) {
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

        // Re-enable source buttons after cancel
        deviceButton.enabled = true;
        localButton.enabled = true;
        cloudButton.enabled = true;

        // Hide cancel button, show load button
        cancelButton.visible = false;
        loadButton.visible = true;

        // Optionally clear persistent data
        if (clearPersistent) {
            clearPersistentData();
        }
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
        for (var i = 0; i < totalQuadrantsToDownload; i++) {
            if (currentDownloadData[i]) {
                completeFileData = completeFileData.concat(currentDownloadData[i]);
            }
        }

        // Store the downloaded data PERSISTENTLY (not just pending)
        persistentRawData = completeFileData;  // Store permanently
        pendingDownloadData = completeFileData;  // Also keep for current operation

        // Reset UI
        isDownloading = false;
        currentDownloadFileIndex = -1;
        currentDownloadData = [];

        // Reset pending download info
        pendingDownloadFileIndex = -1;
        pendingDownloadFileName = "";
        pendingDownloadSelectedFile = null;

        downloadProgress.visible = false;
        downloadStatusText.visible = false;
        loadButton.visible = true;
        cancelButton.visible = false;
        loadButton.enabled = true;
        loadButton.text = "Download & Graph";

        // Re-enable source buttons after download completes
        deviceButton.enabled = true;
        localButton.enabled = true;
        cloudButton.enabled = true;

        // Clear the timeout timer
        quadrantTimeout.stop();

        // Reset retry tracking
        retryCount = 0;
        pendingFileIndex = -1;
        pendingPage = -1;
        pendingQuadrant = -1;

        // Process the data based on pressure source
        if (pendingPressureSource === "BarometerFile") {
            // Check if we have an empty barometer fallback
            if (isEmptyBarometerFallback) {
                processAndGraphDownloadedData(pendingSurfacePressure, "Standard", true);
            } else {
                // Process with barometer data
                processAndGraphDownloadedDataWithBarometer(pendingSurfacePressure, pendingPressureSource);
            }
        } else {
            // Process with regular pressure method
            processAndGraphDownloadedData(pendingSurfacePressure, pendingPressureSource);
        }

        // Clear pending data but keep persistentRawData
        pendingDownloadData = null;
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
        downloadStatusText.text = progress.toFixed(1) + "%";
        fileDetailsText.text = "Downloading: " + selectedFileData.fileName + " (" + downloadedQuadrants + "/" + totalQuadrantsToDownload + " quadrants)";

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

            console.log("Page assembled. Current page index:", currentPage);
        }

        // Check if download is complete
        if (downloadedQuadrants >= totalQuadrantsToDownload) {
            console.log("All quadrants received - finishing download");
            finishDeviceFileDownload();
            return;
        }

        // Calculate next quadrant and page
        var nextQuadrant = (currentQuadrant + 1) % 4;
        var nextPage = currentPage;

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

        // Hide cancel button
        cancelButton.visible = false;

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

        // Reset barometer-related properties
        barometerOverlapWarning = "";
        barometerOverlapStatus = "";
        isEmptyBarometerFallback = false;
        barometerData = [];

        // Reset pressure method to default
        currentPressureMethod = "Standard";
        currentPressureValue = 1013.25;

        // Clear raw data
        rawSensorData = [];
        rawPressureData = [];
        persistentRawData = null;
        currentDataPoints = [];

        // Hide adjust pressure button
        adjustPressureButton.visible = false;

        // Clear the graph
        clearGraph();

        // Reset button visual states
        updateButtonStates();

        // Reset folder model (clear any cached folder)
        folderModel.folder = "";

        console.log("Reset complete");
    }

    function formatRecordCount(records) {
        return records + " records";
    }

    function processAndGraphDownloadedData(surfacePressure, pressureMethod, isEmptyBarometerFallbackParam = false) {
        console.log("Processing downloaded data with surface pressure:", surfacePressure, "mbar", "Method:", pressureMethod, "isEmptyBarometerFallbackParam:", isEmptyBarometerFallbackParam)

        // Store the pressure method and value for indicator
        currentPressureMethod = pressureMethod
        currentPressureValue = surfacePressure

        // Set empty barometer warning if this is a fallback
        if (isEmptyBarometerFallbackParam || isEmptyBarometerFallback) {
            barometerOverlapStatus = "✗ No barometer data (using Standard pressure)"
            barometerOverlapWarning = "⚠️ No barometer data available. Using Standard pressure (1013.25 mbar) instead."
            // Make sure the file details text shows the warning
            if (selectedFileData) {
                fileDetailsText.text = "Warning: Barometer file empty - using Standard pressure. " + selectedFileData.fileName
            }
        } else {
            // Only clear barometer warnings if this is NOT a fallback from empty barometer
            if (pressureMethod !== "BarometerFile") {
                barometerOverlapWarning = ""
                barometerOverlapStatus = ""
            }
        }

        // Handle Auto-zero method specially - calculate pressure after download
        if (pressureMethod === "AutoDetect") {
            // Calculate auto-zero pressure from the downloaded data
            var calculatedPressure = calculateAutoDetectPressure(autoZeroSeconds);
            currentPressureValue = calculatedPressure;
            console.log("Auto-zero method - calculated surface pressure:", calculatedPressure, "mbar");

            // Re-process with the calculated pressure
            var processedPoints = CppClass.processDeviceFileData(pendingDownloadData, calculatedPressure);

            if (processedPoints && processedPoints.length > 0) {
                updateChart(processedPoints);
                fileDetailsText.text = "Download complete: " + selectedFileData.fileName +
                                       " (" + processedPoints.length + " data records) - Auto-zero (" + calculatedPressure.toFixed(2) + " mbar)"

                // Store raw sensor data for future adjustments
                rawSensorData = processedPoints
                rawPressureData = JSON.parse(JSON.stringify(processedPoints))
                adjustPressureButton.visible = true
            } else {
                console.log("Warning: No data points processed with Auto-zero")
                fileDetailsText.text = "Download complete: " + selectedFileData.fileName + " (0 records)"
            }
            return  // Exit early
        }

        // Call C++ backend to process the raw data for other methods
        var processedPoints = CppClass.processDeviceFileData(pendingDownloadData, surfacePressure)

        // Graph the data
        if (processedPoints && processedPoints.length > 0) {
            updateChart(processedPoints)

            // Update file details with record count if not already set by the warning
            if (!isEmptyBarometerFallbackParam && !isEmptyBarometerFallback) {
                fileDetailsText.text = "Download complete: " + selectedFileData.fileName +
                                       " (" + processedPoints.length + " data records) - " + pressureMethod + " pressure"
            } else {
                // Append record count to existing warning
                fileDetailsText.text = fileDetailsText.text + " (" + processedPoints.length + " data records)"
            }

            // Store raw sensor data for future adjustments (WITH RAW PRESSURE)
            rawSensorData = processedPoints

            // ALSO store raw pressure values separately for recalculation
            rawPressureData = JSON.parse(JSON.stringify(processedPoints))

            // Show adjust button after successful download
            adjustPressureButton.visible = true
        } else {
            console.log("Warning: No data points processed")
            if (!isEmptyBarometerFallbackParam && !isEmptyBarometerFallback) {
                fileDetailsText.text = "Download complete: " + selectedFileData.fileName + " (0 records)"
            }
        }
    }

    function calculateAutoDetectPressure(seconds) {
        console.log("Auto-zero: Calculating surface pressure from first", seconds, "seconds of data");

        // Use persistentRawData if available (for recalculation), otherwise use pendingDownloadData
        var rawData = persistentRawData !== null ? persistentRawData : pendingDownloadData;

        // Check if we have data
        if (!rawData || rawData.length === 0) {
            console.log("No data available for auto-zero - using standard pressure");
            return 1013.25;
        }

        console.log("Auto-zero: Using data with", rawData.length, "bytes");

        // Get the raw downloaded data as bytes
        var rawBytes = rawData;

        // Find the calibration coefficients (C0-C6) from the first page header
        var calibrationFound = false;
        var C = [0, 0, 0, 0, 0, 0, 0];

        // Search for RLE (0x77) and RTX (0x76) markers in the raw data
        for (var i = 0; i < rawBytes.length - 30; i++) {
            if (rawBytes[i] === 0x77 && rawBytes[i + 1] === 0x76) {
                // Found page header, extract calibration from bytes 16-29
                C[0] = (rawBytes[i + 16] << 8) | rawBytes[i + 17];
                C[1] = (rawBytes[i + 18] << 8) | rawBytes[i + 19];
                C[2] = (rawBytes[i + 20] << 8) | rawBytes[i + 21];
                C[3] = (rawBytes[i + 22] << 8) | rawBytes[i + 23];
                C[4] = (rawBytes[i + 24] << 8) | rawBytes[i + 25];
                C[5] = (rawBytes[i + 26] << 8) | rawBytes[i + 27];
                C[6] = (rawBytes[i + 28] << 8) | rawBytes[i + 29];

                calibrationFound = true;
                console.log("Auto-zero: Calibration coefficients found");
                break;
            }
        }

        if (!calibrationFound) {
            console.log("Auto-zero: Could not find calibration coefficients");
            return 1013.25;
        }

        // Calculate how many records to process based on seconds
        // Record interval is 2 seconds based on your test data
        var recordIntervalSeconds = 2;
        var recordsToAverage = Math.ceil(seconds / recordIntervalSeconds);
        if (recordsToAverage < 1) recordsToAverage = 1;

        console.log("Auto-zero: Averaging first", recordsToAverage, "records");

        // Parse the raw data and collect pressure readings from the first N records
        var pressureSum = 0;
        var pressureCount = 0;
        var recordsProcessed = 0;

        var offset = 0;
        var bytesPerPage = 512;
        var headerSize = 32;
        var recordSize = 32;

        while (offset + bytesPerPage <= rawBytes.length && recordsProcessed < recordsToAverage) {
            var totalRecordsInPage = rawBytes[offset + 5];
            var dataRecordsInPage = totalRecordsInPage - 1;

            var dataOffset = offset + headerSize;

            for (var i = 0; i < dataRecordsInPage && recordsProcessed < recordsToAverage; i++) {
                var recordStart = dataOffset + (i * recordSize);

                if (recordStart + recordSize > rawBytes.length) break;

                // Extract raw ADC values (bytes 8-11 for D1, bytes 14-17 for D2)
                var D1 = (rawBytes[recordStart + 8] << 24) |
                         (rawBytes[recordStart + 9] << 16) |
                         (rawBytes[recordStart + 10] << 8) |
                         rawBytes[recordStart + 11];

                var D2 = (rawBytes[recordStart + 14] << 24) |
                         (rawBytes[recordStart + 15] << 16) |
                         (rawBytes[recordStart + 16] << 8) |
                         rawBytes[recordStart + 17];

                // Apply MS5837 formulas
                var dT = D2 - (C[5] << 8);
                var OFF = (C[2] << 16) + (C[4] * dT) / 128;
                var SENS = (C[1] << 15) + (C[3] * dT) / 256;
                var P = (((D1 * SENS) / 2097152) - OFF) / 8192;

                var pressure_mbar = P / 10.0;

                pressureSum += pressure_mbar;
                pressureCount++;
                recordsProcessed++;
            }

            offset += bytesPerPage;
        }

        if (pressureCount === 0) {
            console.log("Auto-zero: No pressure readings found");
            return 1013.25;
        }

        var avgPressure = pressureSum / pressureCount;
        console.log("Auto-zero: Average surface pressure =", avgPressure.toFixed(2), "mbar from", pressureCount, "readings");

        return avgPressure;
    }

    function loadBarometerFile(filePath) {
        console.log("Loading barometer file:", filePath);
        // Read file using C++ backend or Qt.file
        // For now, we'll assume C++ will handle this
        CppClass.loadBarometerFile(filePath);
    }

    function processAndGraphDownloadedDataWithBarometer(surfacePressure, pressureMethod) {
        console.log("Processing downloaded data with barometer file, Method:", pressureMethod);

        // Get barometer data from C++ instead of using QML property
        var barometerDataFromCpp = CppClass.getBarometerData()

        console.log("Barometer data from C++ count:", barometerDataFromCpp ? barometerDataFromCpp.length : 0)

        if (!barometerDataFromCpp || barometerDataFromCpp.length === 0) {
            console.log("ERROR: No barometer data available from C++")
            return
        }

        // FIRST: Process the raw data to get points with timestamps
        var processedPoints = CppClass.processDeviceFileDataWithBarometer(persistentRawData, barometerDataFromCpp)

        if (!processedPoints || processedPoints.length === 0) {
            console.log("Warning: No data points processed with barometer file")
            fileDetailsText.text = "Error: No data processed - check barometer file format"
            return
        }

        // SECOND: Calculate overlap warning using the processed points (which have time strings)
        var overlapInfo = CppClass.calculateBarometerOverlap(processedPoints, barometerDataFromCpp)
        barometerOverlapWarning = overlapInfo.warningMessage
        barometerOverlapStatus = overlapInfo.overlapStatus
        console.log("Overlap warning:", barometerOverlapWarning)
        console.log("Overlap status:", barometerOverlapStatus)
        console.log("Overlap info full object:", JSON.stringify(overlapInfo))

        // Store barometer data in QML for later recalculation
        barometerData = barometerDataFromCpp

        // Store raw sensor data for future adjustments
        rawSensorData = processedPoints
        currentPressureMethod = pressureMethod
        currentPressureValue = surfacePressure
        console.log("currentPressureMethod set to:", currentPressureMethod)

        // Extract pressure_mbar from processed points for future recalculation
        rawPressureData = []
        for (var i = 0; i < processedPoints.length; i++) {
            rawPressureData.push({
                time: processedPoints[i].time,
                temperature: processedPoints[i].temperature,
                pressure_mbar: processedPoints[i].pressure_mbar,
                conductivity: processedPoints[i].conductivity || 0
            })
        }

        updateChart(processedPoints)

        // Update file details with record count and overlap warning
        if (barometerOverlapWarning !== "") {
            fileDetailsText.text = "Download complete: " + selectedFileData.fileName +
                                   " (" + processedPoints.length + " data records) - " + barometerOverlapWarning
        } else {
            fileDetailsText.text = "Download complete: " + selectedFileData.fileName +
                                   " (" + processedPoints.length + " data records) - Barometer Compensated"
        }

        // Show adjust button after successful download
        adjustPressureButton.visible = true
        console.log("adjustPressureButton.visible set to true")

        pendingDownloadData = null
    }

    function recalculateWithBarometerPressure() {
        console.log("=== BAROMETER RECALCULATION START ===")

        // Get barometer data from C++ instead of using QML property
        var barometerDataFromCpp = CppClass.getBarometerData()

        console.log("Barometer data count:", barometerDataFromCpp ? barometerDataFromCpp.length : 0)
        console.log("Persistent raw data available:", persistentRawData ? persistentRawData.length : 0)

        if (!barometerDataFromCpp || barometerDataFromCpp.length === 0) {
            console.log("No barometer data available for recalculation")
            console.log("Please load a barometer file first")
            return
        }

        // Use persistentRawData instead of pendingDownloadData
        if (!persistentRawData || persistentRawData.length === 0) {
            console.log("No raw data available for barometer recalculation")
            console.log("Please download the file again before using barometer adjustment")
            return
        }

        // Call C++ backend to process the raw data with barometer compensation
        var processedPoints = CppClass.processDeviceFileDataWithBarometer(persistentRawData, barometerDataFromCpp)

        if (processedPoints && processedPoints.length > 0) {
            // Calculate overlap warning using the processed points (after they are created)
            var overlapInfo = CppClass.calculateBarometerOverlap(processedPoints, barometerDataFromCpp)
            barometerOverlapWarning = overlapInfo.warningMessage
            barometerOverlapStatus = overlapInfo.overlapStatus
            console.log("Overlap status:", barometerOverlapStatus)

            // Store raw sensor data for future adjustments
            rawSensorData = processedPoints
            currentPressureMethod = "BarometerFile"

            // Extract pressure_mbar from processed points for future recalculation
            rawPressureData = []
            for (var i = 0; i < processedPoints.length; i++) {
                rawPressureData.push({
                    time: processedPoints[i].time,
                    temperature: processedPoints[i].temperature,
                    pressure_mbar: processedPoints[i].pressure_mbar,
                    conductivity: processedPoints[i].conductivity || 0
                })
            }

            updateChart(processedPoints)

            if (barometerOverlapWarning !== "") {
                fileDetailsText.text = "Download complete: " + selectedFileData.fileName +
                                       " (" + processedPoints.length + " data records) - Recalculated - " + barometerOverlapWarning
            } else {
                fileDetailsText.text = "Download complete: " + selectedFileData.fileName +
                                       " (" + processedPoints.length + " data records) - Recalculated with barometer"
            }
        } else {
            console.log("Warning: No data points processed with barometer file")
        }
    }

    // Start the actual download after pressure selection
    function startActualDownload() {
        var selectedFile = pendingDownloadSelectedFile;
        var fileName = pendingDownloadFileName;
        var fileIndex = pendingDownloadFileIndex;

        if (!selectedFile) {
            console.log("Error: No file selected for download");
            return;
        }

        // RESET ALL DOWNLOAD STATE VARIABLES
        isDownloading = true;
        currentDownloadFileIndex = fileIndex;
        downloadedQuadrants = 0;
        totalQuadrantsToDownload = selectedFile.quadrantsToDownload;
        currentPage = 0;
        currentQuadrant = 0;
        currentPageData = [];
        currentDownloadData = [];

        // RESET PROGRESS UI
        downloadProgress.value = 0;
        downloadStatusText.text = "0%";
        fileDetailsText.text = "Downloading: " + fileName + " (0/" + totalQuadrantsToDownload + " quadrants)";

        console.log("Total page records:", selectedFile.totalPageRecords);
        console.log("File data records:", selectedFile.fileDataRecords);
        console.log("Page count:", selectedFile.pageCount);
        console.log("Quadrants to download:", totalQuadrantsToDownload);

        // Clear the graph before starting new download
        clearGraph();

        // Update UI
        downloadProgress.visible = true;
        downloadStatusText.visible = true;
        loadButton.visible = false;
        cancelButton.visible = true;

        // Disable source buttons during download
        deviceButton.enabled = false;
        localButton.enabled = false;
        cloudButton.enabled = false;

        // Start the download process - Request first quadrant
        requestQuadrant(fileIndex, 0, 0);
    }

    function startActualDownloadWithBarometer() {
        var selectedFile = pendingDownloadSelectedFile;
        var fileName = pendingDownloadFileName;
        var fileIndex = pendingDownloadFileIndex;

        if (!selectedFile) {
            console.log("Error: No file selected for download");
            return;
        }

        // RESET ALL DOWNLOAD STATE VARIABLES
        isDownloading = true;
        currentDownloadFileIndex = fileIndex;
        downloadedQuadrants = 0;
        totalQuadrantsToDownload = selectedFile.quadrantsToDownload;
        currentPage = 0;
        currentQuadrant = 0;
        currentPageData = [];
        currentDownloadData = [];

        // RESET PROGRESS UI
        downloadProgress.value = 0;
        downloadStatusText.text = "0%";
        fileDetailsText.text = "Downloading: " + fileName + " (0/" + totalQuadrantsToDownload + " quadrants)";

        console.log("Total page records:", selectedFile.totalPageRecords);
        console.log("File data records:", selectedFile.fileDataRecords);
        console.log("Page count:", selectedFile.pageCount);
        console.log("Quadrants to download:", totalQuadrantsToDownload);

        // Clear the graph before starting new download
        clearGraph();

        // Update UI
        downloadProgress.visible = true;
        downloadStatusText.visible = true;
        loadButton.visible = false;
        cancelButton.visible = true;

        // Disable source buttons during download
        deviceButton.enabled = false;
        localButton.enabled = false;
        cloudButton.enabled = false;

        // Start the download process - Request first quadrant
        requestQuadrant(fileIndex, 0, 0);
    }

    function recalculateWithNewPressure(surfacePressure, pressureMethod) {
        console.log("Recalculating depth with new pressure:", surfacePressure, "mbar", "Method:", pressureMethod)

        // Update current method
        currentPressureMethod = pressureMethod

        // Check if we have the empty barometer warning
        var hadEmptyBarometerWarning = (barometerOverlapStatus.indexOf("No barometer data") !== -1)

        // Clear barometer-specific warnings when switching to non-barometer methods
        if (pressureMethod !== "BarometerFile") {
            if (!hadEmptyBarometerWarning) {
                barometerOverlapWarning = ""
                barometerOverlapStatus = ""
            }
        }

        // ====================================================================
        // Handle Auto-zero method - reprocess from original raw data
        // ====================================================================
        if (pressureMethod === "AutoDetect") {
            if (!persistentRawData || persistentRawData.length === 0) {
                console.log("ERROR: No persistent raw data available for Auto-zero recalculation")
                return
            }

            // Calculate auto-zero pressure from persistent raw data
            var calculatedPressure = calculateAutoDetectPressure(autoZeroSeconds);
            currentPressureValue = calculatedPressure;
            console.log("Auto-zero recalculation - calculated surface pressure:", calculatedPressure, "mbar");

            // Reprocess the original raw data with the calculated auto-zero pressure
            var newProcessedPoints = CppClass.processDeviceFileData(persistentRawData, calculatedPressure);

            if (newProcessedPoints && newProcessedPoints.length > 0) {
                updateChart(newProcessedPoints);
                rawSensorData = newProcessedPoints;
                // Store the processed points for future recalculations
                rawPressureData = JSON.parse(JSON.stringify(newProcessedPoints));
                fileDetailsText.text = "Recalculated with Auto-zero pressure (" + calculatedPressure.toFixed(2) + " mbar) - " + selectedFileData.fileName + " (" + newProcessedPoints.length + " data records)"
                adjustPressureButton.visible = true
            } else {
                console.log("ERROR: Failed to reprocess data with Auto-zero pressure")
            }
            return
        }

        // ====================================================================
        // Handle Barometer File method - reprocess from original raw data
        // ====================================================================
        if (pressureMethod === "BarometerFile") {
            if (!persistentRawData || persistentRawData.length === 0) {
                console.log("ERROR: No persistent raw data available for Barometer recalculation")
                return
            }

            var barometerDataFromCpp = CppClass.getBarometerData()

            if (!barometerDataFromCpp || barometerDataFromCpp.length === 0) {
                console.log("No barometer data available for recalculation")
                console.log("Please load a barometer file first")
                return
            }

            // Reprocess the original raw data with barometer compensation
            var newProcessedPoints = CppClass.processDeviceFileDataWithBarometer(persistentRawData, barometerDataFromCpp)

            if (newProcessedPoints && newProcessedPoints.length > 0) {
                // Calculate overlap warning
                var overlapInfo = CppClass.calculateBarometerOverlap(newProcessedPoints, barometerDataFromCpp)
                barometerOverlapWarning = overlapInfo.warningMessage
                barometerOverlapStatus = overlapInfo.overlapStatus

                updateChart(newProcessedPoints)
                rawSensorData = newProcessedPoints
                rawPressureData = JSON.parse(JSON.stringify(newProcessedPoints))

                if (barometerOverlapWarning !== "") {
                    fileDetailsText.text = "Recalculated - " + barometerOverlapWarning + " - " + selectedFileData.fileName + " (" + newProcessedPoints.length + " data records)"
                } else {
                    fileDetailsText.text = "Recalculated with barometer file - " + selectedFileData.fileName + " (" + newProcessedPoints.length + " data records)"
                }
                adjustPressureButton.visible = true
            } else {
                console.log("Warning: No data points processed with barometer file")
            }
            return
        }

        // ====================================================================
        // Handle Standard, Manual, and other methods - use stored rawPressureData
        // ====================================================================

        // Check if we have raw pressure data
        if (!rawPressureData || rawPressureData.length === 0) {
            console.log("ERROR: No raw pressure data available for recalculation")
            return
        }

        var newPoints = []
        var usedPressure = surfacePressure
        currentPressureValue = surfacePressure

        // Recalculate depth for each stored point
        for (var i = 0; i < rawPressureData.length; i++) {
            var point = rawPressureData[i]
            var newDepth = (point.pressure_mbar - usedPressure) * 0.010197
            if (newDepth < 0) newDepth = 0
            newPoints.push({
                time: point.time,
                temperature: point.temperature,
                depth: newDepth,
                conductivity: point.conductivity || 0,
                pressure_mbar: point.pressure_mbar
            })
        }

        // Update graph with new points
        updateChart(newPoints)
        rawSensorData = newPoints

        // Update file details text based on method
        if (hadEmptyBarometerWarning) {
            fileDetailsText.text = "Warning: Barometer file empty - using Standard pressure. " + selectedFileData.fileName +
                                   " (" + newPoints.length + " data records) (Recalculated with " + pressureMethod + " pressure: " + usedPressure.toFixed(2) + " mbar)"
        } else {
            if (pressureMethod === "Standard") {
                fileDetailsText.text = "Recalculated with Standard pressure (" + usedPressure.toFixed(2) + " mbar) - " + selectedFileData.fileName + " (" + newPoints.length + " data records)"
            } else if (pressureMethod === "Manual") {
                fileDetailsText.text = "Recalculated with Manual pressure (" + usedPressure.toFixed(2) + " mbar) - " + selectedFileData.fileName + " (" + newPoints.length + " data records)"
            }
        }

        console.log("Graph updated with new pressure compensation")
    }

    function clearPendingDownloadData() {
        pendingDownloadData = null
    }

    // Add a function to clear persistent data when loading a new file
    function clearPersistentData() {
        persistentRawData = null
        rawSensorData = []
        rawPressureData = []
        currentDataPoints = []
        barometerOverlapWarning = ""
        barometerOverlapStatus = ""
        isEmptyBarometerFallback = false
        currentPressureMethod = "Standard"
        currentPressureValue = 1013.25
        adjustPressureButton.visible = false
        clearGraph()
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
        onBarometerDataLoaded: function(loadedData) {
            console.log("Barometer data loaded signal received in QML, count:", loadedData.length);

            // Check for empty barometer file
            if (!loadedData || loadedData.length === 0) {
                console.log("WARNING: Empty barometer file - using standard pressure");

                // Set the empty barometer flag
                isEmptyBarometerFallback = true;

                // Set the warning status immediately for UI
                barometerOverlapStatus = "✗ No barometer data (using Standard pressure)"
                barometerOverlapWarning = "⚠️ No barometer data available. Using Standard pressure (1013.25 mbar) instead."

                // Update file details immediately if we have selected file info
                if (selectedFileData) {
                    fileDetailsText.text = "Warning: Barometer file empty - using Standard pressure. " + selectedFileData.fileName
                } else {
                    fileDetailsText.text = "Warning: Barometer file empty - using Standard pressure"
                }

                // Fall back to standard pressure method
                pendingPressureSource = "Standard";
                pendingSurfacePressure = 1013.25;
                barometerData = [];

                // If download data is already available, process it
                if (pendingDownloadData) {
                    processAndGraphDownloadedData(1013.25, "Standard", true);
                }
                return;
            }

            // Reset empty barometer flag when we have valid data
            isEmptyBarometerFallback = false;

            // Store the barometer data for use in recalculation
            barometerData = loadedData;

            // If we're in the middle of a download with barometer option
            if (pendingPressureSource === "BarometerFile" && pendingDownloadData) {
                console.log("Processing download with barometer data");
                processAndGraphDownloadedDataWithBarometer(pendingSurfacePressure, pendingPressureSource);
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
                        implicitHeight: 50
                        enabled: true

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 25
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
                        implicitHeight: 50
                        enabled: true

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 25
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
                        implicitHeight: 50
                        enabled: false

                        contentItem: Text {
                            text: parent.text
                            font.pixelSize: 25
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
                                    text: source === "device" ? recordCount : fileSize
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

        // File Details Area
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
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
                    font.pixelSize: 24
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
                    font.pixelSize: 22
                    color: "#cccccc"
                    wrapMode: Text.WordWrap
                    width: parent.width
                }

                // Surface Pressure Indicator
                Rectangle {
                    width: parent.width
                    visible: rawSensorData.length > 0  // This should be true after download
                    color: "#1a1a2a"
                    radius: 4
                    border.color: "#FFA500"
                    border.width: 1
                    height: indicatorText.height + 10

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: 5
                        spacing: 5

                        Text {
                            text: "⚙️"
                            font.pixelSize: 18
                            color: "#FFA500"
                        }
                        Text {
                            id: indicatorText
                            text: {
                                if (currentPressureMethod === "Standard") {
                                    return "Surface Pressure: Standard (" + currentPressureValue.toFixed(2) + " mbar)"
                                } else if (currentPressureMethod === "Manual") {
                                    return "Surface Pressure: Manual (" + currentPressureValue.toFixed(2) + " mbar)"
                                } else if (currentPressureMethod === "AutoDetect") {
                                    return "Surface Pressure: Auto-zero (" + currentPressureValue.toFixed(2) + " mbar)"
                                } else if (currentPressureMethod === "BarometerFile") {
                                    if (barometerOverlapStatus !== "") {
                                        return "Surface Pressure: Barometer file - " + barometerOverlapStatus
                                    }
                                    return "Surface Pressure: Barometer file"
                                }
                                return "Surface Pressure: Not set"
                            }
                            font.pixelSize: 16
                            color: "#FFA500"
                            Layout.fillWidth: true
                            wrapMode: Text.WordWrap
                        }

                        // Info icon with tooltip for overlap warnings
                        Text {
                            id: infoIcon
                            text: "ⓘ"
                            font.pixelSize: 16
                            color: barometerOverlapWarning !== "" ? "#FFD700" : "#555555"
                            visible: true
                            opacity: 0.8

                            ToolTip {
                                visible: infoIcon.hovered
                                text: barometerOverlapWarning !== "" ? barometerOverlapWarning : "Barometer data fully overlaps recording"
                                delay: 500
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                            }
                        }
                    }
                }

                // Progress bar for device file download
                ProgressBar {
                    id: downloadProgress
                    width: parent.width
                    visible: false
                    from: 0
                    to: 100
                    value: 0

                    background: Rectangle {
                        implicitHeight: 12
                        radius: 6
                        color: "#555555"
                    }

                    contentItem: Item {
                        implicitHeight: 12

                        Rectangle {
                            width: downloadProgress.visualPosition * parent.width
                            height: parent.height
                            radius: 6
                            color: "#4CAF50"
                        }
                    }
                }

                Text {
                    id: downloadStatusText
                    text: ""
                    font.pixelSize: 20
                    font.bold: true
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
            implicitHeight: 50
            visible: false

            contentItem: Text {
                text: parent.text
                font.pixelSize: 24
                font.bold: true
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: parent.enabled ? "#4CAF50" : "#cccccc"
                radius: 6
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

        // Cancel Button (appears during download)
        Button {
            id: cancelButton
            text: "Cancel"
            Layout.fillWidth: true
            implicitHeight: 50
            visible: false
            enabled: true

            contentItem: Text {
                text: parent.text
                font.pixelSize: 24
                font.bold: true
                color: "#FFFFFF"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: "#d32f2f"  // Material Red
                radius: 6

                // Add a subtle hover effect
                Rectangle {
                    anchors.fill: parent
                    color: "#ffffff"
                    opacity: cancelButton.down ? 0.2 : (cancelButton.hovered ? 0.1 : 0)
                    radius: 6
                }
            }

            onClicked: {
                console.log("Cancel button clicked - aborting download");
                cancelDownload();
            }
        }

        // Adjust Surface Pressure Button (appears after download)
        Button {
            id: adjustPressureButton
            text: "Adjust Surface Pressure"
            Layout.fillWidth: true
            implicitHeight: 45
            visible: false

            contentItem: Text {
                text: parent.text
                font.pixelSize: 20
                font.bold: true
                color: "#FFA500"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            background: Rectangle {
                color: "#333333"
                radius: 6
                border.color: "#FFA500"
                border.width: 1
            }

            onClicked: {
                isAdjustingPressure = true
                // Store current method to pre-select in dialog
                if (currentPressureMethod === "Standard") {
                    stdPressureRadio.checked = true
                } else if (currentPressureMethod === "Manual") {
                    manualRadio.checked = true
                    manualPressureField.text = currentPressureValue.toString()
                } else if (currentPressureMethod === "AutoDetect") {
                    autoDetectRadio.checked = true
                    autoDetectSeconds.value = 5
                } else if (currentPressureMethod === "BarometerFile") {
                    baroFileRadio.checked = true
                }
                surfacePressureDialog.open()
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

    Dialog {
        id: surfacePressureDialog
        modal: true
        focus: true
        title: "Surface Pressure Reference"
        width: 450
        height: 720
        anchors.centerIn: parent
        standardButtons: Dialog.NoButton

        ColumnLayout {
            id: contentLayout
            anchors.fill: parent
            anchors.margins: 20
            spacing: 15

            Label {
                text: "Select surface pressure source for depth calculation:"
                font.pixelSize: 22
                wrapMode: Text.WordWrap
                Layout.fillWidth: true
            }

            RadioButton {
                id: stdPressureRadio
                font.pixelSize: 18
                text: "Standard pressure: 1013.25 mbar (sea level)"
                checked: true
            }

            RadioButton {
                id: manualRadio
                font.pixelSize: 18
                text: "Manual entry:"
            }

            RowLayout {
                Layout.leftMargin: 30
                enabled: manualRadio.checked
                TextField {
                    id: manualPressureField
                    font.pixelSize: 17
                    text: "1013.25"
                    validator: DoubleValidator { bottom: 800; top: 1100; decimals: 2 }
                }
                Label {
                    text: "mbar"
                    font.pixelSize: 17
                }
            }

            RadioButton {
                id: autoDetectRadio
                font.pixelSize: 18
                text: "Auto-zero (first N seconds):"
            }

            RowLayout {
                Layout.leftMargin: 30
                enabled: autoDetectRadio.checked
                SpinBox {
                    id: autoDetectSeconds
                    font.pixelSize: 17
                    from: 1
                    to: 60
                    value: 5
                }
                Label {
                    text: "seconds of data"
                    font.pixelSize: 17
                }
            }

            RadioButton {
                id: baroFileRadio
                font.pixelSize: 18
                text: "Import barometer file:"
            }

            RowLayout {
                Layout.leftMargin: 30
                enabled: baroFileRadio.checked

                TextField {
                    id: baroFilePathField
                    font.pixelSize: 16
                    readOnly: true
                    placeholderText: "No file selected"
                    Layout.fillWidth: true
                }

                Button {
                    text: "Browse..."
                    font.pixelSize: 16
                    onClicked: baroFileDialog.open()
                }
            }

            // Add some space before buttons
            // Item { Layout.preferredHeight: 1 }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 10
                Button {
                    text: "Cancel"
                    font.pixelSize: 18
                    onClicked: {
                        surfacePressureDialog.close();
                        pendingDownloadData = null;
                    }
                }
                Button {
                    text: "Apply"
                    font.pixelSize: 18
                    onClicked: {
                        var surfacePressure = 1013.25;
                        var pressureSource = "Standard";

                        if (manualRadio.checked) {
                            surfacePressure = parseFloat(manualPressureField.text);
                            pressureSource = "Manual";
                        } else if (autoDetectRadio.checked) {
                            // Store the seconds value, but don't calculate yet
                            autoZeroSeconds = autoDetectSeconds.value;
                            pressureSource = "AutoDetect";
                            surfacePressure = 1013.25;  // Placeholder, will be calculated after download
                        } else if (baroFileRadio.checked && baroFilePathField.text !== "") {
                            // Load barometer file and check result
                            var success = CppClass.loadBarometerFile(baroFilePathField.text);

                            if (!success) {
                                console.log("Barometer file load failed or empty - falling back to Standard pressure");
                                pressureSource = "Standard";
                                surfacePressure = 1013.25;

                                if (isAdjustingPressure) {
                                    surfacePressureDialog.close();
                                    isAdjustingPressure = false;
                                    recalculateWithNewPressure(surfacePressure, pressureSource);
                                    return;
                                } else {
                                    pendingSurfacePressure = surfacePressure;
                                    pendingPressureSource = pressureSource;
                                    surfacePressureDialog.close();
                                    startActualDownload();
                                    return;
                                }
                            }

                            pressureSource = "BarometerFile";

                            if (isAdjustingPressure) {
                                // Recalculate with barometer data (no new download)
                                surfacePressureDialog.close();
                                isAdjustingPressure = false;
                                // Wait a moment for barometer data to load, then recalculate
                                Qt.callLater(function() {
                                    recalculateWithBarometerPressure();
                                });
                                return;
                            } else {
                                // New download with barometer data
                                pendingSurfacePressure = surfacePressure;
                                pendingPressureSource = pressureSource;
                                surfacePressureDialog.close();
                                // Wait a moment for barometer data to load, then start download
                                Qt.callLater(function() {
                                    startActualDownloadWithBarometer();
                                });
                                return;
                            }
                        }

                        if (isAdjustingPressure) {
                            recalculateWithNewPressure(surfacePressure, pressureSource);
                        } else {
                            pendingSurfacePressure = surfacePressure;
                            pendingPressureSource = pressureSource;
                            startActualDownload();
                        }
                        surfacePressureDialog.close();
                        isAdjustingPressure = false;
                    }
                }
            }
        }
    }
}
