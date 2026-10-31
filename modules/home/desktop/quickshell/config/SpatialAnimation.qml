import QtQuick

// Movement and size: the M3 spatial spring. Set `duration` to Motion.spatialFast / spatialSlow to change it.
NumberAnimation {
    duration: Motion.spatialDefault
    easing.type: Easing.BezierSpline
    easing.bezierCurve: Motion.spring
}
