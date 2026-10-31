import QtQuick

// Bar widget wrapper: shared height, hover highlight, and a tooltip on hover.
Item {
    id: root

    default property alias content: holder.data
    property var tooltipRows: []
    // Stat widgets set this so SystemStats samples the extra tooltip metrics while open.
    property bool wantsStatDetails: false
    property alias spacing: holder.spacing
    signal clicked
    readonly property bool hovered: mouse.containsMouse
    readonly property bool tooltipOpen: tip.visible

    onTooltipOpenChanged: if (wantsStatDetails) SystemStats.detailUsers += tooltipOpen ? 1 : -1

    // Total horizontal padding. Noctalia v5 uses widgetSpacing = 6 between widgets and none inside,
    // so this is the whole gap: the bar rows use spacing 0.
    property int padding: 6

    implicitWidth: holder.implicitWidth + padding
    implicitHeight: 27

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.hovered ? Theme.surface : "transparent"

        Behavior on color {
            EffectsColorAnimation {}
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
        onClicked: root.clicked()
    }

    Tooltip {
        id: tip
        target: root
        hovered: root.hovered
        rows: root.tooltipRows
    }
}
