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

    RowLayout {
        id: mainRow
        anchors.left: parent.left
        anchors.top: parent.top
        spacing: Tokens.spacing.large

        // Local Time Hero Card
        StyledRect {
            implicitWidth: 460
            implicitHeight: 320
            color: Colours.tPalette.m3surfaceContainer
            radius: Tokens.rounding.large

            ColumnLayout {
                anchors.centerIn: parent
                spacing: Tokens.spacing.large

                MaterialIcon {
                    Layout.alignment: Qt.AlignHCenter
                    text: "schedule"
                    fontStyle: Tokens.font.icon.builders.extraLarge.scale(2.5).build()
                    color: Colours.palette.m3primary
                }

                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatTime(root.currentTime, "hh:mm:ss")
                    font: Tokens.font.display.builders.large.scale(1.5).build()
                    color: Colours.palette.m3onSurface
                }
                
                StyledText {
                    Layout.alignment: Qt.AlignHCenter
                    text: Qt.formatDate(root.currentTime, "dddd, MMMM d")
                    font: Tokens.font.headline.builders.small.build()
                    color: Colours.palette.m3onSurfaceVariant
                }
            }
        }

        // Timer Card
        StyledRect {
            implicitWidth: 460
            implicitHeight: 320
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
                        implicitSize: 180
                        strokeWidth: 12
                        spacing: 0
                        fgColour: root.timerRemaining === 0 ? Colours.palette.m3error : Colours.palette.m3primary
                        bgColour: Colours.palette.m3surfaceVariant
                        value: root.timerRemaining / root.timerDefault

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: Tokens.spacing.small

                            // Minus Button
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

                            // Plus Button
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

                // Controls
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: Tokens.spacing.large

                    // Start/Pause Button
                    StyledRect {
                        implicitWidth: 120
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
                        implicitWidth: 120
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
