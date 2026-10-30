import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Quick controls: output volume, microphone, brightness.
ColumnLayout {
    id: root

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    spacing: 8

    Component.onCompleted: Brightness.refresh()

    // Audio properties are only live for tracked nodes; tracking ends when the panel closes.
    PwObjectTracker {
        objects: [root.sink, root.source]
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
