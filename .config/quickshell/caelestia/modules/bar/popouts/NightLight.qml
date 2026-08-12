pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    required property PopoutState popouts

    implicitWidth: layout.implicitWidth + Tokens.padding.medium * 2
    implicitHeight: layout.implicitHeight + Tokens.padding.medium * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacing.medium
        implicitWidth: 260

        // Header Row with Title and Switch
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            RowLayout {
                spacing: Tokens.spacing.small

                MaterialIcon {
                    text: NightLight.enabled ? "bedtime" : "bedtime_off"
                    color: NightLight.enabled ? Colours.palette.m3primary : Colours.palette.m3onSurfaceVariant
                }

                StyledText {
                    text: qsTr("Night Light")
                    font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
                    color: Colours.palette.m3onSurface
                }
            }

            Item { Layout.fillWidth: true }

            StyledSwitch {
                checked: NightLight.enabled
                onClicked: NightLight.toggle()
            }
        }

        // Temperature label and percentage value
        RowLayout {
            Layout.fillWidth: true
            visible: NightLight.enabled

            StyledText {
                text: qsTr("Warmth")
                font: Tokens.font.body.builders.small.build()
                color: Colours.palette.m3onSurfaceVariant
            }

            Item { Layout.fillWidth: true }

            StyledText {
                text: `${Math.round(((6500 - NightLight.temp) / 4500.0) * 100)}%`
                font: Tokens.font.body.builders.small.weight(Font.Medium).build()
                color: Colours.palette.m3primary
            }
        }

        // Horizontal Filled Capsule Slider (matching Caelestia volume/brightness style)
        CustomMouseArea {
            Layout.fillWidth: true
            implicitHeight: 36
            opacity: NightLight.enabled ? 1.0 : 0.38
            enabled: NightLight.enabled

            onWheel: event => {
                let step = 250;
                if (event.angleDelta.y > 0)
                    NightLight.setTemperature(NightLight.temp - step, true);
                else if (event.angleDelta.y < 0)
                    NightLight.setTemperature(NightLight.temp + step, true);
            }

            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                implicitHeight: 36

                showValueOnMove: true
                orientation: Qt.Horizontal
                icon: NightLight.enabled ? "bedtime" : "bedtime_off"
                from: 0.0
                to: 1.0
                value: (6500 - NightLight.temp) / 4500.0

                onMoved: {
                    let targetK = Math.round(6500 - (value * 4500));
                    NightLight.setTemperature(targetK, false);
                }
            }
        }
    }
}
