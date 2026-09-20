# Custom Scripts

Comprehensive catalogue of user scripts and helper utilities installed on this machine across `~/.local/bin/` and the dedicated `~/custom_scripts/` directory.

---

## Dedicated Custom Scripts Directory (`~/custom_scripts/`)
Centralized directory for custom daemons, macros, and integration scripts (mirrored in `~/dotfiles/custom_scripts/`):
- **`genshin_f_macro.py`**: Event-driven Genshin Impact rapid F-spam macro daemon (`genshin-f-macro.service`). Listens on Hyprland IPC (`.socket2.sock`) to guarantee that `Ctrl + F` spamming only activates when the game window is focused, pausing automatically when switching to other apps.
- **`caelestia-romaji-daemon`**: Python daemon (`caelestia-romaji.service`) running under `~/.local/share/caelestia/venv` that provides instantaneous Japanese romaji search matching, lyrics conversion, and Google Translate English translation. Symlinked to `~/.local/bin/caelestia-romaji-daemon`.
- **`caelestia-romaji`**: CLI client utility communicating with `caelestia-romaji-daemon` over UNIX domain socket (`/run/user/$UID/caelestia-romaji.sock`). Symlinked to `~/.local/bin/caelestia-romaji`.
- **`toggle_monitor.py`**: Dual-monitor controller and DPMS query script for Hyprland (`status`, `detect`, `on`, `off`). Managed persistently via Caelestia's `Hypr.qml` singleton to provide zero-delay Quick Toggles rendering.
- **`toggle-autologin`**: Helper utility to check (`status`), enable (`on`), disable (`off`), or `toggle` SDDM autologin (`/etc/sddm.conf.d/autologin.conf`) for unattended remote desktop streaming via Sunshine/Tailscale, integrated with Caelestia Control Center Quick Toggles.

---

## Autostart, Display & UI (`~/.local/bin/`)
- **`autostart-manager`**: Graphical / TUI Startup Applications Manager. Allows enabling/disabling autostart entries in `~/.config/autostart` (mapped to `SUPER + ALT + A`).
- **`nightlight`**: Toggles `hyprsunset -t 4000` (4000K warm color temperature) for night-time eye comfort (mapped to `SUPER + SHIFT + N`).
- **`caelestia-auto-reload`**: Active background daemon watching `~/.config/quickshell/caelestia` via `inotifywait`. Automatically reloads the Caelestia Quickshell UI on file saves.
- **`caelestia-wallpaper-shift`**: Utility script to shift or cycle desktop wallpapers dynamically.
- **`sync-sddm-pixie`**: Copies the active desktop wallpaper to `/usr/share/sddm/themes/pixie/assets/background.jpg` and recalculates accent colors for SDDM login screen. Triggered automatically by Caelestia post-hooks.
- **`toggle-autologin`**: Helper utility to check (`status`), enable (`on`), disable (`off`), or `toggle` SDDM autologin (`/etc/sddm.conf.d/autologin.conf`) for unattended remote desktop streaming via Sunshine/Tailscale, integrated with Caelestia Control Center Quick Toggles.
- **`hypr-gnome-mouse-sync`**: Daemon that reads mouse acceleration and speed settings from GNOME dconf and synchronizes them into Hyprland's input config.

## AI & Local Models (`~/.local/bin/`)
- **`minicpm`**: Terminal launcher for `openbmb/MiniCPM5-2B` (`MiniCPM5-2B-Q4_K_M.gguf`) using `llama-cli`. Configured with `-t 6` CPU cores, `--temp 1.0`, `--top-p 0.95`, and `--min-p 0.0`. Supports interactive chat mode, single-turn prompts (`-st`), or custom arguments.

## Audio & Media
- **`restart-audio`**: Fast recovery utility. Restarts `pipewire.service`, `pipewire-pulse.service`, and `wireplumber.service` user units when audio routing or devices hang.
- **`vlc`**: Wrapper script that strips recursive launch flags to prevent desktop freezes when VLC is configured as the default MIME video player.

## System, Maintenance & Sync
- **`dotfiles-sync`**: Synchronizes local `~/.config`, `~/custom_scripts`, and `~/ArchBrain` changes to `~/dotfiles`.
- **`backup-system`**: Creates system configuration and package state backups.
- **`fast-speedtest`**: Low-latency network benchmark measuring DNS resolution speed, ping, and downstream throughput.
- **`rclone`**: Standalone rclone binary powering `archbrain-sync.service` (syncs `~/ArchBrain` to Google Drive).

---

## Related Notes
- [[caelestia-hyprland]]
- [[system-services]]
- [[sddm-pixie-display-manager]]
- [[audio-recovery-and-taskbar-widget]]
