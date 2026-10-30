import QtQuick
import QtQuick.Layouts

// A control card in Noctalia v5's control-center style: icon tile, title and subtitle,
// value on the right, a slider underneath, and an optional mute button (red when muted).
Rectangle {
    id: root

    required property int icon
    required property string title
    property string subtitle: ""
    property real value: 0 // 0..1
    property bool showMute: false
    property bool muted: false
    property int muteIcon: icon
    signal moved(real value)
    signal muteToggled

    implicitHeight: content.implicitHeight + 24
    radius: 12
    color: Theme.container
    border.width: 1
    border.color: Theme.surface

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            spacing: 8

            // Icon tile
            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                radius: 6
                color: Theme.surface

                Icon {
                    anchors.centerIn: parent
                    glyph: root.icon
                    color: root.muted ? Theme.critical : Theme.fg
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: root.title
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    Layout.fillWidth: true
                    visible: root.subtitle !== ""
                    text: root.subtitle
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }

            Text {
                text: root.muted ? "Muted" : Math.round(root.value * 100) + "%"
                font.family: Theme.font
                font.pixelSize: 14
                color: root.muted ? Theme.critical : Theme.fg
            }

            IconButton {
                visible: root.showMute
                glyph: root.muted ? root.muteIcon : root.icon
                variant: root.muted ? "destructive" : "default"
                onClicked: root.muteToggled()
            }
        }

        Slider {
            Layout.fillWidth: true
            value: root.value
            onMoved: v => root.moved(v)
        }
    }
}
