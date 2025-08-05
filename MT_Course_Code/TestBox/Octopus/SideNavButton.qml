import QtQuick 2.13
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4

Button {
    id: root
    flat: true
    spacing: 40

    // Make the background fill the button
    background: Rectangle {
        anchors.fill: parent
        color: root.down ? Material.listHighlightColor : "transparent"
    }

    // Custom content layout
    contentItem: Row {
        spacing: root.spacing
        leftPadding: 10

        // Optional icon
        Image {
            id: icon
            source: root.icon.source
            width: 24
            height: 24
            anchors.verticalCenter: parent.verticalCenter
            visible: root.icon.source.toString() !== ""
        }

        // Text label
        Label {
            text: root.text
            font: root.font
            anchors.verticalCenter: parent.verticalCenter
            color: Material.foreground
        }
    }

    // You don't need a separate MouseArea because Button already handles clicks
    // The onClicked handler will be available when you use this component
}
