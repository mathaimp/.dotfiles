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

    Variants {
        model: Quickshell.screens
        delegate: Launcher {}
    }

    // Popup notifications (also instantiates the NotificationCenter daemon at startup).
    Variants {
        model: Quickshell.screens
        delegate: NotificationPopups {}
    }

    // Keybind targets: `qs -c default ipc call notifications toggleDnd` / `clear`.
    IpcHandler {
        target: "notifications"

        function toggleDnd(): void {
            NotificationCenter.dnd = !NotificationCenter.dnd;
        }

        function clear(): void {
            NotificationCenter.clear();
        }
    }

    // Keybind target: `qs -c default ipc call launcher toggle`.
    IpcHandler {
        target: "launcher"

        function toggle(): void {
            Panels.toggleLauncher();
        }
    }

    // Keybind target: `qs -c default ipc call brightness stepExternal 0.05` (negative to lower). Moves the
    // external monitors; the keybinds pair it with swayosd-client for the built-in panel and the OSD.
    IpcHandler {
        target: "brightness"

        function stepExternal(delta: real): void {
            Brightness.stepExternal(delta);
        }
    }

    // Bluetooth pairing prompts (also instantiates the BluetoothAgent singleton at startup).
    Variants {
        model: Quickshell.screens
        delegate: PairingDialog {}
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
