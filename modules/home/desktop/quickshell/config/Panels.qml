pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Which screen (if any) has the control center open, and which tab it shows.
Singleton {
    id: root

    property var quickSettingsScreen: null
    property string tab: "home" // remembered between opens

    function toggleQuickSettings(screen) {
        quickSettingsScreen = quickSettingsScreen === screen ? null : screen;
    }

    // For the keybind: open on the focused monitor (Hyprland), else the first screen.
    function toggleQuickSettingsOnFocused() {
        const focused = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== null ? Hyprland.focusedMonitor?.name : null;
        const screen = Quickshell.screens.find(s => s.name === focused) ?? Quickshell.screens[0];
        toggleQuickSettings(quickSettingsScreen ? quickSettingsScreen : screen);
    }
}
