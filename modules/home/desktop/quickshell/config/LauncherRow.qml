import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

// One application in the launcher list (Noctalia v4's list delegate): icon, name, description,
// and a pin button on the selected row.
Rectangle {
    id: root

    required property var modelData
    required property int index
    required property bool selected
    signal hovered
    signal activated

    readonly property bool pinned: AppUsage.isPinned(modelData.id)

    implicitHeight: 60
    radius: 10
    color: selected ? Theme.accent : "transparent"

    Behavior on color {
        ColorAnimation {
            duration: 100
        }
    }

    // Hover selects, but only when the mouse actually moves (the list scrolling under a still
    // cursor must not steal the selection).
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onPositionChanged: root.hovered()
        onClicked: root.activated()
    }

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 10
        anchors.rightMargin: 10
        spacing: 12

        IconImage {
            implicitSize: 40
            source: Quickshell.iconPath(root.modelData.icon, "application-x-executable")
            asynchronous: true
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0

            Text {
                Layout.fillWidth: true
                text: root.modelData.name
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: 15
                font.bold: true
                color: root.selected ? Theme.bg : Theme.fg
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.modelData.genericName || root.modelData.comment || ""
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: 12
                color: root.selected ? Qt.alpha(Theme.bg, 0.75) : Qt.alpha(Theme.fg, 0.7)
            }
        }

        // Pin toggle: shown on the selected row, and on any pinned row.
        Item {
            visible: root.selected || root.pinned
            implicitWidth: 28
            implicitHeight: 28

            Icon {
                anchors.centerIn: parent
                glyph: root.pinned ? Glyphs.pinFilled : Glyphs.pin
                size: 15
                color: root.selected ? Theme.bg : Theme.accent
                opacity: pinMouse.containsMouse || root.pinned ? 1 : 0.6
            }

            MouseArea {
                id: pinMouse
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: AppUsage.togglePin(root.modelData.id)
            }
        }
    }
}
