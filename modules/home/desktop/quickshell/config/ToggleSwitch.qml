import QtQuick

// On/off switch. Bind `checked` to the real state and handle `toggled` to change it.
Rectangle {
    id: root

    property bool checked: false
    signal toggled(bool checked)

    implicitWidth: 40
    implicitHeight: 22
    radius: height / 2
    color: checked ? Theme.accent : Theme.surface

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    Rectangle {
        width: 16
        height: 16
        radius: 8
        y: 3
        x: root.checked ? root.width - width - 3 : 3
        color: root.checked ? Theme.bg : Theme.fg

        Behavior on x {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutCubic
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.toggled(!root.checked)
    }
}
