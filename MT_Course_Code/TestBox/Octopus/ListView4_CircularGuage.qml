// ListView4_CircularGauge.qml
import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects

Item {
    id: gaugeRoot

    // Public properties that can be set from outside
    property real value: 75
    property real minValue: 0
    property real maxValue: 150
    property string unit: "m"

    // Colors that can be customized
    property color gaugeColor: "#1a1a1a"
    property color textColor: "#ffffff"
    property color scaleColor: "#666666"

    // Two-color gradient for progress indicator
    property color progressStartColor: "springgreen"
    property color progressEndColor: "deepskyblue"

    // Size properties that scale with parent
    width: 300
    height: 300

    // Calculate the normalized value (0-1 range)
    property real normalizedValue: (value - minValue) / (maxValue - minValue)

    // ANIMATION FOR TESTING
    PropertyAnimation on value {
        id: testAnimation
        from: minValue
        to: maxValue
        duration: 5000
        loops: Animation.Infinite
        running: true
    }

    Behavior on value {
        SmoothedAnimation {
            velocity: 200 // Adjust for your value range
            duration: 200
        }
    }

    // Subtle glow effect
    layer.enabled: true
    layer.effect: Glow {
        radius: 20
        samples: 16
        color: blendColors(progressStartColor, progressEndColor, normalizedValue)
        spread: 0.1
    }

    // Function to convert degrees to radians with 0° at 6 o'clock
    function degreesToRadians(degrees) {
        var adjustedDegrees = degrees + 90;
        return adjustedDegrees * Math.PI / 180;
    }

    // Function to blend two colors based on progress
    function blendColors(color1, color2, ratio) {
        return Qt.rgba(
            color1.r * (1 - ratio) + color2.r * ratio,
            color1.g * (1 - ratio) + color2.g * ratio,
            color1.b * (1 - ratio) + color2.b * ratio,
            1
        );
    }

    Canvas {
        id: gaugeCanvas
        anchors.fill: parent

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()

            var centerX = width / 2
            var centerY = height / 2
            var radius = Math.min(width, height) * 0.38
            var lineWidth = radius * 0.18
            var innerRadius = radius - lineWidth / 2
            var outerRadius = radius + lineWidth / 2

            // Dramatic background gradient
            var gradient = ctx.createRadialGradient(centerX, centerY, radius * 0.3, centerX, centerY, radius * 1.2)
            gradient.addColorStop(0, "#3a3a3a")
            gradient.addColorStop(0.7, gaugeColor)
            gradient.addColorStop(1, "#0a0a0a")

            ctx.beginPath()
            ctx.arc(centerX, centerY, radius * 1.05, 0, Math.PI * 2)
            ctx.fillStyle = gradient
            ctx.fill()

            // Metallic rim
            var rimGradient = ctx.createLinearGradient(centerX - radius, centerY, centerX + radius, centerY)
            rimGradient.addColorStop(0, "#555555")
            rimGradient.addColorStop(0.5, "#888888")
            rimGradient.addColorStop(1, "#555555")

            ctx.beginPath()
            ctx.arc(centerX, centerY, radius + lineWidth/2, 0, Math.PI * 2)
            ctx.lineWidth = 3
            ctx.strokeStyle = rimGradient
            ctx.stroke()

            // Define angles for the entire range
            var startAngle = degreesToRadians(30)
            var endAngle = degreesToRadians(330)
            var currentDegrees = 30 + (300 * normalizedValue)
            var currentAngle = degreesToRadians(currentDegrees)

            // Draw progress bar as filled shape
            if (normalizedValue > 0) {
                var startInnerX = centerX + innerRadius * Math.cos(startAngle)
                var startInnerY = centerY + innerRadius * Math.sin(startAngle)
                var startOuterX = centerX + outerRadius * Math.cos(startAngle)
                var startOuterY = centerY + outerRadius * Math.sin(startAngle)

                var endInnerX = centerX + innerRadius * Math.cos(currentAngle)
                var endInnerY = centerY + innerRadius * Math.sin(currentAngle)
                var endOuterX = centerX + outerRadius * Math.cos(currentAngle)
                var endOuterY = centerY + outerRadius * Math.sin(currentAngle)

                ctx.beginPath()
                ctx.moveTo(startInnerX, startInnerY)
                ctx.arc(centerX, centerY, innerRadius, startAngle, currentAngle, false)
                ctx.lineTo(endOuterX, endOuterY)
                ctx.arc(centerX, centerY, outerRadius, currentAngle, startAngle, true)
                ctx.closePath()

                var progressGradient = ctx.createLinearGradient(
                    centerX - radius, centerY,
                    centerX + radius, centerY
                )
                progressGradient.addColorStop(0.0, progressStartColor)
                progressGradient.addColorStop(0.5, blendColors(progressStartColor, progressEndColor, 0.5))
                progressGradient.addColorStop(1.0, progressEndColor)

                ctx.fillStyle = progressGradient
                ctx.fill()
            }

            // Draw remaining range
            if (normalizedValue < 1) {
                ctx.beginPath()
                ctx.moveTo(endInnerX, endInnerY)
                ctx.arc(centerX, centerY, innerRadius, currentAngle, endAngle, false)

                var maxInnerX = centerX + innerRadius * Math.cos(endAngle)
                var maxInnerY = centerY + innerRadius * Math.sin(endAngle)
                var maxOuterX = centerX + outerRadius * Math.cos(endAngle)
                var maxOuterY = centerY + outerRadius * Math.sin(endAngle)

                ctx.lineTo(maxOuterX, maxOuterY)
                ctx.arc(centerX, centerY, outerRadius, endAngle, currentAngle, true)
                ctx.closePath()

                ctx.fillStyle = "#333333"
                ctx.fill()
            }

            // Draw arrow at current value
            if (normalizedValue > 0) {
                var arrowRadius = outerRadius + 10
                var arrowSize = 14
                var arrowX = centerX + arrowRadius * Math.cos(currentAngle)
                var arrowY = centerY + arrowRadius * Math.sin(currentAngle)
                var arrowAngle = currentAngle + Math.PI / 2
                var arrowColor = blendColors(progressStartColor, progressEndColor, normalizedValue)

                ctx.fillStyle = arrowColor
                ctx.beginPath()

                var tipX = arrowX + arrowSize * Math.cos(currentAngle)
                var tipY = arrowY + arrowSize * Math.sin(currentAngle)
                var baseX1 = arrowX + arrowSize * 0.6 * Math.cos(arrowAngle)
                var baseY1 = arrowY + arrowSize * 0.6 * Math.sin(arrowAngle)
                var baseX2 = arrowX - arrowSize * 0.6 * Math.cos(arrowAngle)
                var baseY2 = arrowY - arrowSize * 0.6 * Math.sin(arrowAngle)

                ctx.moveTo(tipX, tipY)
                ctx.lineTo(baseX1, baseY1)
                ctx.lineTo(baseX2, baseY2)
                ctx.closePath()
                ctx.fill()
            }

            // Draw scale marks with gradient coloring
            for (var j = 0; j <= 10; j++) {
                var markDegrees = 30 + (j * 30)
                var markAngle = degreesToRadians(markDegrees)
                var markProgress = j / 10
                var markColor = blendColors(progressStartColor, progressEndColor, markProgress)

                var markInnerRadius = radius * 0.82
                var markOuterRadius = radius * 0.92

                if (j % 5 === 0) {
                    markInnerRadius = radius * 0.78
                    ctx.lineWidth = radius * 0.035
                    ctx.strokeStyle = markColor
                } else {
                    ctx.lineWidth = radius * 0.02
                    ctx.strokeStyle = scaleColor
                }

                var x1 = centerX + markInnerRadius * Math.cos(markAngle)
                var y1 = centerY + markInnerRadius * Math.sin(markAngle)
                var x2 = centerX + markOuterRadius * Math.cos(markAngle)
                var y2 = centerY + markOuterRadius * Math.sin(markAngle)

                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.stroke()
            }

            // Inner circle with gradient
            var innerGradient = ctx.createRadialGradient(centerX, centerY, 0, centerX, centerY, radius * 0.7)
            innerGradient.addColorStop(0, "#1a1a1a")
            innerGradient.addColorStop(1, "#0a0a0a")

            ctx.beginPath()
            ctx.arc(centerX, centerY, radius * 0.68, 0, Math.PI * 2)
            ctx.fillStyle = innerGradient
            ctx.fill()

            // Central dot
            //ctx.beginPath()
            //ctx.arc(centerX, centerY, radius * 0.08, 0, Math.PI * 2)
            //ctx.fillStyle = textColor
            //ctx.fill()
        }
    }

    // OPTIONAL BORDER/SHADOW EFFECTS - Add this after the Canvas
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: "transparent"
        border.color: "#20000000"  // Semi-transparent black
        border.width: 2
        anchors.margins: -0.5  // Extends slightly beyond the gauge
    }

    // Value display with modern typography and with warning (if below/above min/max)
    Column {
        anchors.centerIn: parent
        spacing: gaugeRoot.height * 0.02

        Text {
            id: valueText

            text: {
                if (value > maxValue - 20) return "ABOVE LIMIT!"
                else if (value < minValue + 20) return "BELOW LIMIT!"
                else return value.toFixed(1)
            }
            color: {
                if (value > maxValue - 20) return progressEndColor
                else if (value < minValue + 20) return progressStartColor
                else return textColor
            }
            font.pixelSize: {
                if ((value > maxValue - 20) || (value < minValue + 20))
                    return gaugeRoot.height * 0.06  // Smaller for longer text
                else
                    return gaugeRoot.height * 0.12
            }


            /*
            text: {
                if (value > maxValue) return "ABOVE LIMIT!"
                else if (value < minValue) return "BELOW LIMIT!"
                else return value.toFixed(1)
            }
            color: {
                if (value > maxValue) return progressEndColor
                else if (value < minValue) return progressStartColor
                else return textColor
            }
            font.pixelSize: {
                if (value > maxValue || value < minValue)
                    return gaugeRoot.height * 0.06  // Smaller for longer text
                else
                    return gaugeRoot.height * 0.12
            }
            */

            font.bold: true
            font.family: "Segoe UI"
            style: Text.Raised
            styleColor: "#40000000"
            anchors.horizontalCenter: parent.horizontalCenter
        }

        Text {
            id: unitText
            text: {
                if (value > maxValue || value < minValue) return ""
                else return unit
            }
            color: blendColors(progressStartColor, progressEndColor, normalizedValue)
            font.pixelSize: gaugeRoot.height * 0.1
            font.bold: false
            font.family: "Segoe UI"
            anchors.horizontalCenter: parent.horizontalCenter
            visible: text !== ""  // Hide when empty
        }
    }


    // Min and max value displays
    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.bottom
        anchors.topMargin: gaugeRoot.height * 0.03
        spacing: gaugeRoot.width * 0.55

        Text {
            text: minValue.toFixed(1) + " " + unit
            color: scaleColor
            font.pixelSize: gaugeRoot.height * 0.055
            font.family: "Arial"
        }

        Text {
            text: maxValue.toFixed(1) + " " + unit
            color: scaleColor
            font.pixelSize: gaugeRoot.height * 0.055
            font.family: "Arial"
        }
    }

    // Update canvas when properties change
    onValueChanged: gaugeCanvas.requestPaint()
    onMinValueChanged: gaugeCanvas.requestPaint()
    onMaxValueChanged: gaugeCanvas.requestPaint()
    onWidthChanged: gaugeCanvas.requestPaint()
    onHeightChanged: gaugeCanvas.requestPaint()
}
