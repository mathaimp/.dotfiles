import QtQuick
import Quickshell
import Quickshell.Wayland

// App launcher window: a transparent full-screen overlay (click outside or Esc closes) holding the
// centred panel. The panel only exists while open (Loader), like the control center.
PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    readonly property bool isOpen: Panels.launcherScreen === modelData

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
    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.keyboardFocus: isOpen ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    MouseArea {
        anchors.fill: parent
        onClicked: Panels.launcherScreen = null
    }

    Loader {
        active: root.isOpen
        anchors.centerIn: parent

        sourceComponent: LauncherPanel {
            maxHeight: root.height - 120
        }
    }
}
