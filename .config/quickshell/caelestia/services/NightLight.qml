pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled: false
    property int temp: 4000

    function toggle(): void {
        if (enabled) {
            enabled = false;
            applyTimer.stop();
            Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset"]);
        } else {
            enabled = true;
            applyTemp();
        }
    }

    function setTemperature(newTemp: int, immediate: bool): void {
        temp = Math.max(2000, Math.min(6500, newTemp));
        if (enabled) {
            if (immediate) {
                applyTemp();
            } else {
                applyTimer.restart();
            }
        }
    }

    function applyTemp(): void {
        if (enabled) {
            applyTimer.stop();
            Quickshell.execDetached(["sh", "-c", "hyprctl hyprsunset temperature " + temp + " 2>/dev/null || (pkill -x hyprsunset 2>/dev/null; sleep 0.1; hyprsunset -t " + temp + " >/dev/null 2>&1 &)"]);
        }
    }

    Timer {
        id: applyTimer
        interval: 20
        repeat: false
        onTriggered: root.applyTemp()
    }

    Process {
        id: procCheck
        command: ["sh", "-c", "pgrep -x hyprsunset"]
        running: true
        onExited: (code) => {
            root.enabled = (code === 0);
        }
    }

    Timer {
        id: checkTimer
        interval: 2000
        repeat: true
        running: true
        onTriggered: {
            if (!procCheck.running) {
                procCheck.running = true;
            }
        }
    }

    IpcHandler {
        function isEnabled(): bool {
            return root.enabled;
        }

        function toggle(): void {
            root.toggle();
        }

        function setTemp(t: int): void {
            root.setTemperature(t, true);
        }

        target: "nightLight"
    }
}
