pragma Singleton

import QtQuick
import Quickshell
import Caelestia.Config
import qs.utils

Singleton {
    id: root

    // 1. Countdown Timer State
    property int timerRemaining: 300 // 5 minutes
    property int timerDefault: 300
    property bool timerRunning: false
    property bool isOverdue: false
    property int overdueSeconds: 0
    property string inputHours: "00"
    property string inputMinutes: "05"
    property string inputSeconds: "00"

    // 2. Stopwatch State
    property int stopwatchMs: 0
    property bool stopwatchRunning: false

    // Active state indicator
    readonly property bool hasActive: timerRunning || stopwatchRunning || isOverdue

    Timer {
        id: countdownTimer
        interval: 1000
        running: root.timerRunning || root.isOverdue
        repeat: true
        onTriggered: {
            if (!root.isOverdue) {
                if (root.timerRemaining > 1) {
                    root.timerRemaining--;
                    root.syncInputsFromRemaining();
                } else if (root.timerRemaining === 1) {
                    root.timerRemaining = 0;
                    root.syncInputsFromRemaining();
                    root.isOverdue = true;
                    root.overdueSeconds = 0;

                    // Play haptic vibration sound
                    Quickshell.execDetached(["pw-play", `${Paths.home}/.config/quickshell/caelestia/assets/vibrate.wav`]);
                }
            } else {
                root.overdueSeconds++;
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

    function adjustHours(delta) {
        if (timerRunning) return;
        let h = Math.floor(timerRemaining / 3600);
        let m = Math.floor((timerRemaining % 3600) / 60);
        let s = timerRemaining % 60;
        h = (h + delta + 24) % 24;
        timerDefault = h * 3600 + m * 60 + s;
        timerRemaining = timerDefault;
        syncInputsFromRemaining();
    }

    function adjustMinutes(delta) {
        if (timerRunning) return;
        let h = Math.floor(timerRemaining / 3600);
        let m = Math.floor((timerRemaining % 3600) / 60);
        let s = timerRemaining % 60;
        m = (m + delta + 60) % 60;
        timerDefault = h * 3600 + m * 60 + s;
        timerRemaining = timerDefault;
        syncInputsFromRemaining();
    }

    function adjustSeconds(delta) {
        if (timerRunning) return;
        let h = Math.floor(timerRemaining / 3600);
        let m = Math.floor((timerRemaining % 3600) / 60);
        let s = timerRemaining % 60;
        s = (s + delta + 60) % 60;
        timerDefault = h * 3600 + m * 60 + s;
        timerRemaining = timerDefault;
        syncInputsFromRemaining();
    }

    function toggleTimer() {
        if (isOverdue) {
            resetTimer();
            return;
        }
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
        isOverdue = false;
        overdueSeconds = 0;
        timerRunning = false;
        timerRemaining = timerDefault;
        syncInputsFromRemaining();
    }

    function restartTimer() {
        isOverdue = false;
        overdueSeconds = 0;
        timerRemaining = timerDefault > 0 ? timerDefault : 300;
        syncInputsFromRemaining();
        timerRunning = true;
    }

    function addFiveMinutes() {
        if (isOverdue) {
            isOverdue = false;
            overdueSeconds = 0;
            timerRemaining = 300;
            timerDefault = 300;
            syncInputsFromRemaining();
            timerRunning = true;
        } else {
            timerRemaining += 300;
            timerDefault = Math.max(timerDefault, timerRemaining);
            syncInputsFromRemaining();
            if (!timerRunning) {
                timerRunning = true;
            }
        }
    }

    function setAndStartTimer(seconds) {
        isOverdue = false;
        overdueSeconds = 0;
        timerDefault = seconds;
        timerRemaining = seconds;
        syncInputsFromRemaining();
        timerRunning = true;
    }

    function toggleStopwatch() {
        stopwatchRunning = !stopwatchRunning;
    }

    function resetStopwatch() {
        stopwatchRunning = false;
        stopwatchMs = 0;
    }
}
