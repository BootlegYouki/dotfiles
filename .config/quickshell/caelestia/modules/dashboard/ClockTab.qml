import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    property bool isCompact: false

    implicitWidth: {
        if (!isCompact) return 840;
        if (Timers.timerRunning && Timers.stopwatchRunning) return 540;
        return 260;
    }
    implicitHeight: isCompact ? 76 : mainLayout.implicitHeight

    // Local Current Time (without milliseconds)
    property var currentTime: new Date()
    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    function isDstUs(d) {
        const year = d.getUTCFullYear();
        const march1 = new Date(Date.UTC(year, 2, 1));
        const marchDstDay = 14 - ((march1.getUTCDay() + 6) % 7);
        const marchDst = new Date(Date.UTC(year, 2, marchDstDay, 7));
        const nov1 = new Date(Date.UTC(year, 10, 1));
        const novDstDay = 7 - ((nov1.getUTCDay() + 6) % 7);
        const novDst = new Date(Date.UTC(year, 10, novDstDay, 6));
        return d >= marchDst && d < novDst;
    }

    function isDstEu(d) {
        const year = d.getUTCFullYear();
        const marchLast = new Date(Date.UTC(year, 2, 31));
        const marchDstDay = 31 - marchLast.getUTCDay();
        const marchDst = new Date(Date.UTC(year, 2, marchDstDay, 1));
        const octLast = new Date(Date.UTC(year, 9, 31));
        const octDstDay = 31 - octLast.getUTCDay();
        const octDst = new Date(Date.UTC(year, 9, octDstDay, 1));
        return d >= marchDst && d < octDst;
    }

    function getTzOffset(tz, d) {
        if (tz === "America/New_York") return isDstUs(d) ? -4 : -5;
        if (tz === "Europe/London") return isDstEu(d) ? 1 : 0;
        if (tz === "Asia/Tokyo") return 9;
        return 0;
    }

    function getTzHour(tz) {
        const d = root.currentTime;
        const offset = getTzOffset(tz, d);
        let totalMinutes = d.getUTCHours() * 60 + d.getUTCMinutes() + offset * 60;
        totalMinutes = (totalMinutes % 1440 + 1440) % 1440;
        let h = Math.floor(totalMinutes / 60);
        if (GlobalConfig.services.useTwelveHourClock) {
            h = h % 12 || 12;
        }
        return h < 10 ? "0" + h : h.toString();
    }

    function getTzMinute(tz) {
        const d = root.currentTime;
        const offset = getTzOffset(tz, d);
        let totalMinutes = d.getUTCHours() * 60 + d.getUTCMinutes() + offset * 60;
        totalMinutes = (totalMinutes % 1440 + 1440) % 1440;
        let m = totalMinutes % 60;
        return m < 10 ? "0" + m : m.toString();
    }

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Tokens.spacing.medium

        // --- Top Row: Hero Clock Card + 3 Timezone Cards (Hidden in compact mode) ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium
            visible: !root.isCompact

            // 1. Local Time Hero Card
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 150
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.extraSmall

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatTime(root.currentTime, "hh:mm:ss")
                        font: Tokens.font.clock.size(44).weight(Font.Medium).build()
                        color: Colours.palette.m3onSurface
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                        font: Tokens.font.title.medium
                        color: Colours.palette.m3onSurfaceVariant
                    }
                }
            }

            // 2. Timezone Cards (New York, London, Tokyo)
            Repeater {
                model: [
                    { name: "New York", tz: "America/New_York" },
                    { name: "London", tz: "Europe/London" },
                    { name: "Tokyo", tz: "Asia/Tokyo" }
                ]

                delegate: StyledRect {
                    implicitWidth: 104
                    implicitHeight: 150
                    color: Colours.tPalette.m3surfaceContainer
                    radius: Tokens.rounding.large

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: 0

                        StyledText {
                            Layout.bottomMargin: -(font.pointSize * 0.35)
                            Layout.alignment: Qt.AlignHCenter
                            text: root.getTzHour(modelData.tz)
                            color: Colours.palette.m3secondary
                            font: Tokens.font.clock.size(26).weight(Font.Medium).build()
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: "•••"
                            color: Colours.palette.m3primary
                            font: Tokens.font.clock.size(22).build()
                        }

                        StyledText {
                            Layout.topMargin: -(font.pointSize * 0.35)
                            Layout.alignment: Qt.AlignHCenter
                            text: root.getTzMinute(modelData.tz)
                            color: Colours.palette.m3secondary
                            font: Tokens.font.clock.size(26).weight(Font.Medium).build()
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            Layout.topMargin: Tokens.spacing.small
                            text: modelData.name
                            font: Tokens.font.label.small
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }
            }
        }

        // --- Bottom Row: Countdown Timer & Stopwatch Cards ---
        RowLayout {
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            spacing: Tokens.spacing.medium

            // === 1. Countdown Timer Card ===
            StyledRect {
                id: timerCard
                implicitWidth: root.isCompact ? 260 : 0
                Layout.fillWidth: !root.isCompact
                implicitHeight: root.isCompact ? 76 : 150
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large
                visible: !root.isCompact || Timers.timerRunning

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.medium

                    // Time Digits: [ HH : MM : SS ]
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        TextInput {
                            id: hoursInput
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Timers.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                            selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                            selectedTextColor: color
                            selectByMouse: true
                            renderType: Text.NativeRendering
                            readOnly: Timers.timerRunning
                            cursorVisible: activeFocus && !Timers.timerRunning
                            maximumLength: 2
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }
                            text: Timers.timerRunning ? Timers.getHours(Timers.timerRemaining) : Timers.inputHours

                            onTextEdited: {
                                Timers.inputHours = text;
                                Timers.updateTimerFromInputs();
                                if (text.length >= 2) {
                                    minutesInput.forceActiveFocus();
                                    minutesInput.selectAll();
                                }
                            }

                            onActiveFocusChanged: {
                                if (activeFocus) {
                                    selectAll();
                                } else {
                                    Timers.inputHours = (parseInt(text) || 0).toString().padStart(2, '0');
                                    Timers.updateTimerFromInputs();
                                }
                            }

                            onAccepted: {
                                minutesInput.forceActiveFocus();
                            }
                        }

                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        TextInput {
                            id: minutesInput
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Timers.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                            selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                            selectedTextColor: color
                            selectByMouse: true
                            renderType: Text.NativeRendering
                            readOnly: Timers.timerRunning
                            cursorVisible: activeFocus && !Timers.timerRunning
                            maximumLength: 2
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }
                            text: Timers.timerRunning ? Timers.getMinutes(Timers.timerRemaining) : Timers.inputMinutes

                            onTextEdited: {
                                Timers.inputMinutes = text;
                                Timers.updateTimerFromInputs();
                                if (text.length >= 2) {
                                    secondsInput.forceActiveFocus();
                                    secondsInput.selectAll();
                                }
                            }

                            onActiveFocusChanged: {
                                if (activeFocus) {
                                    selectAll();
                                } else {
                                    Timers.inputMinutes = (parseInt(text) || 0).toString().padStart(2, '0');
                                    Timers.updateTimerFromInputs();
                                }
                            }

                            onAccepted: {
                                secondsInput.forceActiveFocus();
                            }
                        }

                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        TextInput {
                            id: secondsInput
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Timers.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                            selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                            selectedTextColor: color
                            selectByMouse: true
                            renderType: Text.NativeRendering
                            readOnly: Timers.timerRunning
                            cursorVisible: activeFocus && !Timers.timerRunning
                            maximumLength: 2
                            inputMethodHints: Qt.ImhDigitsOnly
                            validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }
                            text: Timers.timerRunning ? Timers.getSeconds(Timers.timerRemaining) : Timers.inputSeconds

                            onTextEdited: {
                                Timers.inputSeconds = text;
                                Timers.updateTimerFromInputs();
                            }

                            onActiveFocusChanged: {
                                if (activeFocus) {
                                    selectAll();
                                } else {
                                    Timers.inputSeconds = (parseInt(text) || 0).toString().padStart(2, '0');
                                    Timers.updateTimerFromInputs();
                                }
                            }

                            onAccepted: {
                                focus = false;
                                Timers.inputSeconds = (parseInt(text) || 0).toString().padStart(2, '0');
                                Timers.updateTimerFromInputs();
                            }
                        }
                    }

                    // Action Buttons (Play/Pause & Reset) - ONLY visible in full dashboard
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium
                        visible: !root.isCompact

                        IconButton {
                            icon: Timers.timerRunning ? "pause" : "play_arrow"
                            type: Timers.timerRunning ? IconButton.Filled : IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.toggleTimer()
                        }

                        IconButton {
                            icon: "replay"
                            type: IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.resetTimer()
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    acceptedButtons: Qt.NoButton
                    cursorShape: !Timers.timerRunning ? Qt.IBeamCursor : undefined
                    onWheel: event => {
                        if (!Timers.timerRunning) {
                            let s = parseInt(Timers.inputSeconds) || 0;
                            if (event.angleDelta.y > 0) {
                                s = (s + 5) % 60;
                            } else if (s >= 5) {
                                s = s - 5;
                            }
                            Timers.inputSeconds = s < 10 ? "0" + s : s.toString();
                            Timers.updateTimerFromInputs();
                        }
                    }
                }
            }

            // === 2. Stopwatch Card ===
            StyledRect {
                id: stopwatchCard
                implicitWidth: root.isCompact ? 260 : 0
                Layout.fillWidth: !root.isCompact
                implicitHeight: root.isCompact ? 76 : 150
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large
                visible: !root.isCompact || Timers.stopwatchRunning

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.medium

                    // Time Digits: [ MM : SS . MS ]
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 8

                        StyledText {
                            text: Timers.getStopwatchMinutes(Timers.stopwatchMs)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: ":"
                            font.pixelSize: 34
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            text: Timers.getStopwatchSeconds(Timers.stopwatchMs)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            text: "."
                            font.pixelSize: 34
                            font.weight: Font.Bold
                            color: Colours.palette.m3primary
                        }

                        StyledText {
                            text: Timers.getStopwatchMs(Timers.stopwatchMs)
                            font: Tokens.font.clock.size(36).weight(Font.Medium).build()
                            color: Timers.stopwatchRunning ? Colours.palette.m3primary : Colours.palette.m3onSurface
                        }
                    }

                    // Action Buttons (Play/Pause & Reset) - ONLY visible in full dashboard
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium
                        visible: !root.isCompact

                        IconButton {
                            icon: Timers.stopwatchRunning ? "pause" : "play_arrow"
                            type: Timers.stopwatchRunning ? IconButton.Filled : IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.toggleStopwatch()
                        }

                        IconButton {
                            icon: "replay"
                            type: IconButton.Tonal
                            isRound: true
                            font: Tokens.font.icon.medium
                            onClicked: Timers.resetStopwatch()
                        }
                    }
                }
            }
        }
    }
}
