pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// CPU usage, CPU temperature and RAM, sampled every 2s from /proc and hwmon.
// Extra tooltip metrics (frequency, GPU, disk) are only read while a stat tooltip is open.
Singleton {
    id: root

    property real cpu: 0 // %
    property real temp: 0 // °C
    // Temperature meter range, as in v5: starts at 30-80°C and widens to fit what's been seen.
    property real tempMin: 30
    property real tempMax: 80
    property real ramUsedMib: 0
    property real ramTotalMib: 0
    property real ramPct: 0
    property real swapUsedMib: 0
    property real swapTotalMib: 0

    // Tooltip-only metrics; -1 means not available.
    property real cpuFreqGhz: -1
    property real gpuTemp: -1
    property real gpuBusy: -1
    property real diskUsed: -1 // bytes
    property real diskTotal: -1

    // Number of open stat tooltips; details are sampled while > 0.
    property int detailUsers: 0
    onDetailUsersChanged: if (detailUsers > 0) sampleDetails()

    property var paths: ({})
    property var lastCpuTimes: null

    function gib(mib) {
        return (mib / 1024).toFixed(1) + " GiB";
    }

    // v5 tooltip layout: the hovered stat first, then everything else that's available.
    function tooltipRows(first) {
        const rows = {
            cpu: ["CPU usage", Math.round(cpu) + "%"],
            temp: ["CPU temperature", Math.round(temp) + "°C"],
            freq: cpuFreqGhz >= 0 ? ["CPU frequency", cpuFreqGhz.toFixed(2) + " GHz"] : null,
            gpuTemp: gpuTemp >= 0 ? ["GPU temperature", Math.round(gpuTemp) + "°C"] : null,
            gpuBusy: gpuBusy >= 0 ? ["GPU usage", Math.round(gpuBusy) + "%"] : null,
            ram: ["RAM", gib(ramUsedMib) + " / " + gib(ramTotalMib) + "  (" + Math.round(ramPct) + "%)"],
            swap: swapTotalMib > 0 ? ["Swap", gib(swapUsedMib) + " / " + gib(swapTotalMib)] : null,
            disk: diskTotal > 0 ? ["Disk (/)", gib(diskUsed / 1048576) + " / " + gib(diskTotal / 1048576)] : null
        };
        const order = [first].concat(Object.keys(rows).filter(k => k !== first));
        return order.map(k => rows[k]).filter(r => r !== null);
    }

    function sampleDetails() {
        cpuinfo.reload();
        if (paths.gpuTemp)
            gpuTempFile.reload();
        if (paths.gpuBusy)
            gpuBusyFile.reload();
        df.running = true;
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            stat.reload();
            meminfo.reload();
            if (root.paths.cpuTemp)
                tempFile.reload();
            if (root.detailUsers > 0)
                root.sampleDetails();
        }
    }

    FileView {
        id: stat
        path: "/proc/stat"
        onLoaded: {
            // cpu  user nice system idle iowait irq softirq steal ...
            const t = text().split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
            const idle = t[3] + t[4];
            const total = t.reduce((a, b) => a + b, 0);
            if (root.lastCpuTimes) {
                const dTotal = total - root.lastCpuTimes.total;
                if (dTotal > 0)
                    root.cpu = 100 * (1 - (idle - root.lastCpuTimes.idle) / dTotal);
            }
            root.lastCpuTimes = { idle, total };
        }
    }

    FileView {
        id: meminfo
        path: "/proc/meminfo"
        onLoaded: {
            const kb = key => Number(text().match(new RegExp(key + ":\\s+(\\d+)"))[1]);
            const total = kb("MemTotal");
            const used = total - kb("MemAvailable");
            root.ramUsedMib = used / 1024;
            root.ramTotalMib = total / 1024;
            root.ramPct = 100 * used / total;
            root.swapTotalMib = kb("SwapTotal") / 1024;
            root.swapUsedMib = root.swapTotalMib - kb("SwapFree") / 1024;
        }
    }

    FileView {
        id: tempFile
        path: root.paths.cpuTemp ?? ""
        onLoaded: {
            root.temp = Number(text()) / 1000;
            root.tempMin = Math.min(root.tempMin, root.temp);
            root.tempMax = Math.max(root.tempMax, root.temp);
        }
    }

    FileView {
        id: cpuinfo
        path: "/proc/cpuinfo"
        onLoaded: {
            const mhz = text().match(/cpu MHz\s*:\s*[\d.]+/g) ?? [];
            if (mhz.length)
                root.cpuFreqGhz = mhz.map(l => Number(l.split(":")[1])).reduce((a, b) => a + b, 0) / mhz.length / 1000;
        }
    }

    FileView {
        id: gpuTempFile
        path: root.paths.gpuTemp ?? ""
        onLoaded: root.gpuTemp = Number(text()) / 1000
    }

    FileView {
        id: gpuBusyFile
        path: root.paths.gpuBusy ?? ""
        onLoaded: root.gpuBusy = Number(text())
    }

    Process {
        id: df
        command: ["df", "-B1", "--output=used,size", "/"]
        stdout: StdioCollector {
            onStreamFinished: {
                const [used, size] = text.trim().split("\n")[1].trim().split(/\s+/).map(Number);
                root.diskUsed = used;
                root.diskTotal = size;
            }
        }
    }

    // hwmon/drm numbering changes between boots, so find sensors by name.
    // CPU: same sensors as Noctalia v5 (k10temp/zenpower Tctl, coretemp package).
    // GPU: amdgpu only, which avoids waking a powered-down Nvidia dGPU.
    Process {
        running: true
        command: ["sh", "-c", `
            for h in /sys/class/hwmon/hwmon*; do
                case $(cat $h/name) in
                    k10temp|zenpower|coretemp) [ -z "$cpu" ] && cpu=1 && echo "cpuTemp=$h/temp1_input" ;;
                    amdgpu) [ -z "$gpu" ] && gpu=1 && echo "gpuTemp=$h/temp1_input" ;;
                esac
            done
            for f in /sys/class/drm/card*/device/gpu_busy_percent; do [ -e "$f" ] && echo "gpuBusy=$f" && break; done`]
        stdout: StdioCollector {
            onStreamFinished: {
                const found = {};
                for (const line of text.trim().split("\n")) {
                    const [k, v] = line.split("=");
                    if (v)
                        found[k] = v;
                }
                root.paths = found;
            }
        }
    }
}
