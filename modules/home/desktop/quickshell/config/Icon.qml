import QtQuick

// An icon from Glyphs.qml (the Lucide icon font, Theme.iconFont). It occupies a `size` square. The
// glyph itself is scaled per icon (Glyphs.scaleOf) so that icons with different footprints look the
// same size, and it stays centred in the square even where it overflows a little.
Text {
    required property int glyph
    property real size: Theme.iconSize

    width: size
    height: size
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    text: String.fromCodePoint(glyph)
    font.family: Theme.iconFont
    font.pixelSize: Math.round(size * Glyphs.scaleOf(glyph))
    // Lift icons that draw low in their box (Glyphs.dropOf): padding below the text moves it up.
    bottomPadding: 2 * Glyphs.dropOf(glyph) * font.pixelSize
    color: Theme.fg
}
