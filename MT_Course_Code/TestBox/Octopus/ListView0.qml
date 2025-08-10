// ListView0.qml
import QtQuick 2.13
import QtQuick.Layouts 1.11
import QtQuick.Controls 2.4
import QtQuick.Controls.Material 2.4
import QtCharts 2.2

Item {
    // This replicates your original Pane content
    GridLayout
    {
      anchors.fill: parent
      flow: GridLayout.TopToBottom
      rows: 2
      CellBox
      {
        title: 'Buttons'
        ColumnLayout
        {
          anchors.fill: parent
          Button
          {
            text: 'Button'
            Layout.fillWidth: true
            onClicked: normalPopup.open()
          }
          Button
          {
            text: 'Flat'
            Layout.fillWidth: true
            flat: true
            onClicked: modalPopup.open()
          }
          Button
          {
            text: 'Highlighted'
            Layout.fillWidth: true
            highlighted: true
            onClicked: dialog.open()
          }
          RoundButton
          {
            text: '+'
            Layout.alignment: Qt.AlignHCenter
          }
        }
      }
      CellBox
      {
        title: 'Radio Buttons'
        ColumnLayout
        {
          anchors.fill: parent
          RadioButton { text: 'Radio Button 1'; checked: true }
          RadioButton { text: 'Radio Button 2' }
          RadioButton { text: 'Radio Button 3' }
          RadioButton { text: 'Radio Button 4' }
        }
      }


      // MT added
      CellBox
      {
        id: mttestA
        title: 'MT Testing'
        ColumnLayout
        {
          Button
          {
              id : button1Id
              //anchors.top : mtrest.top
              text : "Pass data to Cpp"
              onClicked:
              {
                  var arr = ['Africa','Asia',"Europe","North America","South America","Oceania","Antarctica"]
                  var obj =
                  {
                      firstName:"John",
                      lastName:"Doe",
                      location:"Earth"
                  }

                  CppClass.passFromQmlToCpp(arr,obj);
              }
          }




          Button
          {
              id : button2Id

              text : "GetVariantListFromCpp"
              onClicked:
              {
                  var data = CppClass.getVariantListFromCpp() //returns array
                  data.forEach(function(element){
                      console.log("Array item :" + element)
                  })
              }
          }


          Button
          {
              id : button3Id

              text : "GetVariantMapFromCpp"
              onClicked:
              {
                  var data = CppClass.getVariantMapFromCpp() //returns object
                  for ( var mKey in data){
                      console.log("Object[" +mKey+"] :"+ data[mKey])
                  }
              }
          }


          Button
          {
              id : button4Id
              text : "TriggerJSCall"

              onClicked:
              {
                  CppClass.triggerJSCall();
              }
          }

          Switch
          {
              id : switch5Id
              text: qsTr("switchbutton")
              Layout.alignment: Qt.AlignHCenter
              enabled: true
              checked: CppClass.switchEnabled  // This binds to the C++ property
          }



        }





      }





      CellBox
      {
        title: 'Check Boxes'
        ColumnLayout
        {
          anchors.fill: parent
          Switch { Layout.alignment: Qt.AlignHCenter }
          ButtonGroup
          {
            id: childGroup
            exclusive: false
            checkState: parentBox.checkState
          }
          CheckBox
          {
            id: parentBox
            text: 'Parent'
            checkState: childGroup.checkState
          }
          CheckBox
          {
            checked: true
            text: 'Child 1'
            leftPadding: indicator.width
            ButtonGroup.group: childGroup
          }
          CheckBox
          {
            text: 'Child 2'
            leftPadding: indicator.width
            ButtonGroup.group: childGroup
          }
        }
      }
      CellBox
      {
        title: 'Progress Indicators'
        ColumnLayout
        {
          anchors.fill: parent
          BusyIndicator
          {
            running: true
            Layout.alignment: Qt.AlignHCenter
            ToolTip.visible: hovered
            ToolTip.text: 'Busy Indicator'
          }
          DelayButton
          {
            text: 'Delay Button'
            delay: 3000
            Layout.fillWidth: true
          }
          ProgressBar { value: 0.6; Layout.fillWidth: true }
          ProgressBar { indeterminate: true; Layout.fillWidth: true }
        }
      }
      CellBox
      {
          title: 'ComboBoxes'
          ColumnLayout
          {
              anchors.fill: parent
              ComboBox
              {
                model: ['Normal', 'Second', 'Third']
                Layout.fillWidth: true
              }
              ComboBox
              {
                model: ['Flat', 'Second', 'Third']
                Layout.fillWidth: true
                flat: true
              }
              ComboBox
              {
                model: ['Editable', 'Second', 'Third']
                Layout.fillWidth: true
                editable: true
              }
              ComboBox
              {
                  model: 10
                  editable: true
                  validator: IntValidator { top: 9; bottom: 0 }
                  Layout.fillWidth: true
              }
          }
      }
      CellBox
      {
        title: 'Range Controllers'
        ColumnLayout
        {
          anchors.fill: parent
          Dial {
            id: dial
            scale: 1.1
            Layout.alignment: Qt.AlignHCenter
            ToolTip {
              parent: dial.handle
              visible: dial.pressed
              text: dial.value.toFixed(2)
            }
          }
          RangeSlider {
            first.value: 0.25; second.value: 0.75; Layout.fillWidth: true
            ToolTip.visible: hovered
            ToolTip.text: 'Range Slider'
          }
          Slider {
            id: slider
            Layout.fillWidth: true
            ToolTip {
              parent: slider.handle
              visible: slider.pressed
              text: slider.value.toFixed(2)
            }
          }
        }
      }
      CellBox
      {
        title: 'Spin Boxes'
        ColumnLayout
        {
          anchors.fill: parent
          SpinBox { value: 50; editable: true; Layout.fillWidth: true }

          /*
          SpinBox
          {
              from: 0
              to: items.length - 1
              value: 1 // 'Medium'
              property var items: ['Small', 'Medium', 'Large']
              validator: IntValidator {
                  bottom: 0
                  top: items.length - 1
              }
              textFromValue: function(value) {
                  return items[value];
              }
              valueFromText: function(text) {
                  for (var i = 0; i < items.length; ++i)
                      if (items[i].toLowerCase().indexOf(text.toLowerCase()) === 0)
                          return i
                  return sb.value
              }
              Layout.fillWidth: true
          }
          */

          SpinBox
          {
            id: doubleSpinbox
            editable: true
            from: 0
            value: 110
            to: 100 * 100
            stepSize: 100
            property int decimals: 2
            property real realValue: value / 100
            validator: DoubleValidator
            {
              bottom: Math.min(doubleSpinbox.from, doubleSpinbox.to)
              top:  Math.max(doubleSpinbox.from, doubleSpinbox.to)
            }
            textFromValue: function(value, locale)
            {
              return Number(value / 100).toLocaleString(locale, 'f', doubleSpinbox.decimals)
            }
            valueFromText: function(text, locale)
            {
              return Number.fromLocaleString(locale, text) * 100
            }
            Layout.fillWidth: true
          }
        }
      }
      CellBox
      {
        title: 'Text Inputs'
        Column
        {
          // ScrollView will not work if we use ColumnLayout as
          // ColumnLayout always measures its size depending on its
          // contents.
          anchors.fill: parent
          spacing: 10
          TextField
          {
            width: parent.width
            placeholderText: 'Enter something here...'
            selectByMouse: true
          }
          TextField {
            width: parent.width
            text: 'read only'
            readOnly: true
          }
          ScrollView
          {
            width: parent.width
            height: parent.height - y
            TextArea {
              placeholderText: 'Multi-line text editor...'
              selectByMouse: true
              persistentSelection: true
            }
          }
        }
      }
      CellBox
      {
        Layout.rowSpan: 2; Layout.minimumWidth: 700
        title: 'Tabs'
        Layout.preferredWidth: height // Keep the ratio right!
        TabBar
        {
          id: bar
          width: parent.width
          TabButton { text: 'Area' }
          TabButton { text: 'Bar' }
          TabButton { text: 'Box' }
          TabButton { text: 'Candlestick' }
          TabButton { text: 'Polar' }
          TabButton { text: 'Scatter' }
          TabButton { text: 'Spine' }
          TabButton { text: 'Pie' }
        }

        StackLayout
        {
          width: parent.width
          height: parent.height - y
          anchors.top: bar.bottom
          currentIndex: bar.currentIndex

          // Bar Graph - 2 x Y axis (Depth, Tempeature)
          ChartView
          {
              width: 1600
              height: 800
              theme: ChartView.ChartThemeDark
              antialiasing: true
              legend.visible: true
              legend.alignment: Qt.AlignBottom
              margins { top: 20; bottom: 40; left: 20; right: 40 } // Increased right margin

              /*
              // Customize the legend appearance
              // Add a custom legend (e.g., using Row + Rectangle + Text)
              Row
              {
                  anchors.bottom: parent.bottom
                  spacing: 10
                  Repeater
                  {
                      model: ["Temperature", "Depth", "Conductivity"]
                      delegate: Row
                      {
                          spacing: 5
                          Rectangle { width: 15; height: 15; color: "green" }
                          Text { text: modelData; color: "white"; font.pixelSize: 14 }
                      }
                  }
              }
              */

              // X-Axis (Time)
              DateTimeAxis {
                  id: axisX
                  format: "hh:mm"
                  titleText: "Time (minutes)"
                  min: new Date(2023, 0, 1, 0, 0, 0)
                  max: new Date(2023, 0, 1, 3, 20, 0) // 3 hours, 20 minutes
              }

              // Left Y-Axis (Depth - Primary)
              ValueAxis {
                  id: axisYDepth
                  min: 0
                  max: 50
                  titleText: "Depth (meters)"
                  labelFormat: "%.0f"
              }

              // Right Y-Axis 1 (Temperature)
              ValueAxis {
                  id: axisYTemp
                  min: 10
                  max: 30
                  titleText: "Temperature (°C)"
                  labelFormat: "%.1f"
              }

              // Right Y-Axis 2 (Conductivity)
              ValueAxis {
                  id: axisYConductivity
                  min: 0
                  max: 60
                  titleText: "Conductivity (mS/cm)"
                  labelFormat: "%.0f"
              }

              /*
              // Right Y-Axis 3 (Oxygen - New)
              ValueAxis {
                  id: axisYOxygen
                  min: 0
                  max: 10
                  titleText: "Oxygen (mg/L)"
                  labelFormat: "%.1f"
              }
              */

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
                          var temp = 18 + 7 * Math.sin(i/16);
                          append(new Date(2023,0,1,0,i,0).getTime(), temp);
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
                      for (var i = 0; i <= 500; i+=2) {
                          var cond = 10 + 50 * Math.sin(i/25);
                          append(new Date(2023,0,1,0,i,0).getTime(), cond);
                      }
                  }
              }

              // Oxygen Line (New)
              LineSeries {
                  name: "Oxygen"
                  axisX: axisX
                  axisYRight: axisYOxygen
                  color: "#d62728" // Red
                  width: 2
                  style: Qt.DashDotLine

                  Component.onCompleted: {
                      for (var i = 0; i <= 500; i+=2) {
                          var oxygen = 5 + 4 * Math.cos(i/20);
                          append(new Date(2023,0,1,0,i,0).getTime(), oxygen);
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
                          var depth = 20 + 15 * Math.sin(i/10);
                          append(new Date(2023,0,1,0,i,0).getTime(), depth);
                      }
                  }
              }

              // Custom axis placement
              onPlotAreaChanged: {
                  // Position Temperature axis (first right axis)
                  axisYTemp.visible = true;
                  axisYTemp.lineVisible = true;
                  axisYTemp.labelsVisible = true;
                  axisYTemp.titleVisible = true;
                  axisYTemp.alignment = Qt.AlignRight;
                  axisYTemp.offset = 0;

                  // Position Conductivity axis (second right axis)
                  axisYConductivity.visible = true;
                  axisYConductivity.lineVisible = true;
                  axisYConductivity.labelsVisible = true;
                  axisYConductivity.titleVisible = true;
                  axisYConductivity.alignment = Qt.AlignRight;
                  axisYConductivity.offset = -50; // Adjust based on your chart width

                  // Position Oxygen axis (third right axis)
                  axisYOxygen.visible = true;
                  axisYOxygen.lineVisible = true;
                  axisYOxygen.labelsVisible = true;
                  axisYOxygen.titleVisible = true;
                  axisYOxygen.alignment = Qt.AlignRight;
                  axisYOxygen.offset = -100; // Adjust based on your chart width
              }
          }



/*
          // Line Graph - 2 x Y axis (Depth, Tempeature)
          ChartView {
              width: 800
              height: 500
              theme: ChartView.ChartThemeLight
              antialiasing: true
              legend.visible: true
              legend.alignment: Qt.AlignBottom

              // X-Axis (Time)
              DateTimeAxis {
                  id: axisX
                  format: "hh:mm"
                  titleText: "Time"
                  min: new Date(2023, 0, 1, 8, 0)  // Jan 1 2023, 8:00 AM
                  max: new Date(2023, 0, 1, 12, 0) // Jan 1 2023, 12:00 PM
              }

              // Left Y-Axis (Depth)
              ValueAxis {
                  id: axisYDepth
                  min: 0
                  max: 40
                  titleText: "Depth (meters)"
                  labelFormat: "%.0f"
              }

              // Right Y-Axis (Temperature)
              ValueAxis {
                  id: axisYTemp
                  min: 15
                  max: 25
                  titleText: "Temperature (°C)"
                  labelFormat: "%.0f"
              }

              // Temperature Line (right axis)
              LineSeries {
                  name: "Temperature"
                  axisX: axisX
                  axisYRight: axisYTemp
                  color: "#ff7f0e"  // Orange
                  width: 3
                  style: Qt.DashLine

                  // Sample temperature data points
                  XYPoint { x: new Date(2023, 0, 1, 8, 0).getTime(); y: 18 }
                  XYPoint { x: new Date(2023, 0, 1, 9, 0).getTime(); y: 19 }
                  XYPoint { x: new Date(2023, 0, 1, 10, 0).getTime(); y: 22 }
                  XYPoint { x: new Date(2023, 0, 1, 11, 0).getTime(); y: 20 }
                  XYPoint { x: new Date(2023, 0, 1, 12, 0).getTime(); y: 17 }
              }

              // Depth Line (left axis)
              LineSeries {
                  name: "Depth"
                  axisX: axisX
                  axisY: axisYDepth
                  color: "#1f77b4"  // Blue
                  width: 3

                  // Sample depth data points
                  XYPoint { x: new Date(2023, 0, 1, 8, 0).getTime(); y: 12 }
                  XYPoint { x: new Date(2023, 0, 1, 9, 0).getTime(); y: 22 }
                  XYPoint { x: new Date(2023, 0, 1, 10, 0).getTime(); y: 35 }
                  XYPoint { x: new Date(2023, 0, 1, 11, 0).getTime(); y: 18 }
                  XYPoint { x: new Date(2023, 0, 1, 12, 0).getTime(); y: 8 }
              }

              // Add margins to prevent clipping
              margins {
                  top: 20
                  bottom: 30
                  left: 20
                  right: 20
              }
          }

*/
        }



/*
        StackLayout
        {
          width: parent.width
          height: parent.height - y
          anchors.top: bar.bottom
          currentIndex: bar.currentIndex
          LargeChartView
          {
            // Define x-axis to be used with the series instead of default one
            ValueAxis
            {
              id: valueAxisAreaSeries
              min: 2000
              max: 2011
              tickCount: 12
              labelFormat: '%.0f'
            }
            AreaSeries
            {
              name: 'The U.S.'
              axisX: valueAxisAreaSeries
              upperSeries: LineSeries
              {
                XYPoint { x: 2000; y: 3 }
                XYPoint { x: 2001; y: 2 }
                XYPoint { x: 2002; y: 1 }
                XYPoint { x: 2003; y: 2 }
                XYPoint { x: 2004; y: 1 }
                XYPoint { x: 2005; y: 1 }
                XYPoint { x: 2006; y: 0 }
                XYPoint { x: 2007; y: 3 }
                XYPoint { x: 2008; y: 4 }
                XYPoint { x: 2009; y: 1 }
                XYPoint { x: 2010; y: 0 }
                XYPoint { x: 2011; y: 1 }
              }
            }
            AreaSeries
            {
              name: 'Russian'
              axisX: valueAxisAreaSeries
              upperSeries: LineSeries
              {
                XYPoint { x: 2000; y: 1 }
                XYPoint { x: 2001; y: 1 }
                XYPoint { x: 2002; y: 1 }
                XYPoint { x: 2003; y: 1 }
                XYPoint { x: 2004; y: 1 }
                XYPoint { x: 2005; y: 0 }
                XYPoint { x: 2006; y: 1 }
                XYPoint { x: 2007; y: 1 }
                XYPoint { x: 2008; y: 4 }
                XYPoint { x: 2009; y: 3 }
                XYPoint { x: 2010; y: 2 }
                XYPoint { x: 2011; y: 1 }             
              }
            }
            AreaSeries
            {
              name: 'Taiwan'
              axisX: valueAxisAreaSeries
              upperSeries: LineSeries
              {
                XYPoint { x: 2000; y: 2 }
                XYPoint { x: 2001; y: 1 }
                XYPoint { x: 2002; y: 0 }
                XYPoint { x: 2003; y: 3 }
                XYPoint { x: 2004; y: 0 }
                XYPoint { x: 2005; y: 0 }
                XYPoint { x: 2006; y: 1 }
                XYPoint { x: 2007; y: 1 }
                XYPoint { x: 2008; y: 0 }
                XYPoint { x: 2009; y: 2 }
                XYPoint { x: 2010; y: 2 }
                XYPoint { x: 2011; y: 1 }
              }
            }
          }
          LargeChartView
          {
            BarSeries
            {
              axisX: BarCategoryAxis
              {
                categories: ['2007', '2008', '2009', '2010', '2011', '2012' ]
              }
              BarSet { label: 'Bob'; values: [2, 2, 3, 4, 5, 6] }
              BarSet { label: 'Susan'; values: [5, 1, 2, 4, 1, 7] }
              BarSet { label: 'James'; values: [3, 5, 8, 13, 5, 8] }
            }
          }
          LargeChartView
          {
            BoxPlotSeries
            {
              name: 'Income'
              BoxSet { label: 'Jan'; values: [3, 4, 5.1, 6.2, 8.5] }
              BoxSet { label: 'Feb'; values: [5, 6, 7.5, 8.6, 11.8] }
              BoxSet { label: 'Mar'; values: [3.2, 5, 5.7, 8, 9.2] }
              BoxSet { label: 'Apr'; values: [3.8, 5, 6.4, 7, 8] }
              BoxSet { label: 'May'; values: [4, 5, 5.2, 6, 7] }
            }
            BoxPlotSeries
            {
              name: 'Tax'
              BoxSet { label: 'Jan'; values: [1.2, 2.1, 3.2, 3.4, 5.5] }
              BoxSet { label: 'Feb'; values: [2, 2.2, 2.9, 3.6, 6.8] }
              BoxSet { label: 'Mar'; values: [1.2, 2.2, 2.7, 3.9, 5.2] }
              BoxSet { label: 'Apr'; values: [1.8, 2, 2.2, 3, 3.2] }
              BoxSet { label: 'May'; values: [2, 1.9, 2.2, 3, 4] }
            }
          }
          LargeChartView
          {
            CandlestickSeries
            {
              name: 'Acme Ltd.'
              increasingColor: 'green'
              decreasingColor: 'red'
              CandlestickSet { timestamp: 1435708800000; open: 690; high: 694; low: 599; close: 660 }
              CandlestickSet { timestamp: 1435795200000; open: 669; high: 669; low: 669; close: 669 }
              CandlestickSet { timestamp: 1436140800000; open: 485; high: 623; low: 485; close: 600 }
              CandlestickSet { timestamp: 1436227200000; open: 589; high: 615; low: 377; close: 569 }
              CandlestickSet { timestamp: 1436313600000; open: 464; high: 464; low: 254; close: 254 }
            }
          }
          PolarChartView
          {
            animationOptions: ChartView.SeriesAnimations
            legend.visible: false
            antialiasing: true
            theme: ChartView[qtquickChartsThemes.currentText]
            ValueAxis
            {
              id: axisAngular
              min: 0
              max: 20
              tickCount: 9
            }
            ValueAxis
            {
              id: axisRadial
              min: -0.5
              max: 1.5
            }
            SplineSeries
            {
              id: series1
              axisAngular: axisAngular
              axisRadial: axisRadial
              pointsVisible: true
            }
            ScatterSeries
            {
              id: series2
              axisAngular: axisAngular
              axisRadial: axisRadial
              markerSize: 10
            }
          }
          // Add data dynamically to the series
          Component.onCompleted:
          {
            for (var i = 0; i <= 20; i++) {
              series1.append(i, Math.random());
              series2.append(i, Math.random());
            }
          }
          LargeChartView
          {
            ScatterSeries
            {
              name: 'Scatter1'
              XYPoint { x: 0.51; y: 1.5 }
              XYPoint { x: 0.56; y: 1.6 }
              XYPoint { x: 0.57; y: 1.55 }
              XYPoint { x: 0.85; y: 1.8 }
              XYPoint { x: 0.96; y: 1.6 }
              XYPoint { x: 0.12; y: 1.3 }
              XYPoint { x: 0.52; y: 2.1 }
            }
            ScatterSeries
            {
              name: 'Scatter2'
              XYPoint { x: 0.4; y: 1.5 }
              XYPoint { x: 0.9; y: 1.6 }
              XYPoint { x: 0.7; y: 1.55 }
              XYPoint { x: 0.8; y: 1.8 }
              XYPoint { x: 0.5; y: 1.6 }
              XYPoint { x: 0.1; y: 1.3 }
              XYPoint { x: 0.6; y: 2.1 }
            }
          }
          LargeChartView
          {
            SplineSeries
            {
              name: 'BPM'
              XYPoint { x: 0; y: 0.0 }
              XYPoint { x: 1.1; y: 5.2 }
              XYPoint { x: 1.9; y: 2.4 }
              XYPoint { x: 2.1; y: 2.1 }
              XYPoint { x: 2.9; y: 2.6 }
              XYPoint { x: 3.4; y: 2.3 }
              XYPoint { x: 4.1; y: 3.1 }
            }

            SplineSeries
            {
              name: 'Temp'
              XYPoint { x: 0; y: 0.0 }
              XYPoint { x: 1.1; y: 15.2 }
              XYPoint { x: 1.9; y: 12.4 }
              XYPoint { x: 2.1; y: 25.1 }
              XYPoint { x: 2.9; y: 22.6 }
              XYPoint { x: 3.4; y: 8.3 }
              XYPoint { x: 4.1; y: 13.1 }
            }

          }
          LargeChartView
          {
            PieSeries {
              PieSlice { label: 'eaten'; value: 74.7 }
              PieSlice { label: 'not yet eaten'; value: 5.1 }
              PieSlice { label: 'wut?'; value: 20.2; exploded: true }
            }
          }
        }

*/

      }
      Popup
      {
        id: normalPopup
        ColumnLayout
        {
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
        ColumnLayout
        {
          anchors.fill: parent
          Label { text: 'Modal Popup' }
          CheckBox { text: 'E-mail' }
          CheckBox { text: 'Calendar' }
          CheckBox { text: 'Contacts' }
        }
      }
      Dialog
      {
        id: dialog
        title: 'Dialog'
        Label { text: 'The standard dialog.' }
        footer: DialogButtonBox {
          standardButtons: DialogButtonBox.Ok | DialogButtonBox.Cancel
        }
      }
    }
}
