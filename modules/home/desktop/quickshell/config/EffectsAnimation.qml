import QtQuick

// Opacity and other non-spatial numbers: the M3 effects spring.
NumberAnimation {
    duration: Motion.effectsDefault
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.spring
}
