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
- `SUPER + ALT + Space` -> Toggle Window Floating
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

## Related Notes
- [[custom-scripts]]
- [[system-services]]
- [[nexus-multi-monitor-geometry-overflow]]
- [[multi-monitor-sleep-and-proton-idle-inhibit]]


