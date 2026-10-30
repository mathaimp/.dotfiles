import QtQuick

// Keep-awake button in Noctalia v4 BarPill style: an icon that slides out a countdown
// when a timeout is set. Click toggles, scroll adds/removes time.
Item {
    id: root

    readonly property int pillHeight: 27
    readonly property bool revealed: Caffeine.timeout !== null
    readonly property bool hovered: mouse.containsMouse
    readonly property color fgColor: hovered ? Theme.bg : Theme.fg

    implicitWidth: pillHeight + (revealed ? label.implicitWidth + 12 : 0)
    implicitHeight: pillHeight

    Behavior on implicitWidth {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Rectangle {
        anchors.fill: parent
        radius: height / 2
        color: root.hovered ? Theme.accent : root.revealed ? Theme.surface : "transparent"

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // Countdown, to the left of the icon (the widget sits on the right edge).
    Text {
        id: label
        anchors.left: parent.left
        anchors.leftMargin: 10
        anchors.verticalCenter: parent.verticalCenter
        opacity: root.revealed ? 1 : 0
        visible: opacity > 0
        text: Caffeine.timeout !== null ? Caffeine.formatTimeout(Caffeine.timeout) : ""
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        color: root.fgColor

        Behavior on opacity {
            NumberAnimation {
                duration: 150
            }
        }
    }

    Icon {
        anchors.right: parent.right
        width: root.pillHeight
        height: root.pillHeight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        glyph: Glyphs.mug
        color: root.fgColor
        opacity: Caffeine.enabled ? 1 : 0.5 // no "coffee-off" icon, so the off state is dimmed
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: Caffeine.toggle()
        // Same step sizes as v4: 1m up to 10m, 5m up to 30m, 10m up to 1h, then 30m.
        onWheel: wheel => {
            const sign = wheel.angleDelta.y > 0 ? 1 : -1;
            const t = (Caffeine.timeout ?? 0) - (sign < 0 ? 60 : 0);
            const step = t < 600 ? 60 : t < 1800 ? 300 : t < 3600 ? 600 : 1800;
            Caffeine.changeTimeout(step * sign);
        }
    }
}
