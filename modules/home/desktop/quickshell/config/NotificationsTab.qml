import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Notifications

// Notification history (this session) and the do-not-disturb switch.
ColumnLayout {
    id: root

    // Bumped every 30 s so the "5m ago" labels stay current.
    property int tick: 0

    function ago(time) {
        tick; // dependency
        const s = Math.max(0, Math.round((Date.now() - time) / 1000));
        if (s < 60)
            return "now";
        if (s < 3600)
            return Math.floor(s / 60) + "m ago";
        if (s < 86400)
            return Math.floor(s / 3600) + "h ago";
        return Math.floor(s / 86400) + "d ago";
    }

    spacing: 12

    Timer {
        interval: 30000
        running: true
        repeat: true
        onTriggered: root.tick++
    }

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
                    glyph: NotificationCenter.dnd ? Glyphs.bellOff : Glyphs.bell
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                Text {
                    text: "Do not disturb"
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
                Text {
                    Layout.fillWidth: true
                    text: NotificationCenter.dnd ? "Popups are hidden (critical ones still show)" : "Popups are shown"
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 13
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }

            ToggleSwitch {
                checked: NotificationCenter.dnd
                onToggled: on => NotificationCenter.dnd = on
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

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 8
            spacing: 6

            RowLayout {
                Layout.leftMargin: 6
                Layout.rightMargin: 2

                Text {
                    Layout.fillWidth: true
                    text: "History"
                    font.family: Theme.font
                    font.pixelSize: 16
                    font.bold: true
                    color: Theme.fg
                }
                TextButton {
                    visible: NotificationCenter.history.length > 0
                    text: "Clear all"
                    onClicked: NotificationCenter.clear()
                }
            }

            ListView {
                Layout.fillWidth: true
                Layout.fillHeight: true
                clip: true
                spacing: 4
                model: NotificationCenter.history
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: row

                    required property var modelData

                    width: ListView.view.width
                    implicitHeight: rowContent.implicitHeight + 16
                    height: implicitHeight
                    radius: 8
                    color: rowHover.hovered ? Theme.surface : "transparent"

                    HoverHandler {
                        id: rowHover
                    }

                    RowLayout {
                        id: rowContent
                        anchors.fill: parent
                        anchors.margins: 8
                        spacing: 10

                        Item {
                            Layout.alignment: Qt.AlignTop
                            implicitWidth: 28
                            implicitHeight: 28

                            IconImage {
                                anchors.centerIn: parent
                                visible: row.modelData.icon !== ""
                                implicitSize: 28
                                source: row.modelData.icon
                                asynchronous: true
                            }
                            Icon {
                                anchors.centerIn: parent
                                visible: row.modelData.icon === ""
                                glyph: Glyphs.bell
                                color: row.modelData.urgency === NotificationUrgency.Critical ? Theme.critical : Theme.accent
                            }
                        }

                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 0

                            RowLayout {
                                spacing: 6

                                Text {
                                    Layout.fillWidth: true
                                    text: row.modelData.summary || row.modelData.appName
                                    elide: Text.ElideRight
                                    textFormat: Text.PlainText
                                    font.family: Theme.font
                                    font.pixelSize: 14
                                    font.bold: true
                                    color: row.modelData.urgency === NotificationUrgency.Critical ? Theme.critical : Theme.fg
                                }
                                Text {
                                    text: root.ago(row.modelData.time)
                                    font.family: Theme.font
                                    font.pixelSize: 11
                                    color: Qt.alpha(Theme.fg, 0.6)
                                }
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: text !== ""
                                text: row.modelData.body
                                wrapMode: Text.WordWrap
                                maximumLineCount: 3
                                elide: Text.ElideRight
                                textFormat: Text.StyledText
                                font.family: Theme.font
                                font.pixelSize: 12
                                color: Qt.alpha(Theme.fg, 0.8)
                            }
                            Text {
                                Layout.fillWidth: true
                                visible: row.modelData.summary !== "" && row.modelData.appName !== ""
                                text: row.modelData.appName
                                elide: Text.ElideRight
                                font.family: Theme.font
                                font.pixelSize: 11
                                color: Qt.alpha(Theme.fg, 0.55)
                            }
                        }

                        IconButton {
                            Layout.alignment: Qt.AlignTop
                            visible: rowHover.hovered
                            glyph: Glyphs.x
                            glyphSize: 12
                            implicitWidth: 22
                            implicitHeight: 22
                            variant: "tab"
                            onClicked: NotificationCenter.remove(row.modelData.id)
                        }
                    }
                }

                Text {
                    anchors.centerIn: parent
                    visible: NotificationCenter.history.length === 0
                    text: "No notifications"
                    font.family: Theme.font
                    font.pixelSize: 14
                    color: Qt.alpha(Theme.fg, 0.7)
                }
            }
        }
    }
}
