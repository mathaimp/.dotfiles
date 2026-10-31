pragma Singleton
import QtQuick
import Quickshell

// Motion tokens from the Material 3 springs in the Hyprland config (mass 1 for all):
//   spatial (movement, size)  fast 600/49   default 300/35   slow 160/25   stiffness/damping
//   effects (colour, opacity) fast 3800/123 default 1600/80  slow 800/57
// Every one is critically damped (damping = 2 * sqrt(stiffness)), so there is no overshoot and they
// all share one step response: x(t) = 1 - (1 + wt) e^(-wt), w = sqrt(stiffness). QML has no
// physical spring on a Behavior, so that curve is fitted by a cubic Bezier (rms error 0.5%) and
// stretched to the time the spring takes to get within 5% of its target, 4.74 / w (the rest is
// imperceptible, and running it out makes everything feel slow).
Singleton {
    readonly property var spring: [0.225, 0.15, 0.175, 1, 1, 1]

    readonly property int spatialFast: 194
    readonly property int spatialDefault: 274
    readonly property int spatialSlow: 375

    readonly property int effectsFast: 77
    readonly property int effectsDefault: 118
    readonly property int effectsSlow: 168

    // Layers (panels, popups), Hyprland's md3_standard and md3_emphasized_accel Beziers.
    readonly property var standard: [0.2, 0, 0, 1, 1, 1]
    readonly property var emphasizedAccel: [0.3, 0, 0.8, 0.15, 1, 1]
    readonly property int layerIn: 300
    readonly property int layerOut: 250

    // Windows pop in from this scale ("popin 92%").
    readonly property real popinScale: 0.92
}
