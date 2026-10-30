import QtQuick

// A bar glyph from Noctalia v5's Tabler icon font, at the shared icon size.
// Code points are from Noctalia's assets/fonts/tabler.json.
Text {
    required property int glyph

    text: String.fromCodePoint(glyph)
    font.family: Theme.iconFont
    font.pixelSize: Theme.iconSize
    color: Theme.fg
}
