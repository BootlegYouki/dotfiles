# Custom Scripts

Comprehensive catalogue of user scripts and helper utilities installed in `~/.local/bin/` on this machine.

---

## Autostart, Display & UI
- **`autostart-manager`**: Graphical / TUI Startup Applications Manager. Allows enabling/disabling autostart entries in `~/.config/autostart` (mapped to `SUPER + ALT + A`).
- **`nightlight`**: Toggles `hyprsunset -t 4000` (4000K warm color temperature) for night-time eye comfort (mapped to `SUPER + SHIFT + N`).
- **`caelestia-auto-reload`**: Active background daemon watching `~/.config/quickshell/caelestia` via `inotifywait`. Automatically reloads the Caelestia Quickshell UI on file saves.
- **`caelestia-wallpaper-shift`**: Utility script to shift or cycle desktop wallpapers dynamically.
- **`sync-sddm-pixie`**: Copies the active desktop wallpaper to `/usr/share/sddm/themes/pixie/assets/background.jpg` and recalculates accent colors for SDDM login screen. Triggered automatically by Caelestia post-hooks.
- **`hypr-gnome-mouse-sync`**: Daemon that reads mouse acceleration and speed settings from GNOME dconf and synchronizes them into Hyprland's input config.

## Audio & Media
- **`restart-audio`**: Fast recovery utility. Restarts `pipewire.service`, `pipewire-pulse.service`, and `wireplumber.service` user units when audio routing or devices hang.
- **`vlc`**: Wrapper script that strips recursive launch flags to prevent desktop freezes when VLC is configured as the default MIME video player.

## System, Maintenance & Sync
- **`dotfiles-sync`**: Synchronizes local `~/.config` changes to `~/dotfiles`.
- **`backup-system`**: Creates system configuration and package state backups.
- **`fast-speedtest`**: Low-latency network benchmark measuring DNS resolution speed, ping, and downstream throughput.
- **`rclone`**: Standalone rclone binary powering `archbrain-sync.service` (syncs `~/ArchBrain` to Google Drive).

## Caelestia Romaji Daemon
- **`caelestia-romaji`**: CLI tool for Japanese Romaji transliteration and search.
- **`caelestia-romaji-daemon`**: Python daemon (`caelestia-romaji-daemon`) running under `~/.local/share/caelestia/venv` that provides instantaneous romaji search matching for the Caelestia app launcher.

## Gaming & Input
- **`genshin_f_macro.py`**: Event-driven Genshin Impact rapid F-spam macro daemon (`genshin-f-macro.service`). Listens on Hyprland IPC (`.socket2.sock`) to guarantee that `Ctrl + F` spamming only activates when the game window is focused, pausing automatically when switching to other apps.

---

## Related Notes
- [[caelestia-hyprland]]
- [[system-services]]
- [[sddm-pixie-display-manager]]
- [[audio-recovery-and-taskbar-widget]]
