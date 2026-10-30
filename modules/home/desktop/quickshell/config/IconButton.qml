import QtQuick

// Square glyph button with Noctalia v5's button variants:
// "default" (surface), "tab" (clear, hover fill), "tabActive" (accent), "destructive" (red).
Rectangle {
    id: root

    required property int glyph
    property string variant: "default"
    property int glyphSize: Theme.iconSize
    // Spins the glyph, for refresh buttons while a scan runs.
    property bool spinning: false
    signal clicked

    readonly property bool hovered: mouse.containsMouse
    readonly property color fill: variant === "tabActive" ? Theme.accent
        : variant === "destructive" ? Theme.critical
        : hovered ? Theme.muted
        : variant === "tab" ? "transparent"
        : Theme.surface

    implicitWidth: 32
    implicitHeight: 32
    radius: 6
    color: fill

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Icon {
        id: icon
        anchors.centerIn: parent
        glyph: root.glyph
        size: root.glyphSize
        color: root.variant === "tabActive" || root.variant === "destructive" ? Theme.bg : Theme.fg

        RotationAnimator on rotation {
            running: root.spinning
            from: 0
            to: 360
            duration: 900
            loops: Animation.Infinite
            onRunningChanged: if (!running)
                icon.rotation = 0
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
