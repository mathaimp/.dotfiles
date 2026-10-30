import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

// Wi-Fi: on/off switch and the list of networks in range (connected first, then saved, then the rest).
// Click a network to connect or disconnect; secured networks that aren't saved ask for a password.
ColumnLayout {
    id: root

    readonly property var device: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null

    // Names in the order they first appeared. Rows keep their place while you use the list: re-sorting
    // by live signal strength moved rows under the cursor and rebuilt them on every scan update.
    // A plain object mutated in place (not a notifying property), so recording new names while
    // `networks` is evaluated doesn't feed back into it.
    readonly property var firstSeen: ({
            names: []
        })

    // Connected first, then saved, then the rest; within each group, first-seen order (a network seen
    // for the first time is placed by signal strength, strongest first).
    readonly property var networks: {
        const names = firstSeen.names;
        const seen = new Set();
        const list = (device?.networks.values ?? []).filter(n => {
            if (!n.name || seen.has(n.name))
                return false;
            seen.add(n.name);
            return true;
        });
        const placed = list.filter(n => names.includes(n.name)).sort((a, b) => names.indexOf(a.name) - names.indexOf(b.name));
        const fresh = list.filter(n => !names.includes(n.name)).sort((a, b) => b.signalStrength - a.signalStrength);
        for (const n of fresh)
            names.push(n.name);
        const all = placed.concat(fresh);
        return all.filter(n => n.connected).concat(all.filter(n => !n.connected && n.known), all.filter(n => !n.connected && !n.known));
    }

    // Set to { ssid, locked, security, hidden } to show the connect form instead of the list.
    property var form: null

    // Name of the network whose password prompt is open; only one at a time.
    property string asking: ""
    // What's typed in that prompt. Kept here, not in the row: the rows are rebuilt when networks
    // appear or disappear, and the text and reveal state must survive that.
    property string askingPassword: ""
    property bool askingReveal: false

    onAskingChanged: {
        askingPassword = "";
        askingReveal = false;
    }

    readonly property var enterpriseTypes: [WifiSecurityType.Wpa2Eap, WifiSecurityType.WpaEap, WifiSecurityType.Wpa3SuiteB192]

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
                    glyph: Networking.wifiEnabled ? Glyphs.wifi : Glyphs.wifiOff
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

            IconButton {
                visible: !!root.device && Networking.wifiEnabled
                glyph: Glyphs.plus
                glyphSize: 14
                implicitWidth: 28
                implicitHeight: 28
                variant: "tab"
                onClicked: root.form = { ssid: "", locked: false, security: "psk", hidden: true }
            }

            ToggleSwitch {
                visible: !!root.device
                checked: Networking.wifiEnabled
                onToggled: on => Networking.wifiEnabled = on
            }
        }
    }

    Loader {
        Layout.fillWidth: true
        Layout.fillHeight: true
        active: !!root.form
        visible: active

        sourceComponent: WifiForm {
            seed: root.form
            device: root.device?.name ?? ""
            onFinished: root.form = null
            onCancelled: root.form = null
        }
    }

    Rectangle {
        Layout.fillWidth: true
        Layout.fillHeight: true
        radius: 12
        visible: !root.form
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
                readonly property bool asking: root.asking === modelData.name
                property bool failed: false

                // Focus the field on opening, and again when a rebuilt row takes over an open prompt.
                onAskingChanged: if (asking)
                    password.forceActiveFocus()
                Component.onCompleted: if (asking) {
                    password.text = root.askingPassword;
                    password.forceActiveFocus();
                    password.cursorPosition = password.text.length;
                }

                width: ListView.view.width
                implicitHeight: rowContent.implicitHeight + 16
                height: implicitHeight
                radius: 8
                color: mouse.containsMouse ? Theme.surface : "transparent"

                function activate() {
                    failed = false;
                    // Selecting a row closes whichever prompt was open (this one toggles).
                    const wasAsking = asking;
                    root.asking = "";
                    if (modelData.connected) {
                        modelData.disconnect();
                    } else if (!modelData.known && root.enterpriseTypes.includes(modelData.security)) {
                        root.form = { ssid: modelData.name, locked: true, security: "eap", hidden: false };
                    } else if (modelData.known || !secured) {
                        modelData.connect();
                    } else if (!wasAsking) {
                        root.asking = modelData.name;
                    }
                }

                function submit() {
                    if (!password.text)
                        return;
                    failed = false;
                    modelData.connectWithPsk(password.text);
                    root.asking = ""; // also clears the stored text
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
                            glyph: row.signal >= 0.8 ? Glyphs.wifi
                                : row.signal >= 0.6 ? Glyphs.wifi3
                                : row.signal >= 0.35 ? Glyphs.wifi2
                                : row.signal >= 0.15 ? Glyphs.wifi1
                                : Glyphs.wifi0
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
                            glyph: Glyphs.lock
                            color: Qt.alpha(Theme.fg, 0.7)
                        }

                        IconButton {
                            visible: row.modelData.known
                            glyph: Glyphs.trash
                            glyphSize: 14
                            implicitWidth: 28
                            implicitHeight: 28
                            variant: "tab"
                            onClicked: row.modelData.forget()
                        }
                    }

                    // Password prompt for secured networks that aren't saved yet.
                    RowLayout {
                        Layout.fillWidth: true
                        visible: row.asking
                        spacing: 6

                        Rectangle {
                            Layout.fillWidth: true
                            implicitHeight: 32
                            radius: 6
                            color: Theme.surface

                            TextInput {
                                id: password
                                anchors.fill: parent
                                anchors.leftMargin: 10
                                anchors.rightMargin: 38
                                verticalAlignment: TextInput.AlignVCenter
                                echoMode: root.askingReveal ? TextInput.Normal : TextInput.Password
                                font.family: Theme.font
                                font.pixelSize: 14
                                color: Theme.fg
                                clip: true
                                selectByMouse: true
                                onTextChanged: if (row.asking)
                                    root.askingPassword = text
                                onAccepted: row.submit()
                                Keys.onEscapePressed: event => root.asking = ""

                                Text {
                                    visible: !password.text
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "Password"
                                    font: password.font
                                    color: Qt.alpha(Theme.fg, 0.5)
                                }
                            }

                            IconButton {
                                anchors.right: parent.right
                                anchors.verticalCenter: parent.verticalCenter
                                anchors.rightMargin: 4
                                glyph: root.askingReveal ? Glyphs.eyeOff : Glyphs.eye
                                glyphSize: 14
                                implicitWidth: 28
                                implicitHeight: 26
                                variant: "tab"
                                onClicked: root.askingReveal = !root.askingReveal
                            }
                        }

                        TextButton {
                            variant: "accent"
                            text: "Connect"
                            opacity: password.text ? 1 : 0.5
                            onClicked: row.submit()
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
