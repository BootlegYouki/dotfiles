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
                    color: Colours.layer(Colours.palette.m3surfaceContainer, 2)
                    border.color: Colours.palette.m3outlineVariant
                    border.width: 1

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowBlur: 16
                        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.6)
                        shadowVerticalOffset: 4
                    }

                    RowLayout {
                        id: contentRow

                        anchors.centerIn: parent
                        spacing: Tokens.spacing.medium

                        // Icon badge matching Notification appIcon circular badge
                        StyledRect {
                            implicitWidth: 36
                            implicitHeight: 36
                            radius: Tokens.rounding.full
                            color: Colours.palette.m3primaryContainer

                            MaterialIcon {
                                anchors.centerIn: parent
                                animate: true
                                text: "sports_esports"
                                color: Colours.palette.m3onPrimaryContainer
                                fontStyle: Tokens.font.icon.medium
                            }
                        }

                        // Text Column with crisp Material 3 typography
                        ColumnLayout {
                            spacing: 1

                            StyledText {
                                text: qsTr("Auto-Loot Active")
                                font: Tokens.font.title.small
                                color: Colours.palette.m3onSurface
                            }

                            StyledText {
                                text: qsTr("F-Spamming • Ctrl+F to stop")
                                font: Tokens.font.body.small
                                color: Colours.palette.m3onSurfaceVariant
                            }
                        }

                        // Status Badge
                        StyledRect {
                            implicitWidth: onLabel.implicitWidth + 14
                            implicitHeight: onLabel.implicitHeight + 6
                            radius: Tokens.rounding.full
                            color: Colours.palette.m3primary

                            StyledText {
                                id: onLabel
                                anchors.centerIn: parent
                                text: "ON"
                                font: Tokens.font.label.small
                                color: Colours.palette.m3onPrimary
                            }
                        }
                    }
                }
            }
        }
    }
}
