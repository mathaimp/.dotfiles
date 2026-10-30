import QtQuick

// Square glyph button with Noctalia v5's button variants:
// "default" (surface), "tab" (clear, hover fill), "tabActive" (accent), "destructive" (red).
Rectangle {
    id: root

    required property int glyph
    property string variant: "default"
    property int glyphSize: Theme.iconSize
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
        anchors.centerIn: parent
        glyph: root.glyph
        size: root.glyphSize
        color: root.variant === "tabActive" || root.variant === "destructive" ? Theme.bg : Theme.fg
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
