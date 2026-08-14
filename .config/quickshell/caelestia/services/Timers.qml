pragma Singleton

import QtQuick
import Quickshell
import Caelestia.Config

Singleton {
    id: root

    // 1. Countdown Timer State
    property int timerRemaining: 300 // 5 minutes
    property int timerDefault: 300
    property bool timerRunning: false
    property string inputHours: "00"
    property string inputMinutes: "05"
    property string inputSeconds: "00"

    // 2. Stopwatch State
    property int stopwatchMs: 0
    property bool stopwatchRunning: false

    // Active state indicator
    readonly property bool hasActive: timerRunning || stopwatchRunning

    Timer {
        id: countdownTimer
        interval: 1000
        running: root.timerRunning
        repeat: true
        onTriggered: {
            if (root.timerRemaining > 0) {
                root.timerRemaining--;
            } else {
                root.timerRunning = false;
                root.syncInputsFromRemaining();
            }
        }
    }

    Timer {
        id: stopwatchTimer
        interval: 30
        running: root.stopwatchRunning
        repeat: true
        onTriggered: {
            root.stopwatchMs += 30;
        }
    }

    function getHours(seconds) {
        const h = Math.floor(seconds / 3600);
        return h < 10 ? "0" + h : h.toString();
    }

    function getMinutes(seconds) {
        const m = Math.floor((seconds % 3600) / 60);
        return m < 10 ? "0" + m : m.toString();
    }

    function getSeconds(seconds) {
        const s = seconds % 60;
        return s < 10 ? "0" + s : s.toString();
    }

    function getStopwatchMinutes(ms) {
        const m = Math.floor(ms / 60000);
        return m < 10 ? "0" + m : m.toString();
    }

    function getStopwatchSeconds(ms) {
        const s = Math.floor((ms % 60000) / 1000);
        return s < 10 ? "0" + s : s.toString();
    }

    function getStopwatchMs(ms) {
        const hundredths = Math.floor((ms % 1000) / 10);
        return hundredths < 10 ? "0" + hundredths : hundredths.toString();
    }

    function syncInputsFromRemaining() {
        inputHours = getHours(timerRemaining);
        inputMinutes = getMinutes(timerRemaining);
        inputSeconds = getSeconds(timerRemaining);
    }

    function updateTimerFromInputs() {
        const h = parseInt(inputHours) || 0;
        const m = parseInt(inputMinutes) || 0;
        const s = parseInt(inputSeconds) || 0;
        timerDefault = h * 3600 + m * 60 + s;
        timerRemaining = timerDefault;
    }

    function toggleTimer() {
        if (!timerRunning) {
            updateTimerFromInputs();
            if (timerRemaining === 0) {
                timerRemaining = timerDefault > 0 ? timerDefault : 300;
                syncInputsFromRemaining();
            }
        }
        timerRunning = !timerRunning;
        if (!timerRunning) {
            syncInputsFromRemaining();
        }
    }

    function resetTimer() {
        timerRunning = false;
        timerRemaining = timerDefault;
        syncInputsFromRemaining();
    }

    function toggleStopwatch() {
        stopwatchRunning = !stopwatchRunning;
    }

    function resetStopwatch() {
        stopwatchRunning = false;
        stopwatchMs = 0;
    }
}
