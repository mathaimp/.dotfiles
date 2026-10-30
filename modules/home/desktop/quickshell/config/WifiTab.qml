import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

// Wi-Fi: on/off switch and the list of networks in range (connected first, then saved, then by signal).
// Click a network to connect or disconnect; secured networks that aren't saved ask for a password.
ColumnLayout {
    id: root

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
    readonly property var networks: {
        const seen = new Set();
        return (device?.networks.values ?? []).filter(n => {
            if (!n.name || seen.has(n.name))
                return false;
            seen.add(n.name);
            return true;
        }).sort((a, b) => (b.connected - a.connected) || (b.known - a.known) || (b.signalStrength - a.signalStrength));
    }

    spacing: 12

    // Only scan while the tab is open.
    Component.onCompleted: if (device)
        device.scannerEnabled = true
    Component.onDestruction: if (device)
        device.scannerEnabled = false

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
                    glyph: Networking.wifiEnabled ? 0xEB52 : 0xECFA // wifi / wifi-off
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: "Wi-Fi"
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    Layout.fillWidth: true
                    text: !root.device ? "No Wi-Fi adapter" : !Networking.wifiEnabled ? "Off" : (root.networks.find(n => n.connected)?.name ?? "Not connected")
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }

            ToggleSwitch {
                visible: !!root.device
                checked: Networking.wifiEnabled
                onToggled: on => Networking.wifiEnabled = on
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
            model: Networking.wifiEnabled ? root.networks : []
            boundsBehavior: Flickable.StopAtBounds

            delegate: Rectangle {
                id: row

                required property var modelData

                readonly property bool secured: modelData.security !== WifiSecurityType.Open && modelData.security !== WifiSecurityType.Owe
                readonly property bool busy: modelData.state === ConnectionState.Connecting || modelData.state === ConnectionState.Disconnecting
                readonly property real signal: modelData.signalStrength
                property bool asking: false
                property bool failed: false

                width: ListView.view.width
                implicitHeight: rowContent.implicitHeight + 16
                height: implicitHeight
                radius: 8
                color: mouse.containsMouse ? Theme.surface : "transparent"

                function activate() {
                    failed = false;
                    if (modelData.connected) {
                        modelData.disconnect();
                    } else if (modelData.known || !secured) {
                        modelData.connect();
                    } else {
                        asking = !asking;
                        if (asking)
                            password.forceActiveFocus();
                    }
                }

                function submit() {
                    failed = false;
                    asking = false;
                    modelData.connectWithPsk(password.text);
                    password.text = "";
                }

                Connections {
                    target: row.modelData

                    function onConnectionFailed(reason) {
                        row.failed = true;
                    }
                }

                MouseArea {
                    id: mouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: row.activate()
                }

                ColumnLayout {
                    id: rowContent
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8

                    RowLayout {
                        spacing: 8

                        Icon {
                            glyph: row.signal >= 0.8 ? 0xEB52 // wifi
                                : row.signal >= 0.6 ? 0xEBFC // wifi-3
                                : row.signal >= 0.35 ? 0xEBA5 // wifi-2
                                : row.signal >= 0.15 ? 0xEBA4 // wifi-1
                                : 0xEBA3 // wifi-0
                            color: row.modelData.connected ? Theme.accent : Theme.fg
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            Text {
                                Layout.fillWidth: true
                                text: row.modelData.name
                                elide: Text.ElideRight
                                font.family: Theme.font
                                font.pixelSize: 14
                                color: row.modelData.connected ? Theme.accent : Theme.fg
                            }
                            Text {
                                Layout.fillWidth: true
                                text: row.failed ? "Connection failed"
                                    : row.modelData.state === ConnectionState.Connecting ? "Connecting…"
                                    : row.modelData.state === ConnectionState.Disconnecting ? "Disconnecting…"
                                    : row.modelData.connected ? "Connected"
                                    : row.modelData.known ? "Saved"
                                    : row.secured ? "Secured" : "Open"
                                elide: Text.ElideRight
                                font.family: Theme.font
                                font.pixelSize: 12
                                color: row.failed ? Theme.critical : Qt.alpha(Theme.fg, 0.7)
                            }
                        }

                        Icon {
                            visible: row.secured
                            glyph: 0xEAE2 // lock
                            color: Qt.alpha(Theme.fg, 0.7)
                        }

                        IconButton {
                            visible: row.modelData.known
                            glyph: 0xEB41 // trash
                            glyphSize: 14
                            implicitWidth: 28
                            implicitHeight: 28
                            variant: "tab"
                            onClicked: row.modelData.forget()
                        }
                    }

                    // Password prompt for secured networks that aren't saved yet.
                    Rectangle {
                        Layout.fillWidth: true
                        visible: row.asking
                        implicitHeight: 32
                        radius: 6
                        color: Theme.surface

                        TextInput {
                            id: password
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: TextInput.AlignVCenter
                            echoMode: TextInput.Password
                            font.family: Theme.font
                            font.pixelSize: 14
                            color: Theme.fg
                            clip: true
                            onAccepted: row.submit()
                            Keys.onEscapePressed: event => {
                                row.asking = false;
                                text = "";
                            }

                            Text {
                                visible: !password.text
                                anchors.verticalCenter: parent.verticalCenter
                                text: "Password, then Enter"
                                font: password.font
                                color: Qt.alpha(Theme.fg, 0.5)
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            visible: !Networking.wifiEnabled || root.networks.length === 0
            text: !Networking.wifiEnabled ? "Wi-Fi is off" : "No networks found"
            font.family: Theme.font
            font.pixelSize: 14
            color: Qt.alpha(Theme.fg, 0.7)
        }
    }
}
