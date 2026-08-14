pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.services

Variants {
    model: Screens.screens

    Scope {
        id: scope

        required property ShellScreen modelData

        PanelWindow {
            id: window

            screen: scope.modelData
            color: "transparent"
            mask: Region {}

            WlrLayershell.layer: WlrLayer.Overlay
            WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
            WlrLayershell.namespace: "caelestia-macro-indicator"

            contentItem.Config.screen: screen.name
            contentItem.Tokens.screen: screen.name

            anchors {
                top: true
                right: true
            }

            margins {
                top: 20
                right: 20
            }

            implicitWidth: pill.implicitWidth + 24
            implicitHeight: pill.implicitHeight + 24
            visible: MacroState.active || pill.opacity > 0.01

            Item {
                id: pillContainer

                anchors.fill: parent

                StyledRect {
                    id: pill

                    readonly property bool isActive: MacroState.active

                    anchors.top: parent.top
                    anchors.right: parent.right
                    anchors.margins: 6

                    opacity: isActive ? 1.0 : 0.0
                    transform: Translate {
                        x: pill.isActive ? 0 : 40
                        Behavior on x {
                            NumberAnimation {
                                duration: 250
                                easing.type: Easing.OutCubic
                            }
                        }
                    }

                    Behavior on opacity {
                        NumberAnimation {
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }

                    implicitWidth: contentRow.implicitWidth + Tokens.padding.large * 2
                    implicitHeight: contentRow.implicitHeight + Tokens.padding.medium * 2

                    radius: Tokens.rounding.large
                    color: Colours.tPalette.m3surfaceContainer
                    border.color: Qt.alpha(Colours.palette.m3outlineVariant, 0.4)
                    border.width: 1

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowBlur: 16
                        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.45)
                        shadowVerticalOffset: 4
                    }

                    RowLayout {
                        id: contentRow

                        anchors.centerIn: parent
                        spacing: Tokens.spacing.medium

                        // Icon badge with pulsing ring matching Caelestia primary color
                        Item {
                            implicitWidth: 34
                            implicitHeight: 34

                            Rectangle {
                                id: iconBg
                                anchors.fill: parent
                                radius: Tokens.rounding.medium
                                color: Qt.alpha(Colours.palette.m3primary, 0.15)
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: Tokens.rounding.medium
                                color: "transparent"
                                border.color: Colours.palette.m3primary
                                border.width: 1.5

                                SequentialAnimation on opacity {
                                    running: pill.isActive
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.25; to: 0.9; duration: 900; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 0.9; to: 0.25; duration: 900; easing.type: Easing.InOutSine }
                                }

                                SequentialAnimation on scale {
                                    running: pill.isActive
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.96; to: 1.06; duration: 900; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 1.06; to: 0.96; duration: 900; easing.type: Easing.InOutSine }
                                }
                            }

                            MaterialIcon {
                                anchors.centerIn: parent
                                animate: true
                                text: "sports_esports"
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.builders.medium.weight(Font.Bold).build()
                            }
                        }

                        // Text Column matching dashboard typography
                        ColumnLayout {
                            spacing: 1

                            StyledText {
                                text: qsTr("Auto-Loot Active")
                                font: Tokens.font.title.small
                                color: Colours.palette.m3primary
                            }

                            StyledText {
                                text: qsTr("F-Spamming • Ctrl+F to stop")
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }

                        // Active ON badge using M3 primary container tokens
                        StyledRect {
                            implicitWidth: onLabel.implicitWidth + 14
                            implicitHeight: onLabel.implicitHeight + 6
                            radius: Tokens.rounding.small
                            color: Colours.palette.m3primaryContainer

                            StyledText {
                                id: onLabel
                                anchors.centerIn: parent
                                text: "ON"
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onPrimaryContainer
                            }
                        }
                    }
                }
            }
        }
    }
}
