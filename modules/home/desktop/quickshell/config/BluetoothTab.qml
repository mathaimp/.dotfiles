import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

// Bluetooth: adapter on/off and the device list (connected first, then paired, then nearby).
// Click a device to connect or disconnect; unpaired devices are paired first.
ColumnLayout {
    id: root

    readonly property var adapter: Bluetooth.defaultAdapter
    // BlueZ falls back to the address (colon or dash form) when a device has no name.
    function isAddress(s) {
        return /^([0-9a-f]{2}[:-]){5}[0-9a-f]{2}$/i.test(s ?? "");
    }

    // The alias (user-set name) if real, else the device's own name, else the address.
    function nameOf(d) {
        return !isAddress(d.name) && d.name ? d.name : !isAddress(d.deviceName) && d.deviceName ? d.deviceName : d.address;
    }

    readonly property var devices: (adapter?.devices.values ?? [])
        // Nearby devices that only advertise their address aren't useful to list.
        .filter(d => d.paired || d.connected || !isAddress(nameOf(d)))
        .sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || nameOf(a).localeCompare(nameOf(b)))

    function glyphFor(icon) {
        if (icon.includes("headset") || icon.includes("headphone") || icon.includes("audio"))
            return Glyphs.headphones;
        if (icon.includes("keyboard"))
            return Glyphs.keyboard;
        if (icon.includes("mouse"))
            return Glyphs.mouse;
        if (icon.includes("phone"))
            return Glyphs.deviceMobile;
        if (icon.includes("gaming"))
            return Glyphs.gamepad2;
        return Glyphs.bluetooth;
    }

    spacing: 12

    // Discovery has no progress signal either, so the refresh icon spins for one turn.
    property bool scanning: false

    Timer {
        id: scanTimer
        interval: 900 // one full turn of the icon
        onTriggered: root.scanning = false
    }

    // Only scan while the tab is open.
    Component.onCompleted: if (adapter?.enabled) {
        adapter.discovering = true;
        scanning = true;
        scanTimer.restart();
    }
    Component.onDestruction: if (adapter)
        adapter.discovering = false

    Rectangle {
        Layout.fillWidth: true
        implicitHeight: header.implicitHeight + 24
        radius: 12
        color: Theme.container
        border.width: 1
        border.color: Theme.surface

        RowLayout {
            id: header
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            Rectangle {
                implicitWidth: 32
                implicitHeight: 32
                radius: 6
                color: Theme.surface

                Icon {
                    anchors.centerIn: parent
                    glyph: !root.adapter?.enabled ? Glyphs.bluetoothOff
                        : root.devices.some(d => d.connected) ? Glyphs.bluetoothConnected
                        : Glyphs.bluetooth
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: "Bluetooth"
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    Layout.fillWidth: true
                    text: !root.adapter ? "No Bluetooth adapter" : !root.adapter.enabled ? "Off" : root.adapter.discovering ? "Scanning…" : "On"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }

            // Restart discovery.
            IconButton {
                visible: !!root.adapter?.enabled
                glyph: Glyphs.refresh
                glyphSize: 14
                implicitWidth: 28
                implicitHeight: 28
                variant: "tab"
                spinning: root.scanning
                onClicked: {
                    root.adapter.discovering = false;
                    root.adapter.discovering = true;
                    root.scanning = true;
                    scanTimer.restart();
                }
            }

            ToggleSwitch {
                visible: !!root.adapter
                checked: root.adapter?.enabled ?? false
                onToggled: on => {
                    root.adapter.enabled = on;
                    root.adapter.discovering = on;
                }
            }
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 12
        color: Theme.container
        border.width: 1
        border.color: Theme.surface

        ListView {
            anchors.fill: parent
            anchors.margins: 8
            clip: true
            spacing: 4
            model: root.adapter?.enabled ? root.devices : []
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: row

                required property var modelData

                readonly property bool busy: modelData.pairing || modelData.state === BluetoothDeviceState.Connecting || modelData.state === BluetoothDeviceState.Disconnecting

                width: ListView.view.width
                implicitHeight: rowContent.implicitHeight + 16
                height: implicitHeight
                radius: 8
                color: mouse.containsMouse ? Theme.surface : "transparent"

                function activate() {
                    if (busy)
                        return;
                    if (modelData.connected)
                        modelData.disconnect();
                    else if (modelData.paired)
                        modelData.connect();
                    else
                        modelData.pair();
                }

                // After pairing finishes, connect right away.
                Connections {
                    target: row.modelData

                    function onPairedChanged() {
                        if (row.modelData.paired && !row.modelData.connected) {
                            row.modelData.trusted = true;
                            row.modelData.connect();
                        }
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: row.activate()
                }

                RowLayout {
                    id: rowContent
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    Icon {
                        glyph: root.glyphFor(row.modelData.icon)
                        color: row.modelData.connected ? Theme.accent : Theme.fg
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        Text {
                            Layout.fillWidth: true
                            text: root.nameOf(row.modelData)
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: 14
                            color: row.modelData.connected ? Theme.accent : Theme.fg
                        }
                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.pairing ? "Pairing…"
                                : row.modelData.state === BluetoothDeviceState.Connecting ? "Connecting…"
                                : row.modelData.state === BluetoothDeviceState.Disconnecting ? "Disconnecting…"
                                : row.modelData.connected ? "Connected"
                                : row.modelData.paired ? "Paired" : "Not paired"
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: 12
                            color: Qt.alpha(Theme.fg, 0.7)
                        }
                    }

                    Text {
                        visible: row.modelData.batteryAvailable
                        text: Math.round(row.modelData.battery * 100) + "%"
                        font.family: Theme.font
                        font.pixelSize: 13
                        color: Qt.alpha(Theme.fg, 0.7)
                    }

                    IconButton {
                        visible: row.modelData.paired
                        glyph: Glyphs.trash
                        glyphSize: 14
                        implicitWidth: 28
                        implicitHeight: 28
                        variant: "tab"
                        onClicked: row.modelData.forget()
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !root.adapter?.enabled || root.devices.length === 0
            text: !root.adapter ? "No Bluetooth adapter" : !root.adapter.enabled ? "Bluetooth is off" : "No devices found"
            font.family: Theme.font
            font.pixelSize: 14
            color: Qt.alpha(Theme.fg, 0.7)
        }
    }
}
