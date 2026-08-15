# Caelestia Hyprland Configuration

Configuration for Hyprland under the Caelestia shell.

## Apps
- **Terminal:** ghostty
- **Browser:** brave
- **Editor:** zeditor
- **File Explorer:** nautilus
- **Audio Settings:** pavucontrol

## UI Changes
- **Blur:** Enabled (Size: 8, Passes: 2)
- **Shadows:** Enabled (Range: 15, Power: 4)
- **Gaps:** Workspace 20, Window In 8, Window Out 18
- **Window:** Opacity 0.95, Rounding 10, Border Size 2
- **Cursor Theme:** sweet-cursors (Size: 24)

## Keybindings (Shortcuts)
Most keybindings are mapped in `~/.config/hypr/variables.lua` and `~/.config/hypr/userprefs.conf`:

### Windows-style shortcuts
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
- `SUPER + Z` -> Move Window
- `SUPER + X` -> Resize Window
- `SUPER + ALT + Space` -> Toggle Window Floating
- `SUPER + Q` -> Close Window
- `SUPER + S` -> Special Workspace Toggle
- `SUPER + M` -> Music Workspace
- `SUPER + D` -> Communication Workspace
- `SUPER + C` -> Dev Workspace
- `SUPER + SHIFT + N` -> Night Light Toggle (via custom `nightlight` script)
- `SUPER + ALT + A` -> Startup Applications Manager (`autostart-manager`)

## Dashboard Enhancements
- **Agenda & Events System (`Events.qml`, `ClockTab.qml`)**:
  - Replaced static timezone cards with an interactive Agenda & Events manager.
  - **Fixed 150px Height**: Card stays strictly locked at 150px height across all states (no container jumping).
  - **3-Step Sliding Creator**: 1. Event Name ➔ 2. 7-Day Horizontal Week Strip ➔ 3. 24h Scrollable Time Picker.
  - **Single & Multi-Event View**: 2-row layout (`{Event Title}` + `{MMM d, HH:mm} ({Countdown})`) with seamless infinite marquee loop for long titles and mouse-wheel vertical slide navigation across multiple events.
  - **Data Persistence**: Stored locally in `~/.local/state/caelestia/events.json`.

## Related Notes
- [[custom-scripts]]
- [[system-services]]

