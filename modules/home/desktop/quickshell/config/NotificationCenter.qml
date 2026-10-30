pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Notifications

// The desktop notification daemon (org.freedesktop.Notifications). Live notifications are tracked
// and shown as popups by NotificationPopups; every notification is also kept in `history` (in
// memory only: it's gone when the shell restarts) for the control center's Notifications tab.
Singleton {
    id: root

    // Do not disturb: no popups (critical ones still show), history keeps filling.
    property bool dnd: false

    // Newest first: { id, appName, icon, summary, body, urgency, time }.
    property var history: []
    readonly property int maxHistory: 100

    // Notifications currently on screen (an ObjectModel of Notification).
    readonly property var popups: server.trackedNotifications

    function remove(id) {
        history = history.filter(e => e.id !== id);
    }

    function clear() {
        history = [];
        for (const n of server.trackedNotifications.values)
            n.dismiss();
    }

    // Icon URL for a notification: its own icon, else its desktop entry's, else "".
    function iconUrl(n) {
        const icon = n.appIcon || (n.desktopEntry ? DesktopEntries.heuristicLookup(n.desktopEntry)?.icon : "") || "";
        if (!icon)
            return "";
        if (icon.startsWith("/") || icon.startsWith("file:") || icon.startsWith("image:"))
            return icon;
        return Quickshell.iconPath(icon, true); // "" when the theme has no such icon
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        bodySupported: true
        bodyMarkupSupported: true
        imageSupported: true
        persistenceSupported: true

        onNotification: n => {
            if (!n.transient)
                root.history = [
                    {
                        id: n.id,
                        appName: n.appName,
                        icon: root.iconUrl(n),
                        summary: n.summary,
                        body: n.body,
                        urgency: n.urgency,
                        time: Date.now()
                    }
                ].concat(root.history).slice(0, root.maxHistory);
            // Untracked notifications are closed right away, which is how do-not-disturb hides them.
            if (!root.dnd || n.urgency === NotificationUrgency.Critical)
                n.tracked = true;
        }
    }
}
