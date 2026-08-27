# SDDM Display Manager & Pixie Theme Configuration

## Overview
Migrated from the previous pseudo-login setup (getty `tty1` autologin + Caelestia force lock on boot) to a genuine display manager using **SDDM** (Qt6) and the **Pixie SDDM** theme.

---

## Architecture & Dynamic Theming

### 1. SDDM Service
- **Service**: `sddm.service` enabled as system default display manager (`display-manager.service`).
- **Config Directory**: `/etc/sddm.conf.d/10-theme.conf`
  ```ini
  [Theme]
  Current=pixie
  ```

### 2. Pixie Theme Installation
- **Source**: [pixie-sddm](https://github.com/xCaptaiN09/pixie-sddm) (Qt6 / Material Design 3 inspired).
- **Installed Location**: `/usr/share/sddm/themes/pixie/`
- **Dependencies**: `sddm`, `qt6-declarative`, `qt6-svg`.
- **User Avatar**: Synchronized from `~/.face` to `/usr/share/sddm/themes/pixie/assets/avatar.jpg` and `/usr/share/sddm/faces/youki.face.icon`.
- **Dynamic Color Extraction**: Automatically calculates Material 3 accent hue based on the current wallpaper image (`autoColor=true` in `theme.conf`).

### 3. Dynamic Wallpaper Synchronization
- **Sync Script**: `~/.local/bin/sync-sddm-pixie` copies the currently selected wallpaper directly to `/usr/share/sddm/themes/pixie/assets/background.jpg`.
- **Automatic Caelestia Post-Hook**: Configured in `~/.config/caelestia/cli.json`:
  ```json
  "wallpaper": {
      "postHook": "/home/youki/.local/bin/sync-sddm-pixie"
  },
  "theme": {
      "postHook": "/home/youki/.local/bin/sync-sddm-pixie"
  }
  ```
  Whenever you change your wallpaper (via `SUPER + Comma` / `SUPER + Period` or Caelestia's wallpaper switcher), the login screen background and color accents update dynamically.

### 4. Removed Getty Autologin & Hyprland Boot Lock
- Removed drop-in override: `/etc/systemd/system/getty@tty1.service.d/autologin.conf`.
- In `~/.config/hypr/hyprland/execs.lua`, removed the boot-lock IPC loop (`until qs ipc -c caelestia call lock lock...`).
- Caelestia lockscreen remains active for `SUPER + L` and idle timeouts.

---

## Testing & Verification
To test the SDDM theme in an isolated test window:
```bash
sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/pixie
```

---

## Related Notes
- [[caelestia-hyprland]]
- [[shell-terminal-config]]
- [[restore-setup-script]]
