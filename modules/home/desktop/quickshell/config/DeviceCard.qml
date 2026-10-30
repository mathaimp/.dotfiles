import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

// Output/input device card from Noctalia v5's audio tab: title, current device, a ⋮ menu to
// pick the default device, then volume slider, percentage and mute.
Rectangle {
    id: root

    required property string title
    required property var node // current default PwNode
    required property var devices // PwNodes to choose from
    required property int icon
    required property int muteIcon
    signal picked(var node)

    property bool menuOpen: false
    readonly property bool muted: node?.audio?.muted ?? false

    z: menuOpen ? 10 : 0 // keep the device menu above neighbouring cards
    implicitHeight: content.implicitHeight + 24
    radius: 12
    color: Theme.container
    border.width: 1
    border.color: Theme.surface

    ColumnLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8

        RowLayout {
            spacing: 4

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: root.title
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    Layout.fillWidth: true
                    text: root.node?.description || "No device selected"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }

            IconButton {
                id: menuButton
                glyph: Glyphs.dotsVertical
                glyphSize: 13
                implicitWidth: 24
                implicitHeight: 24
                variant: root.menuOpen ? "tabActive" : "tab"
                onClicked: root.menuOpen = !root.menuOpen
            }
        }

        RowLayout {
            spacing: 8

            Slider {
                Layout.fillWidth: true
                value: root.node?.audio?.volume ?? 0
                onMoved: v => root.node.audio.volume = v
            }
            Text {
                Layout.minimumWidth: 36
                horizontalAlignment: Text.AlignRight
                text: Math.round((root.node?.audio?.volume ?? 0) * 100) + "%"
                font.family: Theme.font
                font.pixelSize: 14
                color: root.muted ? Theme.critical : Theme.fg
            }
            IconButton {
                glyph: root.muted ? root.muteIcon : root.icon
                glyphSize: 14
                variant: root.muted ? "destructive" : "default"
                onClicked: root.node.audio.muted = !root.muted
            }
        }
    }

    // Device menu (v5 opens a context menu from the ⋮ button).
    Rectangle {
        visible: root.menuOpen
        anchors.top: parent.top
        anchors.topMargin: 40
        anchors.right: parent.right
        anchors.rightMargin: 8
        width: Math.max(220, root.width - 16)
        height: menuColumn.implicitHeight + 8
        radius: 9
        color: Theme.bg
        border.width: 1
        border.color: Theme.surface

        Column {
            id: menuColumn
            anchors.fill: parent
            anchors.margins: 4

            Repeater {
                model: root.devices

                Rectangle {
                    required property var modelData
                    readonly property bool current: modelData === root.node

                    width: menuColumn.width
                    height: 32
                    radius: 6
                    color: itemMouse.containsMouse ? Theme.surface : "transparent"

                    Text {
                        anchors.left: parent.left
                        anchors.right: check.left
                        anchors.leftMargin: 8
                        anchors.rightMargin: 4
                        anchors.verticalCenter: parent.verticalCenter
                        text: parent.modelData.description || parent.modelData.name
                        elide: Text.ElideRight
                        font.family: Theme.font
                        font.pixelSize: 13
                        font.bold: parent.current
                        color: Theme.fg
                    }
                    Icon {
                        id: check
                        visible: parent.current
                        anchors.right: parent.right
                        anchors.rightMargin: 8
                        anchors.verticalCenter: parent.verticalCenter
                        glyph: Glyphs.check
                        size: 14
                        color: Theme.accent
                    }

                    MouseArea {
                        id: itemMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            root.picked(parent.modelData);
                            root.menuOpen = false;
                        }
                    }
                }
            }
        }
    }
}
