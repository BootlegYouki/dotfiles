---
title: Complete OS Configurations Backup
date: 2026-08-11
---

# Complete OS Configurations Backup

I have created a comprehensive backup of all the configurations and dotfiles we have set up in this OS environment. 

**Backup File:** `os-configurations-backup.tar.gz` (located in `~/ArchBrain/02-Dotfiles-Configs/`).

## Backed Up Components

The following directories and files have been safely archived:

1. **Desktop & Window Manager:**
   - `~/.config/hypr/` (Hyprland window manager configurations, keybinds, workspaces)
   - `~/.config/quickshell/caelestia/` (Caelestia Shell UI, panels, OSD, services, and the Nightlight widget)

2. **Terminal & Shell Environment:**
   - `~/.config/ghostty/` (Ghostty terminal emulator config)
   - `~/.config/fish/` (Fish shell configs and aliases)
   - `~/.config/starship.toml` (Starship prompt configuration)
   - `~/.config/fastfetch/` (System information fetch utility config)

3. **System Services & Autostart:**
   - `~/.config/autostart/` (XDG autostart apps and scripts)
   
4. **Custom Daemons:**
   - `~/.local/bin/caelestia-romaji-daemon` (The multithreaded Romaji & Translation daemon)
   - `~/.config/systemd/user/caelestia-romaji.service` (Systemd service file for the daemon)

## How to Restore

If you ever need to restore your entire setup (for instance, on a fresh install or if something breaks), run this exact command from your home directory:

```bash
tar -xzvf ~/ArchBrain/02-Dotfiles-Configs/os-configurations-backup.tar.gz -C ~/
```

### Post-Restore Steps:
- **Systemd Daemons:** Reload and restart your custom services:
  ```bash
  systemctl --user daemon-reload
  systemctl --user restart caelestia-romaji.service
  ```
- **Shells & Prompt:** Open a new terminal to let Fish and Starship reload their settings.
- **Desktop Environment:** You can reload Hyprland or log out and log back in to apply all UI/WM changes completely.
