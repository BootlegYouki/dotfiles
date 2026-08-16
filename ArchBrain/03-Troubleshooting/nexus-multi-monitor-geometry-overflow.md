# Caelestia Nexus Multi-Monitor Floating Window Geometry Overflow

Documentation of the issue where Caelestia's Settings window (Nexus) opened with oversized dimensions (e.g. 2390x1344) and offset positions (`at: -210, -132`), appearing cut off on the left and spanning across monitors.

---

## Symptoms & Misconception

### Symptoms
- When opening Caelestia Settings / Nexus (`Super + ,` or IPC), the window spawned partially off-screen on the left side (cropping out the sidebar navigation buttons) and extended all the way across to the secondary monitor boundary.
- `hyprctl clients` showed the window geometry as `size: 2390, 1344` at position `at: -210, -132` on the 1920x1080 main monitor (`HDMI-A-1`).

### Misconception
- The user wondered if this was caused by the recent sleep / DPMS idle inhibit fix.
- **Verdict:** Unrelated. The sleep fix only touched game window tagging (`rules.lua`) and lock surface DPMS wake animations (`LockSurface.qml`).

---

## Root Cause

1. **Unassigned Screen Target on Floating Window:**
   - In [`WindowFactory.qml`](file:///home/youki/.config/quickshell/caelestia/modules/nexus/WindowFactory.qml), `FloatingWindow` was instantiated without setting its `screen` property.
   - Quickshell defaulted `win.screen` to `Quickshell.screens[0]`, which in this setup was the secondary vertical portrait monitor (`DP-1` with resolution `1080x1920`).

2. **Aspect Ratio Calculation on Portrait Resolution:**
   - In [`Nexus.qml`](file:///home/youki/.config/quickshell/caelestia/modules/nexus/Nexus.qml), window dimensions were computed as:
     - `implicitHeight = nState.screen.height * 0.7`
     - `implicitWidth = implicitHeight * (16 / 9)`
   - Because `win.screen` was pointing to `DP-1` (height = 1920), `implicitHeight` became `1344px` and `implicitWidth` became `2390px`.

3. **Centering Oversized Window on 1080p Landscape Display:**
   - When Hyprland centered this `2390x1344` window on the `1920x1080` active display (`HDMI-A-1`), it placed the window at `x = -210` and `y = -132`.
   - This caused the left ~210px of the UI to overflow off the left monitor edge, and the right ~470px to extend rightwards across towards `DP-1`.

---

## Resolution

1. **Added `activeScreen` in `Screens.qml`:**
   - Bound `activeScreen` to the currently focused Hyprland monitor:
     ```qml
     readonly property ShellScreen activeScreen: screens.find(s => s.name === Hyprland.focusedMonitor?.name) ?? screens[0] ?? null
     ```

2. **Explicitly Assigned `screen` in `WindowFactory.qml`:**
   - Assigned `screen: Screens.activeScreen` to `FloatingWindow` so Nexus dimensions always derive from the monitor it is being opened on.

3. **Capped Aspect Ratio Width in `Nexus.qml`:**
   - Added width clamping to ensure that even on portrait monitors (where height > width), `implicitWidth` will never exceed 90% of screen width:
     ```qml
     implicitHeight: Math.min(nState.screen.height * Tokens.sizes.nexus.heightMult, (nState.screen.width * 0.9) / Tokens.sizes.nexus.ratio)
     implicitWidth: implicitHeight * Tokens.sizes.nexus.ratio
     ```

4. **Applied to both `~/.config/quickshell` and `~/dotfiles/.config/quickshell`.**

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[multi-monitor-sleep-and-proton-idle-inhibit]]
- [[system-services]]
