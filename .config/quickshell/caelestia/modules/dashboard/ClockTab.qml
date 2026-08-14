import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    implicitWidth: Math.max(content.implicitWidth, 300)
    implicitHeight: content.implicitHeight

    // Current time property
    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    // Countdown Timer logic
    property int timerRemaining: 300 // 5 minutes (in seconds)
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

    function formatTime(seconds) {
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    function getTimeInZone(tz) {
        try {
            return new Intl.DateTimeFormat('en-US', {
                timeZone: tz,
                hour: '2-digit',
                minute: '2-digit',
                hour12: true
            }).format(root.currentTime);
        } catch (e) {
            return "--:--";
        }
    }

    ColumnLayout {
        id: content
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: Tokens.spacing.large

        // --- Current Local Time Card ---
        StyledRect {
            Layout.fillWidth: true
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large
            implicitHeight: 120

            ColumnLayout {
                anchors.centerIn: parent
                spacing: 0

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDateTime(root.currentTime, "hh:mm:ss")
                    font: Tokens.font.display.builders.large.build()
                    color: Colours.palette.m3primary
                }
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                    font: Tokens.font.body.medium
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }

        // --- World Clocks (Timezones) ---
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.medium

            Repeater {
                model: [
                    { name: "New York", tz: "America/New_York", icon: "public" },
                    { name: "London", tz: "Europe/London", icon: "public" },
                    { name: "Tokyo", tz: "Asia/Tokyo", icon: "public" }
                ]
                delegate: StyledRect {
                    Layout.fillWidth: true
                    color: Colours.tPalette.m3surfaceContainer
                    radius: Tokens.rounding.medium
                    implicitHeight: 80

                    ColumnLayout {
                        anchors.centerIn: parent
                        spacing: Tokens.spacing.extraSmall

                        MaterialIcon {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.icon
                            fontStyle: Tokens.font.icon.small
                            color: Colours.palette.m3secondary
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: root.getTimeInZone(modelData.tz)
                            font: Tokens.font.title.medium
                            color: Colours.palette.m3onSurface
                        }
                        StyledText {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            font: Tokens.font.body.small
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }
            }
        }

        // --- Countdown Timer Card ---
        StyledRect {
            Layout.fillWidth: true
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large
            implicitHeight: 140

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.spacing.medium

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: qsTr("Timer")
                    font: Tokens.font.title.small
                    color: Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: root.formatTime(root.timerRemaining)
                    font: Tokens.font.display.builders.medium.build()
                    color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                }

                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Tokens.spacing.medium

                    // Start/Stop Button
                    StyledRect {
                        implicitWidth: 100
                        implicitHeight: 40
                        radius: Tokens.rounding.medium
                        color: root.timerRunning ? Colours.palette.m3secondaryContainer : Colours.palette.m3primaryContainer

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                if (root.timerRemaining === 0) root.timerRemaining = root.timerDefault;
                                root.timerRunning = !root.timerRunning;
                            }
                        }

                        StyledText {
                            anchors.centerIn: parent
                            text: root.timerRunning ? qsTr("Pause") : qsTr("Start")
                            font: Tokens.font.label.large
                            color: root.timerRunning ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onPrimaryContainer
                        }
                    }

                    // Reset Button
                    StyledRect {
                        implicitWidth: 100
                        implicitHeight: 40
                        radius: Tokens.rounding.medium
                        color: Colours.palette.m3surfaceVariant

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.timerRunning = false;
                                root.timerRemaining = root.timerDefault;
                            }
                        }

                        StyledText {
                            anchors.centerIn: parent
                            text: qsTr("Reset")
                            font: Tokens.font.label.large
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }
            }
        }
    }
}
