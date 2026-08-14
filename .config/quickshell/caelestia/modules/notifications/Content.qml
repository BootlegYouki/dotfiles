pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Widgets
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.containers
import qs.components.widgets
import qs.services
import qs.modules.utilities as Utilities

Item {
    id: root

    required property ScreenState screenState
    required property Item osdPanel
    required property Item sessionPanel
    required property Item utilitiesPanel
    readonly property int padding: Tokens.padding.large
    readonly property int clampedPadding: CUtils.clamp(padding - Config.border.thickness, 0, padding)

    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.right: parent.right

    implicitWidth: Tokens.sizes.notifs.width
    implicitHeight: {
        const count = list.count;
        const macroHeight = (MacroState.active || macroItem.visible) ? (macroItem.nonAnimHeight + (count > 0 ? Tokens.spacing.medium : 0)) : 0;
        if (count === 0 && macroHeight === 0)
            return 0;

        let height = macroHeight + (count > 0 ? (count - 1) * Tokens.spacing.medium : 0);
        for (let i = 0; i < count; i++)
            height += (list.itemAtIndex(i) as NotifWrapper)?.nonAnimHeight ?? 0;

        if (screenState.osd) {
            const h = osdPanel.y - clampedPadding;
            if (height > h)
                height = h;
        }

        if (screenState.session) {
            const h = sessionPanel.y - clampedPadding;
            if (height > h)
                height = h;
        }

        if (screenState.utilities) {
            const h = ((QsWindow.window as QsWindow)?.screen.height ?? 0) - (utilitiesPanel as Utilities.Wrapper).nonAnimHeight - Config.border.thickness * 2 - padding * 2 - Tokens.spacing.extraLarge;
            if (height > h)
                height = h;
        }

        return Math.min(((QsWindow.window as QsWindow)?.screen?.height ?? 0) + padding - clampedPadding * 2 - Config.border.thickness, height + padding + clampedPadding);
    }

    ClippingWrapperRectangle {
        anchors.fill: parent
        anchors.margins: root.padding
        anchors.topMargin: root.clampedPadding
        anchors.rightMargin: root.clampedPadding

        color: "transparent"
        radius: Tokens.rounding.large

        Item {
            id: container
            anchors.fill: parent

            MacroItem {
                id: macroItem
                anchors.top: parent.top
                implicitWidth: root.implicitWidth - root.padding - root.clampedPadding
            }

            StyledListView {
                id: list

                model: ScriptModel {
                    values: Notifs.popups.filter(n => !n.closed)
                }

                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: macroItem.visible ? macroItem.bottom : parent.top
                anchors.topMargin: (macroItem.visible && list.count > 0) ? Tokens.spacing.medium : 0
                anchors.bottom: parent.bottom

                orientation: Qt.Vertical
                spacing: 0
                cacheBuffer: (QsWindow.window as QsWindow)?.screen.height ?? 0

                delegate: NotifWrapper {}

                move: Transition {
                    Anim {
                        property: "y"
                    }
                }

                displaced: Transition {
                    Anim {
                        property: "y"
                    }
                }

                ExtraIndicator {
                    anchors.top: parent.top
                    extra: {
                        const count = list.count;
                        if (count === 0)
                            return 0;

                        const scrollY = list.contentY;

                        let height = 0;
                        for (let i = 0; i < count; i++) {
                            height += ((list.itemAtIndex(i) as NotifWrapper)?.nonAnimHeight ?? 0) + Tokens.spacing.medium;

                            if (height - Tokens.spacing.medium >= scrollY)
                                return i;
                        }

                        return count;
                    }
                }

                ExtraIndicator {
                    anchors.bottom: parent.bottom
                    extra: {
                        const count = list.count;
                        if (count === 0)
                            return 0;

                        const scrollY = list.contentHeight - (list.contentY + list.height);

                        let height = 0;
                        for (let i = count - 1; i >= 0; i--) {
                            height += ((list.itemAtIndex(i) as NotifWrapper)?.nonAnimHeight ?? 0) + Tokens.spacing.medium;

                            if (height - Tokens.spacing.medium >= scrollY)
                                return count - i - 1;
                        }

                        return 0;
                    }
                }
            }
        }
    }

    Behavior on implicitHeight {
        Anim {}
    }

    component MacroItem: Item {
        id: mRoot

        readonly property bool isActive: MacroState.active
        readonly property int nonAnimHeight: notifCard.implicitHeight

        visible: isActive || opacity > 0.001
        implicitHeight: isActive ? nonAnimHeight : 0
        opacity: isActive ? 1 : 0

        Behavior on implicitHeight {
            Anim {}
        }

        Behavior on opacity {
            Anim {}
        }

        ClippingRectangle {
            id: clipRect

            anchors.fill: parent
            color: "transparent"
            radius: notifCard.radius
            implicitWidth: notifCard.implicitWidth
            implicitHeight: notifCard.implicitHeight

            StyledRect {
                id: notifCard

                color: Colours.tPalette.m3surfaceContainer
                radius: Tokens.rounding.large
                implicitWidth: mRoot.implicitWidth
                implicitHeight: innerContent.implicitHeight + innerContent.anchors.margins * 2

                x: mRoot.isActive ? 0 : implicitWidth

                Behavior on x {
                    Anim {
                        easing: Tokens.anim.emphasizedDecel
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: MacroState.toggle()

                    Item {
                        id: innerContent

                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                        anchors.margins: Tokens.padding.medium

                        implicitHeight: Math.max(appIconBadge.implicitHeight, summaryText.implicitHeight + bodyText.implicitHeight + Tokens.spacing.extraSmall)

                        StyledRect {
                            id: appIconBadge

                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            radius: Tokens.rounding.full
                            color: Colours.palette.m3secondaryContainer
                            implicitWidth: TokenConfig.sizes.notifs.image
                            implicitHeight: TokenConfig.sizes.notifs.image

                            MaterialIcon {
                                anchors.centerIn: parent
                                anchors.verticalCenterOffset: 1
                                text: "sports_esports"
                                color: Colours.palette.m3onSecondaryContainer
                                fontStyle: Tokens.font.icon.medium
                            }
                        }

                        StyledText {
                            id: summaryText

                            anchors.top: parent.top
                            anchors.left: appIconBadge.right
                            anchors.leftMargin: Tokens.spacing.medium

                            animate: !GameMode.enabled
                            text: qsTr("Auto-Loot Active")
                            color: Colours.palette.m3onSurface
                            font: Tokens.font.title.small
                        }

                        StyledText {
                            id: dotSep

                            anchors.top: parent.top
                            anchors.left: summaryText.right
                            anchors.leftMargin: Tokens.spacing.small

                            text: "•"
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.body.small
                        }

                        StyledText {
                            id: timeLabel

                            anchors.top: parent.top
                            anchors.left: dotSep.right
                            anchors.leftMargin: Tokens.spacing.small

                            animate: !GameMode.enabled
                            text: qsTr("now")
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.body.small
                        }

                        StyledText {
                            id: bodyText

                            anchors.left: summaryText.left
                            anchors.right: parent.right
                            anchors.rightMargin: Tokens.padding.extraSmall
                            anchors.top: summaryText.bottom
                            anchors.topMargin: Tokens.spacing.extraSmall

                            animate: !GameMode.enabled
                            text: qsTr("F-Spamming • Ctrl+F to stop")
                            color: Colours.palette.m3onSurfaceVariant
                            font: Tokens.font.body.small
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }
    }

    component NotifWrapper: Item {
        id: wrapper

        required property NotifData modelData
        required property int index
        readonly property alias nonAnimHeight: notif.nonAnimHeight
        property int idx

        onIndexChanged: {
            if (index !== -1)
                idx = index;
        }

        implicitWidth: notif.implicitWidth
        implicitHeight: notif.implicitHeight + (idx === 0 ? 0 : Tokens.spacing.medium)

        ListView.onRemove: removeAnim.start()

        SequentialAnimation {
            id: removeAnim

            PropertyAction {
                target: wrapper
                property: "ListView.delayRemove"
                value: true
            }
            PropertyAction {
                target: wrapper
                property: "enabled"
                value: false
            }
            PropertyAction {
                target: wrapper
                property: "implicitHeight"
                value: 0
            }
            PropertyAction {
                target: wrapper
                property: "z"
                value: 1
            }
            Anim {
                target: notif
                property: "x"
                to: (notif.x >= 0 ? root.implicitWidth : -root.implicitWidth) * 2
                duration: GameMode.enabled ? 0 : Tokens.anim.durations.normal
                easing: Tokens.anim.emphasized
            }
            PropertyAction {
                target: wrapper
                property: "ListView.delayRemove"
                value: false
            }
        }

        ClippingRectangle {
            anchors.top: parent.top
            anchors.topMargin: wrapper.idx === 0 ? 0 : Tokens.spacing.medium

            color: "transparent"
            radius: notif.radius
            implicitWidth: notif.implicitWidth
            implicitHeight: notif.implicitHeight

            Notification {
                id: notif

                modelData: wrapper.modelData
                implicitWidth: root.implicitWidth - root.padding - root.clampedPadding
            }
        }
    }

    component Anim: NumberAnimation {
        duration: GameMode.enabled ? 0 : Tokens.anim.durations.expressiveDefaultSpatial
        easing: Tokens.anim.expressiveDefaultSpatial
    }
}
