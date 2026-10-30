import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Noctalia v5's audio tab: output and input device cards side by side, then application volumes.
ColumnLayout {
    id: root

    // Hardware devices vs application playback streams (media.class Audio/Sink, Audio/Source,
    // Stream/Output/Audio).
    readonly property var nodes: Pipewire.nodes.values.filter(n => n.audio)
    readonly property var outputs: nodes.filter(n => !n.isStream && n.isSink)
    readonly property var inputs: nodes.filter(n => !n.isStream && !n.isSink)
    readonly property var streams: nodes.filter(n => n.isStream && n.isSink)

    spacing: 12

    // Audio properties are only live for tracked nodes; tracking ends when the panel closes.
    PwObjectTracker {
        objects: root.nodes
    }

    RowLayout {
        z: 1 // device menus overlay the application list
        spacing: 12

        DeviceCard {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            title: "Output"
            node: Pipewire.defaultAudioSink
            devices: root.outputs
            icon: 0xEB51 // volume
            muteIcon: 0xF1C3 // volume-off
            onPicked: n => Pipewire.preferredDefaultAudioSink = n
        }
        DeviceCard {
            Layout.fillWidth: true
            Layout.preferredWidth: 1
            title: "Input"
            node: Pipewire.defaultAudioSource
            devices: root.inputs
            icon: 0xEAF0 // microphone
            muteIcon: 0xED16 // microphone-off
            onPicked: n => Pipewire.preferredDefaultAudioSource = n
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 12
        color: Theme.container
        border.width: 1
        border.color: Theme.surface

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Text {
                text: "Application volumes"
                font.family: Theme.font
                font.pixelSize: 16
                font.bold: true
                color: Theme.fg
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 8
                model: root.streams
                boundsBehavior: Flickable.StopAtBounds

                delegate: AppVolumeRow {
                    required property var modelData
                    width: ListView.view.width
                    node: modelData
                }
            }

            Text {
                visible: root.streams.length === 0
                Layout.fillWidth: true
                Layout.fillHeight: true
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: "No applications are playing audio"
                font.family: Theme.font
                font.pixelSize: 13
                color: Qt.alpha(Theme.fg, 0.7)
            }
        }
    }
}
