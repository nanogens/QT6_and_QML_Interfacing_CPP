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

  // To inidcate if a connection (Connect) button is active so we know what Stream Data button is allowed to do
  Connections {
      target: CppClass
      function onRunningChanged() {
          if (contentStack.currentItem && contentStack.currentItem.setConnectionState) {
              contentStack.currentItem.setConnectionState(CppClass.running);

              // Force reset the streaming state when connection changes
              if (contentStack.currentItem && contentStack.currentItem.resetStreamState) {
                  contentStack.currentItem.resetStreamState();
              }
          }
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

                  // Connect button
                  ToolButton
                  {
                      text: 'Connect'
                      // Add null check
                      enabled: CppClass ? !CppClass.running : false

                      contentItem: Text {
                          text: parent.text
                          // Add null checks
                          font.pixelSize: (CppClass && CppClass.running) ? 18 : 16
                          font.bold: (CppClass && CppClass.running)
                          color: parent.enabled ? ((CppClass && CppClass.running) ? "#36454F" : "#36454F") : "gray"
                          horizontalAlignment: Text.AlignHCenter
                          verticalAlignment: Text.AlignVCenter
                      }
                      onClicked: {
                          if (CppClass) {
                              CppClass.startComm();
                              if (contentStack.currentItem && contentStack.currentItem.setConnectionState) {
                                  contentStack.currentItem.setConnectionState(true);
                              }
                          }
                      }
                  }

                  ToolSeparator {}


                  // Disconnect button
                  ToolButton
                  {
                      text: 'Disconnect'
                      // Add null check
                      enabled: CppClass ? CppClass.running : false

                      contentItem: Text {
                          text: parent.text
                          // Add null checks
                          font.pixelSize: (CppClass && !CppClass.running) ? 18 : 16
                          font.bold: (CppClass && !CppClass.running)
                          color: parent.enabled ? ((CppClass && !CppClass.running) ? "#36454F" : "white") : "gray"
                          horizontalAlignment: Text.AlignHCenter
                          verticalAlignment: Text.AlignVCenter
                      }
                      onClicked: {
                          if (!CppClass) return;

                          console.log("=== Disconnect button clicked ===");

                          // Directly reset streaming state
                          if (contentStack.currentItem) {
                              console.log("Directly resetting stream state");
                              contentStack.currentItem.streamActive = false;
                              if (contentStack.currentItem.resetStreamState) {
                                  contentStack.currentItem.resetStreamState();
                              }
                          }

                          // Then stop the communication
                          CppClass.stopComm();
                          console.log("=== Disconnect complete ===");
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
                  source: "qrc:/Octopus/images/Spectraware_D1.png"
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
      width: 280
      height: parent.height
      ColumnLayout {
          width: parent.width
          Label {
              text: '-= Main Menu =-'
              horizontalAlignment: Text.AlignHCenter
              verticalAlignment: Text.AlignVCenter
              font.pixelSize: 25
              Layout.fillWidth: true
          }
          Repeater {
              model: ["1. Streaming Page", "2. Settings Page", "3. Graphing Page"]
              SideNavButton {
                  icon.source: "qrc:/Octopus/images/baseline-category-24px.svg"
                  text: modelData
                  font.pixelSize: 22
                  Layout.fillWidth: true
                  onClicked: {
                      currentViewIndex = index
                      sideNav.close()
                      console.log("Switched to view:", modelData)
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

          ListView4 {}  // Guages
          ListView2 {}
          ListView3 {}  // New simple view
          //ListView0 {}  // Your original grid content
          //ListView1 {}  // New simple view
      }
  }
}
