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
        ListElement {
            fileName: "data_20230815.csv"
            fileSize: "2.4 MB"
            timeClosed: "15:42:23"
            note: "Main dataset"
        }
        ListElement {
            fileName: "calibration.json"
            fileSize: "145 KB"
            timeClosed: "14:15:07"
            note: "Sensor calibration"
        }
        ListElement {
            fileName: "config_backup.ini"
            fileSize: "87 KB"
            timeClosed: "11:30:45"
            note: "System configuration"
        }
        ListElement {
            fileName: "log_20230814.txt"
            fileSize: "1.2 MB"
            timeClosed: "09:22:18"
            note: "Debug logs"
        }
        ListElement {
            fileName: "export_results.xlsx"
            fileSize: "3.1 MB"
            timeClosed: "16:55:33"
            note: "Final report"
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
            var fileInfo = {
                fileName: folderModel.get(i, "fileName"),
                fileSize: folderModel.get(i, "fileSize"),
                lastModified: new Date(folderModel.get(i, "fileModified")).getTime(),
                note: "Text file"  // For visual model only
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
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    spacing: 2
                    model: fileListModel

                    delegate: Rectangle {
                        width: fileListView.width
                        height: 60
                        color: index % 2 ? "#f5f5f5" : "gray"
                        border.color: "#e0e0e0"
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
                                    font.pixelSize: 14
                                    elide: Text.ElideRight
                                }

                                Text {
                                    text: note
                                    font.pixelSize: 12
                                    color: "#666"
                                    elide: Text.ElideRight
                                }
                            }

                            Column {
                                Layout.alignment: Qt.AlignRight
                                spacing: 2

                                Text {
                                    text: fileSize
                                    font.pixelSize: 12
                                    horizontalAlignment: Text.AlignRight
                                }

                                Text {
                                    text: timeClosed
                                    font.pixelSize: 12
                                    color: "#666"
                                    horizontalAlignment: Text.AlignRight
                                }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: fileListView.currentIndex = index
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
                width: 1600
                height: 800
                theme: ChartView.ChartThemeDark
                antialiasing: true
                legend.visible: true // MT was true
                legend.alignment: Qt.AlignBottom
                margins {
                    top: 20
                    bottom: 40
                    left: 20
                    right: 40
                } // Increased right margin

                // Customize the legend appearance
                // Add a custom legend (e.g., using Row + Rectangle + Text)
                Row {
                    anchors.bottom: parent.bottom
                    spacing: 10
                    Repeater {
                        model: ["Temperature", "Depth", "Conductivity"]
                        delegate: Row {
                            spacing: 5
                            Rectangle {
                                width: 15
                                height: 15
                                color: "green"
                            }
                            Text {
                                text: modelData
                                color: "white"
                                font.pixelSize: 14
                            }
                        }
                    }
                }

                // X-Axis (Time)
                DateTimeAxis {
                    id: axisX
                    format: "hh:mm"
                    titleText: "Time (min)"
                    min: new Date(2023, 0, 1, 0, 0, 0)
                    max: new Date(2023, 0, 1, 3, 20, 0) // 3 hours, 20 minutes

                    // Set font size for axis labels
                    labelsFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 16
                    })

                    // Set font size for axis title
                    titleFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 18,
                        "bold": true
                    })
                }

                ValueAxis {
                    id: axisYDepth
                    min: 0
                    max: 50
                    titleText: "Depth  (m)"
                    labelFormat: "%.0f"

                    // Set font size for axis labels
                    labelsFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 16
                    })

                    // Set font size for axis title
                    titleFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 18,
                        "bold": true
                    })
                }

                // Right Y-Axis 1 (Temperature)
                ValueAxis {
                    id: axisYTemp
                    min: 10
                    max: 30
                    titleText: "Temperature  (°C)"
                    labelFormat: "%.1f"

                    // Set font size for axis labels
                    labelsFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 16
                    })

                    // Set font size for axis title
                    titleFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 18,
                        "bold": true
                    })
                }

                // Right Y-Axis 2 (Conductivity)
                ValueAxis {
                    id: axisYConductivity
                    min: -100
                    max: 100
                    titleText: "Conductivity  (mS/cm)"
                    labelFormat: "%.0f"

                    // Set font size for axis labels
                    labelsFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 16
                    })

                    // Set font size for axis title
                    titleFont: Qt.font({
                        "family": "Arial",
                        "pixelSize": 18,
                        "bold": true
                    })
                }

                // Temperature Line
                LineSeries {
                    name: "Temperature"
                    axisX: axisX
                    axisYRight: axisYTemp
                    color: "#ff7f0e" // Orange
                    width: 2
                    style: Qt.DashLine

                    Component.onCompleted: {
                        for (var i = 0; i <= 500; i++) {
                            var temp = 18 + 7 * Math.sin(i / 16)
                            append(new Date(2023, 0, 1, 0, i, 0).getTime(), temp)
                        }
                    }
                }

                // Conductivity Line
                LineSeries {
                    name: "Conductivity"
                    axisX: axisX
                    axisYRight: axisYConductivity
                    color: "#2ca02c" // Green
                    width: 2
                    style: Qt.DotLine

                    Component.onCompleted: {
                        for (var i = 0; i <= 500; i += 2) {
                            var cond = 10 + 50 * Math.sin(i / 25)
                            append(new Date(2023, 0, 1, 0, i, 0).getTime(), cond)
                        }
                    }
                }

                // Depth Line (Primary)
                LineSeries {
                    name: "Depth"
                    axisX: axisX
                    axisY: axisYDepth
                    color: "#1f77b4" // Blue
                    width: 4

                    Component.onCompleted: {
                        for (var i = 0; i <= 500; i++) {
                            var depth = 20 + 15 * Math.sin(i / 10)
                            append(new Date(2023, 0, 1, 0, i, 0).getTime(), depth)
                        }
                    }
                }

                // Custom axis placement
                onPlotAreaChanged: {
                    // Position Temperature axis (first right axis)
                    axisYTemp.visible = true
                    axisYTemp.lineVisible = true
                    axisYTemp.labelsVisible = true
                    axisYTemp.titleVisible = true
                    axisYTemp.alignment = Qt.AlignRight
                    axisYTemp.offset = 0

                    // Position Conductivity axis (second right axis)
                    axisYConductivity.visible = true
                    axisYConductivity.lineVisible = true
                    axisYConductivity.labelsVisible = true
                    axisYConductivity.titleVisible = true
                    axisYConductivity.alignment = Qt.AlignRight
                    axisYConductivity.offset = -50 // Adjust based on your chart width

                    // Position Depth axis (third right axis)
                    axisYDepth.visible = true
                    axisYDepth.lineVisible = true
                    axisYDepth.labelsVisible = true
                    axisYDepth.titleVisible = true
                    axisYDepth.alignment = Qt.AlignRight
                    axisYDepth.offset = -100 // Adjust based on your chart width
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
