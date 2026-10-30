import QtQuick
import Quickshell.Services.UPower

// Android 16 style battery, ported from Noctalia v4's NBattery: a filled body with the
// percentage inside, alternating with a bolt while charging.
Item {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool ready: device.ready && device.isPresent
    readonly property real percentage: device.percentage * 100
    readonly property bool charging: device.state === UPowerDeviceState.Charging
    readonly property bool pluggedIn: device.state === UPowerDeviceState.FullyCharged
        || device.state === UPowerDeviceState.PendingCharge
    // Thresholds match the Noctalia config (warning 20%, critical 5%).
    readonly property bool critical: !charging && !pluggedIn && percentage <= 5
    readonly property bool low: !charging && !pluggedIn && percentage <= 20

    // v4's proportions, scaled so the body matches the ~13px ink height of the 16px icon glyphs.
    readonly property int bodyWidth: percentage > 99 ? 27 : 21
    readonly property int bodyHeight: 13
    readonly property int terminalWidth: 3
    readonly property int terminalHeight: 6
    readonly property int cornerRadius: 3

    readonly property color baseColor: Theme.fg
    readonly property color emptyColor: Qt.alpha(baseColor, 0.66)
    readonly property color activeColor: !ready ? Qt.alpha(baseColor, 0.5)
        : charging ? Theme.accent
        : low || critical ? Theme.critical
        : baseColor
    readonly property color textColor: Qt.alpha(Theme.bg, 0.75)

    // Tooltip rows, as in Noctalia v5: charge, status, time left/to full, rate, health.
    readonly property var tooltipRows: {
        if (!ready)
            return [["Battery", "Not available"]];
        const rows = [["Battery", Math.round(percentage) + "%"], ["Status", stateLabel(device.state)]];
        if (device.timeToEmpty > 0)
            rows.push(["Time left", formatDuration(device.timeToEmpty)]);
        else if (device.timeToFull > 0)
            rows.push(["Time to full", formatDuration(device.timeToFull)]);
        if (Math.abs(device.changeRate) > 0)
            rows.push(["Rate", Math.abs(device.changeRate).toFixed(1) + " W"]);
        if (device.healthSupported)
            rows.push(["Health", Math.round(device.healthPercentage) + "%"]);
        return rows;
    }

    function stateLabel(state) {
        switch (state) {
        case UPowerDeviceState.Charging: return "Charging";
        case UPowerDeviceState.Discharging: return "Discharging";
        case UPowerDeviceState.FullyCharged: return "Fully charged";
        case UPowerDeviceState.Empty: return "Empty";
        case UPowerDeviceState.PendingCharge: return "Plugged in, not charging";
        case UPowerDeviceState.PendingDischarge: return "Pending discharge";
        default: return "Unknown";
        }
    }

    function formatDuration(seconds) {
        const h = Math.floor(seconds / 3600);
        const m = Math.round((seconds % 3600) / 60);
        return h > 0 ? `${h}h ${m}m` : `${m}m`;
    }

    // Tabler x / bolt-filled / plug-filled, as in v4 (see Icon.qml)
    readonly property int stateIcon: !ready ? 0xEB55 : charging ? 0x10021 : 0xF6B3

    // Toggles between percentage and bolt every 4s while charging.
    property bool showStateIcon: false
    onChargingChanged: if (!charging) showStateIcon = false

    property real animatedPercentage: percentage
    Behavior on animatedPercentage {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutCubic
        }
    }

    Timer {
        interval: 4000
        repeat: true
        running: root.charging
        onTriggered: root.showStateIcon = !root.showStateIcon
    }

    implicitWidth: bodyWidth + terminalWidth
    implicitHeight: bodyHeight

    Rectangle {
        id: body
        width: root.bodyWidth
        height: root.bodyHeight
        radius: root.cornerRadius
        color: root.emptyColor
    }

    // Terminal cap
    Rectangle {
        x: root.bodyWidth
        y: (root.bodyHeight - root.terminalHeight) / 2
        width: root.terminalWidth
        height: root.terminalHeight
        radius: root.cornerRadius / 2
        color: root.critical ? Theme.critical : root.emptyColor
    }

    // Fill level
    Rectangle {
        visible: root.ready && (root.animatedPercentage > 0 || root.critical)
        width: root.bodyWidth * (root.critical ? 1 : root.animatedPercentage / 100)
        height: root.bodyHeight
        radius: root.cornerRadius
        color: root.activeColor
    }

    Text {
        anchors.centerIn: body
        opacity: root.ready && (root.charging ? !root.showStateIcon : !root.pluggedIn) ? 1 : 0
        visible: opacity > 0
        text: Math.round(root.animatedPercentage)
        font.family: "SFRounded Nerd Font Heavy"
        font.pixelSize: 10
        color: root.textColor

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }

    Icon {
        anchors.centerIn: body
        opacity: !root.ready || (root.charging ? root.showStateIcon : root.pluggedIn) ? 1 : 0
        visible: opacity > 0
        glyph: root.stateIcon
        font.pixelSize: 11
        color: root.textColor

        Behavior on opacity {
            NumberAnimation {
                duration: 150
                easing.type: Easing.InOutQuad
            }
        }
    }
}
