import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Services.Notifications

// One popup notification: icon or image, app name, summary, body and action buttons.
// Click the card to invoke its default action and dismiss; right-click or × dismisses.
// Hovering pauses the timeout.
Rectangle {
    id: root

    required property var modelData // Notification
    readonly property var n: modelData

    readonly property bool critical: n?.urgency === NotificationUrgency.Critical
    readonly property string icon: n ? NotificationCenter.iconUrl(n) : ""
    readonly property var actions: (n?.actions ?? []).filter(a => a.identifier !== "default")
    readonly property var defaultAction: (n?.actions ?? []).find(a => a.identifier === "default")
    // The sender's timeout (milliseconds) if it gave one; else by urgency, and critical ones stay.
    readonly property int duration: (n?.expireTimeout ?? 0) > 0 ? Math.round(n.expireTimeout) : critical ? 0 : n?.urgency === NotificationUrgency.Low ? 4000 : 7000

    width: 380
    implicitHeight: content.implicitHeight + 24
    radius: 12
    color: Qt.alpha(Theme.bg, 0.97)
    border.width: 1
    border.color: critical ? Theme.critical : Theme.surface

    Timer {
        interval: root.duration
        running: root.duration > 0 && !hover.hovered
        onTriggered: root.n?.expire()
    }

    HoverHandler {
        id: hover
    }

    // Behind the content so the buttons keep their own clicks.
    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        cursorShape: root.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
        onClicked: mouse => {
            if (mouse.button === Qt.LeftButton && root.defaultAction)
                root.defaultAction.invoke();
            root.n?.dismiss();
        }
    }

    RowLayout {
        id: content
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12

        // Image (e.g. a chat avatar), else the app icon, else a bell.
        Rectangle {
            Layout.alignment: Qt.AlignTop
            implicitWidth: 44
            implicitHeight: 44
            radius: 8
            color: Theme.surface
            clip: true

            Image {
                anchors.fill: parent
                visible: !!root.n?.image
                source: root.n?.image ?? ""
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
            IconImage {
                anchors.centerIn: parent
                visible: !root.n?.image && root.icon !== ""
                implicitSize: 32
                source: root.icon
                asynchronous: true
            }
            Icon {
                anchors.centerIn: parent
                visible: !root.n?.image && root.icon === ""
                glyph: Glyphs.bell
                color: root.critical ? Theme.critical : Theme.accent
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                spacing: 6

                Text {
                    Layout.fillWidth: true
                    text: root.n?.appName ?? ""
                    elide: Text.ElideRight
                    font.family: Theme.font
                    font.pixelSize: 12
                    color: Qt.alpha(Theme.fg, 0.7)
                }
                IconButton {
                    glyph: Glyphs.x
                    glyphSize: 12
                    implicitWidth: 22
                    implicitHeight: 22
                    variant: "tab"
                    onClicked: root.n?.dismiss()
                }
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.n?.summary ?? ""
                wrapMode: Text.WordWrap
                maximumLineCount: 2
                elide: Text.ElideRight
                textFormat: Text.PlainText
                font.family: Theme.font
                font.pixelSize: 14
                font.bold: true
                color: root.critical ? Theme.critical : Theme.fg
            }

            Text {
                Layout.fillWidth: true
                visible: text !== ""
                text: root.n?.body ?? ""
                wrapMode: Text.WordWrap
                maximumLineCount: 4
                elide: Text.ElideRight
                textFormat: Text.StyledText
                font.family: Theme.font
                font.pixelSize: 13
                color: Qt.alpha(Theme.fg, 0.85)
                onLinkActivated: link => Qt.openUrlExternally(link)
            }

            Flow {
                Layout.fillWidth: true
                Layout.topMargin: 4
                visible: root.actions.length > 0
                spacing: 6

                Repeater {
                    model: root.actions

                    TextButton {
                        required property var modelData

                        text: modelData.text
                        onClicked: modelData.invoke()
                    }
                }
            }
        }
    }
}
