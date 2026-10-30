import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Hyprland
import Quickshell.Services.UPower
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.WindowManager

PanelWindow {
    id: bar

    required property ShellScreen modelData
    screen: modelData

    anchors {
        top: true
        left: true
        right: true
    }
    margins {
        top: 4
        left: 8
        right: 8
    }
    implicitHeight: 32
    color: "transparent"
    // Below windows: the exclusive zone keeps normal windows clear, fullscreen ones cover it.
    WlrLayershell.layer: WlrLayer.Bottom

    component Label: Text {
        color: Theme.fg
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        verticalAlignment: Text.AlignVCenter
    }

    Rectangle {
        anchors.fill: parent
        radius: 12
        color: Qt.alpha(Theme.bg, 0.93)

        // Left: clock and system stats (thresholds are Noctalia v5's defaults)
        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            // Widgets carry their own padding (Widget.qml), so no extra spacing here.
            spacing: 0

            Widget {
                tooltipRows: [["Date", Qt.formatDate(clock.date, "dddd, d MMMM yyyy")]]

                Label {
                    text: Qt.formatDateTime(clock.date, "hh:mm AP")

                    SystemClock {
                        id: clock
                        precision: SystemClock.Minutes
                    }
                }
            }

            // CPU, temperature and RAM share one hover zone and tooltip.
            Widget {
                wantsStatDetails: true
                tooltipRows: SystemStats.tooltipRows("cpu")
                spacing: 5

                SysStat {
                    icon: Glyphs.speedometer
                    value: SystemStats.cpu
                    fraction: SystemStats.cpu / 100
                    label: Math.round(SystemStats.cpu) + "%"
                    activity: 50
                    critical: 90
                }
                SysStat {
                    icon: Glyphs.flame
                    value: SystemStats.temp
                    fraction: (SystemStats.temp - SystemStats.tempMin) / (SystemStats.tempMax - SystemStats.tempMin)
                    label: Math.round(SystemStats.temp) + "°C"
                    activity: 60
                    critical: 85
                }
                SysStat {
                    icon: Glyphs.cpu
                    value: SystemStats.ramPct
                    fraction: SystemStats.ramPct / 100
                    label: SystemStats.ramUsedMib >= 1024
                        ? (SystemStats.ramUsedMib / 1024).toFixed(1) + " GiB"
                        : Math.round(SystemStats.ramUsedMib) + " MiB"
                    activity: 60
                    critical: 90
                }
            }
        }

        // Centre: workspaces on this screen (ext-workspace, works on Hyprland and niri).
        // Sizing follows Noctalia v4: every workspace gets a visible pill so the gaps
        // between pills (not between glyphs) are what reads as spacing.
        Row {
            id: workspaces

            // Base pill size (Noctalia v5 at scale 1.1). Odd, like SF Rounded digit ink, so labels centre exactly.
            readonly property int unit: 21

            // ext-workspace has no window info, so "has windows" comes from compositor IPC.
            // Hyprland only for now; on niri every inactive workspace shows as empty.
            readonly property bool onHyprland: Quickshell.env("HYPRLAND_INSTANCE_SIGNATURE") !== null
            readonly property var occupiedNames: onHyprland
                ? Hyprland.workspaces.values.filter(w => w.toplevels.values.length > 0).map(w => w.name)
                : []

            // Hovering the workspaces shows each workspace's app icons (Noctalia v4's
            // "show applications on hover"). Hyprland only, like occupiedNames.
            property bool showApps: false

            function windowsFor(name) {
                return Hyprland.workspaces.values.find(w => w.name === name)?.toplevels.values ?? [];
            }

            function iconFor(toplevel) {
                const appId = toplevel.wayland?.appId ?? toplevel.lastIpcObject?.class ?? "";
                return Quickshell.iconPath(DesktopEntries.heuristicLookup(appId)?.icon ?? appId, "application-x-executable");
            }

            HoverHandler {
                onHoveredChanged: {
                    if (hovered) {
                        unhoverDelay.stop();
                        workspaces.showApps = workspaces.onHyprland;
                    } else {
                        unhoverDelay.restart();
                    }
                }
            }

            // Short grace period (as in v4) so the icons don't collapse while moving between pills.
            Timer {
                id: unhoverDelay
                interval: 150
                onTriggered: workspaces.showApps = false
            }

            anchors.centerIn: parent
            spacing: 4

            Repeater {
                model: (WindowManager.screenProjection(bar.screen)?.windowsets ?? [])
                    .filter(w => w.shouldDisplay)
                    .sort((a, b) => a.coordinates[0] - b.coordinates[0])

                delegate: Item {
                    id: ws
                    required property Windowset modelData

                    readonly property int unit: workspaces.unit
                    readonly property bool occupied: workspaces.occupiedNames.includes(modelData.name)
                    readonly property color pillColor: modelData.urgent ? Theme.critical
                        : modelData.active ? Theme.accent
                        : occupied ? Qt.alpha(Theme.occupied, 0.7)
                        : Qt.alpha(Theme.muted, 0.6)
                    readonly property bool filled: modelData.urgent || modelData.active
                    readonly property var windows: workspaces.showApps ? workspaces.windowsFor(modelData.name) : []
                    readonly property bool showIcons: windows.length > 0
                    readonly property int iconSize: 15
                    // Width from character count, not measured glyphs, so digits don't skew it.
                    readonly property int pillWidth: {
                        if (showIcons)
                            return windows.length * (iconSize + 3) - 3 + 12;
                        const forText = modelData.name.length * unit * 0.33 + unit * 0.6;
                        const w = Math.round(Math.max(unit * (modelData.active ? 2 : 1), forText));
                        return w % 2 ? w : w - 1;
                    }

                    width: pillWidth
                    height: bar.implicitHeight

                    Behavior on width {
                        NumberAnimation {
                            duration: 250
                            easing.type: Easing.OutBack
                        }
                    }

                    Rectangle {
                        anchors.centerIn: parent
                        width: ws.width
                        height: ws.unit - 2
                        radius: height / 2
                        color: mouse.containsMouse && mouse.enabled ? Qt.lighter(ws.pillColor, 1.2) : ws.pillColor

                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }

                        Label {
                            id: wsLabel

                            // Centre the glyph ink rather than the text box: SF digits have
                            // uneven side bearings, and the line box includes descender space.
                            readonly property rect ink: fontMetrics.tightBoundingRect(text)

                            // ink is relative to the baseline origin; the baseline sits at y + ascent.
                            x: Math.round(parent.width / 2 - (ink.x + ink.width / 2))
                            y: Math.round(parent.height / 2 - (fontMetrics.ascent + ink.y + ink.height / 2))
                            text: ws.modelData.name
                            font.family: "SFRounded Nerd Font Heavy"
                            font.pixelSize: 12
                            color: ws.filled ? Theme.bg : Theme.fg
                            opacity: ws.showIcons ? 0 : 1

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: 150
                                }
                            }

                            FontMetrics {
                                id: fontMetrics
                                font: wsLabel.font
                            }
                        }
                    }

                    // Full bar height click area
                    MouseArea {
                        id: mouse
                        anchors.fill: parent
                        hoverEnabled: true
                        enabled: ws.modelData.canActivate
                        cursorShape: Qt.PointingHandCursor
                        onClicked: ws.modelData.activate()
                    }

                    // App icons, above the pill's click area so each icon can focus its window.
                    Row {
                        anchors.centerIn: parent
                        spacing: 3
                        opacity: ws.showIcons ? 1 : 0
                        visible: opacity > 0

                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                            }
                        }

                        Repeater {
                            model: ws.windows

                            Item {
                                required property var modelData

                                width: ws.iconSize
                                height: ws.iconSize

                                IconImage {
                                    anchors.fill: parent
                                    source: workspaces.iconFor(parent.modelData)
                                    asynchronous: true
                                }

                                // Focused window marker, as in v4.
                                Rectangle {
                                    visible: parent.modelData.activated
                                    anchors.top: parent.bottom
                                    anchors.horizontalCenter: parent.horizontalCenter
                                    width: 5
                                    height: 2
                                    radius: 1
                                    color: ws.filled ? Theme.bg : Theme.accent
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: parent.modelData.wayland?.activate()
                                }
                            }
                        }
                    }
                }
            }
        }

        // Right: widgets
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            // Widgets carry their own padding (Widget.qml), so no extra spacing here.
            spacing: 0

            KeepAwake {
                anchors.verticalCenter: parent.verticalCenter
            }
            Widget {
                id: networkWidget
                anchors.verticalCenter: parent.verticalCenter
                padding: 8 // the neighbouring pills carry their own padding, so these need a bit more
                tooltipRows: network.tooltipRows
                onClicked: Panels.toggleTab(bar.modelData, "wifi")

                Network {
                    id: network
                    detailed: networkWidget.tooltipOpen
                }
            }
            Widget {
                visible: UPower.displayDevice.isLaptopBattery
                anchors.verticalCenter: parent.verticalCenter
                padding: 8
                tooltipRows: battery.tooltipRows

                Battery {
                    id: battery
                }
            }

            // Opens quick settings (v5's control-center button, "settings" glyph as in your config).
            Item {
                readonly property bool active: Panels.quickSettingsScreen === bar.modelData

                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: 27
                implicitHeight: 27

                Rectangle {
                    anchors.fill: parent
                    radius: height / 2
                    color: parent.active ? Theme.accent : settingsMouse.containsMouse ? Theme.surface : "transparent"

                    Behavior on color {
                        ColorAnimation {
                            duration: 150
                        }
                    }
                }

                Icon {
                    anchors.centerIn: parent
                    glyph: Glyphs.settings
                    color: parent.active ? Theme.bg : Theme.fg
                }

                MouseArea {
                    id: settingsMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        // The gear always opens on Home (the tab is otherwise remembered between opens).
                        if (Panels.quickSettingsScreen !== bar.modelData)
                            Panels.tab = "home";
                        Panels.toggleQuickSettings(bar.modelData);
                    }
                }
            }
        }
    }
}
