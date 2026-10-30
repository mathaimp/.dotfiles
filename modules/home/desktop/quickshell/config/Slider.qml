import QtQuick

// Horizontal slider in Noctalia v5's style: 8px track, accent fill, 18px round thumb.
Item {
    id: root

    property real value: 0 // 0..1
    signal moved(real value)

    readonly property int trackHeight: 8
    readonly property int thumbSize: 18
    readonly property int sidePadding: 2
    readonly property real trackWidth: width - sidePadding * 2
    readonly property bool active: mouse.pressed || mouse.containsMouse

    implicitHeight: thumbSize

    Rectangle {
        id: track
        x: root.sidePadding
        anchors.verticalCenter: parent.verticalCenter
        width: root.trackWidth
        height: root.trackHeight
        radius: height / 2
        color: Theme.muted
    }

    Rectangle {
        x: root.sidePadding
        anchors.verticalCenter: parent.verticalCenter
        width: root.trackWidth * Math.max(0, Math.min(1, root.value))
        height: root.trackHeight
        radius: height / 2
        color: Theme.accent
    }

    Rectangle {
        x: Math.max(root.sidePadding, Math.min(root.sidePadding + root.trackWidth * root.value - width / 2,
            root.sidePadding + root.trackWidth - width))
        anchors.verticalCenter: parent.verticalCenter
        width: root.thumbSize
        height: root.thumbSize
        radius: width / 2
        color: Theme.bg
        border.width: 1
        border.color: root.active ? Theme.accent : Theme.muted
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        preventStealing: true

        function update(x) {
            root.moved(Math.max(0, Math.min(1, (x - root.sidePadding) / root.trackWidth)));
        }

        onPressed: mouse => update(mouse.x)
        onPositionChanged: mouse => {
            if (pressed)
                update(mouse.x);
        }
        // Scroll nudges by 5%, like the volume keys.
        onWheel: wheel => root.moved(Math.max(0, Math.min(1, root.value + (wheel.angleDelta.y > 0 ? 0.05 : -0.05))))
    }
}
