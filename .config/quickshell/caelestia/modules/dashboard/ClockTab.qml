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

    // 3. Stopwatch
    property int stopwatchMs: 0
    property int stopwatchSeconds: 0
    property bool stopwatchRunning: false
    Timer {
        id: stopwatchTimer
        interval: 50
        running: root.stopwatchRunning
        repeat: true
        onTriggered: {
            root.stopwatchMs += 50;
            root.stopwatchSeconds = Math.floor(root.stopwatchMs / 1000);
        }
    }

    function getMinutes(seconds) {
        const m = Math.floor(seconds / 60);
        return m < 10 ? "0" + m : m.toString();
    }

    function getSeconds(seconds) {
        const s = seconds % 60;
        return s < 10 ? "0" + s : s.toString();
    }

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        spacing: Tokens.spacing.medium

        // --- Top Hero Card: Local Date & Time ---
        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 140
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
                        font.pixelSize: 56
                        font.weight: Font.Bold
                        color: Colours.palette.m3onSurface
                    }

                    StyledText {
                        Layout.alignment: Qt.AlignBaseline
                        text: "." + Qt.formatTime(root.currentTime, "zzz")
                        font.pixelSize: 26
                        font.weight: Font.DemiBold
                        color: Colours.palette.m3primary
                    }
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                    font.pixelSize: 18
                    font.weight: Font.Medium
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }

        // --- Bottom Row: Countdown Timer & Stopwatch Cards ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            // === 1. Countdown Timer Card ===
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 230
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.small

                    // Header
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: "timer"
                            fontStyle: Tokens.font.icon.small
                            color: root.timerRunning ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            text: qsTr("Countdown Timer")
                            font: Tokens.font.title.medium
                            color: Colours.palette.m3onSurface
                        }
                    }

                    // Digital Cards Display
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium

                        // Minutes Box
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("Minutes")
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StyledRect {
                                implicitWidth: 84
                                implicitHeight: 62
                                color: Colours.tPalette.m3surfaceContainerHigh
                                radius: Tokens.rounding.medium

                                StyledText {
                                    anchors.centerIn: parent
                                    text: root.getMinutes(root.timerRemaining)
                                    font.pixelSize: 32
                                    font.weight: Font.Bold
                                    color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: !root.timerRunning ? Qt.PointingHandCursor : undefined
                                    onWheel: wheel => {
                                        if (!root.timerRunning) {
                                            if (wheel.angleDelta.y > 0) {
                                                root.timerDefault += 60;
                                            } else if (root.timerDefault >= 60) {
                                                root.timerDefault -= 60;
                                            }
                                            root.timerRemaining = root.timerDefault;
                                        }
                                    }
                                    onClicked: {
                                        if (!root.timerRunning) {
                                            root.timerDefault += 60;
                                            root.timerRemaining = root.timerDefault;
                                        }
                                    }
                                }
                            }
                        }

                        // Colon Separator
                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.topMargin: 16
                            text: ":"
                            font.pixelSize: 30
                            font.weight: Font.Bold
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        // Seconds Box
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("Seconds")
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StyledRect {
                                implicitWidth: 84
                                implicitHeight: 62
                                color: Colours.tPalette.m3surfaceContainerHigh
                                radius: Tokens.rounding.medium

                                StyledText {
                                    anchors.centerIn: parent
                                    text: root.getSeconds(root.timerRemaining)
                                    font.pixelSize: 32
                                    font.weight: Font.Bold
                                    color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                }

                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: !root.timerRunning ? Qt.PointingHandCursor : undefined
                                    onWheel: wheel => {
                                        if (!root.timerRunning) {
                                            if (wheel.angleDelta.y > 0) {
                                                root.timerDefault += 10;
                                            } else if (root.timerDefault >= 10) {
                                                root.timerDefault -= 10;
                                            }
                                            root.timerRemaining = root.timerDefault;
                                        }
                                    }
                                    onClicked: {
                                        if (!root.timerRunning) {
                                            root.timerDefault = (root.timerDefault + 10) % 60 + Math.floor(root.timerDefault / 60) * 60;
                                            root.timerRemaining = root.timerDefault;
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Quick Presets / Progress Bar
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 26

                        // When stopped: Quick preset chips
                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.small
                            visible: !root.timerRunning

                            Repeater {
                                model: [
                                    { label: "-1m", delta: -60 },
                                    { label: "+1m", delta: 60 },
                                    { label: "+5m", delta: 300 },
                                    { label: "+15m", delta: 900 }
                                ]
                                delegate: StyledRect {
                                    implicitWidth: 46
                                    implicitHeight: 24
                                    radius: Tokens.rounding.full
                                    color: Colours.palette.m3surfaceVariant

                                    StyledText {
                                        anchors.centerIn: parent
                                        text: modelData.label
                                        font: Tokens.font.label.small
                                        color: Colours.palette.m3onSurfaceVariant
                                    }

                                    StateLayer {
                                        onClicked: {
                                            const newVal = root.timerDefault + modelData.delta;
                                            if (newVal >= 10) {
                                                root.timerDefault = newVal;
                                                root.timerRemaining = root.timerDefault;
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // When running: Clean sleek progress bar
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

            // === 2. Stopwatch Card ===
            StyledRect {
                Layout.fillWidth: true
                implicitHeight: 230
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.large
                    spacing: Tokens.spacing.small

                    // Header
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.small

                        MaterialIcon {
                            text: "pace"
                            fontStyle: Tokens.font.icon.small
                            color: root.stopwatchRunning ? Colours.palette.m3tertiary : Colours.palette.m3onSurfaceVariant
                        }

                        StyledText {
                            text: qsTr("Stopwatch")
                            font: Tokens.font.title.medium
                            color: Colours.palette.m3onSurface
                        }
                    }

                    // Digital Cards Display
                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.medium

                        // Minutes Box
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("Minutes")
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StyledRect {
                                implicitWidth: 84
                                implicitHeight: 62
                                color: Colours.tPalette.m3surfaceContainerHigh
                                radius: Tokens.rounding.medium

                                StyledText {
                                    anchors.centerIn: parent
                                    text: root.getMinutes(root.stopwatchSeconds)
                                    font.pixelSize: 32
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurface
                                }
                            }
                        }

                        // Colon Separator
                        StyledText {
                            Layout.alignment: Qt.AlignVCenter
                            Layout.topMargin: 16
                            text: ":"
                            font.pixelSize: 30
                            font.weight: Font.Bold
                            color: Colours.palette.m3onSurfaceVariant
                        }

                        // Seconds Box
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("Seconds")
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StyledRect {
                                implicitWidth: 84
                                implicitHeight: 62
                                color: Colours.tPalette.m3surfaceContainerHigh
                                radius: Tokens.rounding.medium

                                StyledText {
                                    anchors.centerIn: parent
                                    text: root.getSeconds(root.stopwatchSeconds)
                                    font.pixelSize: 32
                                    font.weight: Font.Bold
                                    color: Colours.palette.m3onSurface
                                }
                            }
                        }

                        // Tenths of a second Box
                        ColumnLayout {
                            Layout.alignment: Qt.AlignHCenter
                            spacing: 2

                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: qsTr("ms")
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            StyledRect {
                                implicitWidth: 44
                                implicitHeight: 62
                                color: Colours.tPalette.m3surfaceContainerHigh
                                radius: Tokens.rounding.medium

                                StyledText {
                                    anchors.centerIn: parent
                                    text: "." + Math.floor((root.stopwatchMs % 1000) / 100)
                                    font.pixelSize: 22
                                    font.weight: Font.Bold
                                    color: root.stopwatchRunning ? Colours.palette.m3tertiary : Colours.palette.m3onSurfaceVariant
                                }
                            }
                        }
                    }

                    // Status Text Row (Matches the 26px height of Timer presets)
                    Item {
                        Layout.fillWidth: true
                        implicitHeight: 26

                        StyledText {
                            anchors.centerIn: parent
                            text: root.stopwatchRunning ? qsTr("Tracking active...") : (root.stopwatchMs > 0 ? qsTr("Paused") : qsTr("Ready"))
                            font: Tokens.font.label.small
                            color: root.stopwatchRunning ? Colours.palette.m3tertiary : Colours.palette.m3onSurfaceVariant
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
                                    root.stopwatchSeconds = 0;
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
