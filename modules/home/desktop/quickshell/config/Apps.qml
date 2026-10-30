pragma Singleton
import QtQuick
import Quickshell

// Installed applications for the launcher: category tabs, fuzzy search and launching.
// Follows Noctalia v4's applications provider.
Singleton {
    id: root

    // Terminal used for Terminal=true entries (Quickshell's execute() doesn't open one).
    property var terminal: ["ghostty", "-e"]

    readonly property var entries: {
        const seen = new Set();
        return DesktopEntries.applications.values.filter(app => {
            if (!app || app.noDisplay || !app.name || seen.has(app.id))
                return false;
            seen.add(app.id);
            return true;
        });
    }

    // Tab order and icons as in v4; Pinned and "all" come first.
    readonly property var categoryOrder: ["AudioVideo", "Chat", "Development", "Education", "Game", "Graphics", "Network", "Office", "System", "WebBrowser", "Misc"]
    readonly property var categoryIcons: ({
            all: Glyphs.apps,
            Pinned: Glyphs.pin,
            AudioVideo: Glyphs.music,
            Chat: Glyphs.messageCircle,
            Development: Glyphs.code,
            Education: Glyphs.school,
            Game: Glyphs.gamepad,
            Graphics: Glyphs.brush,
            Network: Glyphs.wifi,
            Office: Glyphs.fileText,
            System: Glyphs.deviceDesktop,
            WebBrowser: Glyphs.world,
            Misc: Glyphs.dots
        })
    readonly property var categoryNames: ({
            all: "All",
            Pinned: "Pinned",
            AudioVideo: "Audio & Video",
            Chat: "Chat",
            Development: "Development",
            Education: "Education",
            Game: "Games",
            Graphics: "Graphics",
            Network: "Network",
            Office: "Office",
            System: "System",
            WebBrowser: "Web",
            Misc: "Other"
        })

    // Each app lives in exactly one category tab (v4's mapping).
    function categoryOf(app) {
        const has = c => (app.categories ?? []).includes(c);
        if (has("AudioVideo") || has("Audio") || has("Video"))
            return "AudioVideo";
        if (has("Chat") || has("InstantMessaging"))
            return "Chat";
        if (has("WebBrowser"))
            return "WebBrowser";
        if (has("Science") || has("Education"))
            return "Education";
        if (has("Settings") || has("Utility") || has("System"))
            return "System";
        return ["Game", "Development", "Graphics", "Office", "Network"].find(has) ?? "Misc";
    }

    // Tabs to show: Pinned (if anything is pinned), All, then the categories that have apps.
    readonly property var categories: {
        const present = new Set(entries.map(categoryOf));
        const list = ["all"].concat(categoryOrder.filter(c => present.has(c)));
        return entries.some(a => AppUsage.isPinned(a.id)) ? ["Pinned"].concat(list) : list;
    }

    function execName(app) {
        return (app.command?.[0] ?? "").split("/").pop().toLowerCase();
    }

    // 0 = no match. Exact > prefix > word start > substring > (names only) loose subsequence, e.g.
    // "ffx" for Firefox. The subsequence must start at a word start, or long texts match anything.
    function fieldScore(q, text, fuzzy) {
        const t = (text ?? "").toLowerCase();
        if (!t)
            return 0;
        if (t === q)
            return 100;
        if (t.startsWith(q))
            return 80;
        if (t.includes(" " + q) || t.includes("-" + q))
            return 60;
        if (t.includes(q))
            return 40;
        if (fuzzy && q.length >= 2) {
            for (let start = 0; start < t.length; start++) {
                if (t[start] !== q[0] || (start > 0 && !" -_.".includes(t[start - 1])))
                    continue;
                let i = 1;
                for (let j = start + 1; j < t.length && i < q.length; j++)
                    if (t[j] === q[i])
                        i++;
                if (i === q.length)
                    return 15;
            }
        }
        return 0;
    }

    function score(q, app) {
        return Math.max(fieldScore(q, app.name, true), 0.9 * fieldScore(q, execName(app), true), 0.6 * fieldScore(q, app.genericName), 0.5 * fieldScore(q, (app.keywords ?? []).join(" ")), 0.4 * fieldScore(q, app.comment));
    }

    // Empty query: the category's apps, pinned first, then most used, then by name.
    // Otherwise: the best 20 fuzzy matches across all apps, pinned first.
    function results(query, category) {
        const q = query.trim().toLowerCase();
        const pinned = a => AppUsage.isPinned(a.id);
        if (!q) {
            const list = category === "Pinned" ? entries.filter(pinned) : category === "all" ? entries : entries.filter(a => categoryOf(a) === category);
            return list.slice().sort((a, b) => (pinned(b) - pinned(a)) || (AppUsage.count(b.id) - AppUsage.count(a.id)) || a.name.toLowerCase().localeCompare(b.name.toLowerCase()));
        }
        const scored = entries.map(app => ({
                    app,
                    score: score(q, app)
                })).filter(r => r.score > 0).sort((a, b) => b.score - a.score).slice(0, 20).map(r => r.app);
        return scored.filter(pinned).concat(scored.filter(a => !pinned(a)));
    }

    function launch(app) {
        AppUsage.record(app.id);
        Panels.launcherScreen = null;
        // Let the launcher close (and release keyboard focus) before the app starts.
        Qt.callLater(() => {
            if (app.runInTerminal && app.command)
                Quickshell.execDetached(terminal.concat(app.command));
            else
                app.execute();
        });
    }
}
