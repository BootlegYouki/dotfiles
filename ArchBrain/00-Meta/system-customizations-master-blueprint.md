# 🗺️ System Customizations Master Blueprint & Disaster Recovery Guide

This document is the **authoritative master blueprint** containing the **complete source code, config files, systemd units, and scripts** for all custom tweaks on this CachyOS (Arch Linux) + Hyprland + Caelestia setup.

> [!IMPORTANT]
> **Disaster Recovery Notice**: If the system is formatted or reinstalled, all configuration files are embedded below in full so that the entire desktop environment can be restored automatically by an LLM or user without relying on local filesystem links.

---

## 📑 WikiLinks Graph
- 🎨 **Desktop Environment**: [[desktop-caelestia-hyprland]]
- 🐚 **Fish Shell & Starship**: [[fish-and-starship]]
- 💻 **Terminal Setup**: [[ghostty-and-terminals]]
- 🖼️ **Fastfetch Greeting**: [[fastfetch]]
- 🈲 **Japanese Romaji Lyrics**: [[romaji-lyrics-daemon]]
- 📦 **Installed Applications**: [[installed-applications]]
- ⚡ **Hardware Profile**: [[hardware-and-kernel]]

---

## 🛠️ Complete Source Code & Configurations

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

# Windows + . -> Emoji Picker
bind = SUPER, period, exec, caelestia emoji

# Windows + Shift + S -> Region Screenshot (Saves immediately to ~/Pictures/Screenshots + Clipboard)
bind = SUPER SHIFT, S, exec, sh -c 'dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"; region=$(slurp); [ -n "$region" ] || exit 0; file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"; grim -g "$region" "$file" && wl-copy < "$file" && notify-send -i image-x-generic "Screenshot Saved" "Saved to ~/Pictures/Screenshots/"'

# Print / PrtScn -> Fullscreen Screenshot (Saves immediately to ~/Pictures/Screenshots + Clipboard)
bind = , Print, exec, sh -c 'dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"; file="$dir/Screenshot_$(date +%Y-%m-%d_%H-%M-%S).png"; grim "$file" && wl-copy < "$file" && notify-send -i image-x-generic "Screenshot Saved" "Saved to ~/Pictures/Screenshots/"'

# Windows + L -> Lock Screen
bind = SUPER, L, exec, hyprlock

# Windows + M -> Minimize / Toggle Floating
bind = SUPER, M, togglefloating

# Windows + K -> Quick Settings / Control Center Panels (Handled by kbShowPanels in variables.lua)
```

---

### 2. Caelestia Special Workspace Navigation (`~/.config/caelestia/hypr-user.lua`)
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

### 3. Caelestia Shell Config (`~/.config/caelestia/shell.json`)
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

### 4. Japanese Romaji Lyrics Daemon Stack

#### Python Socket Daemon (`~/.local/bin/caelestia-romaji-daemon`)
```python
#!/home/bootlegyouki/.local/share/caelestia/venv/bin/python3
import os
import sys
import json
import re
import socket
import pykakasi

SOCK_PATH = f"/run/user/{os.getuid()}/caelestia-romaji.sock"
kks = pykakasi.kakasi()
jp_regex = re.compile(r'[\u3040-\u30ff\u3400-\u4dbf\u4e00-\u9fff]')

def convert_line(line):
    if not line or not jp_regex.search(line):
        return line
    cleaned = re.sub(r'[\u3400-\u9fff]+\(([\u3040-\u30ff]+)\)', r'\1', line)
    cleaned = re.sub(r'[\u3400-\u9fff]+（([\u3040-\u30ff]+)）', r'\1', cleaned)
    
    result = kks.convert(cleaned)
    converted_parts = []
    for item in result:
        hepburn = item.get('hepburn', '')
        if hepburn:
            converted_parts.append(hepburn)
        else:
            converted_parts.append(item.get('orig', ''))
    res = ' '.join(converted_parts)
    res = re.sub(r'\s+', ' ', res).strip()
    res = re.sub(r'\s+([,\.!\?\)])', r'\1', res)
    res = re.sub(r'(\()\s+', r'\1', res)
    return res

def process_data(raw):
    data = json.loads(raw)
    if isinstance(data, list):
        return [convert_line(l) for l in data]
    return convert_line(str(data))

