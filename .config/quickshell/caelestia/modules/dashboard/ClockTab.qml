import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    implicitWidth: mainLayout.implicitWidth
    implicitHeight: mainLayout.implicitHeight

    // 1. Current Time
    property var currentTime: new Date()
    Timer {
        interval: 1000
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
    property int stopwatchSeconds: 0
    property bool stopwatchRunning: false
    Timer {
        id: stopwatchTimer
        interval: 1000
        running: root.stopwatchRunning
        repeat: true
        onTriggered: {
            root.stopwatchSeconds++;
        }
    }

    function formatTime(seconds) {
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    ColumnLayout {
        id: mainLayout
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: Tokens.spacing.large

        // Top Row: Local Time Hero Card
        StyledRect {
            Layout.fillWidth: true
            implicitHeight: 180
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.spacing.small
                
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatTime(root.currentTime, "hh:mm:ss")
                    font: Tokens.font.display.builders.large.scale(2.5).build()
                    color: Colours.palette.m3onSurface
                }
                
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                    font: Tokens.font.headline.builders.small.scale(1.5).build()
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }

        // Bottom Row: Timer and Stopwatch
        RowLayout {
            spacing: Tokens.spacing.large

            // 2. Countdown Timer Card
            StyledRect {
                implicitWidth: 360
                implicitHeight: 360
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.extraLarge
                    spacing: Tokens.spacing.large

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Countdown Timer")
                        font: Tokens.font.title.large
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        CircularProgress {
                            anchors.centerIn: parent
                            implicitSize: 180
                            strokeWidth: 12
                            spacing: 0
                            fgColour: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3primary
                            bgColour: Colours.palette.m3surfaceVariant
                            value: root.timerRemaining / root.timerDefault

                            RowLayout {
                                anchors.centerIn: parent
                                spacing: Tokens.spacing.small

                                // Minus Button (Edit)
                                StyledRect {
                                    visible: !root.timerRunning
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    radius: 16
                                    color: Colours.palette.m3surfaceVariant
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            if (root.timerDefault > 60) {
                                                root.timerDefault -= 60;
                                                root.timerRemaining = root.timerDefault;
                                            }
                                        }
                                    }
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "remove"
                                        color: Colours.palette.m3onSurfaceVariant
                                    }
                                }

                                StyledText {
                                    text: root.formatTime(root.timerRemaining)
                                    font: Tokens.font.headline.large
                                    color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                }

                                // Plus Button (Edit)
                                StyledRect {
                                    visible: !root.timerRunning
                                    implicitWidth: 32
                                    implicitHeight: 32
                                    radius: 16
                                    color: Colours.palette.m3surfaceVariant
                                    MouseArea {
                                        anchors.fill: parent
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: {
                                            root.timerDefault += 60;
                                            root.timerRemaining = root.timerDefault;
                                        }
                                    }
                                    MaterialIcon {
                                        anchors.centerIn: parent
                                        text: "add"
                                        color: Colours.palette.m3onSurfaceVariant
                                    }
                                }
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.large

                        StyledRect {
                            implicitWidth: 100
                            implicitHeight: 45
                            radius: Tokens.rounding.large
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

                        StyledRect {
                            implicitWidth: 100
                            implicitHeight: 45
                            radius: Tokens.rounding.large
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

            // 3. Stopwatch Card
            StyledRect {
                implicitWidth: 360
                implicitHeight: 360
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.extraLarge
                    spacing: Tokens.spacing.large

                    StyledText {
                        Layout.alignment: Qt.AlignHCenter
                        text: qsTr("Stopwatch")
                        font: Tokens.font.title.large
                        color: Colours.palette.m3onSurfaceVariant
                    }

                    Item {
                        Layout.fillWidth: true
                        Layout.fillHeight: true

                        CircularProgress {
                            anchors.centerIn: parent
                            implicitSize: 180
                            strokeWidth: 12
                            spacing: 0
                            fgColour: Colours.palette.m3tertiary
                            bgColour: Colours.palette.m3surfaceVariant
                            value: root.stopwatchSeconds === 0 ? 1.0 : (root.stopwatchSeconds % 60) / 60

                            Behavior on value {
                                enabled: root.stopwatchRunning
                                NumberAnimation { duration: 1000 }
                            }

                            StyledText {
                                anchors.centerIn: parent
                                text: root.formatTime(root.stopwatchSeconds)
                                font: Tokens.font.headline.large
                                color: Colours.palette.m3onSurface
                            }
                        }
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: Tokens.spacing.large

                        StyledRect {
                            implicitWidth: 100
                            implicitHeight: 45
                            radius: Tokens.rounding.large
                            color: root.stopwatchRunning ? Colours.palette.m3secondaryContainer : Colours.palette.m3tertiaryContainer
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: root.stopwatchRunning = !root.stopwatchRunning
                            }
                            StyledText {
                                anchors.centerIn: parent
                                text: root.stopwatchRunning ? qsTr("Pause") : qsTr("Start")
                                font: Tokens.font.label.large
                                color: root.stopwatchRunning ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onTertiaryContainer
                            }
                        }

                        StyledRect {
                            implicitWidth: 100
                            implicitHeight: 45
                            radius: Tokens.rounding.large
                            color: Colours.palette.m3surfaceVariant
                            MouseArea {
                                anchors.fill: parent
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    root.stopwatchRunning = false;
                                    root.stopwatchSeconds = 0;
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
}
