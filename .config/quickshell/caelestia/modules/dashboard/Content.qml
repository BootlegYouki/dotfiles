pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets
import Caelestia
import Caelestia.Config
import qs.components
import qs.components.filedialog
import qs.services

Item {
    id: root

    required property ScreenState screenState
    required property FileDialog facePicker

    readonly property bool isCompactTimer: !screenState.dashboard && Timers.hasActive

    readonly property var dashboardTabs: {
        const allTabs = [
            {
                component: dashComponent,
                iconName: "dashboard",
                text: qsTr("Dashboard"),
                enabled: Config.dashboard.showDashboard
            },
            {
                component: mediaComponent,
                iconName: "queue_music",
                text: qsTr("Media"),
                enabled: Config.dashboard.showMedia
            },
            {
                component: performanceComponent,
                iconName: "speed",
                text: qsTr("Performance"),
                enabled: Config.dashboard.showPerformance
            },
            {
                component: weatherComponent,
                iconName: "cloud",
                text: qsTr("Weather"),
                enabled: Config.dashboard.showWeather
            },
            {
                component: clockComponent,
                iconName: "schedule",
                text: qsTr("Clock"),
                enabled: true
            }
        ];
        return allTabs.filter(tab => tab.enabled);
    }

    readonly property real nonAnimWidth: isCompactTimer
        ? (compactTimerLoader.item?.implicitWidth ?? 280) + Tokens.padding.large * 2
        : view.implicitWidth + viewWrapper.anchors.margins * 2
    readonly property real nonAnimHeight: isCompactTimer
        ? (compactTimerLoader.item?.implicitHeight ?? 155) + Tokens.padding.large * 2
        : tabs.implicitHeight + tabs.anchors.topMargin + view.implicitHeight + viewWrapper.anchors.margins * 2

    implicitWidth: nonAnimWidth
    implicitHeight: nonAnimHeight

    // 1. Normal Dashboard View (Tabs + Flickable)
    Item {
        id: normalView
        anchors.fill: parent
        visible: !root.isCompactTimer

        Tabs {
            id: tabs

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.topMargin: CUtils.clamp(anchors.margins - Config.border.thickness, 0, anchors.margins)
            anchors.margins: Tokens.padding.large

            nonAnimWidth: root.nonAnimWidth - anchors.margins * 2
            screenState: root.screenState
            tabs: root.dashboardTabs
        }

        ClippingRectangle {
            id: viewWrapper

            anchors.top: tabs.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: Tokens.padding.large

            radius: Tokens.rounding.large
            color: "transparent"

            Flickable {
                id: view

                readonly property int currentIndex: root.screenState.dashboardTab
                readonly property Item currentItem: {
                    repeater.count;
                    return repeater.itemAt(currentIndex);
                }

                anchors.fill: parent
                flickableDirection: Flickable.HorizontalFlick

                implicitWidth: currentItem?.implicitWidth ?? 0
                implicitHeight: currentItem?.implicitHeight ?? 0

                contentX: currentItem?.x ?? 0
                contentWidth: row.implicitWidth
                contentHeight: row.implicitHeight

                onContentXChanged: {
                    if (!moving || !currentItem)
                        return;

                    const x = contentX - currentItem.x;
                    if (x > currentItem.implicitWidth / 2)
                        root.screenState.dashboardTab = Math.min(root.screenState.dashboardTab + 1, tabs.count - 1);
                    else if (x < -currentItem.implicitWidth / 2)
                        root.screenState.dashboardTab = Math.max(root.screenState.dashboardTab - 1, 0);
                }

                onDragEnded: {
                    if (!currentItem)
                        return;

                    const x = contentX - currentItem.x;
                    if (x > currentItem.implicitWidth / 10)
                        root.screenState.dashboardTab = Math.min(root.screenState.dashboardTab + 1, tabs.count - 1);
                    else if (x < -currentItem.implicitWidth / 10)
                        root.screenState.dashboardTab = Math.max(root.screenState.dashboardTab - 1, 0);
                    else
                        contentX = Qt.binding(() => currentItem?.x ?? 0);
                }

                RowLayout {
                    id: row

                    Repeater {
                        id: repeater

                        model: ScriptModel {
                            values: root.dashboardTabs
                        }

                        delegate: Loader {
                            id: paneLoader

                            required property int index
                            required property var modelData

                            Layout.alignment: Qt.AlignTop
                            sourceComponent: modelData.component

                            Component.onCompleted: active = Qt.binding(() => {
                                if (index === view.currentIndex)
                                    return true;
                                const vx = Math.floor(view.visibleArea.xPosition * view.contentWidth);
                                const vex = Math.floor(vx + view.visibleArea.widthRatio * view.contentWidth);
                                return (vx >= x && vx <= x + implicitWidth) || (vex >= x && vex <= x + implicitWidth);
                            })
                        }
                    }
                }

                Behavior on contentX {
                    Anim {}
                }
            }
        }
    }

    // 2. Compact Timer View (Direct, isolated display with zero flickable horizontal shifting)
    Loader {
        id: compactTimerLoader
        anchors.centerIn: parent
        active: root.isCompactTimer
        visible: root.isCompactTimer
        sourceComponent: clockComponent
    }

    Component {
        id: dashComponent

        Dash {
            screenState: root.screenState
            facePicker: root.facePicker
        }
    }

    Component {
        id: mediaComponent

        Media {
            screenState: root.screenState
        }
    }

    Component {
        id: performanceComponent

        Performance {}
    }

    Component {
        id: weatherComponent

        WeatherTab {}
    }

    Component {
        id: clockComponent

        ClockTab {
            screenState: root.screenState
        }
    }

    Behavior on implicitWidth {
        Anim {}
    }

    Behavior on implicitHeight {
        Anim {}
    }
}
