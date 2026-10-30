import QtQuick

// One system stat in Noctalia v5 style: icon, thin vertical meter, value.
// Colour blends from the text colour to red between the activity and critical thresholds.
Row {
    id: root

    required property int icon // Tabler code point (see Icon.qml)
    required property real value // in the same unit as the thresholds
    required property real fraction // meter fill, 0..1
    required property string label
    required property real activity
    required property real critical

    // v5's gradient: jump to a 25% tint when crossing `activity`, then ramp to full at `critical`.
    readonly property real factor: value <= activity ? 0
        : value >= critical ? 1
        : 0.25 + 0.75 * (value - activity) / (critical - activity)
    readonly property color color: Qt.rgba(
        Theme.fg.r + (Theme.critical.r - Theme.fg.r) * factor,
        Theme.fg.g + (Theme.critical.g - Theme.fg.g) * factor,
        Theme.fg.b + (Theme.critical.b - Theme.fg.b) * factor, 1)

    spacing: 4

    Icon {
        anchors.verticalCenter: parent.verticalCenter
        glyph: root.icon
        color: root.color
    }

    // Meter: track is the fill colour at 30%, fill grows from the bottom.
    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: 3
        height: 13
        radius: width / 2
        color: Qt.alpha(root.color, 0.3)

        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: Math.round(parent.height * Math.max(0, Math.min(1, root.fraction)))
            radius: width / 2
            color: root.color
        }
    }

    Text {
        anchors.verticalCenter: parent.verticalCenter
        text: root.label
        font.family: Theme.font
        font.pixelSize: Theme.fontSize
        color: root.color
    }
}
