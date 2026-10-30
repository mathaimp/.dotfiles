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

    // History grouped by app (ordered by each app's newest entry), flattened into rows for the
    // list: a header for apps with several entries, then their entries unless collapsed.
    property var collapsed: ({})

    function toggleCollapsed(appName) {
        const next = Object.assign({}, collapsed);
        next[appName] = !next[appName];
        collapsed = next;
    }

    readonly property var rows: {
        const groups = new Map();
        for (const e of NotificationCenter.history) {
            if (!groups.has(e.appName))
                groups.set(e.appName, []);
            groups.get(e.appName).push(e);
        }
        const out = [];
        for (const [appName, items] of groups) {
            const grouped = items.length > 1;
            if (grouped) {
                out.push({
                    kind: "header",
                    appName,
                    icon: items[0].icon,
                    count: items.length,
                    collapsed: !!collapsed[appName]
                });
                if (collapsed[appName])
                    continue;
            }
            for (const e of items)
                out.push(Object.assign({
                    kind: "item",
                    grouped
                }, e));
        }
        return out;
    }

    // Everything here is being looked at, so nothing counts as unread while the tab is open.
    Component.onCompleted: NotificationCenter.unread = 0

    Connections {
        target: NotificationCenter

        function onHistoryChanged() {
            NotificationCenter.unread = 0;
        }
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
                model: root.rows
                boundsBehavior: Flickable.StopAtBounds

                delegate: Rectangle {
                    id: row

                    required property var modelData

                    width: ListView.view.width
                    implicitHeight: modelData.kind === "header" ? 36 : rowContent.implicitHeight + 16
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
                        anchors.leftMargin: row.modelData.grouped ? 20 : 8
                        visible: row.modelData.kind === "item"
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

                    // App header for a group of several notifications: click to collapse or expand.
                    MouseArea {
                        anchors.fill: parent
                        visible: row.modelData.kind === "header"
                        cursorShape: Qt.PointingHandCursor
                        onClicked: root.toggleCollapsed(row.modelData.appName)
                    }

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 8
                        anchors.rightMargin: 8
                        spacing: 8
                        visible: row.modelData.kind === "header"

                        Icon {
                            glyph: row.modelData.collapsed ? Glyphs.chevronRight : Glyphs.chevronDown
                            size: 14
                            color: Qt.alpha(Theme.fg, 0.7)
                        }
                        IconImage {
                            visible: row.modelData.icon !== ""
                            implicitSize: 18
                            source: row.modelData.icon ?? ""
                            asynchronous: true
                        }
                        Text {
                            Layout.fillWidth: true
                            text: row.modelData.appName || "Unknown"
                            elide: Text.ElideRight
                            font.family: Theme.font
                            font.pixelSize: 13
                            font.bold: true
                            color: Theme.fg
                        }
                        Text {
                            text: row.modelData.count
                            font.family: Theme.font
                            font.pixelSize: 12
                            color: Qt.alpha(Theme.fg, 0.7)
                        }
                        IconButton {
                            visible: rowHover.hovered
                            glyph: Glyphs.x
                            glyphSize: 12
                            implicitWidth: 22
                            implicitHeight: 22
                            variant: "tab"
                            onClicked: NotificationCenter.removeApp(row.modelData.appName)
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
