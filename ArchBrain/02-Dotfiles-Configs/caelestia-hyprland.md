# Caelestia Hyprland Configuration

Configuration for Hyprland under the Caelestia shell.

## Apps
- **Terminal:** ghostty
- **Browser:** brave
- **Editor:** zeditor
- **File Explorer:** nautilus
- **Audio Settings:** pavucontrol
- **System Settings:** hyprmod

## UI Changes
- **Blur:** Enabled (Size: 8, Passes: 2)
- **Shadows:** Enabled (Range: 15, Power: 4)
- **Gaps:** Workspace 20, Window In 8, Window Out 18
- **Window:** Opacity 0.95, Rounding 10, Border Size 2
- **Cursor Theme:** sweet-cursors (Size: 24)

## Keybindings (Shortcuts)
Most keybindings are mapped in `~/.config/hypr/variables.lua` and `~/.config/hypr/userprefs.conf`:

### Windows-style shortcuts
- `SUPER + I` -> System Settings (hyprmod)
- `SUPER + E` -> File Manager (nautilus)
- `SUPER + T` -> Terminal (ghostty)
- `SUPER + W` -> Browser (brave)
- `SUPER + V` -> Clipboard History Manager
- `SUPER + Period` / `Comma` -> Next/Prev Wallpaper
- `SUPER + L` -> Lock Screen
- `SUPER + F` -> Bordered Fullscreen / Maximized
- `F11` -> True Fullscreen
- `ALT + F4` -> Session Menu / Power
- `CTRL + SHIFT + Escape` -> Task Manager / System Monitor (btop / special workspace)

### Caelestia / Hyprland specific
- `SUPER + Left` / `Right` / `Up` / `Down` -> Move active window / swap sides in tiling layout
- `SUPER + SHIFT + Left` / `Right` / `Up` / `Down` -> Move active window (alternative)
- `SUPER + Z` -> Move Window (floating drag mode)
- `SUPER + X` -> Resize Window (floating resize mode)
- `SUPER + ALT + Left` / `Right` / `Up` / `Down` -> Resize active window dimensions
- `SUPER + G` / `SUPER + ALT + Space` -> Smart Toggle Window Floating (tile <-> float)
  - *Floating logic*: Un-maximizes/un-fullscreens if needed, floats window, resizes to a comfortable 65%x75% monitor ratio, and centers it.
  - *Tiling logic*: Toggling again cleanly un-floats the window, snapping it back into the active workspace tiling management tree.
- `SUPER + Q` -> Close Window
- `SUPER + S` -> Special Workspace Toggle
- `SUPER + M` -> Music Workspace
- `SUPER + D` -> Communication Workspace
- `SUPER + C` -> Dev Workspace
- `CTRL + SUPER + Up` / `Down` -> Cycle through open Special Workspaces
- `SUPER + SHIFT + N` -> Night Light Toggle (via custom `nightlight` script)
- `SUPER + ALT + A` -> Startup Applications Manager (`autostart-manager`)

## Dashboard Enhancements
- **Agenda & Events System (`Events.qml`, `ClockTab.qml`)**:
  - Replaced static timezone cards with an interactive Agenda & Events manager.
  - **Fixed 150px Height**: Card stays strictly locked at 150px height across all states (no container jumping).
  - **3-Step Sliding Creator**: 1. Event Name ➔ 2. 7-Day Horizontal Week Strip ➔ 3. 24h Scrollable Time Picker.
  - **Single & Multi-Event View**: 2-row layout (`{Event Title}` + `{MMM d, HH:mm} ({Countdown})`) with seamless infinite marquee loop for long titles and mouse-wheel vertical slide navigation across multiple events.
  - **Data Persistence**: Stored locally in `~/.local/state/caelestia/events.json`.
