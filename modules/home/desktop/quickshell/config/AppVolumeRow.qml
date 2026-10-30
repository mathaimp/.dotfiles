import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

// One application stream in Noctalia v5's "Application volumes" list:
// app icon, app name and what it's playing, slider, percentage, mute.
Rectangle {
    id: root

    required property var node // PwNode (Stream/Output/Audio)
    readonly property var props: node?.properties ?? ({})
    readonly property string appName: props["application.name"] || node?.name || "Unknown"
    readonly property bool muted: node?.audio?.muted ?? false

    implicitHeight: Math.max(52, content.implicitHeight + 16)
    radius: 6
    color: Qt.alpha(Theme.surface, 0.5)

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        anchors.topMargin: 8
        anchors.bottomMargin: 8
        spacing: 12

        // App icon from its icon name, falling back to the process binary, then a music note.
        IconImage {
            implicitSize: 28
            source: Quickshell.iconPath(root.props["application.icon-name"] || root.props["application.process.binary"] || "", "audio-x-generic")
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 4

            RowLayout {
                spacing: 8

                Text {
                    Layout.fillWidth: true
                    text: root.appName
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 14
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    text: Math.round((root.node?.audio?.volume ?? 0) * 100) + "%"
                    font.family: Theme.font
                    font.pixelSize: 14
                    color: root.muted ? Theme.critical : Theme.fg
                }
            }
            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.props["media.name"] ?? ""
                elide: Text.ElideRight
                font.family: Theme.font
                font.pixelSize: 13
                color: Qt.alpha(Theme.fg, 0.7)
            }
            Slider {
                Layout.fillWidth: true
                value: root.node?.audio?.volume ?? 0
                onMoved: v => root.node.audio.volume = v
            }
        }

        IconButton {
            glyph: root.muted ? Glyphs.volumeOff : Glyphs.volume
            glyphSize: 14
            variant: root.muted ? "destructive" : "default"
            onClicked: root.node.audio.muted = !root.muted
        }
    }
}