def main():
    if os.path.exists(SOCK_PATH):
        try:
            os.unlink(SOCK_PATH)
        except OSError:
            pass
    server = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    server.bind(SOCK_PATH)
    server.listen(10)
    
    while True:
        try:
            conn, _ = server.accept()
            data = b""
            while True:
                chunk = conn.recv(4096)
                if not chunk:
                    break
                data += chunk
            if data.strip():
                res = process_data(data.decode('utf-8'))
                conn.sendall(json.dumps(res, ensure_ascii=False).encode('utf-8'))
            conn.close()
        except Exception:
            pass

if __name__ == '__main__':
    main()
```

#### Systemd User Unit (`~/.config/systemd/user/caelestia-romaji.service`)
```ini
[Unit]
Description=Caelestia Romaji Lyrics Converter Daemon
After=graphical-session.target

[Service]
Type=simple
ExecStart=/home/bootlegyouki/.local/bin/caelestia-romaji-daemon
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
```

---

### 5. Fastfetch Config (`~/.config/fastfetch/config.jsonc`)
```jsonc
{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

  "logo": {
    "type": "data",
    "source": "\u001b[36m██╗   ██╗ ██████╗ ██╗   ██╗██╗  ██╗██╗\n╚██╗ ██╔╝██╔═══██╗██║   ██║██║ ██╔╝██║\n ╚████╔╝ ██║   ██║██║   ██║█████╔╝ ██║\n  ╚██╔╝  ██║   ██║██║   ██║██╔═██╗ ██║\n   ██║   ╚██████╔╝╚██████╔╝██║  ██╗██║\n   ╚═╝    ╚═════╝  ╚═════╝ ╚═╝  ╚═╝╚═╝\u001b[0m",
    "padding": {
      "top": 0,
      "right": 0
    }
  },

  "display": {
    "color": {
      "keys": "cyan"
    }
  },

  "modules": []
}
```

---

### 6. Ghostty Config (`~/.config/ghostty/config`)
```ini
# Ghostty Configuration for Caelestia / Hyprland

font-family = JetBrainsMono Nerd Font
font-size = 12

# Window Padding & Opacity for Hyprland Blur
window-padding-x = 20
window-padding-y = 20
background-opacity = 0.78

# Cursor
cursor-style = bar
cursor-style-blink = false

# Colors matching Caelestia current scheme
background = 0b0f11
foreground = e0e6ee
selection-background = 34566f
selection-foreground = cce6ff

palette = 0=#343434
palette = 1=#8383ff
palette = 2=#44def5
palette = 3=#75fcdd
palette = 4=#81b0cd
palette = 5=#89aaed
palette = 6=#89d3f0
palette = 7=#ccdcd6
palette = 8=#9aa59f
palette = 9=#a29eff
palette = 10=#89ecff
palette = 11=#c9fff3
palette = 12=#a8c5d5
palette = 13=#a7bef8
palette = 14=#a0e5ff
palette = 15=#ffffff
```

---

### 7. Interactive Fish Shell Config (`~/.config/fish/config.fish`)
```fish
if status is-interactive
    # Starship custom prompt
    command -v starship &> /dev/null && starship init fish | source

    # Direnv + Zoxide
    command -v direnv &> /dev/null && direnv hook fish | source
    command -v zoxide &> /dev/null && zoxide init fish --cmd cd | source

    # Better ls
    command -v eza &> /dev/null && alias ls='eza --icons --group-directories-first -1'

    # Abbrs
    abbr lg 'lazygit'
    abbr gd 'git diff'
    abbr ga 'git add .'
    abbr gc 'git commit -am'
    abbr gl 'git log'
    abbr gs 'git status'
    abbr gst 'git stash'
    abbr gsp 'git stash pop'
    abbr gp 'git push'
    abbr gpl 'git pull'
    abbr gsw 'git switch'
    abbr gsm 'git switch main'
    abbr gb 'git branch'
    abbr gbd 'git branch -d'
    abbr gco 'git checkout'
    abbr gsh 'git show'

    abbr l 'ls'
    abbr ll 'ls -l'
    abbr la 'ls -a'
    abbr lla 'ls -la'

    # Custom colours
    cat ~/.local/state/caelestia/sequences.txt 2> /dev/null

    # For jumping between prompts in foot terminal
    function mark_prompt_start --on-event fish_prompt
        echo -en "\e]133;A\e\\"
    end

    # Custom fish config
    set -q XDG_CONFIG_HOME && set -l cConf $XDG_CONFIG_HOME/caelestia || set -l cConf $HOME/.config/caelestia
    source $cConf/user-config.fish 2> /dev/null
end


# Added by Antigravity CLI installer
set -gx PATH "/home/bootlegyouki/.local/bin" $PATH
```
