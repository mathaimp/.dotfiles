import QtQuick

// Bar widget wrapper: shared height, hover highlight, and a tooltip on hover.
Item {
    id: root

    default property alias content: holder.data
    property var tooltipRows: []
    // Stat widgets set this so SystemStats samples the extra tooltip metrics while open.
    property bool wantsStatDetails: false
    property alias spacing: holder.spacing
    readonly property bool hovered: mouse.containsMouse
    readonly property bool tooltipOpen: tip.visible

    onTooltipOpenChanged: if (wantsStatDetails) SystemStats.detailUsers += tooltipOpen ? 1 : -1

    implicitWidth: holder.implicitWidth + 8
    implicitHeight: 27

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.hovered ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    Row {
        id: holder
        anchors.centerIn: parent
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
    }

    Tooltip {
        id: tip
        target: root
        hovered: root.hovered
        rows: root.tooltipRows
    }
}
