pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtMultimedia as Media
import Caelestia.Config
import qs.components
import qs.components.controls
import qs.services

ColumnLayout {
    id: root

    property bool cameraActive: false
    property bool slidersExpanded: false

    width: 340
    spacing: Tokens.spacing.small

    // Header Row with Title (No emoji/icon)
    RowLayout {
        Layout.fillWidth: true
        spacing: Tokens.spacing.small

        StyledText {
            text: qsTr("Camera")
            font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
            color: Colours.palette.m3onSurface
        }
        Item { Layout.fillWidth: true }
        StyledText {
            text: root.cameraActive ? qsTr("Active") : qsTr("Click to start")
            font: Tokens.font.label.small
            color: root.cameraActive ? Colours.palette.m3primary : Colours.palette.m3outline
        }
    }

    Media.MediaDevices { id: mediaDevices }
    Media.Camera {
        id: camera
        cameraDevice: mediaDevices.defaultVideoInput
        active: root.visible && root.cameraActive
    }
    Media.CaptureSession {
        camera: camera
        videoOutput: videoOutput
    }
    
    // Interactive Camera Container (Click to toggle on/off)
    StyledRect {
        Layout.fillWidth: true
        Layout.preferredHeight: 190
        color: Colours.palette.m3surfaceContainerHigh
        radius: Tokens.rounding.medium
        clip: true

        StateLayer {
            radius: parent.radius
            color: Colours.palette.m3onSurface
            onClicked: root.cameraActive = !root.cameraActive
        }

        // Placeholder state when camera is disabled
        ColumnLayout {
            anchors.centerIn: parent
            visible: !root.cameraActive
            spacing: Tokens.spacing.small

            MaterialIcon {
                Layout.alignment: Qt.AlignHCenter
                text: "photo_camera"
                fontStyle: Tokens.font.icon.extraLarge
                color: Colours.palette.m3primary
            }

            StyledText {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Click to start camera")
                font: Tokens.font.body.small
                color: Colours.palette.m3onSurfaceVariant
            }
        }

        // Live Video Output
        Media.VideoOutput {
            id: videoOutput
            anchors.fill: parent
            visible: root.cameraActive
            fillMode: Media.VideoOutput.PreserveAspectCrop
        }
    }

    // Expand / Collapse Dropdown Button for Sliders
    StyledRect {
        Layout.fillWidth: true
        implicitHeight: 38
        radius: Tokens.rounding.medium
        color: root.slidersExpanded ? Colours.palette.m3secondaryContainer : Colours.palette.m3surfaceContainerHigh

        StateLayer {
            radius: parent.radius
            color: root.slidersExpanded ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            onClicked: root.slidersExpanded = !root.slidersExpanded
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: Tokens.padding.medium
            anchors.rightMargin: Tokens.padding.medium
            spacing: Tokens.spacing.small

            MaterialIcon {
                text: "tune"
                color: root.slidersExpanded ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3primary
            }

            StyledText {
                Layout.fillWidth: true
                text: qsTr("Adjustments")
                font: Tokens.font.body.builders.medium.weight(Font.Medium).build()
                color: root.slidersExpanded ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurface
            }

            MaterialIcon {
                text: "expand_more"
                color: root.slidersExpanded ? Colours.palette.m3onSecondaryContainer : Colours.palette.m3onSurfaceVariant
                rotation: root.slidersExpanded ? 180 : 0
                Behavior on rotation { Anim {} }
            }
        }
    }

    // All 5 Sliders shown when expanded
    ColumnLayout {
        Layout.fillWidth: true
        visible: root.slidersExpanded
        spacing: Tokens.spacing.small

        Item {
            Layout.fillWidth: true
            implicitHeight: 36
            FilledSlider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                orientation: Qt.Horizontal
                implicitHeight: 36
                showValueOnMove: true
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
                showValueOnMove: true
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
                showValueOnMove: true
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
                showValueOnMove: true
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
                showValueOnMove: true
                icon: "exposure"
                from: 72
                to: 500
                value: CameraSettings.gamma
                onMoved: CameraSettings.setParam("gamma", Math.round(value))
            }
        }
    }
}
