pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property int brightness: 0
    property int contrast: 32
    property int saturation: 64
    property int sharpness: 3
    property int gamma: 100

    function testCamera(): void {
        Quickshell.execDetached(["sh", "-c", "/home/youki/.config/quickshell/caelestia/utils/camera_ctl.sh test"]);
    }

    function setParam(param: string, val: int): void {
        if (param === "brightness") brightness = val;
        else if (param === "contrast") contrast = val;
        else if (param === "saturation") saturation = val;
        else if (param === "sharpness") sharpness = val;
        else if (param === "gamma") gamma = val;
        
        applyTimer.restart();
    }
    
    // Batch updates to avoid spamming v4l2-ctl
    Timer {
        id: applyTimer
        interval: 50
        repeat: false
        onTriggered: {
            Quickshell.execDetached(["sh", "-c", "v4l2-ctl -d /dev/video0 -c brightness=" + root.brightness + " -c contrast=" + root.contrast + " -c saturation=" + root.saturation + " -c sharpness=" + root.sharpness + " -c gamma=" + root.gamma + " >/dev/null 2>&1"]);
        }
    }

    Process {
        id: procFetch
        command: ["sh", "-c", "/home/youki/.config/quickshell/caelestia/utils/camera_ctl.sh get"]
        running: true
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    const data = JSON.parse(text.trim());
                    root.brightness = data.brightness;
                    root.contrast = data.contrast;
                    root.saturation = data.saturation;
                    root.sharpness = data.sharpness;
                    root.gamma = data.gamma;
                } catch (e) {}
            }
        }
    }
}
