# 🖥️ Caelestia Desktop Dotfiles & Custom Tools

A private backup of my custom CachyOS/Hyprland desktop setup, widgets, background daemons, and system documentation.

---

## 📁 Repository Structure

*   **`.config/hypr/`**: My core Hyprland window manager configurations and keyboard shortcuts.
*   **`.config/quickshell/caelestia/`**: The complete QML/JavaScript source code for the desktop widgets (top bar, lock screen, widgets, and lyrics display).
*   **`.local/bin/`**: Custom scripts and binary utilities:
    *   `caelestia-romaji-daemon` & `caelestia-romaji`: Convert Japanese/Korean lyrics and translate them to English on demand via direct socket IPC.
    *   `caelestia-wallpaper-shift`: Rotates wallpapers automatically.
    *   `backup-system`: System-wide backup script.
    *   `hypr-gnome-mouse-sync`: Syncs mouse sensitivities between environments.
    *   `nightlight`: Toggles screen color temperatures.
*   **`scripts/genshin_f_macro.py`**: A custom python script to intercept and spam the `F` key inside Genshin Impact while leaving typing unaffected globally.
*   **`systemd-system/genshin-f-macro.service`**: The systemd service descriptor to run the Genshin macro at boot.
*   **`ArchBrain/`**: A complete backup of my system notes, cheatsheets, dotfile guides, and troubleshooting documentation vault.

---

## ⚡ How to Manage the Services

### 1. Romaji & Lyrics Translation Daemon
Runs as a user-level service to Romanize and translate Spotify lyrics instantly in the desktop shell:
```bash
# Start/Enable on boot:
systemctl --user enable --now caelestia-romaji.service

# Restart:
systemctl --user restart caelestia-romaji.service

# Logs:
systemctl --user status caelestia-romaji.service
```

### 2. Genshin Impact Loot Macro
Runs as a system-level service to automate looting when active in the game window:
```bash
# Start/Enable on boot:
sudo systemctl enable --now genshin-f-macro

# Stop:
sudo systemctl stop genshin-f-macro

# Logs:
sudo systemctl status genshin-f-macro
```
