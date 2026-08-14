pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.components.containers
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

            anchors {
                top: true
                right: true
            }

            margins {
                top: 16
                right: 16
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
                    anchors.margins: 8

                    opacity: isActive ? 1.0 : 0.0
                    transform: Translate {
                        x: pill.isActive ? 0 : 50
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

                    implicitWidth: contentRow.implicitWidth + Tokens.padding.medium * 2
                    implicitHeight: contentRow.implicitHeight + Tokens.padding.small * 2

                    radius: Tokens.rounding.large
                    color: Colours.layer(Colours.palette.m3surfaceContainerHigh, 2)
                    border.color: Qt.alpha(Colours.palette.m3primary, 0.4)
                    border.width: 1

                    layer.enabled: true
                    layer.effect: MultiEffect {
                        shadowEnabled: true
                        shadowBlur: 15
                        shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.6)
                        shadowVerticalOffset: 4
                    }

                    RowLayout {
                        id: contentRow

                        anchors.centerIn: parent
                        spacing: Tokens.spacing.medium

                        // Icon badge with pulsing ring
                        Item {
                            implicitWidth: 32
                            implicitHeight: 32

                            Rectangle {
                                id: iconBg
                                anchors.fill: parent
                                radius: width / 2
                                color: Qt.alpha(Colours.palette.m3primary, 0.15)
                            }

                            Rectangle {
                                anchors.fill: parent
                                radius: width / 2
                                color: "transparent"
                                border.color: Colours.palette.m3primary
                                border.width: 1.5

                                SequentialAnimation on opacity {
                                    running: pill.isActive
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.3; to: 1.0; duration: 900; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 1.0; to: 0.3; duration: 900; easing.type: Easing.InOutSine }
                                }

                                SequentialAnimation on scale {
                                    running: pill.isActive
                                    loops: Animation.Infinite
                                    NumberAnimation { from: 0.95; to: 1.08; duration: 900; easing.type: Easing.InOutSine }
                                    NumberAnimation { from: 1.08; to: 0.95; duration: 900; easing.type: Easing.InOutSine }
                                }
                            }

                            MaterialIcon {
                                anchors.centerIn: parent
                                text: "sports_esports"
                                color: Colours.palette.m3primary
                                fontStyle: Tokens.font.icon.builders.medium.weight(Font.Bold).build()
                            }
                        }

                        // Text Column
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

                        // Active ON badge
                        StyledRect {
                            implicitWidth: onLabel.implicitWidth + 12
                            implicitHeight: onLabel.implicitHeight + 6
                            radius: Tokens.rounding.small
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
