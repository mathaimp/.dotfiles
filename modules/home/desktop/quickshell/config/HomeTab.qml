import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Services.Mpris
import Quickshell.Services.Pipewire

// Home, after Noctalia v5's control center: profile and uptime, now playing with transport controls,
// CPU / temperature / RAM meters, then output volume, microphone and brightness.
ColumnLayout {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    // The playing player, else the first one.
    readonly property var player: Mpris.players.values.find(p => p.isPlaying) ?? Mpris.players.values[0] ?? null

    property string uptime: ""

    function formatUptime(seconds) {
        const d = Math.floor(seconds / 86400);
        const h = Math.floor(seconds % 86400 / 3600);
        const m = Math.floor(seconds % 3600 / 60);
        return d > 0 ? d + "d " + h + "h " + m + "m" : h > 0 ? h + "h " + m + "m" : m + "m";
    }

    function formatTime(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        return Math.floor(s / 60) + ":" + String(s % 60).padStart(2, "0");
    }

    spacing: 8

    Component.onCompleted: {
        Brightness.refresh();
        uptimeFile.reload();
    }

    // Audio properties are only live for tracked nodes; tracking ends when the panel closes.
    PwObjectTracker {
        objects: [root.sink, root.source]
    }

    FileView {
        id: uptimeFile
        path: "/proc/uptime"
        onLoaded: root.uptime = root.formatUptime(Number(text().split(" ")[0]))
    }

    Timer {
        interval: 30000
        repeat: true
        running: true
        onTriggered: uptimeFile.reload()
    }

    // Profile and uptime.
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: profile.implicitHeight + 24
        radius: 12
        color: Theme.container
        border.width: 1
        border.color: Theme.surface

        RowLayout {
            id: profile
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            Rectangle {
                implicitWidth: 40
                implicitHeight: 40
                radius: 20
                color: Theme.surface

                Icon {
                    anchors.centerIn: parent
                    glyph: Glyphs.user
                    size: 20
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: Quickshell.env("USER") || "User"
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    text: "Up " + root.uptime
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }
        }
    }

    // Now playing.
    Rectangle {
        Layout.fillWidth: true
        implicitHeight: media.implicitHeight + 24
        radius: 12
        color: Theme.container
        border.width: 1
        border.color: Theme.surface

        // Position isn't pushed by MPRIS; poll it while a track is playing.
        Timer {
            interval: 1000
            repeat: true
            running: !!root.player?.isPlaying && !!root.player?.positionSupported
            onTriggered: root.player.positionChanged()
        }

        ColumnLayout {
            id: media
            anchors.fill: parent
            anchors.margins: 12
            spacing: 10

            RowLayout {
                spacing: 12

                Rectangle {
                    implicitWidth: 64
                    implicitHeight: 64
                    radius: 8
                    color: Theme.surface
                    clip: true

                    Icon {
                        anchors.centerIn: parent
                        glyph: Glyphs.music
                        size: 24
                        color: Qt.alpha(Theme.fg, 0.5)
                    }
                    Image {
                        anchors.fill: parent
                        source: root.player?.trackArtUrl ?? ""
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        visible: status === Image.Ready
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 0

                    Text {
                        Layout.fillWidth: true
                        text: root.player ? (root.player.trackTitle || "Unknown track") : "Nothing playing"
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: 15
                        font.bold: true
                        color: Theme.fg
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: !!root.player
                        text: root.player?.trackArtist ?? ""
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: 13
                        color: Qt.alpha(Theme.fg, 0.7)
                    }
                    Text {
                        Layout.fillWidth: true
                        visible: !!root.player
                        text: root.player?.identity ?? ""
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: 12
                        color: Qt.alpha(Theme.fg, 0.5)
                    }
                }
            }

            // Progress bar with times, when the player reports a length.
            RowLayout {
                Layout.fillWidth: true
                visible: !!root.player && root.player.lengthSupported && root.player.length > 0
                spacing: 8

                Text {
                    text: root.formatTime(root.player?.position ?? 0)
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Qt.alpha(Theme.fg, 0.7)
                }
                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: 4
                    radius: 2
                    color: Theme.surface

                    Rectangle {
                        width: parent.width * Math.min(1, (root.player?.position ?? 0) / Math.max(1, root.player?.length ?? 1))
                        height: parent.height
                        radius: 2
                        color: Theme.accent
                    }
                }
                Text {
                    text: root.formatTime(root.player?.length ?? 0)
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8
                opacity: root.player ? 1 : 0.4

                IconButton {
                    glyph: Glyphs.skipBack
                    variant: "tab"
                    enabled: !!root.player?.canGoPrevious
                    onClicked: root.player.previous()
                }
                IconButton {
                    glyph: root.player?.isPlaying ? Glyphs.pause : Glyphs.play
                    variant: "tabActive"
                    implicitWidth: 40
                    implicitHeight: 40
                    radius: 20
                    enabled: !!root.player?.canTogglePlaying
                    onClicked: root.player.togglePlaying()
                }
                IconButton {
                    glyph: Glyphs.skipForward
                    variant: "tab"
                    enabled: !!root.player?.canGoNext
                    onClicked: root.player.next()
                }
            }
        }
    }

    // System meters.
    RowLayout {
        Layout.fillWidth: true
        spacing: 8

        Repeater {
            model: [
                { glyph: Glyphs.cpu, label: "CPU", value: SystemStats.cpu / 100, text: Math.round(SystemStats.cpu) + "%" },
                { glyph: Glyphs.thermometer, label: "Temp", value: (SystemStats.temp - SystemStats.tempMin) / (SystemStats.tempMax - SystemStats.tempMin), text: Math.round(SystemStats.temp) + "°C" },
                { glyph: Glyphs.memory, label: "RAM", value: SystemStats.ramPct / 100, text: Math.round(SystemStats.ramPct) + "%" }
            ]

            Rectangle {
                id: stat

                required property var modelData

                Layout.fillWidth: true
                Layout.preferredWidth: 1
                implicitHeight: statCol.implicitHeight + 24
                radius: 12
                color: Theme.container
                border.width: 1
                border.color: Theme.surface

                ColumnLayout {
                    id: statCol
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 6

                    RowLayout {
                        spacing: 6
                        Icon {
                            glyph: stat.modelData.glyph
                            color: Theme.accent
                        }
                        Text {
                            Layout.fillWidth: true
                            text: stat.modelData.label
                            font.family: Theme.font
                            font.pixelSize: 12
                            color: Qt.alpha(Theme.fg, 0.7)
                        }
                    }
                    Text {
                        text: stat.modelData.text
                        font.family: Theme.font
                        font.pixelSize: 18
                        font.bold: true
                        color: Theme.fg
                    }
                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 4
                        radius: 2
                        color: Theme.surface

                        Rectangle {
                            width: parent.width * Math.max(0, Math.min(1, stat.modelData.value))
                            height: parent.height
                            radius: 2
                            color: Theme.accent
                        }
                    }
                }
            }
        }
    }

    SliderCard {
        Layout.fillWidth: true
        visible: !!root.sink
        icon: Glyphs.volume
        muteIcon: Glyphs.volumeOff
        title: "Output"
        subtitle: root.sink?.description ?? ""
        value: root.sink?.audio?.volume ?? 0
        showMute: true
        muted: root.sink?.audio?.muted ?? false
        onMoved: v => root.sink.audio.volume = v
        onMuteToggled: root.sink.audio.muted = !root.sink.audio.muted
    }

    SliderCard {
        Layout.fillWidth: true
        visible: !!root.source
        icon: Glyphs.microphone
        muteIcon: Glyphs.microphoneOff
        title: "Microphone"
        subtitle: root.source?.description ?? ""
        value: root.source?.audio?.volume ?? 0
        showMute: true
        muted: root.source?.audio?.muted ?? false
        onMoved: v => root.source.audio.volume = v
        onMuteToggled: root.source.audio.muted = !root.source.audio.muted
    }

    SliderCard {
        Layout.fillWidth: true
        visible: Brightness.any
        icon: Glyphs.brightness
        title: "Brightness"
        subtitle: "All displays"
        value: Brightness.value
        onMoved: v => Brightness.set(v)
    }

    Item {
        Layout.fillHeight: true
    }
}
