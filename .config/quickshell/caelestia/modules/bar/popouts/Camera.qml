pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia as Media
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

Item {
    id: root

    property bool previewEnabled: false

    implicitWidth: 340
    implicitHeight: layout.implicitHeight + Tokens.padding.medium * 2

    ColumnLayout {
        id: layout

        anchors.left: parent.left
        anchors.verticalCenter: parent.verticalCenter
        spacing: Tokens.spacing.medium

        // Force a wide column layout
        Item {
            Layout.preferredWidth: 340
            Layout.preferredHeight: 0
        }

        // Header Row with Title and Switch
        RowLayout {
            Layout.fillWidth: true
            spacing: Tokens.spacing.small

            RowLayout {
                spacing: Tokens.spacing.small
                MaterialIcon {
                    text: "photo_camera"
                    color: Colours.palette.m3onSurface
                }
                StyledText {
                    text: qsTr("Camera")
                    font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
                    color: Colours.palette.m3onSurface
                }
            }

            Item { Layout.fillWidth: true }

            StyledSwitch {
                checked: root.previewEnabled
                onClicked: root.previewEnabled = !root.previewEnabled
            }
        }

        Media.MediaDevices { id: mediaDevices }
        Media.Camera {
            id: camera
            cameraDevice: mediaDevices.defaultVideoInput
            active: root.visible && root.previewEnabled
        }
        Media.CaptureSession {
            camera: camera
            videoOutput: videoOutput
        }
        
        StyledRect {
            Layout.fillWidth: true
            Layout.preferredHeight: root.previewEnabled ? 190 : 0
            visible: root.previewEnabled
            color: Colours.palette.m3surfaceContainerHigh
            radius: Tokens.rounding.medium
            clip: true

            Media.VideoOutput {
                id: videoOutput
                anchors.fill: parent
                fillMode: Media.VideoOutput.PreserveAspectCrop
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 36
            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                orientation: Qt.Horizontal
                implicitHeight: 36
                icon: "brightness_medium"
                from: -64
                to: 64
                value: CameraSettings.brightness
                onMoved: CameraSettings.setParam("brightness", Math.round(value))
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 36
            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                orientation: Qt.Horizontal
                implicitHeight: 36
                icon: "contrast"
                from: 0
                to: 64
                value: CameraSettings.contrast
                onMoved: CameraSettings.setParam("contrast", Math.round(value))
            }
        }
        
        Item {
            Layout.fillWidth: true
            implicitHeight: 36
            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                orientation: Qt.Horizontal
                implicitHeight: 36
                icon: "palette"
                from: 0
                to: 128
                value: CameraSettings.saturation
                onMoved: CameraSettings.setParam("saturation", Math.round(value))
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 36
            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                orientation: Qt.Horizontal
                implicitHeight: 36
                icon: "change_history"
                from: 0
                to: 6
                value: CameraSettings.sharpness
                onMoved: CameraSettings.setParam("sharpness", Math.round(value))
            }
        }

        Item {
            Layout.fillWidth: true
            implicitHeight: 36
            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                orientation: Qt.Horizontal
                implicitHeight: 36
                icon: "exposure"
                from: 72
                to: 500
                value: CameraSettings.gamma
                onMoved: CameraSettings.setParam("gamma", Math.round(value))
            }
        }
    }
}
