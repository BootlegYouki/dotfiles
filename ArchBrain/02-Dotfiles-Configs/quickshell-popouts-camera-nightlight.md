# Quickshell Popouts: Camera & Night Light Enhancements

Documentation of UI and UX updates to the Caelestia Quickshell bar popouts (`~/.config/quickshell/caelestia/modules/bar/popouts/`).

---

## 1. Camera Popout (`Camera.qml`)

### Features & Layout
- **Root Component**: Direct `ColumnLayout` (`width: 340`, `spacing: Tokens.spacing.small`) removing extraneous outer `Item` padding to eliminate top gaps.
- **Header**: Clean `"Camera"` label with dynamic status indicator (`Active` / `Click to start`) without emojis/icons.
- **Click-to-Toggle Preview**:
  - Inactive by default (`cameraActive: false`) for privacy and resource savings.
  - Interactive `StyledRect` container (`190px` height) with `StateLayer`:
    - **Off**: Displays camera glyph with *"Click to start camera"*.
    - **On**: Activates live `Media.VideoOutput` feed. Clicking anywhere on the preview deactivates it.
- **Adjustments Accordion**:
  - Expandable **`[ 🎛️ Adjustments ▾ ]`** button with Material 3 active state.
  - Unfolds all 5 camera parameter sliders (`FilledSlider`) dynamically:
    - **Brightness** (`-64` to `64`)
    - **Contrast** (`0` to `64`)
    - **Saturation** (`0` to `128`)
    - **Sharpness** (`0` to `6`)
    - **Gamma** (`72` to `500`)

---

## 2. Night Light Popout (`NightLight.qml`)

### Features & Layout
- **Root Component**: Direct `ColumnLayout` (`width: 260`) eliminating top spacing gaps.
- **Header**: Clean `"Night Light"` title with toggle switch (`StyledSwitch`) and zero preceding icons.
- **Controls**: Warmth percentage display and interactive capsule `FilledSlider` (`from: 0.0, to: 1.0`).

---

## Related Notes
- [[caelestia-hyprland]]
- [[boot-time-optimization-and-systemd-boot-timeout]]
- [[system-cheatsheet]]

---

## 3. Fast.com Inline Speedtest (`Network.qml`)

### Features & Implementation
- **Zero-Window Headless Testing**: Runs headless Netflix Fast.com API bandwidth tests without opening terminal or browser popups.
- **Real-Time Streaming**: [`~/.local/bin/fast-speedtest`](file:///home/youki/.local/bin/fast-speedtest) streams live Mbps metrics over JSON lines.
- **Embedded UI**:
  - Material 3 card container embedded directly in the Ethernet popout.
  - Features dynamic status spinner (`CircularIndicator`) and live updating `X.X Mbps` speed numbers during and after testing.
