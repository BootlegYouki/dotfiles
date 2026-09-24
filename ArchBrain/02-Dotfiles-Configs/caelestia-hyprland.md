# Caelestia Hyprland Configuration

Configuration for Hyprland under the Caelestia shell, configured via Lua (`~/.config/hypr/hyprland.lua`, `hyprland/*.lua`, `~/.config/caelestia/hypr-user.lua`, and `~/.config/hypr/hyprland-gui.lua`).

---

## Dual-Monitor Configuration

Configured in `~/.config/caelestia/hypr-user.lua`:

| Monitor | Connector | Resolution / Rate | Position | Orientation | Workspaces Assigned |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Primary** | `HDMI-A-1` (ASUS VA24E) | `1920x1080@74.99Hz` | `0x0` | Landscape (`transform = 0`) | **1 .. 10** (Default: `1`) |
| **Secondary** | `DP-1` (Dell P2219H) | `1920x1080@60Hz` | `1920x-420` | Portrait / 270° (`transform = 3`) | **11 .. 20** (Default: `11`) |

### Workspace Pinning Rules
```lua
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = (i == 1) })
end
for i = 11, 20 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1", default = (i == 11) })
end
```

---

## Core Applications
- **Terminal:** `ghostty` (Monochrome Caelestia scheme)
- **Browser:** `brave`
- **Editor:** `zeditor` (`zed`)
- **File Explorer:** `nautilus`
- **Audio Control:** `pavucontrol`
- **Settings GUI:** `hyprmod`

---

## Appearance & Window Styling (HyprMod)
- **Rounding:** `17`
- **Borders:** Size `2`, Active Border `0xffffffff` (solid specular white accent)
- **Gaps:** In `3`, Out `9`
- **Opacity:** Active `1.0`, Inactive `1.0` (Blur integrated on terminal & glass surfaces)
- **Blur:** Enabled (Size: 8, Passes: 2)
- **Shadows:** Enabled (Range: 15, Power: 4)

---

## Caelestia Special Workspaces Navigation
Caelestia features persistent vertical special workspace drawer docks. Smooth cycling is configured in `hypr-user.lua`:
- Visual Order:
  1. `special:music`
  2. `special:dev`
  3. `special:communication`
  4. `special:todo`
  5. `special:sysmon`
  6. `special:special`
- **Keybindings**:
  - `CTRL + SUPER + Down`: Cycles DOWN the sidebar special workspaces.
  - `CTRL + SUPER + Up`: Cycles UP the sidebar special workspaces.

---

## Keybindings & Shortcuts Reference

### Global Desktop Navigation
- `SUPER + T`: Launch Terminal (`ghostty`)
- `SUPER + W`: Launch Browser (`brave`)
- `SUPER + E`: Launch File Manager (`nautilus`)
- `SUPER + I`: Launch System Settings (`hyprmod`)
- `SUPER + F`: Bordered Fullscreen / Maximized
- `F11`: True Fullscreen
- `ALT + F4`: Session Menu / Power Dialog
- `SUPER + L`: Lock Screen (`hyprlock` / Caelestia lockscreen)
- `SUPER + F5`: Reload Hyprland config (`hyprctl reload`)

### Universal Mac/Windows Input
- `SUPER + C`: Universal Copy (handled by `keyd` layer & Hyprland Lua)
- `SUPER + V`: Universal Paste (handled by `keyd` layer & Hyprland Lua)
- `SUPER + X`: Universal Cut (handled by `keyd` layer)
- `CTRL + SUPER + V`: Clipboard History Manager (Caelestia / Cliphist)
- `SUPER + Period` / `Comma`: Next / Previous Wallpaper (triggers `sync-sddm-pixie` hook)

### Utilities & Toggles
- `SUPER + SHIFT + S`: Interactive Screenshot Tool (`caelestia:screenshotFreezeClip` via AreaPicker). Freezes screen, auto-snaps to window geometry or drag region with pixel zoom loupe, and immediately auto-copies to clipboard (`wl-copy`) and saves to `~/Pictures/Screenshots/` with zero preview popup.
- `Print`: Fullscreen Screenshot (`caelestia screenshot`).
- `SUPER + SHIFT + N`: Toggle Night Light (4000K warm temperature via `nightlight`)
- `SUPER + ALT + A`: Startup Applications Manager (`autostart-manager`)
- `CTRL + SHIFT + Escape`: Task Manager / System Monitor (opens `special:sysmon` running `btop`)
- `ALT + TAB`: Cursor toggle across monitors

---

## Caelestia Shell v2.5.0 Modernization
- **Workspaces Pill & Window Icons**: Redesigned active workspace pill indicator (`ActiveIndicator.qml`, `Workspace.qml`) powered by C++ `LazyListView` virtualization. Dynamically groups active workspace dot with open/focused app icons (e.g. `>_` terminal) and animates trail transitions.
- **Performance Cards Consistency**: All Dashboard performance cards (`HeroCard`, `MemoryCard`, `StorageCard`, `NetworkCard`, `BatteryTank`) unified to `radius: Tokens.rounding.large` to prevent visual mismatches.
- **Network Card**: Features live dual-line sparkline throughput graph, status icons (`swap_vert`, `download`, `upload`, `history`), and asynchronous rate formatters (`Units.formatBytes`).

---

## Lockscreen Frosted Glass Styling
- Configured in `~/.config/quickshell/caelestia/modules/lock/`:
  - **Surface (`LockSurface.qml`)**: `lockBg` uses `Qt.alpha(Colours.palette.m3surface, 0.22)` with a 1px `m3onSurface` 0.18 translucent specular border over blurred `ScreencopyView` (`blurMax: 64`).
  - **Dashboard Cards (`Fetch.qml`, `WeatherInfo.qml`, etc.)**: `0.18` alpha translucent fill with `0.12` alpha glass borders.
  - **Password Pill (`PasswordInput.qml`)**: `0.28` alpha container with `0.40` alpha `m3primary` accent border.

---

## Related Notes
- [[custom-scripts]]
- [[sddm-pixie-display-manager]]
- [[shell-terminal-config]]
- [[quickshell-caelestia-auto-reload]]
- [[multi-monitor-sleep-wake-hpd-and-quick-toggle-fix]]
