pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Caelestia.Config
import qs.utils

Singleton {
    id: root

    property var events: []
    property bool loaded: false
    property var currentTime: new Date()

    // Timer to update current time & relative countdowns every 5s
    Timer {
        interval: 5000
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = new Date();
        }
    }

    // Returns active upcoming events sorted by timestamp ascending
    readonly property var upcomingEvents: {
        const now = root.currentTime.getTime();
        return root.events
            .filter(e => !e.completed && e.timestamp > now - 300000)
            .sort((a, b) => a.timestamp - b.timestamp);
    }

    readonly property var nextEvent: upcomingEvents.length > 0 ? upcomingEvents[0] : null

    // Format relative countdown strictly as a countdown (e.g. "in 5m", "in 2h 10m", "in 1d 2h")
    function getRelativeTime(timestamp) {
        const now = root.currentTime.getTime();
        const diffMs = timestamp - now;
        const diffSec = Math.floor(diffMs / 1000);
        const diffMin = Math.floor(diffSec / 60);
        const diffHours = Math.floor(diffMin / 60);
        const diffDays = Math.floor(diffHours / 24);

        if (diffSec < 0) {
            return qsTr("Now");
        } else if (diffMin < 60) {
            return qsTr("in %1m").arg(diffMin <= 0 ? 1 : diffMin);
        } else if (diffHours < 24) {
            const remMin = diffMin % 60;
            return remMin > 0 
                ? qsTr("in %1h %2m").arg(diffHours).arg(remMin)
                : qsTr("in %1h").arg(diffHours);
        } else {
            const remHours = diffHours % 24;
            return remHours > 0
                ? qsTr("in %1d %2h").arg(diffDays).arg(remHours)
                : qsTr("in %1d").arg(diffDays);
        }
    }

    function formatEventTime(timestamp) {
        const date = new Date(timestamp);
        return GlobalConfig.services.useTwelveHourClock 
            ? date.toLocaleTimeString(Qt.locale("en_US"), "h:mm AP")
            : Qt.formatTime(date, "hh:mm");
    }

    function addEvent(title, timestamp) {
        const finalTitle = (title && title.trim().length > 0) ? title.trim() : "Reminder";
        const newEvent = {
            id: Date.now().toString(36) + Math.random().toString(36).substr(2, 5),
            title: finalTitle,
            timestamp: timestamp,
            completed: false
        };
        root.events = [...root.events, newEvent];
        saveEvents();
    }

    function removeEvent(id) {
        root.events = root.events.filter(e => e.id !== id);
        saveEvents();
    }

    function toggleEvent(id) {
        root.events = root.events.map(e => {
            if (e.id === id) {
                return Object.assign({}, e, { completed: !e.completed });
            }
            return e;
        });
        saveEvents();
    }

    function saveEvents() {
        if (root.loaded) {
            storage.setText(JSON.stringify(root.events));
        }
    }

    FileView {
        id: storage
        printErrors: false
        path: `${Paths.state}/events.json`
        onLoaded: {
            try {
                const data = JSON.parse(text());
                if (Array.isArray(data)) {
                    root.events = data;
                }
            } catch (e) {
                root.events = [];
            }
            root.loaded = true;
        }
        onLoadFailed: err => {
            if (err === FileViewError.FileNotFound) {
                root.loaded = true;
                Qt.callLater(() => setText("[]"));
            }
        }
    }
}
