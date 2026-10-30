pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Bluetooth

// BlueZ pairing agent. `qs-bt-agent` (bt-agent.py) registers as the default agent and forwards
// requests as JSON lines; PairingDialog shows `request` and answers through respond().
Singleton {
    id: root

    // Current request: { id?, type, device, passkey?, pin?, uuid?, entered? }, or null.
    // Display-only requests (displayPin / displayPasskey) have no id.
    property var request: null
    property string screenName: "" // screen the dialog shows on (the focused one)
    property bool ready: false

    readonly property var device: request ? Bluetooth.devices.values.find(d => d.dbusPath === request.device) ?? null : null
    readonly property string deviceName: {
        const isAddress = s => /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(s ?? "");
        return [device?.name, device?.deviceName].find(n => n && !isAddress(n)) ?? device?.address ?? "device";
    }

    function respond(accept, value) {
        if (request?.id !== undefined)
            agent.write(JSON.stringify({
                id: request.id,
                accept,
                value: value ?? ""
            }) + "\n");
        request = null;
    }

    function handle(msg) {
        if (msg.type === "ready") {
            ready = true;
            restart.interval = 3000;
        } else if (msg.type === "cancel") {
            request = null;
        } else if (msg.type === "service" && Bluetooth.devices.values.find(d => d.dbusPath === msg.device)?.trusted) {
            // Known (trusted) devices reconnecting don't need a prompt.
            agent.write(JSON.stringify({
                id: msg.id,
                accept: true
            }) + "\n");
        } else {
            screenName = Panels.focusedScreen()?.name ?? "";
            request = msg;
            expiry.restart();
        }
    }

    // BlueZ gives up on a request after a while; don't leave a stale dialog behind.
    Timer {
        id: expiry
        interval: 60000
        onTriggered: root.request = null
    }

    // Pairing finished while a display-only code was showing.
    Connections {
        target: root.device

        function onPairedChanged() {
            if (root.device.paired && root.request?.id === undefined)
                root.request = null;
        }
    }

    Process {
        id: agent
        command: ["qs-bt-agent"]
        running: true
        stdinEnabled: true
        stdout: SplitParser {
            onRead: line => {
                try {
                    root.handle(JSON.parse(line));
                } catch (e) {
                    console.warn("qs-bt-agent: bad line:", line);
                }
            }
        }
        // bluetoothd restarted or the agent crashed: register again shortly.
        onExited: {
            root.ready = false;
            root.request = null;
            restart.start();
        }
    }

    // Back off (3s up to 1min) so a missing binary or a bluetoothd that stays down doesn't spin.
    Timer {
        id: restart
        interval: 3000
        onTriggered: {
            interval = Math.min(interval * 2, 60000);
            agent.running = true;
        }
    }
}
