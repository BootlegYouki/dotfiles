pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import Quickshell.Services.Pipewire
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services
import qs.utils

ColumnLayout {
    id: root

    required property PopoutState popouts

    width: 260
    spacing: Tokens.spacing.medium

    Process {
        id: restartAudioProc
        command: ["/home/youki/.local/bin/restart-audio"]
        running: false
    }

    // Header Row with Title and Settings button
    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        StyledText {
            text: qsTr("Audio")
            font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            color: Colours.palette.m3onSurface
        }

        Item { Layout.fillWidth: true }
    }

    // Output Volume Section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small / 2

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: qsTr("Volume")
                font: Tokens.font.body.builders.small.build()
                color: Colours.palette.m3onSurfaceVariant
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: Audio.muted ? qsTr("Muted") : `${Math.round(Audio.volume * 100)}%`
                font: Tokens.font.body.builders.small.weight(Font.Medium).build()
                color: Audio.muted ? Colours.palette.m3error : Colours.palette.m3primary

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Audio.sink?.audio)
                            Audio.sink.audio.muted = !Audio.muted;
                    }
                }
            }
        }

        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: 36

            onWheel: event => {
                if (event.angleDelta.y > 0)
                    Audio.incrementVolume();
                else if (event.angleDelta.y < 0)
                    Audio.decrementVolume();
            }

            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 36

                showValueOnMove: true
                orientation: Qt.Horizontal
                icon: Icons.getVolumeIcon(Audio.volume, Audio.muted)
                from: 0.0
                to: 1.0
                value: Audio.volume

                onMoved: Audio.setVolume(value)
            }
        }
    }

    // Microphone Section
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small / 2

        RowLayout {
            Layout.fillWidth: true

            StyledText {
                text: qsTr("Microphone")
                font: Tokens.font.body.builders.small.build()
                color: Colours.palette.m3onSurfaceVariant
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: Audio.sourceMuted ? qsTr("Muted") : `${Math.round(Audio.sourceVolume * 100)}%`
                font: Tokens.font.body.builders.small.weight(Font.Medium).build()
                color: Audio.sourceMuted ? Colours.palette.m3error : Colours.palette.m3primary

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (Audio.source?.audio)
                            Audio.source.audio.muted = !Audio.sourceMuted;
                    }
                }
            }
        }

        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: 36

            onWheel: event => {
                if (event.angleDelta.y > 0)
                    Audio.incrementSourceVolume();
                else if (event.angleDelta.y < 0)
                    Audio.decrementSourceVolume();
            }

            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 36

                showValueOnMove: true
                orientation: Qt.Horizontal
                icon: Icons.getMicVolumeIcon(Audio.sourceVolume, Audio.sourceMuted)
                from: 0.0
                to: 1.0
                value: Audio.sourceVolume

                onMoved: Audio.setSourceVolume(value)
            }
        }
    }

    // Restart Audio Button
    IconTextButton {
        Layout.fillWidth: true
        Layout.topMargin: Tokens.spacing.extraSmall
        inactiveColour: Colours.tPalette.m3surfaceContainerHigh
        inactiveOnColour: Colours.palette.m3onSurface
        verticalPadding: Tokens.padding.extraSmall
        text: qsTr("Restart audio")
        icon: "restart_alt"

        onClicked: restartAudioProc.running = true
    }
}
