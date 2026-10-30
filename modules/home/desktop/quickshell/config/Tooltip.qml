import QtQuick
import QtQuick.Layouts
import Quickshell

// Label/value tooltip under a bar widget, in Noctalia v5's style.
// Shown while `target` is hovered.
PopupWindow {
    id: root

    required property Item target
    required property bool hovered
    property var rows: [] // [[label, value], ...]

    anchor.item: target
    anchor.edges: Edges.Bottom
    anchor.gravity: Edges.Bottom
    anchor.margins.top: 10
    visible: hovered && hoverDelay.passed && rows.length > 0
    onHoveredChanged: if (!hovered) hoverDelay.passed = false
    color: "transparent"
    implicitWidth: box.implicitWidth
    implicitHeight: box.implicitHeight

    // Small delay so passing the mouse over the bar doesn't flash tooltips.
    Timer {
        id: hoverDelay
        property bool passed: false
        interval: 300
        running: root.hovered
        onTriggered: passed = true
    }

    Rectangle {
        id: box
        implicitWidth: grid.implicitWidth + 24
        implicitHeight: grid.implicitHeight + 16
        radius: 10
        color: Qt.alpha(Theme.bg, 0.97)
        border.color: Theme.surface
        border.width: 1

        GridLayout {
            id: grid
            anchors.centerIn: parent
            columns: 2
            columnSpacing: 16
            rowSpacing: 4

            Repeater {
                model: [].concat(...root.rows)

                Text {
                    required property string modelData
                    required property int index
                    readonly property bool isLabel: index % 2 === 0

                    Layout.alignment: isLabel ? Qt.AlignLeft : Qt.AlignRight
                    text: modelData
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSize - 1
                    font.bold: !isLabel
                    color: isLabel ? Qt.alpha(Theme.fg, 0.7) : Theme.fg
                }
            }
        }
    }
}
