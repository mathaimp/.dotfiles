import QtQuick
import QtQuick.Layouts

// The launcher itself (Noctalia v4 layout): search field, category tabs (hidden while searching),
// and the application list. Only exists while the launcher is open, so every open starts fresh.
Rectangle {
    id: root

    property int maxHeight: 600

    property string query: ""
    property string category: Apps.categories.includes("Pinned") ? "Pinned" : "all"
    property int selected: 0

    readonly property var results: Apps.results(query, category)
    readonly property bool searching: query.trim() !== ""

    width: 500
    height: Math.min(600, maxHeight)
    radius: 12
    color: Qt.alpha(Theme.bg, 0.97)
    border.width: 1
    border.color: Theme.surface

    focus: true

    onQueryChanged: selected = 0
    onCategoryChanged: selected = 0

    function move(delta) {
        const n = results.length;
        if (n > 0)
            selected = ((selected + delta) % n + n) % n;
    }

    function jump(index) {
        selected = Math.max(0, Math.min(results.length - 1, index));
    }

    function cycleCategory(delta) {
        const cats = Apps.categories;
        category = cats[((cats.indexOf(category) + delta) % cats.length + cats.length) % cats.length];
    }

    function activate() {
        const app = results[selected];
        if (app)
            Apps.launch(app);
    }

    function close() {
        Panels.launcherScreen = null;
    }

    // Returns true when the key was handled.
    function handleKey(event) {
        const ctrl = event.modifiers & Qt.ControlModifier;
        switch (event.key) {
        case Qt.Key_Escape:
            close();
            return true;
        case Qt.Key_Return:
        case Qt.Key_Enter:
            activate();
            return true;
        case Qt.Key_Down:
        case Qt.Key_Tab:
            move(1);
            return true;
        case Qt.Key_Up:
        case Qt.Key_Backtab:
            move(-1);
            return true;
        case Qt.Key_PageDown:
            jump(selected + 7);
            return true;
        case Qt.Key_PageUp:
            jump(selected - 7);
            return true;
        case Qt.Key_J:
        case Qt.Key_N:
            if (ctrl) {
                move(1);
                return true;
            }
            return false;
        case Qt.Key_K:
        case Qt.Key_P:
            if (ctrl) {
                move(-1);
                return true;
            }
            return false;
        case Qt.Key_Left:
        case Qt.Key_Right:
            // With nothing typed, left/right switch category tabs.
            if (!searching && input.text === "") {
                cycleCategory(event.key === Qt.Key_Right ? 1 : -1);
                return true;
            }
            return false;
        }
        return false;
    }

    // Swallow clicks so they don't reach the close-on-outside-click area.
    MouseArea {
        anchors.fill: parent
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        Rectangle {
            Layout.fillWidth: true
            implicitHeight: 40
            radius: 8
            color: Theme.surface

            Icon {
                id: searchIcon
                anchors.left: parent.left
                anchors.leftMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                glyph: 0xEB1C // search
                color: Qt.alpha(Theme.fg, 0.6)
            }

            TextInput {
                id: input
                anchors.left: searchIcon.right
                anchors.right: parent.right
                anchors.leftMargin: 10
                anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                font.family: Theme.font
                font.pixelSize: 15
                color: Theme.fg
                clip: true
                selectByMouse: true
                focus: true
                onTextChanged: root.query = text
                Keys.onPressed: event => event.accepted = root.handleKey(event)
                Component.onCompleted: forceActiveFocus()

                Text {
                    visible: !input.text
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Search applications…"
                    font: input.font
                    color: Qt.alpha(Theme.fg, 0.5)
                }
            }
        }

        // Category tabs, only while not searching.
        Rectangle {
            Layout.fillWidth: true
            visible: !root.searching && Apps.categories.length > 1
            implicitHeight: 40
            radius: 8
            color: Theme.container
            border.width: 1
            border.color: Theme.surface

            Row {
                anchors.centerIn: parent
                spacing: 4

                Repeater {
                    model: Apps.categories

                    IconButton {
                        required property string modelData

                        glyph: Apps.categoryIcons[modelData] ?? Apps.categoryIcons.Misc
                        glyphSize: 16
                        implicitWidth: 32
                        implicitHeight: 30
                        variant: root.category === modelData ? "tabActive" : "tab"
                        onClicked: root.category = modelData
                    }
                }
            }
        }

        ListView {
            id: list

            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 4
            model: root.results
            currentIndex: root.selected
            boundsBehavior: Flickable.StopAtBounds
            onCurrentIndexChanged: positionViewAtIndex(currentIndex, ListView.Contain)

            delegate: LauncherRow {
                width: ListView.view.width
                selected: index === root.selected
                onHovered: root.selected = index
                onActivated: {
                    root.selected = index;
                    root.activate();
                }
            }

            Text {
                anchors.centerIn: parent
                visible: root.results.length === 0
                text: root.searching ? "No matching applications" : root.category === "Pinned" ? "Nothing pinned yet" : "No applications"
                font.family: Theme.font
                font.pixelSize: 14
                color: Qt.alpha(Theme.fg, 0.7)
            }
        }
    }
}
