# 🎨 Desktop Environment: Caelestia + Hyprland + UWSM

Detailed configuration map and complete code for the desktop shell, window manager, and session environment.

---

## 📁 Configuration Code & Scripts

### 0. Monitor Configuration (`~/.config/caelestia/hypr-user.lua`)
Note: In Hyprland with Caelestia Lua parser, use `hyprctl eval` instead of legacy `hyprctl keyword`.
```lua
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@60",
    position = "0x0",
    scale    = 1,
    transform = 0,
})

hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@60",
    position = "1920x-420",
    scale    = 1,
    transform = 3, -- 90 deg clockwise rotation (portrait)
})
```
- **Secondary Screen Bar Exclusion**: Configured `"excludedScreens": ["DP-1"]` under `bar` in [`shell.json`](file:///home/youki/.config/caelestia/shell.json#L17) so the Caelestia status bar renders cleanly on your main monitor (`HDMI-A-1`) only.
- **Caelestia Logo Override**: Configured `"general": { "logo": "caelestia" }` in [`shell.json`](file:///home/youki/.config/caelestia/shell.json#L2-L4) to replace the distro (CachyOS) logo with the native Caelestia logo across the top bar, dashboard user card, and lockscreen fetch.
- **Secondary Screen Lockscreen Exclusion**: Fixed [`LockSurface.qml`](file:///home/youki/.config/quickshell/caelestia/modules/lock/LockSurface.qml#L19) to rely directly on `Config.bar.excludedScreens` (`["DP-1"]`). Removed the fragile `Quickshell.screens[0]` index check that previously caused both screens to evaluate as excluded during DPMS wake monitor re-enumeration.

### 1. Hyprland Windows-Style Keybindings (`~/.config/hypr/userprefs.conf`)
```ini
# English locale for Date and Time (Celsius/Metric)
env = LANG,en_US.UTF-8
env = LC_TIME,en_US.UTF-8
env = LC_MEASUREMENT,en_GB.UTF-8

# ============================================
# WINDOWS-STYLE SHORTCUTS
# ============================================

# Windows + E -> File Manager
bind = SUPER, E, exec, thunar

# Alt + F4 -> Power / Session Menu (Handled by kbSession in variables.lua)

# Ctrl + Shift + Esc -> Task Manager / System Monitor
bind = CTRL SHIFT, Escape, exec, btop

# Windows + V -> Clipboard History Manager
bind = SUPER, V, exec, caelestia clipboard

# Wallpaper Navigation Shortcuts (Shift wallpapers from ~/Pictures/Wallpapers)
# Super + , (Super + Comma) -> Previous Wallpaper (caelestia-wallpaper-shift prev)
# Super + . (Super + Period) -> Next Wallpaper (caelestia-wallpaper-shift next)

# Screenshot Helper Script (~/.config/hypr/scripts/screenshot.sh with single-instance pid check)
# Handled centrally in keybinds.lua (vars.kbScreenshotFreeze & vars.kbScreenshot)
# Windows + Shift + S -> Region Screenshot (Saves immediately to ~/Pictures/Screenshots/ + Clipboard)
# Print / PrtScn -> Fullscreen Screenshot (Saves immediately to ~/Pictures/Screenshots/ + Clipboard)

# Windows + L -> Lock Screen (Caelestia Shell IPC)
# Handled in keybinds.lua via hl.dsp.exec_cmd("caelestia shell lock lock") (avoiding hl.dsp.global Lua parser syntax error)

# Windows + Shift + N -> Night Light Toggle (4000K warm blue-light filter)
bind = SUPER SHIFT, N, exec, pkill hyprsunset || hyprsunset -t 4000

# Quick Toggles: Replaced Bluetooth icon with Night Light (bedtime moon icon) and Wi-Fi icon with Ethernet (lan icon) in Caelestia Control Center
# Status Icons Bar Pill: Removed Wi-Fi and Bluetooth icons from top bar status pill (in StatusIcons.qml)

# Windows + M -> Minimize / Toggle Floating
bind = SUPER, M, hl.dsp.window.float()

# Windows + F -> Bordered Fullscreen / Maximized
bind = SUPER, F, hl.dsp.window.fullscreen({ mode = "maximized" })

# F11 -> True Fullscreen
bind = , F11, hl.dsp.window.fullscreen({ mode = "fullscreen" })

# Windows + K -> Quick Settings / Control Center Panels (Handled by kbShowPanels in variables.lua)
```

> [!IMPORTANT]
> **Caelestia Lua Parser Rule**: Standard Hyprland raw dispatchers (like `fullscreen, 1` or `togglefloating`) cause Lua syntax errors in Caelestia because Caelestia wraps non-`exec` bind commands in `hl.dispatch(...)`. Keybindings must use Caelestia Lua dispatcher objects (e.g. `hl.dsp.window.fullscreen({ mode = "maximized" })` or `hl.dsp.window.float()`).

### 1.1 Window Fullscreen Keybindings (`~/.config/hypr/variables.lua` & `userprefs.conf`)
- **`SUPER + F`**: Bordered Fullscreen / Maximized (`hl.dsp.window.fullscreen({ mode = "maximized" })` - preserves gaps and Caelestia status bar)
- **`F11`**: True Fullscreen (`hl.dsp.window.fullscreen({ mode = "fullscreen" })` - covers entire display)

### 1.2 Moving Windows Across Workspaces (`~/.config/hypr/variables.lua`)
- **`SUPER + ALT + 1..9`**: Move active window to a specific workspace (1 through 9).
- **`SUPER + ALT + Right Arrow`** (or **`SUPER + ALT + Mouse Wheel Down`**): Move active window to the next workspace (`+1`).
- **`SUPER + ALT + Left Arrow`** (or **`SUPER + ALT + Mouse Wheel Up`**): Move active window to the previous workspace (`-1`).
- **`SUPER + ALT + S`**: Move active window to Special Scratchpad workspace.
- **Terminal CLI Command**: `hyprctl dispatch movetoworkspace <number>` (e.g. `hyprctl dispatch movetoworkspace 2`).

---

## 2. Caelestia Special Workspace Navigation (`~/.config/caelestia/hypr-user.lua`)
```lua
-- Caelestia Hyprland user configuration
local repeating = { repeating = true }

-- Defined visual order of special workspaces (matching the Caelestia bar from top to bottom)
local special_order = {
    ["special:music"]         = 1,
    ["special:dev"]           = 2,
    ["special:communication"] = 3,
    ["special:todo"]          = 4,
    ["special:sysmon"]        = 5,
    ["special:special"]       = 6,
}

local function cycle_special_workspaces(dir)
    return function()
        local active_special = hl.get_active_special_workspace()

        if active_special then
            local windows = hl.get_windows() or {}
            local special_list = {}
            local special_set = {}

            for _, w in ipairs(windows) do
                if w.workspace and w.workspace.name and w.workspace.name:find("^special:") then
                    local name = w.workspace.name
                    if not special_set[name] then
                        special_set[name] = true
                        table.insert(special_list, name)
                    end
                end
            end

            -- Sort by top-to-bottom visual bar order
            table.sort(special_list, function(a, b)
                local order_a = special_order[a] or 99
                local order_b = special_order[b] or 99
                if order_a ~= order_b then
                    return order_a < order_b
                end
                return a < b
            end)

            if #special_list > 1 then
                local idx = 1
                for i, sname in ipairs(special_list) do
                    if sname == active_special.name then
                        idx = i
                        break
                    end
                end

                if dir > 0 then
                    idx = (idx % #special_list) + 1
                else
                    idx = ((idx - 2 + #special_list) % #special_list) + 1
                end

                local target_special = special_list[idx]
                if target_special ~= active_special.name then
                    hl.dispatch(hl.dsp.focus({ workspace = target_special }))
                end
            end
        end
    end
end

-- Super + Down -> Moves DOWN the sidebar (towards bottom icon)
hl.bind("SUPER + Down", cycle_special_workspaces(-1), repeating)

-- Super + Up -> Moves UP the sidebar (towards top icon)
hl.bind("SUPER + Up", cycle_special_workspaces(1), repeating)
```

---

## 3. Caelestia Shell Config (`~/.config/caelestia/shell.json`)
```json
{
    "appearance": {
        "rounding": {
            "scale": 1
        },
        "transparency": {
            "enabled": true
        }
    },
    "background": {
        "desktopClock": {
            "enabled": true,
            "position": "bottom-right"
        }
    },
    "bar": {
        "clock": {
            "showDate": true
        },
        "tray": {
            "compact": true
        },
        "workspaces": {
            "specialWorkspaceIcons": [
                {
                    "icon": "terminal",
                    "name": "dev"
                }
            ],
            "windowIcons": [
                {
                    "regex": "obsidian|Obsidian|md.obsidian.Obsidian",
                    "icon": "diamond"
                },
                {
                    "regex": "Twintaillauncher|twintaillauncher|app.twintaillauncher.ttl",
                    "icon": "sports_esports"
                }
            ]
        }
    },
    "launcher": {
        "favouriteApps": [
            "brave-browser",
            "spotify",
            "ghostty",
            "thunar"
        ]
    },
    "paths": {
        "wallpaperDir": "~/Pictures/Wallpapers"
    },
    "services": {
        "useFahrenheit": false,
        "useFahrenheitPerformance": false,
        "useTwelveHourClock": false
    },
    "sidebar": {
        "dragThreshold": 80,
        "enabled": true
    },
    "utilities": {
        "toasts": {
            "capsLockChanged": false
        }
    }
}
```

---

## 4. Helper Launchers (`~/.local/bin/`)

### Discord Launcher (`~/.local/bin/discord`)
```bash
#!/bin/sh
exec flatpak run com.discordapp.Discord "$@"
```

### GNOME Control Center Wrapper (`~/.local/bin/gnome-control-center`)
```bash
#!/bin/sh
exec env XDG_CURRENT_DESKTOP=GNOME /usr/bin/gnome-control-center "$@"
```

### Night Light Toggle Script (`~/.local/bin/nightlight`)
```bash
#!/bin/bash
if pgrep -x "hyprsunset" > /dev/null; then
    pkill -x "hyprsunset"
else
    hyprsunset -t 4000 &
fi
```

---

## 5. Related Notes
- [[caelestia-weather-locale-date-fix]]
- [[caelestia-nightlight-widget]]
- [[hyprland-screenshot-direct-save]]
- [[hyprland-workspace-hover-focus]]
- [[ssd-dramless-io-responsiveness-tuning]]
- [[btrfs-multi-device-drive-merge]]
- [[hardware-and-kernel]]
