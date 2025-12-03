// ListView0.qml
import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15
import QtQuick.Controls.Material 2.15
import QtCharts 2.15
import Qt.labs.folderlistmodel 2.15
import QtQuick.Dialogs

GridLayout {
    anchors.fill: parent
    flow: GridLayout.TopToBottom
    rows: 2

    // 1. Folder Dialog
    FolderDialog {
        id: folderDialog
        title: "Please choose a directory"
        currentFolder: StandardPaths.writableLocation(StandardPaths.HomeLocation)
        onAccepted: {
            var path = selectedFolder.toString().replace(/^(file:\/{3})/, "");
            console.log("Selected directory:", path);

            // Force refresh by first clearing the folderModel
            folderModel.folder = "";
            fileListModel.clear();

            // Small delay to ensure model clears before setting new folder
            Qt.callLater(function() {
                folderModel.folder = selectedFolder;
            });
        }
    }

    // 2. Folder Model
    FolderListModel {
        id: folderModel
        showDirs: false
        nameFilters: ["*.txt"]
        showDotAndDotDot: false
        showOnlyReadable: true

        onCountChanged: {
            if (count > 0) {
                console.log("Found", count, "text files:");
                for (var i = 0; i < count; i++) {
                    console.log("- " + get(i, "fileName"));
                }
                updateFileList();  // Update ListView
                //sendFilesToBackend(); // Send to C++
            }
        }
    }

    // 3. ListModel for the ListView
    ListModel {
        id: fileListModel
        // Remove the static ListElement entries since we're populating dynamically
        // The roles will be defined by the data we append
    }



    // Connections to C++ backend
    Connections {
        target: CppClass

        function onFileDataReady(metadata, dataPoints) {
            console.log("Metadata received:", JSON.stringify(metadata, null, 2));
            console.log("Data points count:", dataPoints.length);

            // Update UI with metadata
            deviceInfo.text = metadata.device + " - " + metadata.serialNumber;
            timeInfo.text = metadata.instrumentTime + " " + metadata.timeZone;

            updateChart(dataPoints);
        }

        function onNewDataPointsAdded(newPoints) {
            console.log("New data points count:", newPoints.length);
            addToChart(newPoints);
        }
    }

    function updateChart(points) {
        console.log("Updating chart with", points.length, "points");

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



    // 4. Helper functions
    function formatFileSize(bytes) {
        if (bytes < 1024) return bytes + " B";
        else if (bytes < 1048576) return (bytes / 1024).toFixed(1) + " KB";
        else return (bytes / 1048576).toFixed(1) + " MB";
    }

    function formatFileTime(fileTime) {
        var date = new Date(fileTime);
        return date.toLocaleTimeString(Qt.locale(), "HH:mm:ss");
    }


    /*
    // Helper functions (place at root level of your QML file)
    function updateFileList()
    {
        console.log("Updating file list with", folderModel.count, "files");

        // Clear existing files first
        fileListModel.clear();

        // Process files and get first filename
        var firstFileData = null;
        for (var i = 0; i < folderModel.count; i++) {
            var fileData = {
                fileName: folderModel.get(i, "fileName"),
                fileSize: folderModel.get(i, "fileSize"), // in bytes
                lastModified: new Date(folderModel.get(i, "fileModified"))
            };

            fileListModel.append(fileData);

            // Capture first file's data
            if (i === 0) firstFileData = fileData;
        }

        // Send to C++ backend if files exist
        if (firstFileData)
        {
            CppClass.passFromQmlToCpp(
                [firstFileData.fileName],  // Array with first filename
                firstFileData              // Full first file object
            );
        }
    }
    */


    /*
    function updateFileList() {
        console.log("Updating file list with", folderModel.count, "files");

        // Clear existing files
        fileListModel.clear();

        // Prepare data for C++
        var filesData = [];
        for (var i = 0; i < folderModel.count; i++) {
            var fileInfo = {
                fileName: folderModel.get(i, "fileName"),
                fileSize: folderModel.get(i, "fileSize"),
                lastModified: new Date(folderModel.get(i, "fileModified")).getTime() // Milliseconds since epoch
            };

            fileListModel.append(fileInfo); // Add to visual model
            filesData.push(fileInfo);      // Add to C++ transfer data
        }

        // Send complete files data to C++
        if (filesData.length > 0) {
            CppClass.passFromQmlToCpp2(filesData);
        }
    }
    */

    function updateFileList() {
        fileListModel.clear();
        var filesData = [];

        for (var i = 0; i < folderModel.count; i++) {
            var fileSizeBytes = folderModel.get(i, "fileSize");
            var fileSizeFormatted = formatFileSize(fileSizeBytes);
            var lastModified = new Date(folderModel.get(i, "fileModified"));

            var fileInfo = {
                fileName: folderModel.get(i, "fileName"),
                fileSize: fileSizeFormatted, // Use formatted string for display
                fileSizeBytes: fileSizeBytes, // Keep original bytes for C++
                lastModified: lastModified.getTime(),
                timeClosed: formatFileTime(lastModified),
                note: "Text file"
            };

            fileListModel.append(fileInfo);  // Update visual ListView
            filesData.push(fileInfo);       // Prepare for C++
        }

        if (filesData.length > 0) {
            CppClass.passFromQmlToCpp2(filesData);
        }
    }



    function sendFilesToBackend() {
        var fileData = [];
        for (var i = 0; i < fileListModel.count; i++) {
            fileData.push({
                fileName: fileListModel.get(i).fileName,
                fileSize: fileListModel.get(i).fileSize,
                lastModified: fileListModel.get(i).lastModified
            });
        }

        // Call C++ backend (assuming registered as 'backend')
        cppclass.processFiles(
            folderModel.folder.toString().replace(/^(file:\/{3})/, ""),
            fileData
        );
    }

    // Add this function to your QML to convert time strings to plotable values
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

    CellBox {
        title: 'File Operations'
        ColumnLayout {
            anchors.fill: parent

            GridLayout {
                columns: 1
                columnSpacing: 20
                rowSpacing: 10
                Layout.alignment: Qt.AlignTop

                RowLayout {
                    spacing: 10
                    Button {
                        text: "Device"
                        Layout.fillWidth: true
                        implicitHeight: 40
                    }
                    Button {
                        text: "Local"
                        Layout.fillWidth: true
                        implicitHeight: 40
                        onClicked: folderDialog.open()
                    }
                    Button {
                        text: "Cloud"
                        Layout.fillWidth: true
                        implicitHeight: 40
                    }
                }

                ListView {
                    id: fileListView
                    currentIndex: -1  // Start with no selection
                    Layout.fillWidth: true
                    Layout.fillHeight: true
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
                                    text: note
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
                                var fullPath = folderModel.folder.toString().replace(/^(file:\/{3})/, "") +
                                               "/" + selectedFile.fileName;
                                CppClass.openAndReadFile(fullPath);

                                // Clear selection to allow re-clicking the same file
                                Qt.callLater(function() {
                                    fileListView.currentIndex = -1;
                                });
                            }
                        }
                    }
                    ScrollBar.vertical: ScrollBar {
                        policy: ScrollBar.AsNeeded
                    }
                }
            }
        }
    }

    CellBox {
        Layout.rowSpan: 2
        Layout.minimumWidth: 700
        title: 'Graph'
        Layout.preferredWidth: height // Keep the ratio right!

        // Add this somewhere in your UI (maybe near the chart title)
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

            // Bar Graph - 2 x Y axis (Depth, Tempeature)
            ChartView {
                id: chartView
                width: 1600
                height: 800
                theme: ChartView.ChartThemeDark
                antialiasing: true
                legend.visible: false

                // X-Axis (Time - converted from HH:MM:SS to milliseconds)
                ValueAxis {
                    id: axisX
                    titleText: "Time (minutes)"
                    min: 0
                    max: 200 // Will be dynamically updated
                    labelFormat: "%.0f"
                    labelsFont: Qt.font({ family: "Arial", pointSize: 12, bold: true })
                    titleFont: Qt.font({ family: "Arial", pointSize: 14, bold: true })
                }

                // Left Y-Axis (Depth)
                ValueAxis {
                    id: axisYDepth
                    titleText: "Depth (m)"
                    min: 0
                    max: 100
                    labelFormat: "%.0f"
                    labelsFont: Qt.font({ family: "Arial", pointSize: 12, bold: true })
                    titleFont: Qt.font({ family: "Arial", pointSize: 14, bold: true })
                }

                // Right Y-Axis (Temperature)
                ValueAxis {
                    id: axisYTemp
                    titleText: "Temperature (°C)"
                    min: 0
                    max: 30
                    labelFormat: "%.1f"
                    labelsFont: Qt.font({ family: "Arial", pointSize: 12, bold: true })
                    titleFont: Qt.font({ family: "Arial", pointSize: 14, bold: true })
                }

                // Depth Line Series (Primary - Left Axis)
                LineSeries {
                    id: depthSeries
                    name: "Depth"
                    axisX: axisX
                    axisY: axisYDepth
                    color: "#1f77b4" // Blue
                    width: 2
                }

                // Temperature Line Series (Secondary - Right Axis)
                LineSeries {
                    id: temperatureSeries
                    name: "Temperature"
                    axisX: axisX
                    axisYRight: axisYTemp
                    color: "#ff7f0e" // Orange
                    width: 2
                    style: Qt.DashLine
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
