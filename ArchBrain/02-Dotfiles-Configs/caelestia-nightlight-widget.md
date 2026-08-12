# Caelestia Sidebar Night Light Status Icon & Material Design 3 Popout Widget

## 1. Overview & Architecture
This document details the complete implementation of the **Night Light** status bar icon and hover popout control widget integrated into the Caelestia Shell sidebar. 

The feature provides:
- A dedicated **Night Light** status icon in the Caelestia sidebar status bar pill.
- A **Material Design 3 (MD3) Popout Widget** featuring a title, `StyledSwitch` toggle button, live color temperature label (e.g. `3900K`), and a horizontal `FilledSlider` capsule slider with an embedded circular MaterialIcon handle knob.
- **Zero-Flash Live IPC Temperature Updates** using Hyprland's `hyprctl hyprsunset temperature <temp>` Unix domain socket IPC, enabling seamless temperature adjustments (e.g. `4100K` -> `3900K`) without killing the daemon or flashing back to 6500K daylight color.

---

## 2. Key Problem Diagnoses & Technical Solutions

### Problem A: Process Kill Flashing & Reset to 6500K Daylight
- **Symptom**: When adjusting the temperature slider, the screen would briefly flash un-warmed (6500K daylight color) for 150ms before applying the new temperature, or turn off completely.
- **Root Cause**: Previously, changing temperature executed `pkill -x hyprsunset; hyprsunset -t <temp>`. When `hyprsunset` receives `SIGTERM`, its process exit handler immediately clears the color transformation matrix (CTM) back to identity (6500K daylight), causing a visible screen flash. Furthermore, rapid `pkill` calls led to process race conditions where SIGTERM killed newly spawned instances.
- **Solution**: Intercepted `hyprsunset`'s live Unix domain socket IPC using:
  ```bash
  hyprctl hyprsunset temperature <temp>
  ```
  If `hyprctl hyprsunset` succeeds, the color matrix updates instantly on the fly without killing `hyprsunset` or resetting the screen CTM. If `hyprsunset` is not running (e.g. initial toggle ON), the fallback command launches `hyprsunset -t <temp> &`.

### Problem B: Slider Value Animation Fighting Mouse Drag
- **Symptom**: Dragging the slider felt laggy, stuttery, or fought against mouse movement.
- **Root Cause**: `FilledSlider.qml` had a `Behavior on value { Anim { type: Anim.StandardLarge } }` which animated property transitions even during mouse drags.
- **Solution**: Added `enabled: !root.pressed` to `Behavior on value` inside [`FilledSlider.qml`](file:///home/youki/.config/quickshell/caelestia/components/controls/FilledSlider.qml#L131-L136). Handle position tracks mouse dragging 1:1 with zero latency.

### Problem C: Slider Value Display & Knob Handle Percentage Integration
- **User Request**: Display warmth as a percentage (e.g. `53%`) in the header label, and dynamically display the percentage number (e.g. `53`) inside the circular handle knob when dragging—matching Caelestia's native volume and brightness sliders.
- **Solution**: Enabled `showValueOnMove: true` on `FilledSlider` in [`NightLight.qml`](file:///home/youki/.config/quickshell/caelestia/modules/bar/popouts/NightLight.qml#L204). Because percentage numbers (e.g. `53`) are compact, they fit perfectly inside the circular handle knob during drag interactions, while the label displays `Warmth 53%`.

---

## 3. File Implementation & Source Code

### 3.1 Singleton Service (`~/.config/quickshell/caelestia/services/NightLight.qml`)
```qml
pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property bool enabled: false
    property int temp: 4000

    function toggle(): void {
        if (enabled) {
            enabled = false;
            applyTimer.stop();
            Quickshell.execDetached(["sh", "-c", "pkill -x hyprsunset"]);
        } else {
            enabled = true;
            applyTemp();
        }
    }

    function setTemperature(newTemp: int, immediate: bool): void {
        temp = Math.max(2000, Math.min(6500, newTemp));
        if (enabled) {
            if (immediate) {
                applyTemp();
            } else {
                applyTimer.restart();
            }
        }
    }

    function applyTemp(): void {
        if (enabled) {
            applyTimer.stop();
            Quickshell.execDetached(["sh", "-c", "hyprctl hyprsunset temperature " + temp + " 2>/dev/null || (pkill -x hyprsunset 2>/dev/null; sleep 0.1; hyprsunset -t " + temp + " >/dev/null 2>&1 &)"]);
        }
    }

    Timer {
        id: applyTimer
        interval: 20
        repeat: false
        onTriggered: root.applyTemp()
    }

    Process {
        id: procCheck
        command: ["sh", "-c", "pgrep -x hyprsunset"]
        running: true
        onExited: (code) => {
            root.enabled = (code === 0);
        }
    }

    IpcHandler {
        function isEnabled(): bool {
            return root.enabled;
        }

        function toggle(): void {
            root.toggle();
        }

        function setTemp(t: int): void {
            root.setTemperature(t, true);
        }

        target: "nightLight"
    }
}
```

### 3.2 Material Design 3 Popout Widget (`~/.config/quickshell/caelestia/modules/bar/popouts/NightLight.qml`)
```qml
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
```

### 3.3 Horizontal FilledSlider Component (`~/.config/quickshell/caelestia/components/controls/FilledSlider.qml`)
- Enhanced `FilledSlider.qml` to support `orientation: Qt.Horizontal` and `showValueOnMove: false`.

### 3.4 Popout Registration (`~/.config/quickshell/caelestia/modules/bar/popouts/Content.qml`)
```qml
Popout {
    name: "nightlight"
    sourceComponent: NightLight {
        popouts: root.popouts
    }
}
```

### 3.5 Status Bar Icon (`~/.config/quickshell/caelestia/modules/bar/components/StatusIcons.qml`)
```qml
WrappedLoader {
    name: "nightlight"
    active: true

    sourceComponent: MaterialIcon {
        animate: true
        text: NightLight.enabled ? "bedtime" : "bedtime_off"
        color: NightLight.enabled ? Colours.palette.m3primary : root.colour
    }
}
```

---

## 4. Autostart on Boot

Night light is configured to start automatically on every Hyprland session via `~/.config/hypr/hyprland/execs.lua`.

The line added to the `hyprland.start` event handler:
```lua
-- Night light (warm 4000K color temperature)
hl.exec_cmd("hyprsunset -t 4000")
```

This ensures `hyprsunset` is running at 4000K immediately on boot, so the `nightlight` toggle script (Super+Shift+N) and the Caelestia sidebar widget correctly detect the running process and show the night light as **ON** from the start.

> [!NOTE]
> The `nightlight` toggle script at `/usr/local/bin/nightlight` (or similar) uses `pgrep -x hyprsunset` to determine state. Since `hyprsunset` is now started on boot, it will always be detected as active on first launch.

---

## 5. Related Notes
- [[desktop-caelestia-hyprland]]
- [[system-customizations-master-blueprint]]
- [[hyprland-screenshot-direct-save]]
- [[hyprland-workspace-hover-focus]]
