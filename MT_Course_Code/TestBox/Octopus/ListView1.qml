// ListView1.qml
import QtQuick 2.15
import QtQuick.Controls 2.15

Item {
    Rectangle {
        anchors.fill: parent
        color: "lightblue"

        Label {
            anchors.centerIn: parent
            text: "List 1 Content"
            font.pixelSize: 24
        }

        Button {
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            text: "Sample Button"
            onClicked: console.log("Button in List 1 clicked")
        }
    }
}
