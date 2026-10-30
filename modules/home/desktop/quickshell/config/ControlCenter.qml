import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland

// Control center in Noctalia v5's layout: a compact icon sidebar of tabs on the left, the active
// tab (with a title and close button) on the right. Floating under the bar's right end.
// The window is a transparent full-screen overlay so clicking outside (or Esc) closes it, and its
// contents only exist while open (Loader), so a closed panel holds no UI or PipeWire tracking.
PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    readonly property bool isOpen: Panels.quickSettingsScreen === modelData
    readonly property var tabs: [
        { id: "home", title: "Home", glyph: 0xEAC1 }, // home
        { id: "audio", title: "Audio", glyph: 0xEB51 } // volume
    ]

    visible: isOpen
    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-controlcenter"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: Panels.quickSettingsScreen = null
    }

    Loader {
        active: root.isOpen
        // Under the bar (4px margin + 32px bar + 8px gap), aligned with its right edge.
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: 44
        anchors.rightMargin: 8

        sourceComponent: Rectangle {
            width: 520
            height: 520
            radius: 12
            color: Qt.alpha(Theme.bg, 0.97)
            border.width: 1
            border.color: Theme.surface

            focus: true
            Keys.onEscapePressed: Panels.quickSettingsScreen = null

            // Swallow clicks so they don't reach the close-on-outside-click area.
            MouseArea {
                anchors.fill: parent
            }

            RowLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 14

                // Sidebar: icon-only tab buttons (v5's compact mode).
                Rectangle {
                    Layout.fillHeight: true
                    implicitWidth: tabColumn.implicitWidth + 24
                    radius: 12
                    color: Theme.container

                    Column {
                        id: tabColumn
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: 12
                        spacing: 4

                        Repeater {
                            model: root.tabs

                            IconButton {
                                required property var modelData
                                glyph: modelData.glyph
                                glyphSize: 21
                                radius: 9
                                variant: Panels.tab === modelData.id ? "tabActive" : "tab"
                                onClicked: Panels.tab = modelData.id
                            }
                        }
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12

                    RowLayout {
                        Text {
                            Layout.fillWidth: true
                            text: root.tabs.find(t => t.id === Panels.tab)?.title ?? ""
                            font.family: Theme.font
                            font.pixelSize: 16
                            font.bold: true
                            color: Theme.fg
                        }
                        IconButton {
                            glyph: 0xEB55 // x
                            glyphSize: 14
                            implicitWidth: 28
                            implicitHeight: 28
                            variant: "tab"
                            onClicked: Panels.quickSettingsScreen = null
                        }
                    }

                    // Only the active tab is instantiated.
                    Loader {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        sourceComponent: Panels.tab === "audio" ? audioTab : homeTab
                    }
                }
            }

            Component {
                id: homeTab
                HomeTab {}
            }
            Component {
                id: audioTab
                AudioTab {}
            }
        }
    }
}
