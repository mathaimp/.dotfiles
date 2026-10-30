pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Keep-awake state shared by every bar. Logic follows Noctalia v4's IdleInhibitorService
// (manual toggle + scroll-to-set timeout).
Singleton {
    id: root

    property bool enabled: false
    property var timeout: null // seconds remaining, or null for no timeout

    function toggle() {
        timeout = null;
        enabled = !enabled;
    }

    function changeTimeout(delta) {
        if (timeout === null && delta < 0)
            return;
        const next = (timeout ?? 0) + delta;
        if (next <= 0) {
            enabled = false;
            timeout = null;
        } else {
            enabled = true;
            timeout = next;
        }
    }

    // "1h 5m", "12m", "40s"
    function formatTimeout(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.floor((seconds % 3600) / 60);
        const parts = [];
        if (h)
            parts.push(`${h}h`);
        if (m)
            parts.push(`${m}m`);
        if (!h && !m)
            parts.push(`${seconds % 60}s`);
        return parts.join(" ");
    }

    // A systemd idle lock, which hypridle honours on any compositor. (In testing, Hyprland
    // didn't honour a Wayland IdleInhibitor on the bar's layer surface.) Same approach as Noctalia v5.
    Process {
        running: root.enabled
        command: ["systemd-inhibit", "--what=idle", "--who=quickshell", "--why=Keep awake", "--mode=block", "sleep", "infinity"]
    }

    Timer {
        interval: 1000
        repeat: true
        running: root.timeout !== null
        onTriggered: root.changeTimeout(-1)
    }
}
