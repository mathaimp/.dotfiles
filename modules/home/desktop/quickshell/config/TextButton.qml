import QtQuick

// Text button: "default" (surface) or "accent".
Rectangle {
    id: root

    required property string text
    property string variant: "default"
    signal clicked

    implicitWidth: label.implicitWidth + 28
    implicitHeight: 32
    radius: 6
    color: variant === "accent" ? (mouse.containsMouse ? Qt.lighter(Theme.accent, 1.15) : Theme.accent)
        : mouse.containsMouse ? Theme.muted : Theme.surface

    Behavior on color {
        EffectsColorAnimation {}
    }

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.family: Theme.font
        font.pixelSize: 14
        color: root.variant === "accent" ? Theme.bg : Theme.fg
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