- **Countdown Timer Scrollable Time Selection (`ClockTab.qml`, `Timers.qml`)**:
  - Added individual interactive hover blocks for Hours, Minutes, and Seconds styled at `68x52px` with smooth M3 primary tint highlights (`Colours.layer(Colours.palette.m3primary, 0.15)`).
  - Mouse wheel scrolling up/down on any digit block increments/decrements that unit directly via reactive helper functions in `Timers.qml` (`adjustHours`, `adjustMinutes`, `adjustSeconds`).

## Idle Config (shell.json `general.idle`)

> [!WARNING]
> Caelestia's **default idle timeouts** include `suspendThenHibernate` at 600s — this WILL suspend you mid-game if not overridden.

The caelestia defaults have:
- 180s → lock
- 300s → dpms off
- 600s → **suspend-then-hibernate** ← dangerous for gaming

**The fix** is to explicitly set `general.idle` in [`~/.config/caelestia/shell.json`](~/.config/caelestia/shell.json):

```json
"idle": {
    "lockBeforeSleep": true,
    "inhibitWhenAudio": true,
    "inhibitWhenCharging": false,
    "timeouts": [
        { "timeout": 300, "idleAction": "lock", "respectInhibitors": true },
        { "timeout": 600, "idleAction": "dpms off", "returnAction": "dpms on", "respectInhibitors": true }
    ]
}
```

**Why Hyprland's `idle_inhibit = "always"` window rule alone isn't enough:**
- Quickshell's `IdleMonitor` uses `ext-idle-notify-v1` protocol
- Hyprland sets `inhibitingIdle: 1` on the game window via `zwp-idle-inhibit-manager-v1`
- These two protocols don't always communicate reliably → game can still trigger idle
- `gamemoded` also fails to inhibit: `ERROR: Failed to call Inhibit on org.freedesktop.ScreenSaver` (no provider for that DBus name on Wayland)
- **Explicit `respectInhibitors: true` on all timeouts + no auto-suspend entry = safe**

### Preventing Inactivity Display Wake Loops (`mouse_move_enables_dpms = false`)
- Wireless mice with 1KHz polling rate or optical sensor noise emit micro-motion/wheel jitter packets while resting on the desk.
- In `~/.config/hypr/hyprland/misc.lua`, `misc.mouse_move_enables_dpms` must be set to `false` (with `key_press_enables_dpms = true`). Otherwise, immediately after reaching the 600s DPMS timeout and powering off, mouse jitter will instantly trigger Hyprland to power the display back on.

## Launcher Command Mode & Actions (`shell.json` `launcher.actions`)

When typing `>` in the Caelestia launcher, it enters Command Mode (`state: "actions"`). For actions (calculator, wallpapers, themes, session controls) to appear, the `launcher.actions` array must be defined in `~/.config/caelestia/shell.json`.

Supported command actions include:
- `["autocomplete", "calc"]` - Interactive calculator powered by Qalc
- `["autocomplete", "wallpaper"]` - Wallpaper selector
- `["autocomplete", "scheme"]` - Material 3 theme scheme selector
- `["autocomplete", "variant"]` - Material 3 color variant picker
- `["setMode", "dark"]` / `["setMode", "light"]` - Quick theme mode switch
- `["loginctl", "lock-session"]` - Lock screen
- `["systemctl", "suspend"]` - Suspend system
- `["systemctl", "reboot"]` - Reboot (dangerous action)
- `["systemctl", "poweroff"]` - Power off (dangerous action)

> [!IMPORTANT]
> **QML `Actions.qml` Bug Fix**: In `~/.config/quickshell/caelestia/modules/launcher/services/Actions.qml`, `GlobalConfig.launcher.actions.values` incorrectly targeted JavaScript's `Array.prototype.values` method instead of the array, throwing `TypeError: Property 'filter' of object function values() is not a function`. Fixed by resolving the array directly via `Array.isArray(GlobalConfig.launcher.actions) ? GlobalConfig.launcher.actions : Array.from(GlobalConfig.launcher.actions ?? [])`.

## Related Notes
- [[custom-scripts]]
- [[system-services]]
- [[nexus-multi-monitor-geometry-overflow]]
- [[multi-monitor-sleep-and-proton-idle-inhibit]]



