import QtQuick
import Quickshell
import Quickshell.Wayland

// Popup notifications, stacked under the bar's right end on the focused screen, newest on top.
// The window only covers the cards (click-through everywhere else) and only exists while there
// is something to show.
PanelWindow {
    id: root

    required property ShellScreen modelData
    screen: modelData

    readonly property int count: NotificationCenter.popups.values.length

    visible: count > 0 && Panels.focusedScreen() === modelData
    anchors {
        top: true
        right: true
    }
    margins {
        top: 44
        right: 8
    }
    implicitWidth: 380
    implicitHeight: Math.max(1, list.contentHeight)
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-notifications"
    mask: Region {
        item: list
    }

    // The model is oldest-first; BottomToTop puts the first item at the bottom, so new ones appear on top.
    ListView {
        id: list

        width: 380
        height: contentHeight
        interactive: false
        spacing: 8
        verticalLayoutDirection: ListView.BottomToTop
        model: NotificationCenter.popups

        delegate: NotificationCard {}

        add: Transition {
            EffectsAnimation {
                property: "opacity"
                from: 0
                to: 1
            }
        }
        displaced: Transition {
            SpatialAnimation {
                property: "y"
            }
        }
    }
}
