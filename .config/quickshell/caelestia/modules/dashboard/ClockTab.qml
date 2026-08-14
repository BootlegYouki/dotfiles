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
        interval: 30 // Fast update for milliseconds
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
                    text: Qt.formatTime(root.currentTime, "hh:mm:ss.zzz")
                    font: Tokens.font.display.builders.large.size(120).build()
                    color: Colours.palette.m3onSurface
                }
                
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                    font: Tokens.font.headline.builders.small.size(36).build()
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
                implicitHeight: 280
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

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.medium

                            // Minutes
                            ColumnLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: Tokens.spacing.small

                                // Plus Minute
                                StyledRect {
                                    Layout.alignment: Qt.AlignHCenter
                                    opacity: !root.timerRunning ? 1 : 0
                                    enabled: !root.timerRunning
                                    implicitWidth: 32; implicitHeight: 24; radius: Tokens.rounding.small
                                    color: Colours.palette.m3surfaceVariant
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.timerDefault += 60; root.timerRemaining = root.timerDefault; } }
                                    MaterialIcon { anchors.centerIn: parent; text: "expand_less"; color: Colours.palette.m3onSurfaceVariant }
                                    Behavior on opacity { Anim {} }
                                }

                                StyledText { Layout.alignment: Qt.AlignHCenter; text: qsTr("Minutes"); font: Tokens.font.label.small; color: Colours.palette.m3onSurfaceVariant }

                                StyledRect {
                                    implicitWidth: 100
                                    implicitHeight: 100
                                    color: Colours.tPalette.m3surfaceContainerHigh
                                    radius: Tokens.rounding.medium
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: root.getMinutes(root.timerRemaining)
                                        font: Tokens.font.display.builders.large.build()
                                        color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                    }
                                }

                                // Minus Minute
                                StyledRect {
                                    Layout.alignment: Qt.AlignHCenter
                                    opacity: !root.timerRunning ? 1 : 0
                                    enabled: !root.timerRunning
                                    implicitWidth: 32; implicitHeight: 24; radius: Tokens.rounding.small
                                    color: Colours.palette.m3surfaceVariant
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.timerDefault >= 60) { root.timerDefault -= 60; root.timerRemaining = root.timerDefault; } } }
                                    MaterialIcon { anchors.centerIn: parent; text: "expand_more"; color: Colours.palette.m3onSurfaceVariant }
                                    Behavior on opacity { Anim {} }
                                }
                            }

                            StyledText {
                                text: ":"
                                font: Tokens.font.display.builders.large.build()
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            // Seconds
                            ColumnLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: Tokens.spacing.small

                                // Plus Second
                                StyledRect {
                                    Layout.alignment: Qt.AlignHCenter
                                    opacity: !root.timerRunning ? 1 : 0
                                    enabled: !root.timerRunning
                                    implicitWidth: 32; implicitHeight: 24; radius: Tokens.rounding.small
                                    color: Colours.palette.m3surfaceVariant
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { root.timerDefault += 1; root.timerRemaining = root.timerDefault; } }
                                    MaterialIcon { anchors.centerIn: parent; text: "expand_less"; color: Colours.palette.m3onSurfaceVariant }
                                    Behavior on opacity { Anim {} }
                                }

                                StyledText { Layout.alignment: Qt.AlignHCenter; text: qsTr("Seconds"); font: Tokens.font.label.small; color: Colours.palette.m3onSurfaceVariant }

                                StyledRect {
                                    implicitWidth: 100
                                    implicitHeight: 100
                                    color: Colours.tPalette.m3surfaceContainerHigh
                                    radius: Tokens.rounding.medium
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: root.getSeconds(root.timerRemaining)
                                        font: Tokens.font.display.builders.large.build()
                                        color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                                    }
                                }

                                // Minus Second
                                StyledRect {
                                    Layout.alignment: Qt.AlignHCenter
                                    opacity: !root.timerRunning ? 1 : 0
                                    enabled: !root.timerRunning
                                    implicitWidth: 32; implicitHeight: 24; radius: Tokens.rounding.small
                                    color: Colours.palette.m3surfaceVariant
                                    MouseArea { anchors.fill: parent; cursorShape: Qt.PointingHandCursor; onClicked: { if (root.timerDefault >= 1) { root.timerDefault -= 1; root.timerRemaining = root.timerDefault; } } }
                                    MaterialIcon { anchors.centerIn: parent; text: "expand_more"; color: Colours.palette.m3onSurfaceVariant }
                                    Behavior on opacity { Anim {} }
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
                implicitHeight: 280
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

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.medium

                            // Minutes
                            ColumnLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: Tokens.spacing.small

                                StyledText { Layout.alignment: Qt.AlignHCenter; text: qsTr("Minutes"); font: Tokens.font.label.small; color: Colours.palette.m3onSurfaceVariant }

                                StyledRect {
                                    implicitWidth: 100
                                    implicitHeight: 100
                                    color: Colours.tPalette.m3surfaceContainerHigh
                                    radius: Tokens.rounding.medium
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: root.getMinutes(root.stopwatchSeconds)
                                        font: Tokens.font.display.builders.large.build()
                                        color: Colours.palette.m3onSurface
                                    }
                                }
                            }

                            StyledText {
                                text: ":"
                                font: Tokens.font.display.builders.large.build()
                                color: Colours.palette.m3onSurfaceVariant
                            }

                            // Seconds
                            ColumnLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: Tokens.spacing.small

                                StyledText { Layout.alignment: Qt.AlignHCenter; text: qsTr("Seconds"); font: Tokens.font.label.small; color: Colours.palette.m3onSurfaceVariant }

                                StyledRect {
                                    implicitWidth: 100
                                    implicitHeight: 100
                                    color: Colours.tPalette.m3surfaceContainerHigh
                                    radius: Tokens.rounding.medium
                                    StyledText {
                                        anchors.centerIn: parent
                                        text: root.getSeconds(root.stopwatchSeconds)
                                        font: Tokens.font.display.builders.large.build()
                                        color: Colours.palette.m3onSurface
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
