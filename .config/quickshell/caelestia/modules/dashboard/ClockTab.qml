import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    implicitWidth: 840
    implicitHeight: mainLayout.implicitHeight

    // 1. Current Time (with milliseconds)
    property var currentTime: new Date()
    Timer {
        interval: 30
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    // 2. Countdown Timer
    property int timerRemaining: 300 // 5 minutes
    property int timerDefault: 300
    property bool timerRunning: false
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
            }
        }
    }

    // 3. Stopwatch (Minutes:Seconds.Milliseconds)
    property int stopwatchMs: 0
    property bool stopwatchRunning: false
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

        // --- Top Row: Hero Clock Card + 3 Timezone Cards ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            // 1. Local Time Hero Card
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 150
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: Tokens.spacing.extraSmall

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 4

                        StyledText {
                            text: Qt.formatTime(root.currentTime, "hh:mm:ss")
                            font: Tokens.font.clock.size(44).weight(Font.Medium).build()
                            color: Colours.palette.m3onSurface
                        }

                        StyledText {
                            Layout.alignment: Qt.AlignBaseline
                            text: "." + Qt.formatTime(root.currentTime, "zzz")
                            font: Tokens.font.clock.size(20).weight(Font.Normal).build()
                            color: Colours.palette.m3primary
                        }
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                        font.pixelSize: 16
                        font.weight: Font.Normal
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
            spacing: Tokens.spacing.medium

            // === 1. Countdown Timer Card (HH : MM : SS - Direct Typeable Digits) ===
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 200
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.medium

                    // Direct Editable Digital Cards: HH : MM : SS
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.small

                        // Hours Box
                        StyledRect {
                            implicitWidth: 72
                            implicitHeight: 64
                            color: hoursInput.activeFocus ? Colours.palette.m3surfaceVariant : Colours.tPalette.m3surfaceContainerHigh
                            radius: Tokens.rounding.medium

                            TextInput {
                                id: hoursInput
                                anchors.centerIn: parent
                                font: Tokens.font.clock.size(28).weight(Font.Medium).build()
                                color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                                selectedTextColor: color
                                selectByMouse: true
                                cursorVisible: activeFocus && !root.timerRunning
                                readOnly: root.timerRunning
                                maximumLength: 2
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }

                                text: activeFocus ? text : root.getHours(root.timerRemaining)

                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        selectAll();
                                    } else {
                                        let h = parseInt(text) || 0;
                                        let m = parseInt(minutesInput.text) || 0;
                                        let s = parseInt(secondsInput.text) || 0;
                                        root.timerDefault = h * 3600 + m * 60 + s;
                                        root.timerRemaining = root.timerDefault;
                                    }
                                }

                                onTextEdited: {
                                    if (text.length >= 2) {
                                        minutesInput.forceActiveFocus();
                                        minutesInput.selectAll();
                                    }
                                }

                                onAccepted: {
                                    minutesInput.forceActiveFocus();
                                }
                            }

                            CustomMouseArea {
                                anchors.fill: parent
                                cursorShape: !root.timerRunning ? Qt.IBeamCursor : undefined
                                function onWheel(event: WheelEvent): void {
                                    if (!root.timerRunning) {
                                        if (event.angleDelta.y > 0) {
                                            root.timerDefault += 3600;
                                        } else if (root.timerDefault >= 3600) {
                                            root.timerDefault -= 3600;
                                        }
                                        root.timerRemaining = root.timerDefault;
                                    }
                                }
                                onClicked: {
                                    if (!root.timerRunning) {
                                        hoursInput.forceActiveFocus();
                                        hoursInput.selectAll();
                                    }
                                }
                            }
                        }

                        // Colon Separator
                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: ":"
                            font.pixelSize: 26
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        // Minutes Box
                        StyledRect {
                            implicitWidth: 72
                            implicitHeight: 64
                            color: minutesInput.activeFocus ? Colours.palette.m3surfaceVariant : Colours.tPalette.m3surfaceContainerHigh
                            radius: Tokens.rounding.medium

                            TextInput {
                                id: minutesInput
                                anchors.centerIn: parent
                                font: Tokens.font.clock.size(28).weight(Font.Medium).build()
                                color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                                selectedTextColor: color
                                selectByMouse: true
                                cursorVisible: activeFocus && !root.timerRunning
                                readOnly: root.timerRunning
                                maximumLength: 2
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }

                                text: activeFocus ? text : root.getMinutes(root.timerRemaining)

                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        selectAll();
                                    } else {
                                        let h = parseInt(hoursInput.text) || 0;
                                        let m = parseInt(text) || 0;
                                        let s = parseInt(secondsInput.text) || 0;
                                        root.timerDefault = h * 3600 + m * 60 + s;
                                        root.timerRemaining = root.timerDefault;
                                    }
                                }

                                onTextEdited: {
                                    if (text.length >= 2) {
                                        secondsInput.forceActiveFocus();
                                        secondsInput.selectAll();
                                    }
                                }

                                onAccepted: {
                                    secondsInput.forceActiveFocus();
                                }
                            }

                            CustomMouseArea {
                                anchors.fill: parent
                                cursorShape: !root.timerRunning ? Qt.IBeamCursor : undefined
                                function onWheel(event: WheelEvent): void {
                                    if (!root.timerRunning) {
                                        if (event.angleDelta.y > 0) {
                                            root.timerDefault += 60;
                                        } else if (root.timerDefault >= 60) {
                                            root.timerDefault -= 60;
                                        }
                                        root.timerRemaining = root.timerDefault;
                                    }
                                }
                                onClicked: {
                                    if (!root.timerRunning) {
                                        minutesInput.forceActiveFocus();
                                        minutesInput.selectAll();
                                    }
                                }
                            }
                        }

                        // Colon Separator
                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: ":"
                            font.pixelSize: 26
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        // Seconds Box
                        StyledRect {
                            implicitWidth: 72
                            implicitHeight: 64
                            color: secondsInput.activeFocus ? Colours.palette.m3surfaceVariant : Colours.tPalette.m3surfaceContainerHigh
                            radius: Tokens.rounding.medium

                            TextInput {
                                id: secondsInput
                                anchors.centerIn: parent
                                font: Tokens.font.clock.size(28).weight(Font.Medium).build()
                                color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                selectionColor: Qt.alpha(Colours.palette.m3primary, 0.4)
                                selectedTextColor: color
                                selectByMouse: true
                                cursorVisible: activeFocus && !root.timerRunning
                                readOnly: root.timerRunning
                                maximumLength: 2
                                inputMethodHints: Qt.ImhDigitsOnly
                                validator: RegularExpressionValidator { regularExpression: /[0-9]{1,2}/ }

                                text: activeFocus ? text : root.getSeconds(root.timerRemaining)

                                onActiveFocusChanged: {
                                    if (activeFocus) {
                                        selectAll();
                                    } else {
                                        let h = parseInt(hoursInput.text) || 0;
                                        let m = parseInt(minutesInput.text) || 0;
                                        let s = parseInt(text) || 0;
                                        root.timerDefault = h * 3600 + m * 60 + s;
                                        root.timerRemaining = root.timerDefault;
                                    }
                                }

                                onAccepted: {
                                    focus = false;
                                    let h = parseInt(hoursInput.text) || 0;
                                    let m = parseInt(minutesInput.text) || 0;
                                    let s = parseInt(text) || 0;
                                    root.timerDefault = h * 3600 + m * 60 + s;
                                    root.timerRemaining = root.timerDefault;
                                }
                            }

                            CustomMouseArea {
                                anchors.fill: parent
                                cursorShape: !root.timerRunning ? Qt.IBeamCursor : undefined
                                function onWheel(event: WheelEvent): void {
                                    if (!root.timerRunning) {
                                        if (event.angleDelta.y > 0) {
                                            root.timerDefault += 10;
                                        } else if (root.timerDefault >= 10) {
                                            root.timerDefault -= 10;
                                        }
                                        root.timerRemaining = root.timerDefault;
                                    }
                                }
                                onClicked: {
                                    if (!root.timerRunning) {
                                        secondsInput.forceActiveFocus();
                                        secondsInput.selectAll();
                                    }
                                }
                            }
                        }
                    }

                    // Active Progress Bar / Spacer
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 26

                        StyledProgressBar {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            anchors.margins: Tokens.padding.medium
                            visible: root.timerRunning
                            value: 1.0 - (root.timerRemaining / Math.max(1, root.timerDefault))
                            fgColour: Colours.palette.m3primary
                        }
                    }

                    // Action Buttons
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium

                        StyledRect {
                            implicitWidth: 105
                            implicitHeight: 38
                            radius: Tokens.rounding.full
                            color: root.timerRunning ? Colours.palette.m3secondaryContainer : Colours.palette.m3primary

                            StyledText {
                                anchors.centerIn: parent
                                text: root.timerRunning ? qsTr("Pause") : qsTr("Start")
                                font: Tokens.font.label.large
                                color: root.timerRunning ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onPrimary
                            }

                            StateLayer {
                                onClicked: {
                                    if (root.timerRemaining === 0) root.timerRemaining = root.timerDefault;
                                    root.timerRunning = !root.timerRunning;
                                }
                            }
                        }

                        StyledRect {
                            implicitWidth: 105
                            implicitHeight: 38
                            radius: Tokens.rounding.full
                            color: Colours.palette.m3surfaceVariant

                            StyledText {
                                anchors.centerIn: parent
                                text: qsTr("Reset")
                                font: Tokens.font.label.large
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StateLayer {
                                onClicked: {
                                    root.timerRunning = false;
                                    root.timerRemaining = root.timerDefault;
                                }
                            }
                        }
                    }
                }
            }

            // === 2. Stopwatch Card (MM : SS . MS) ===
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 200
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.medium

                    // Digital Cards Display: MM : SS . MS (No Hours, Continues 60, 61, 62...)
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.small

                        // Minutes Box
                        StyledRect {
                            implicitWidth: 72
                            implicitHeight: 64
                            color: Colours.tPalette.m3surfaceContainerHigh
                            radius: Tokens.rounding.medium

                            StyledText {
                                anchors.centerIn: parent
                                text: root.getStopwatchMinutes(root.stopwatchMs)
                                font: Tokens.font.clock.size(28).weight(Font.Medium).build()
                                color: Colours.palette.m3onSurface
                            }
                        }

                        // Colon Separator
                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: ":"
                            font.pixelSize: 26
                            font.weight: Font.Medium
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        // Seconds Box
                        StyledRect {
                            implicitWidth: 72
                            implicitHeight: 64
                            color: Colours.tPalette.m3surfaceContainerHigh
                            radius: Tokens.rounding.medium

                            StyledText {
                                anchors.centerIn: parent
                                text: root.getStopwatchSeconds(root.stopwatchMs)
                                font: Tokens.font.clock.size(28).weight(Font.Medium).build()
                                color: Colours.palette.m3onSurface
                            }
                        }

                        // Dot Separator
                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            text: "."
                            font.pixelSize: 26
                            font.weight: Font.Bold
                            color: Colours.palette.m3primary
                        }

                        // Milliseconds Box (Hundredths: 00 - 99)
                        StyledRect {
                            implicitWidth: 72
                            implicitHeight: 64
                            color: Colours.tPalette.m3surfaceContainerHigh
                            radius: Tokens.rounding.medium

                            StyledText {
                                anchors.centerIn: parent
                                text: root.getStopwatchMs(root.stopwatchMs)
                                font: Tokens.font.clock.size(28).weight(Font.Medium).build()
                                color: root.stopwatchRunning ? Colours.palette.m3primary : Colours.palette.m3onSurface
                            }
                        }
                    }

                    // Spacer to match progress bar space of timer card
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 26
                    }

                    // Action Buttons
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium

                        StyledRect {
                            implicitWidth: 105
                            implicitHeight: 38
                            radius: Tokens.rounding.full
                            color: root.stopwatchRunning ? Colours.palette.m3secondaryContainer : Colours.palette.m3primary

                            StyledText {
                                anchors.centerIn: parent
                                text: root.stopwatchRunning ? qsTr("Pause") : qsTr("Start")
                                font: Tokens.font.label.large
                                color: root.stopwatchRunning ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onPrimary
                            }

                            StateLayer {
                                onClicked: root.stopwatchRunning = !root.stopwatchRunning
                            }
                        }

                        StyledRect {
                            implicitWidth: 105
                            implicitHeight: 38
                            radius: Tokens.rounding.full
                            color: Colours.palette.m3surfaceVariant

                            StyledText {
                                anchors.centerIn: parent
                                text: qsTr("Reset")
                                font: Tokens.font.label.large
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StateLayer {
                                onClicked: {
                                    root.stopwatchRunning = false;
                                    root.stopwatchMs = 0;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
