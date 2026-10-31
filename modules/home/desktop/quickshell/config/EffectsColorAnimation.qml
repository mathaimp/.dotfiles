import QtQuick

// Colour changes: the M3 effects spring.
ColorAnimation {
    duration: Motion.effectsDefault
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.spring
}
