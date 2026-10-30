pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Hyprland

// Which screen (if any) has the control center or the launcher open, and which tab the control
// center shows. Only one of the two is open at a time (both take exclusive keyboard focus).
Singleton {
    id: root

    property var quickSettingsScreen: null
    property var launcherScreen: null
    property string tab: "home" // remembered between opens

    function toggleQuickSettings(screen) {
        launcherScreen = null;
        quickSettingsScreen = quickSettingsScreen === screen ? null : screen;
    }

    // Open the control center on a given tab; closes it if that tab is already showing.
    function toggleTab(screen, tabId) {
        launcherScreen = null;
        if (quickSettingsScreen === screen && tab === tabId) {
            quickSettingsScreen = null;
        } else {
            tab = tabId;
            quickSettingsScreen = screen;
        }
    }

    // Open (or close) the launcher on the focused monitor.
    function toggleLauncher() {
        if (launcherScreen) {
            launcherScreen = null;
        } else {
            quickSettingsScreen = null;
            launcherScreen = focusedScreen();
        }
    }

    // The focused monitor (Hyprland), else the first screen.
    function focusedScreen() {
        const focused = Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== null ? Hyprland.focusedMonitor?.name : null;
        return Quickshell.screens.find(s => s.name === focused) ?? Quickshell.screens[0];
    }

    // For the keybind: open on the focused monitor.
    function toggleQuickSettingsOnFocused() {
        toggleQuickSettings(quickSettingsScreen ? quickSettingsScreen : focusedScreen());
    }
}
