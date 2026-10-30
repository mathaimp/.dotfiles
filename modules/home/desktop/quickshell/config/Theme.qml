pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Colours and fonts come from Stylix via theme.json, written by Home Manager.
Singleton {
    readonly property color bg: json.bg
    readonly property color container: json.container // card background (v5 SurfaceContainer)
    readonly property color surface: json.surface
    readonly property color fg: json.fg
    readonly property color muted: json.muted
    readonly property color accent: json.accent
    readonly property color occupied: json.occupied
    readonly property color warning: json.warning
    readonly property color critical: json.critical
    readonly property string font: json.font
    readonly property int fontSize: 14
    readonly property string iconFont: iconLoader.name
    // All bar glyphs share one size, as in v5 (baseGlyphSize = 16).
    readonly property int iconSize: 16

    // The Lucide icon font; theme.json holds its path in the Nix store.
    FontLoader {
        id: iconLoader
        source: json.iconFont ? "file://" + json.iconFont : ""
    }

    FileView {
        path: (Quickshell.env("XDG_CONFIG_HOME") || Quickshell.env("HOME") + "/.config") + "/quickshell/theme.json"
        blockLoading: true
        watchChanges: true
        onFileChanged: reload()

        JsonAdapter {
            id: json
            property string bg
            property string container
            property string surface
            property string fg
            property string muted
            property string accent
            property string occupied
            property string warning
            property string critical
            property string font
            property string iconFont
        }
    }
}
