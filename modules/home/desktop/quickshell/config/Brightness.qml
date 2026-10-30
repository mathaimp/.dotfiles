pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Screen brightness: the built-in panel via brightnessctl, external monitors via ddcutil (DDC/CI, VCP 0x10).
// Read on demand (when the quick settings panel opens), written with a short debounce while dragging.
Singleton {
    id: root

    // Built-in backlight.
    property real value: 0 // 0..1
    property bool available: false
    property real pending: -1

    // External monitors: Display objects, created by detect().
    property list<QtObject> externals: []
    property bool detected: false

    component Display: QtObject {
        property string name
        property string bus // i2c bus number, passed to ddcutil --bus
        property real value: 0 // 0..1
        property real max: 100
        property real pending: -1
        property bool ready: false
    }

    Component {
        id: displayFactory
        Display {}
    }

    function refresh() {
        reader.running = true;
        if (!detected)
            detect.running = true;
        else
            for (const d of externals)
                queue(d, "read");
    }

    // True when there is anything to control.
    readonly property bool any: available || externals.some(d => d.ready)

    // One brightness for every display: the slider drives the built-in panel and all external monitors.
    function set(v) {
        value = Math.max(0, Math.min(1, v));
        pending = value;
        if (available && !writeDelay.running)
            writeDelay.start();
        for (const d of externals) {
            d.value = value;
            d.pending = value;
        }
        if (!extDelay.running)
            extDelay.start();
    }

    // ddcutil is slow (hundreds of ms per call), so jobs run one at a time.
    property var jobs: []

    function queue(d, op) {
        if (jobs.some(j => j.d === d && j.op === op))
            return;
        jobs.push({
            d,
            op
        });
        next();
    }

    function next() {
        if (ddc.running || jobs.length === 0)
            return;
        const j = jobs.shift();
        ddc.job = j;
        if (j.op === "read") {
            ddc.command = ["ddcutil", "--bus", j.d.bus, "--brief", "getvcp", "10"];
        } else {
            const raw = Math.round(j.d.pending * j.d.max);
            j.d.pending = -1;
            ddc.command = ["ddcutil", "--bus", j.d.bus, "--noverify", "setvcp", "10", String(raw)];
        }
        ddc.running = true;
    }

    Process {
        id: reader
        // device,class,current,percent,max
        command: ["brightnessctl", "-m", "-c", "backlight"]
        stdout: StdioCollector {
            onStreamFinished: {
                const f = text.trim().split("\n")[0]?.split(",") ?? [];
                root.available = f.length >= 5;
                if (root.available)
                    root.value = Number(f[2]) / Number(f[4]);
            }
        }
    }

    Timer {
        id: writeDelay
        interval: 50
        onTriggered: {
            writer.command = ["brightnessctl", "-q", "-c", "backlight", "set", Math.round(root.pending * 100) + "%"];
            writer.running = true;
        }
    }

    Process {
        id: writer
    }

    // `ddcutil detect --brief` prints blocks like:
    //   Display 1
    //      I2C bus:  /dev/i2c-5
    //      Monitor:  SAM:S24C31x:H9DWA00317
    // Invalid displays (the laptop panel) are labelled "Invalid display" and skipped.
    Process {
        id: detect
        command: ["ddcutil", "detect", "--brief"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.detected = true;
                for (const block of text.split(/\n\s*\n/)) {
                    const bus = block.match(/^Display \d+[\s\S]*?I2C bus:\s+\/dev\/i2c-(\d+)/)?.[1];
                    if (!bus)
                        continue;
                    const model = block.match(/Monitor:\s+[^:\n]*:([^:\n]*)/)?.[1]?.trim();
                    const d = displayFactory.createObject(root, {
                        bus,
                        name: model || "External display"
                    });
                    root.externals = root.externals.concat([d]);
                    root.queue(d, "read");
                }
            }
        }
    }

    Timer {
        id: extDelay
        interval: 150
        onTriggered: {
            for (const d of root.externals)
                if (d.ready && d.pending >= 0)
                    root.queue(d, "write");
        }
    }

    // Runs one ddcutil job at a time.
    Process {
        id: ddc
        property var job
        stdout: StdioCollector {
            onStreamFinished: {
                // "VCP 10 C 45 100" -> current 45, max 100
                const f = text.trim().split(/\s+/);
                const d = ddc.job?.d;
                if (ddc.job?.op === "read" && d && f[0] === "VCP" && f.length >= 5) {
                    d.max = Number(f[4]) || 100;
                    d.value = Number(f[3]) / d.max;
                    d.ready = true;
                    if (!root.available)
                        root.value = d.value;
                }
            }
        }
        onRunningChanged: if (!running)
            root.next()
    }
}
