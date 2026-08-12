# 🖱️ Troubleshooting: Real-Time GNOME Settings Mouse Sensitivity Sync for Hyprland

## Problem Description
When opening system settings (`gnome-control-center`) under Hyprland, changes made to mouse speed, sensitivity, acceleration, or natural scroll did not take effect in real time.

---

## Root Cause
1. `gnome-control-center` writes settings to GNOME `dconf` keys under `/org/gnome/desktop/peripherals/mouse/`.
2. Hyprland is a standalone Wayland compositor using `libinput` and Lua configuration (`hyprland.lua`), which does not automatically read GNOME `dconf`.
3. Standard `hyprctl keyword` calls fail on Hyprland Lua setups with `keyword can't work with non-legacy parsers. Use eval.`.

---

## Solution & Architecture
A lightweight background daemon (`~/.local/bin/hypr-gnome-mouse-sync`) and user systemd service (`hypr-gnome-mouse-sync.service`) were deployed on the system.

### Daemon Script (`~/.local/bin/hypr-gnome-mouse-sync`)
Monitors `dconf watch /org/gnome/desktop/peripherals/mouse/` in real-time and applies settings via `hyprctl eval`:

```bash
hyprctl eval "hl.config({ input = { sensitivity = $SPEED, accel_profile = $ACCEL_LUA, natural_scroll = $NATURAL_LUA } })"
```

### Systemd User Unit (`~/.config/systemd/user/hypr-gnome-mouse-sync.service`)
```ini
[Unit]
Description=Sync GNOME Settings Mouse Sensitivity to Hyprland
After=graphical-session.target

[Service]
ExecStart=/home/youki/.local/bin/hypr-gnome-mouse-sync
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
```

---

## Status
- **Service**: Active and running (`systemctl --user status hypr-gnome-mouse-sync.service`).
- **Functionality**: Adjusting mouse sliders in GNOME Control Center now updates Hyprland mouse speed live in real-time.

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[system-profile]]
