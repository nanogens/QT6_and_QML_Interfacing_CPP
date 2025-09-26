// ListView4.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    width: 1920
    height: 1080

    // Container for the gauge cluster
    Item {
        id: gaugeCluster
        width: 900
        height: 500
        anchors.centerIn: parent

        // Temperature gauge - overlapped on left
        Text {
            text: "TEMPERATURE"
            anchors {
                bottom: tempGauge.top
                bottomMargin: 10
                horizontalCenter: tempGauge.horizontalCenter
            }
            font.pixelSize: 20
            font.bold: true
            color: "white"
            z: tempGauge.z + 1  // Ensure text stays above gauge
        }

        ListView4_CircularGuage {
            id: tempGauge
            width: 320
            height: 320
            anchors {
                verticalCenter: parent.verticalCenter
                right: depthGauge.left
                rightMargin: -80  // Negative margin for overlap
            }
            value: 50
            minValue: 0
            maxValue: 70
            unit: "°C"
            progressStartColor: "gold"
            progressEndColor: "tomato"
            z: 1  // Middle layer
        }

        // Depth gauge - centered and foremost
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
            color: "white"
            z: depthGauge.z + 1
        }

        ListView4_CircularGuage {
            id: depthGauge
            width: 500
            height: 500
            anchors.centerIn: parent
            value: 150
            minValue: 0
            maxValue: 150
            unit: "m"
            progressStartColor: "springgreen"
            progressEndColor: "deepskyblue"
            z: 2  // Top layer (foreground)
        }

        // Conductivity gauge - overlapped on right
        Text {
            text: "CONDUCTIVITY"
            anchors {
                bottom: condGauge.top
                bottomMargin: 10
                horizontalCenter: condGauge.horizontalCenter
            }
            font.pixelSize: 20
            font.bold: true
            color: "white"
            z: condGauge.z + 1
        }

        ListView4_CircularGuage {
            id: condGauge
            width: 320
            height: 320
            anchors {
                verticalCenter: parent.verticalCenter
                left: depthGauge.right
                leftMargin: -80  // Negative margin for overlap
            }
            value: 120
            minValue: 0
            maxValue: 2000
            unit: "mS/cm"
            progressStartColor: "#FF6EC7"
            progressEndColor: "#8A2BE2"
            z: 1  // Middle layer
        }
    }
}
