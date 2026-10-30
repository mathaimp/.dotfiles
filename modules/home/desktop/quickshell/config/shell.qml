import QtQuick
import Quickshell
import Quickshell.Io

ShellRoot {
    Variants {
        model: Quickshell.screens
        delegate: Bar {}
    }

    Variants {
        model: Quickshell.screens
        delegate: ControlCenter {}
    }

    // Keybind targets: `qs -c default ipc call quicksettings toggle`,
    // `qs -c default ipc call quicksettings openTab audio` (opens on that tab).
    IpcHandler {
        target: "quicksettings"

        function toggle(): void {
            Panels.toggleQuickSettingsOnFocused();
        }

        function openTab(tab: string): void {
            Panels.tab = tab;
            if (!Panels.quickSettingsScreen)
                Panels.toggleQuickSettingsOnFocused();
        }
    }
}
