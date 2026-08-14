pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Caelestia.Config
import qs.components
import qs.services
import qs.utils

WlSessionLockSurface {
    id: root

    required property WlSessionLock lock
    required property Pam pam

    readonly property alias unlocking: unlockAnim.running
    readonly property bool isExcluded: Strings.testRegexList(Config.bar.excludedScreens, root.screen?.name)
    readonly property int screenHeight: root.screen?.height || 1080

    contentItem.Config.screen: screen.name
    contentItem.Tokens.screen: screen.name

    color: Colours.palette.m3surface

    Connections {
        function onUnlock(): void {
            initAnim.stop();
            unlockAnim.start();
        }

        function onLockedChanged(): void {
            if (root.lock.locked) {
                unlockAnim.stop();
                initAnim.restart();
            }
        }

        target: root.lock
    }

    SequentialAnimation {
        id: unlockAnim

        ParallelAnimation {
            Anim {
                target: lockContent
                properties: "implicitWidth,implicitHeight"
                to: lockContent.size
            }
            Anim {
                target: lockBg
                property: "radius"
                to: lockContent.radius
            }
            Anim {
                target: content
                property: "scale"
                to: 0
            }
            Anim {
                target: content
                property: "opacity"
                to: 0
                type: Anim.StandardSmall
            }
            Anim {
                target: lockIcon
                property: "opacity"
                to: 1
                type: Anim.StandardLarge
            }
            Anim {
                target: background
                property: "opacity"
                to: 0
                type: Anim.StandardLarge
            }
            SequentialAnimation {
                PauseAnimation {
                    duration: Tokens.anim.durations.small
                }
                Anim {
                    type: Anim.Standard
                    target: lockContent
                    property: "opacity"
                    to: 0
                }
            }
        }
        PropertyAction {
            target: root.lock
            property: "locked"
            value: false
        }
    }

    ParallelAnimation {
        id: initAnim

        running: true

        Anim {
            target: background
            property: "opacity"
            to: 1
            type: Anim.StandardLarge
        }
        Anim {
            target: lockContent
            property: "scale"
            to: 1
            type: Anim.FastSpatial
        }
        Anim {
            type: Anim.DefaultEffects
            target: lockIcon
            property: "opacity"
            to: 0
        }
        Anim {
            type: Anim.DefaultEffects
            target: content
            property: "opacity"
            to: 1
        }
        Anim {
            target: content
            property: "scale"
            to: 1
        }
        Anim {
            target: lockContent
            property: "opacity"
            to: 1
            type: Anim.FastSpatial
        }
        Anim {
            target: lockBg
            property: "radius"
            to: Tokens.rounding.extraLarge * 1.5
        }
        Anim {
            target: lockContent
            property: "implicitWidth"
            to: root.screenHeight * Tokens.sizes.lock.heightMult * Tokens.sizes.lock.ratio
        }
        Anim {
            target: lockContent
            property: "implicitHeight"
            to: root.screenHeight * Tokens.sizes.lock.heightMult
        }
    }

    Rectangle {
        anchors.fill: parent
        color: Colours.palette.m3surface
    }

    ScreencopyView {
        id: background

        anchors.fill: parent
        captureSource: root.screen
        opacity: 0

        layer.enabled: true
        layer.effect: MultiEffect {
            autoPaddingEnabled: false
            blurEnabled: true
            blur: 1
            blurMax: 64
            blurMultiplier: 1
        }
    }

    Item {
        id: lockContent

        readonly property int size: lockIcon.implicitHeight + Tokens.padding.large * 4
        readonly property int radius: size / 4 * Tokens.rounding.scale

        anchors.centerIn: parent
        implicitWidth: size
        implicitHeight: size

        visible: !root.isExcluded
        rotation: 0

        StyledRect {
            id: lockBg

            anchors.fill: parent
            color: Colours.palette.m3surface
            radius: parent.radius
            opacity: Colours.transparency.enabled ? Colours.transparency.base : 1

            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                blurMax: 15
                shadowColor: Qt.alpha(Colours.palette.m3shadow, 0.7)
            }
        }

        MaterialIcon {
            id: lockIcon

            anchors.centerIn: parent
            text: "lock"
            fontStyle: Tokens.font.icon.builders.extraLarge.scale(4).weight(Font.Bold).build()
            rotation: 0
        }

        Content {
            id: content

            anchors.centerIn: parent
            width: root.screenHeight * Tokens.sizes.lock.heightMult * Tokens.sizes.lock.ratio - Tokens.padding.extraLargeIncreased
            height: root.screenHeight * Tokens.sizes.lock.heightMult - Tokens.padding.extraLargeIncreased

            lock: root
            opacity: 1
        }
    }
}
