import QtQuick 2.13
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtCharts 2.2

import Octopus

ApplicationWindow
{
  id: mainWindow
  // ... existing properties ...
  property int currentViewIndex: 0 // Used by the various ListViewX

  onCurrentViewIndexChanged: console.log("Current view index changed to:", currentViewIndex)

  title: "Spectraware"
  visible: true
  width: 1920  // 1200
  height: 1050  // 500
  minimumHeight: 1050  // 500
  minimumWidth: 1920  // 1200

  // Set default font for all child items
  font.family: "Segoe UI Variable"
  font.pixelSize: 16

  Material.theme: Material.Dark
  Material.accent: Material.Red
  Material.primary: Material.DeepOrange

  function arrayObjectFunc(array, object)
  {
      console.log("---Printing array---")
      array.forEach(function(element)
      {
          console.log("Array item :" + element)
      })

      console.log("---Printing object---")
      for ( var mKey in object)
      {
          console.log("Object[" +mKey+"] :"+ object[mKey])
      }
  }

  header: ToolBar {
      contentItem: Rectangle {
          // Gradient fill for the toolbar
          gradient: Gradient {
              orientation: Gradient.Horizontal
              GradientStop { position: 0.0; color: "#4E342E" }  // Deep Warm Brown
              GradientStop { position: 0.25; color: "#FFA500" }  // Vibrant Orange Core
              GradientStop { position: 1.0; color: "#FFBF00" }  // Bright Golden Yellow
          }

          // Container for absolute positioning
          Item {
              anchors.fill: parent

              // Left side items
              ToolButton {
                  id: menuButton
                  icon.source: "qrc:/Octopus/images/baseline-menu-24px.svg"
                  onClicked: sideNav.open()
                  anchors.left: parent.left
                  anchors.verticalCenter: parent.verticalCenter
              }

              // Right side items container
              Row {
                  id: rightButtons
                  anchors.right: parent.right
                  anchors.verticalCenter: parent.verticalCenter
                  spacing: 5

                  ToolButton
                  {
                      text: 'Connect'
                      enabled: !CppClass.running

                      contentItem: Text {
                          text: parent.text
                          font.pixelSize: CppClass.running ? 18 : 16
                          font.bold: CppClass.running
                          color: parent.enabled ? (CppClass.running ? "#36454F" : "white") : "gray"
                          horizontalAlignment: Text.AlignHCenter
                          verticalAlignment: Text.AlignVCenter
                      }
                      onClicked: {
                          CppClass.startComm();
                      }
                  }
                  ToolSeparator {}
                  ToolButton
                  {
                      text: 'Disconnect'
                      enabled: CppClass.running

                      contentItem: Text {
                          text: parent.text
                          font.pixelSize: !CppClass.running ? 18 : 16
                          font.bold: !CppClass.running
                          color: parent.enabled ? (!CppClass.running ? "#36454F" : "white") : "gray"
                          horizontalAlignment: Text.AlignHCenter
                          verticalAlignment: Text.AlignVCenter
                      }
                      onClicked: {
                          CppClass.stopComm();
                      }
                  }
                  ToolButton {
                      icon.source: "qrc:/Octopus/images/baseline-more_vert-24px.svg"
                      onClicked: menu.open()
                      Menu {
                          id: menu
                          y: parent.height
                          MenuItem { text: 'New...' }
                          MenuItem { text: 'Open...' }
                          MenuItem { text: 'Save' }
                      }
                  }
              }

              // Centered Image - absolutely positioned in the true center
              Image {
                  id: logoImage
                  source: "qrc:/Octopus/images/Spectraware_C1.png"
                  fillMode: Image.PreserveAspectFit
                  anchors.centerIn: parent
                  height: 40 // Adjust height as needed
                  width: 1195 // Fixed width matching image dimensions
              }
          }
      }
  }

  Drawer
  {
    id: sideNav
    width: 200
    height: parent.height
    ColumnLayout {
        width: parent.width
        Label {
            text: 'Drawer'
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            font.pixelSize: 20
            Layout.fillWidth: true
        }
        Repeater {
            model: 5
            SideNavButton {
                icon.source: "qrc:/Octopus/images/baseline-category-24px.svg"
                text: 'List ' + (index + 1)
                Layout.fillWidth: true
                onClicked: {
                    currentViewIndex = index
                    sideNav.close()
                    console.log("Switched to view", index)
                }
            }
        }
    }
  }

  Pane
  {
      padding: 10
      anchors.fill: parent

      StackLayout
      {
          id: contentStack
          anchors.fill: parent
          currentIndex: currentViewIndex

          ListView2 {}
          ListView4 {}  // Guages
          ListView3 {}  // New simple view
          ListView0 {}  // Your original grid content
          ListView1 {}  // New simple view
      }
  }
}
