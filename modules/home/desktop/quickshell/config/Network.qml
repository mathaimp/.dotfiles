import QtQuick
import Quickshell.Io
import Quickshell.Networking

// Network status icon with Noctalia v5's glyph logic (wifi icon by signal band, wifi-off,
// wifi-exclamation when disconnected, ethernet when wired). Tooltip rows follow v5's network widget.
Item {
    id: root

    // Set while the tooltip is open: IP, band and throughput are only sampled then.
    property bool detailed: false

    readonly property var wifiDevice: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var wiredDevice: Networking.devices.values.find(d => d.type === DeviceType.Wired && d.connected) ?? null
    readonly property var wifiNetwork: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property var activeDevice: wiredDevice ?? (wifiNetwork ? wifiDevice : null)
    readonly property real signal: wifiNetwork?.signalStrength ?? 0 // 0..1
    // v5's glyphForState / wifiGlyphForSignal.
    readonly property int glyph: wiredDevice ? Glyphs.ethernet
        : !Networking.wifiEnabled ? Glyphs.wifiOff
        : !wifiNetwork ? Glyphs.wifiExclamation
        : signal >= 0.8 ? Glyphs.wifi
        : signal >= 0.6 ? Glyphs.wifi3
        : signal >= 0.35 ? Glyphs.wifi2
        : signal >= 0.15 ? Glyphs.wifi1
        : Glyphs.wifi0

    property string ipv4: ""
    property string band: ""
    property real rxRate: -1 // bytes/s, -1 until two samples exist
    property real txRate: -1
    property var lastBytes: null

    readonly property var tooltipRows: {
        if (wiredDevice) {
            return [["Network", "Wired"], ["Interface", wiredDevice.name]].concat(detailRows());
        }
        if (!Networking.wifiEnabled)
            return [["Wi-Fi", "Off"]];
        if (!wifiNetwork)
            return [["Network", "Disconnected"]];
        const rows = [["Network", wifiNetwork.name], ["Signal", Math.round(signal * 100) + "%"]];
        if (band)
            rows.push(["Band", band]);
        rows.push(["Interface", wifiDevice.name]);
        return rows.concat(detailRows());
    }

    function detailRows() {
        const rows = [];
        if (ipv4)
            rows.push(["IP", ipv4]);
        if (rxRate >= 0) {
            rows.push(["Download", formatRate(rxRate)]);
            rows.push(["Upload", formatRate(txRate)]);
        }
        return rows;
    }

    // Decimal units, as in v5 ("1.2 MB/s").
    function formatRate(bytes) {
        const units = ["B/s", "KB/s", "MB/s", "GB/s"];
        let i = 0;
        while (bytes >= 1000 && i < units.length - 1) {
            bytes /= 1000;
            i++;
        }
        return (i === 0 ? Math.round(bytes) : bytes.toFixed(1)) + " " + units[i];
    }

    onDetailedChanged: {
        if (!detailed) {
            lastBytes = null;
            rxRate = txRate = -1;
            return;
        }
        if (!activeDevice)
            return;
        ipProc.command = ["ip", "-4", "-o", "addr", "show", "dev", activeDevice.name];
        ipProc.running = true;
        if (!wiredDevice)
            bandProc.running = true;
    }

    implicitWidth: icon.width
    implicitHeight: icon.height

    Icon {
        id: icon
        glyph: root.glyph
    }

    Process {
        id: ipProc
        stdout: StdioCollector {
            onStreamFinished: root.ipv4 = (text.match(/inet (\S+)\//) ?? [])[1] ?? ""
        }
    }

    // Quickshell's Networking API has no frequency, so read it from NetworkManager.
    Process {
        id: bandProc
        command: ["nmcli", "-t", "-f", "IN-USE,FREQ", "device", "wifi", "list", "--rescan", "no"]
        stdout: StdioCollector {
            onStreamFinished: {
                const mhz = Number((text.match(/^\*:(\d+)/m) ?? [])[1] ?? 0);
                root.band = mhz >= 5925 ? "6 GHz" : mhz >= 4900 ? "5 GHz" : mhz >= 2400 ? "2.4 GHz" : "";
            }
        }
    }

    // Throughput from /proc/net/dev byte counters, sampled every second while the tooltip is open.
    Timer {
        interval: 1000
        repeat: true
        triggeredOnStart: true
        running: root.detailed && !!root.activeDevice
        onTriggered: netDev.reload()
    }

    FileView {
        id: netDev
        path: "/proc/net/dev"
        onLoaded: {
            if (!root.detailed || !root.activeDevice)
                return;
            const line = text().split("\n").find(l => l.trim().startsWith(root.activeDevice.name + ":"));
            if (!line)
                return;
            const f = line.split(":")[1].trim().split(/\s+/).map(Number);
            const now = { rx: f[0], tx: f[8], t: Date.now() };
            if (root.lastBytes) {
                const dt = (now.t - root.lastBytes.t) / 1000;
                root.rxRate = (now.rx - root.lastBytes.rx) / dt;
                root.txRate = (now.tx - root.lastBytes.tx) / dt;
            }
            root.lastBytes = now;
        }
    }
}
