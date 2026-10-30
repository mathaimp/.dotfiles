import QtQuick
import QtQuick.Layouts
import Quickshell.Io

// Connect to a network the list can't handle on its own: hidden networks, WPA3 Personal, and
// WPA/WPA2/WPA3 Enterprise (802.1X: PEAP, TTLS, TLS). Creates (or updates) a NetworkManager
// profile with nmcli, then brings it up.
Rectangle {
    id: root

    // { ssid, locked, security, hidden } from WifiTab.
    property var seed: ({})
    property string device: "" // wifi interface name

    signal finished
    signal cancelled

    property string security: "psk" // open | psk | sae | eap
    property string eap: "peap" // peap | ttls | tls
    property string phase2: "mschapv2"
    property bool hidden: false
    property bool busy: false
    property string status: ""
    property bool failed: false

    readonly property bool ssidLocked: seed.locked ?? false
    readonly property bool needsPassword: security === "psk" || security === "sae" || (security === "eap" && eap !== "tls")

    radius: 12
    color: Theme.container
    border.width: 1
    border.color: Theme.surface

    Component.onCompleted: {
        security = seed.security ?? "psk";
        hidden = seed.hidden ?? false;
        ssidField.text = seed.ssid ?? "";
        if (!ssidLocked)
            ssidField.focusInput();
        else
            passwordField.focusInput();
    }

    // Labelled text box, optionally hiding its content behind a reveal button.
    component Field: ColumnLayout {
        id: f

        property string label
        property alias text: input.text
        property bool secret: false
        property bool locked: false
        property string placeholder: ""
        signal accepted

        function focusInput() {
            input.forceActiveFocus();
        }

        Layout.fillWidth: true
        spacing: 4

        Text {
            text: f.label
            font.family: Theme.font
            font.pixelSize: 12
            color: Qt.alpha(Theme.fg, 0.7)
        }

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 34
            radius: 6
            color: Theme.surface
            opacity: f.locked ? 0.6 : 1

            TextInput {
                id: input
                anchors.fill: parent
                anchors.leftMargin: 10
                anchors.rightMargin: f.secret ? 38 : 10
                verticalAlignment: TextInput.AlignVCenter
                echoMode: f.secret && !reveal.on ? TextInput.Password : TextInput.Normal
                readOnly: f.locked
                font.family: Theme.font
                font.pixelSize: 14
                color: Theme.fg
                clip: true
                selectByMouse: true
                onAccepted: f.accepted()

                Text {
                    visible: !input.text
                    anchors.verticalCenter: parent.verticalCenter
                    text: f.placeholder
                    font: input.font
                    color: Qt.alpha(Theme.fg, 0.4)
                }
            }

            IconButton {
                id: reveal

                property bool on: false

                visible: f.secret
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                anchors.rightMargin: 4
                glyph: on ? Glyphs.eyeOff : Glyphs.eye
                glyphSize: 14
                implicitWidth: 28
                implicitHeight: 26
                variant: "tab"
                onClicked: on = !on
            }
        }
    }

    // Row of mutually exclusive buttons.
    component Choice: ColumnLayout {
        id: c

        property string label
        property var options: [] // [{ label, value }]
        property string current
        signal picked(string value)

        Layout.fillWidth: true
        spacing: 4

        Text {
            text: c.label
            font.family: Theme.font
            font.pixelSize: 12
            color: Qt.alpha(Theme.fg, 0.7)
        }

        Flow {
            Layout.fillWidth: true
            spacing: 6

            Repeater {
                model: c.options

                TextButton {
                    required property var modelData

                    text: modelData.label
                    variant: c.current === modelData.value ? "accent" : "default"
                    onClicked: c.picked(modelData.value)
                }
            }
        }
    }

    function validate() {
        if (!ssidField.text)
            return "Enter the network name.";
        if (security === "psk" && passwordField.text.length < 8)
            return "WPA passwords are at least 8 characters.";
        if (security === "sae" && !passwordField.text)
            return "Enter the password.";
        if (security === "eap") {
            if (!identityField.text)
                return "Enter the identity (username).";
            if (eap === "tls" && (!certField.text || !keyField.text))
                return "TLS needs a client certificate and a private key.";
            if (eap !== "tls" && !passwordField.text)
                return "Enter the password.";
        }
        return "";
    }

    // NetworkManager properties for the chosen options.
    function properties() {
        const p = ["802-11-wireless.hidden", hidden ? "yes" : "no"];
        if (security === "psk") {
            p.push("802-11-wireless-security.key-mgmt", "wpa-psk", "802-11-wireless-security.psk", passwordField.text);
        } else if (security === "sae") {
            p.push("802-11-wireless-security.key-mgmt", "sae", "802-11-wireless-security.psk", passwordField.text);
        } else if (security === "eap") {
            p.push("802-11-wireless-security.key-mgmt", "wpa-eap", "802-1x.eap", eap, "802-1x.identity", identityField.text);
            if (anonField.text)
                p.push("802-1x.anonymous-identity", anonField.text);
            if (eap === "tls")
                p.push("802-1x.client-cert", certField.text, "802-1x.private-key", keyField.text, "802-1x.private-key-password", passwordField.text);
            else
                p.push("802-1x.phase2-auth", phase2, "802-1x.password", passwordField.text);
            if (caField.text)
                p.push("802-1x.ca-cert", caField.text);
        }
        return p;
    }

    function connectNow() {
        const err = validate();
        if (err) {
            status = err;
            failed = true;
            return;
        }
        failed = false;
        busy = true;
        status = "Saving…";
        runner.step = "list";
        runner.command = ["nmcli", "-t", "-f", "NAME", "connection", "show"];
        runner.running = true;
    }

    // list -> add/modify -> up, one nmcli call at a time.
    Process {
        id: runner

        property string step: ""
        property string out: ""
        property string err: ""

        stdout: StdioCollector {
            onStreamFinished: runner.out = text
        }
        stderr: StdioCollector {
            onStreamFinished: runner.err = text
        }
        // Let the collectors deliver their text before looking at it.
        onExited: code => {
            settle.code = code;
            settle.start();
        }
    }

    Timer {
        id: settle

        property int code: 0

        interval: 80
        onTriggered: {
            const name = ssidField.text;
            if (runner.step === "list") {
                const exists = runner.out.split("\n").includes(name);
                runner.step = "write";
                status = "Saving…";
                runner.command = exists ? ["nmcli", "connection", "modify", "id", name].concat(root.properties()) : ["nmcli", "connection", "add", "type", "wifi", "ifname", root.device || "*", "con-name", name, "ssid", name, "--"].concat(root.properties());
                runner.running = true;
            } else if (runner.step === "write") {
                if (code !== 0)
                    return root.fail(runner.err);
                runner.step = "up";
                status = "Connecting…";
                runner.command = ["nmcli", "--wait", "40", "connection", "up", "id", name];
                runner.running = true;
            } else {
                if (code !== 0)
                    return root.fail(runner.err);
                root.busy = false;
                root.finished();
            }
        }
    }

    function fail(message) {
        busy = false;
        failed = true;
        status = message.trim().replace(/^Error: /, "") || "Could not connect.";
    }

    Flickable {
        id: scroll

        anchors.fill: parent
        anchors.margins: 12
        contentHeight: form.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: form

            width: scroll.width
            spacing: 10

            RowLayout {
                spacing: 8

                IconButton {
                    glyph: Glyphs.arrowLeft
                    glyphSize: 14
                    implicitWidth: 28
                    implicitHeight: 28
                    variant: "tab"
                    onClicked: root.cancelled()
                }
                Text {
                    Layout.fillWidth: true
                    text: root.ssidLocked ? "Connect to " + root.seed.ssid : "Add network"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
            }

            Field {
                id: ssidField
                label: "Network name (SSID)"
                locked: root.ssidLocked
                onAccepted: root.connectNow()
            }

            Choice {
                label: "Security"
                current: root.security
                options: [
                    { label: "Open", value: "open" },
                    { label: "WPA/WPA2", value: "psk" },
                    { label: "WPA3", value: "sae" },
                    { label: "Enterprise", value: "eap" }
                ]
                onPicked: v => root.security = v
            }

            Choice {
                visible: root.security === "eap"
                label: "EAP method"
                current: root.eap
                options: [
                    { label: "PEAP", value: "peap" },
                    { label: "TTLS", value: "ttls" },
                    { label: "TLS", value: "tls" }
                ]
                onPicked: v => root.eap = v
            }

            Choice {
                visible: root.security === "eap" && root.eap !== "tls"
                label: "Inner authentication"
                current: root.phase2
                options: [
                    { label: "MSCHAPv2", value: "mschapv2" },
                    { label: "PAP", value: "pap" },
                    { label: "GTC", value: "gtc" },
                    { label: "MSCHAP", value: "mschap" }
                ]
                onPicked: v => root.phase2 = v
            }

            Field {
                id: identityField
                visible: root.security === "eap"
                label: "Identity (username)"
                onAccepted: root.connectNow()
            }

            Field {
                id: anonField
                visible: root.security === "eap" && root.eap !== "tls"
                label: "Anonymous identity (optional)"
                onAccepted: root.connectNow()
            }

            Field {
                id: certField
                visible: root.security === "eap" && root.eap === "tls"
                label: "Client certificate (path)"
                placeholder: "/home/you/cert.pem"
                onAccepted: root.connectNow()
            }

            Field {
                id: keyField
                visible: root.security === "eap" && root.eap === "tls"
                label: "Private key (path)"
                placeholder: "/home/you/key.pem"
                onAccepted: root.connectNow()
            }

            Field {
                id: passwordField
                visible: root.needsPassword || (root.security === "eap" && root.eap === "tls")
                label: root.security === "eap" && root.eap === "tls" ? "Private key password (if any)" : "Password"
                secret: true
                onAccepted: root.connectNow()
            }

            Field {
                id: caField
                visible: root.security === "eap"
                label: "CA certificate (path, optional)"
                placeholder: "/etc/ssl/certs/ca.pem"
                onAccepted: root.connectNow()
            }

            RowLayout {
                visible: !root.ssidLocked
                spacing: 8

                ToggleSwitch {
                    checked: root.hidden
                    onToggled: on => root.hidden = on
                }
                Text {
                    Layout.fillWidth: true
                    text: "Hidden network"
                    font.family: Theme.font
                    font.pixelSize: 14
                    color: Theme.fg
                }
            }

            Text {
                Layout.fillWidth: true
                visible: root.status !== ""
                text: root.status
                wrapMode: Text.WordWrap
                font.family: Theme.font
                font.pixelSize: 13
                color: root.failed ? Theme.critical : Qt.alpha(Theme.fg, 0.7)
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                TextButton {
                    text: "Cancel"
                    onClicked: root.cancelled()
                }
                TextButton {
                    variant: "accent"
                    text: root.busy ? "Connecting…" : "Connect"
                    opacity: root.busy ? 0.6 : 1
                    onClicked: if (!root.busy)
                        root.connectNow()
                }
            }
        }
    }
}
