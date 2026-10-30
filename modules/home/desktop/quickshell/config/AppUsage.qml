pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// How often each app was launched (for "most used" ordering) and which apps are pinned.
// Persisted as JSON in Quickshell's state dir.
Singleton {
    id: root

    property var usage: ({}) // desktop entry id -> launch count
    property var pinned: [] // desktop entry ids

    function count(id) {
        return usage[id] ?? 0;
    }

    function isPinned(id) {
        return pinned.includes(id);
    }

    function record(id) {
        const u = Object.assign({}, usage);
        u[id] = (u[id] ?? 0) + 1;
        usage = u;
        save();
    }

    function togglePin(id) {
        pinned = isPinned(id) ? pinned.filter(p => p !== id) : pinned.concat([id]);
        save();
    }

    function save() {
        adapter.usage = usage;
        adapter.pinned = pinned;
        file.writeAdapter();
    }

    FileView {
        id: file
        path: Quickshell.statePath("launcher.json")
        blockLoading: true
        onLoaded: {
            root.usage = adapter.usage ?? {};
            root.pinned = adapter.pinned ?? [];
        }
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter
            property var usage: ({})
            property var pinned: []
        }
    }
}
