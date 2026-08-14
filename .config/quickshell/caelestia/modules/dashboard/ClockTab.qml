import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    implicitWidth: mainRow.implicitWidth
    implicitHeight: mainRow.implicitHeight

    // Current time property
    property var currentTime: new Date()

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    // Countdown Timer logic
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

    function formatTime(seconds) {
        const m = Math.floor(seconds / 60);
        const s = seconds % 60;
        return (m < 10 ? "0" + m : m) + ":" + (s < 10 ? "0" + s : s);
    }

    function getOffsetTime(offsetHours) {
        const utcMs = root.currentTime.getTime() + (root.currentTime.getTimezoneOffset() * 60000);
        const targetMs = utcMs + (3600000 * offsetHours);
        const targetDate = new Date(targetMs);
        return Qt.formatTime(targetDate, "hh:mm");
    }

    RowLayout {
        id: mainRow
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: Tokens.spacing.large

        // Left Column (Clocks)
        ColumnLayout {
            Layout.alignment: Qt.AlignTop
            spacing: Tokens.spacing.large

            // Hero Local Clock
            StyledRect {
                implicitWidth: 460
                implicitHeight: 160
                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large

                RowLayout {
                    anchors.fill: parent
                    anchors.margins: Tokens.padding.extraLarge
                    spacing: Tokens.spacing.extraLarge

                    MaterialIcon {
                        text: "schedule"
                        fontStyle: Tokens.font.icon.builders.extraLarge.scale(2.5).build()
                        color: Colours.palette.m3primary
                    }

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 0

                        StyledText {
                            text: Qt.formatTime(root.currentTime, "hh:mm:ss")
                            font: Tokens.font.display.builders.large.scale(1.2).build()
                            color: Colours.palette.m3onSurface
                        }
                        StyledText {
                            text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                            font: Tokens.font.headline.builders.small.build()
                            color: Colours.palette.m3onSurfaceVariant
                        }
                    }
                }
            }

            // World Clocks Row
            RowLayout {
                implicitWidth: 460
                spacing: Tokens.spacing.large

                Repeater {
                    model: [
                        { name: "New York", offset: -4, icon: "public" },
                        { name: "London", offset: 1, icon: "public" },
                        { name: "Tokyo", offset: 9, icon: "public" }
                    ]
                    delegate: StyledRect {
                        Layout.fillWidth: true
                        implicitHeight: 120
                        color: Colours.tPalette.m3surfaceContainer
                        radius: Tokens.rounding.large

                        ColumnLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.small

                            RowLayout {
                                Layout.alignment: Qt.AlignHCenter
                                spacing: Tokens.spacing.small

                                MaterialIcon {
                                    text: modelData.icon
                                    fontStyle: Tokens.font.icon.medium
                                    color: Colours.palette.m3secondary
                                }
                                StyledText {
                                    text: modelData.name
                                    font: Tokens.font.title.medium
                                    color: Colours.palette.m3onSurfaceVariant
                                }
                            }
                            
                            StyledText {
                                Layout.alignment: Qt.AlignHCenter
                                text: root.getOffsetTime(modelData.offset)
                                font: Tokens.font.headline.large
                                color: Colours.palette.m3onSurface
                            }
                        }
                    }
                }
            }
        }

        // Right Column (Timer)
        StyledRect {
            Layout.alignment: Qt.AlignTop
            implicitWidth: 320
            implicitHeight: 320 // Square layout like other widgets
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

                // Circular Progress Timer
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    CircularProgress {
                        anchors.centerIn: parent
                        implicitSize: 160
                        strokeWidth: 12
                        spacing: 0
                        fgColour: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3primary
                        bgColour: Colours.palette.m3surfaceVariant
                        value: root.timerRemaining / root.timerDefault

                        StyledText {
                            anchors.centerIn: parent
                            text: root.formatTime(root.timerRemaining)
                            font: Tokens.font.headline.large
                            color: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3onSurface
                        }
                    }
                }

                // Controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Tokens.spacing.large

                    // Start/Pause Button
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

                    // Reset Button
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
    }
}
