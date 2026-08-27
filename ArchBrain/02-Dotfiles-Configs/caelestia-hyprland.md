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

## Lockscreen Frosted Glass Styling
- Enhanced `~/.config/quickshell/caelestia/modules/lock/` with airy, translucent frosted glass aesthetics:
  - **Main Container (`LockSurface.qml`)**: `lockBg` uses `Qt.alpha(Colours.palette.m3surface, 0.22)` with a 1px `m3onSurface` 0.18 translucent specular border over the blurred `ScreencopyView` (`blurMax: 64`).
  - **Dashboard Cards (`Fetch.qml`, `WeatherInfo.qml`, `Media.qml`, `Resources.qml`, `Content.qml`)**: `0.18` alpha translucent fill with subtle `0.12` alpha glass borders.
  - **Password Pill (`PasswordInput.qml`)**: `0.28` alpha container with `0.40` alpha `m3primary` accent border.

## Keybindings (Shortcuts)
Most keybindings are mapped in `~/.config/hypr/variables.lua` and `~/.config/hypr/userprefs.conf`:

### Windows-style shortcuts
- `SUPER + I` -> System Settings (hyprmod)
- `SUPER + E` -> File Manager (nautilus)
- `SUPER + T` -> Terminal (ghostty)
- `SUPER + W` -> Browser (brave)
- `SUPER + C` -> Universal Copy (Terminal: `Ctrl+Shift+C`, GUI/Websites: `Ctrl+C` via balanced `send_key_state` down/up)
- `SUPER + V` -> Universal Paste (Terminal: `Ctrl+Shift+V`, GUI/Websites: `Ctrl+V` via balanced `send_key_state` down/up)
- `CTRL + SUPER + V` -> Clipboard History Manager (Caelestia / Cliphist)
- `SUPER + Period` / `Comma` -> Next/Prev Wallpaper
- `SUPER + L` -> Lock Screen
- `SUPER + F` -> Bordered Fullscreen / Maximized
- `F11` -> True Fullscreen
- `ALT + F4` -> Session Menu / Power
- `CTRL + SHIFT + Escape` -> Task Manager / System Monitor (btop / special workspace)

## Related Notes
- [[custom-scripts]]
- [[system-services]]
- [[sddm-pixie-display-manager]]
