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
