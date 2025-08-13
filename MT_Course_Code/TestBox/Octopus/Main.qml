import QtQuick 2.13
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtCharts 2.2

import Octopus



ApplicationWindow
{
  // ... existing properties ...
  property int currentViewIndex: 0 // Used by the various ListViewX


  onCurrentViewIndexChanged: console.log("Current view index changed to:", currentViewIndex)

  title: "QML Modern UI Samples By MT 1"
  visible: true
  width: 1200
  height: 500
  minimumHeight: 500
  minimumWidth: 1200

  // Set default font for all child items
  font.family: "Segoe UI Variable"
  font.pixelSize: 16


  //Universal.theme: Universal[subTheme.currentText]
  //Universal.accent: Universal[accentColor.currentText]

  //Material.theme: Material[subTheme.currentText] // MT removed this to fix it to Dark
  //Material.accent: Material[accentColor.currentText]
  //Material.primary: Material[primaryColor.currentText]
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


  menuBar: MenuBar {
    Menu {
      title: '&File'
      Action { text: '&New...' }
      Action { text: '&Open...' }
      Action { text: '&Save' }
      Action { text: 'Save &As...' }
      MenuSeparator {}
      Action { text: '&Quit' }
    }
    Menu {
      title: '&Edit'
      Action { text: 'Cu&t' }
      Action { text: '&Copy' }
      Action { text: '&Paste' }
    }
    Menu {
      title: '&Help'
      Action { text: '&About' }
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

          RowLayout {
              anchors.fill: parent
              ToolButton {
                  icon.source: "qrc:/Octopus/images/baseline-menu-24px.svg"
                  onClicked: sideNav.open()
              }
              Label {
                  text: 'Octopus - Submersible Application ver 1.00 beta'
                  color: "black"  // Keeps text readable against the gradient
                  font {
                      bold: true
                      pixelSize: 18
                      family: "Arial"
                  }
                  elide: Label.ElideRight
                  horizontalAlignment: Qt.AlignHCenter
                  verticalAlignment: Qt.AlignVCenter
                  Layout.fillWidth: true
              }
              ToolButton { text: 'Action 1' }
              ToolButton { text: 'Action 2' }
              ToolSeparator {}
              ToolButton { text: 'Action 3' }
              ToolButton { text: 'Action 4' }
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
                text: 'List ' + (index + 1)  // Changed to show List 1, List 2, etc.
                Layout.fillWidth: true
                // Add click handler
                onClicked: {
                    currentViewIndex = index
                    sideNav.close()
                    console.log("Switched to view", index)  // Debug output
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
          ListView0 {}  // Your original grid content
          ListView1 {}  // New simple view


          // Add more views as needed
      }
  }



  footer: RowLayout
  {
    width: parent.width
    RowLayout
    {
      Layout.margins: 10
      Layout.alignment: Qt.AlignHCenter
      Label { text: 'QtQuick Charts Themes: ' }
      ComboBox {
        id: qtquickChartsThemes
        model: [
          'ChartThemeLight', 'ChartThemeBlueCerulean',
          'ChartThemeDark', 'ChartThemeBrownSand',
          'ChartThemeBlueNcs', 'ChartThemeHighContrast',
          'ChartThemeBlueIcy', 'ChartThemeQt'
        ]
        Layout.fillWidth: true
      }
    }
    RowLayout {
      Layout.margins: 10
      Layout.alignment: Qt.AlignHCenter
      Label { text: 'QtQuick 2 Themes: ' }
      Label {
        id: qtquick2Themes
        objectName: 'qtquick2Themes'
        Layout.fillWidth: true
      }
    }
    RowLayout {
      Layout.margins: 10
      Layout.alignment: Qt.AlignHCenter
      Label { text: 'Sub-Theme: ' }
      ComboBox {
        id: subTheme
        model: ['Dark', 'Light']  // MT swapped temporarily
        Layout.fillWidth: true
        enabled: true // MT Temporarily disabled as we cannot set Materials ..etc theme from main  //qtquick2Themes.text === 'Material' || qtquick2Themes.text === 'Universal'
      }
    }
    RowLayout {
      property var materialColors: [
        'Red', 'Pink', 'Purple', 'DeepPurple', 'Indigo', 'Blue',
        'LightBlue', 'Cyan', 'Teal', 'Green', 'LightGreen', 'Lime',
        'Yellow', 'Amber', 'Orange', 'DeepOrange', 'Brown', 'Grey',
        'BlueGrey'
      ]
      property var universalColors: [
        'Lime', 'Green', 'Emerald', 'Teal', 'Cyan', 'Cobalt',
        'Indigo', 'Violet', 'Pink', 'Magenta', 'Crimson', 'Red',
        'Orange', 'Amber', 'Yellow', 'Brown', 'Olive', 'Steel', 'Mauve',
        'Taupe'
      ]
      Layout.margins: 10
      Layout.alignment: Qt.AlignHCenter
      Label { text: 'Colors: ' }
      Label { text: 'Accent' }
      ComboBox {
        id: accentColor
        Layout.fillWidth: true
        enabled: true // qtquick2Themes.text === 'Material' || qtquick2Themes.text === 'Universal'
        model: {
          if (qtquick2Themes.text === 'Universal') return parent.universalColors
          return parent.materialColors
        }
      }
      Label { text: 'Primary' }
      ComboBox {
        id: primaryColor
        Layout.fillWidth: true
        enabled: true // qtquick2Themes.text === 'Material'
        model: parent.materialColors
      }
    }
  }

}
