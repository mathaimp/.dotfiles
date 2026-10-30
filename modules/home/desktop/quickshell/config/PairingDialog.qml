import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Bluetooth pairing prompt (passkey confirmation, PIN / passkey entry, authorization, and
// display-only codes), shown under the bar on the focused screen while BluetoothAgent has a request.
PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    readonly property var req: BluetoothAgent.request
    readonly property string type: req?.type ?? ""
    readonly property bool needsInput: type === "pin" || type === "passkey"
    readonly property bool displayOnly: type === "displayPin" || type === "displayPasskey"

    visible: !!req && BluetoothAgent.screenName === modelData.name
    // Anchored to the top edge only, so the layer surface is centred horizontally.
    anchors.top: true
    margins.top: 44
    implicitWidth: card.width
    implicitHeight: card.height
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-pairing"
    WlrLayershell.keyboardFocus: visible && needsInput ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    onVisibleChanged: if (visible && needsInput) {
        entry.text = "";
        entry.forceActiveFocus();
    }

    function code(n) {
        return String(n ?? 0).padStart(6, "0");
    }

    Rectangle {
        id: card

        width: 360
        height: content.implicitHeight + 32
        radius: 12
        color: Qt.alpha(Theme.bg, 0.97)
        border.width: 1
        border.color: Theme.surface

        ColumnLayout {
            id: content
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12

            RowLayout {
                spacing: 8

                Rectangle {
                    implicitWidth: 32
                    implicitHeight: 32
                    radius: 6
                    color: Theme.surface

                    Icon {
                        anchors.centerIn: parent
                        glyph: Glyphs.bluetooth
                        color: Theme.accent
                    }
                }

                Text {
                    Layout.fillWidth: true
                    text: root.type === "service" ? "Allow connection?"
                        : root.type === "authorize" ? "Allow pairing?"
                        : root.displayOnly ? "Pairing code"
                        : "Pair with device"
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
            }

            Text {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                font.family: Theme.font
                font.pixelSize: 14
                color: Qt.alpha(Theme.fg, 0.8)
                text: {
                    const n = BluetoothAgent.deviceName;
                    switch (root.type) {
                    case "confirm":
                        return `Confirm that ${n} shows this code:`;
                    case "pin":
                        return `Enter the PIN for ${n}:`;
                    case "passkey":
                        return `Enter the passkey shown on ${n}:`;
                    case "authorize":
                        return `${n} wants to pair with this computer.`;
                    case "service":
                        return `${n} wants to use a service on this computer.`;
                    case "displayPin":
                    case "displayPasskey":
                        return `Enter this code on ${n}:`;
                    }
                    return "";
                }
            }

            // The code to compare or type on the other device.
            Text {
                Layout.alignment: Qt.AlignHCenter
                visible: root.type === "confirm" || root.type === "displayPasskey" || root.type === "displayPin"
                text: root.type === "displayPin" ? (root.req?.pin ?? "") : root.code(root.req?.passkey)
                font.family: Theme.font
                font.pixelSize: 32
                font.bold: true
                font.letterSpacing: 4
                color: Theme.accent
            }

            Rectangle {
                Layout.fillWidth: true
                visible: root.needsInput
                implicitHeight: 36
                radius: 6
                color: Theme.surface

                TextInput {
                    id: entry
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 10
                    verticalAlignment: TextInput.AlignVCenter
                    font.family: Theme.font
                    font.pixelSize: 16
                    color: Theme.fg
                    inputMethodHints: root.type === "passkey" ? Qt.ImhDigitsOnly : Qt.ImhNoPredictiveText
                    validator: root.type === "passkey" ? passkeyValidator : null
                    clip: true
                    onAccepted: if (text.length > 0)
                        BluetoothAgent.respond(true, text)
                    Keys.onEscapePressed: BluetoothAgent.respond(false)

                    IntValidator {
                        id: passkeyValidator
                        bottom: 0
                        top: 999999
                    }
                }
            }

            RowLayout {
                Layout.alignment: Qt.AlignRight
                spacing: 8

                TextButton {
                    text: root.displayOnly ? "Dismiss" : root.type === "authorize" || root.type === "service" ? "Deny" : "Cancel"
                    onClicked: BluetoothAgent.respond(false)
                }
                TextButton {
                    visible: !root.displayOnly
                    variant: "accent"
                    text: root.type === "authorize" || root.type === "service" ? "Allow" : root.type === "confirm" ? "Pair" : "OK"
                    onClicked: BluetoothAgent.respond(true, entry.text)
                }
            }
        }
    }
}
