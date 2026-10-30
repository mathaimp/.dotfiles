import QtQuick
import QtQuick.Layouts

// Quick-toggle tile for the control center's Home tab: icon over a label, accent-filled when on.
Rectangle {
    id: root

    required property int glyph
    required property string text
    property bool checked: false
    signal clicked

    implicitHeight: 64
    radius: 12
    color: checked ? Theme.accent : mouse.containsMouse ? Theme.surface : Theme.container
    border.width: 1
    border.color: checked ? Theme.accent : Theme.surface

    Behavior on color {
        ColorAnimation {
            duration: 150
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        spacing: 4

        Icon {
            Layout.alignment: Qt.AlignHCenter
            glyph: root.glyph
            size: 20
            color: root.checked ? Theme.bg : Theme.fg
        }
        Text {
            Layout.alignment: Qt.AlignHCenter
            text: root.text
            font.family: Theme.font
            font.pixelSize: 12
            color: root.checked ? Theme.bg : Theme.fg
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
