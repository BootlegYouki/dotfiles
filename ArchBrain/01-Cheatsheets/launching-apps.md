# Manual Application & Environment Launch Guide

If you are a new user operating this system without AI assistance, this cheatsheet provides the fundamental commands required to launch apps and manage the environment effectively. 

## 1. Launching Applications (UWSM/Hyprland)

> [!IMPORTANT]  
> Because this environment uses `uwsm` (Universal Wayland Session Manager) under Hyprland, graphical applications should **never** be launched directly by typing their raw binary name in the terminal. Doing so orphans them from the session manager and systemd environment variables.

**Always wrap GUI applications with `uwsm app --`:**

### Web & Communication
- **Brave Browser:** `uwsm app -- brave`
- **Discord:** `uwsm app -- discord`
- **Spotify:** `uwsm app -- spotify`

### Gaming
- **Steam:** `uwsm app -- steam`
- **Twintail Launcher:** `uwsm app -- twintaillauncher` (or `twintail-launcher`)

### Productivity & Tools
- **Obsidian:** `uwsm app -- obsidian`
- **Zed Editor:** `uwsm app -- zeditor`
- **File Manager (Nautilus):** `uwsm app -- nautilus`

## 2. Shell & Terminal Aliases (Fish)
Your Fish shell (`~/.config/fish/config.fish`) comes with quality-of-life abbreviations and aliases built-in:
- **`ls`** -> `eza --icons --group-directories-first -1` (modern `ls` replacement)
- **`lg`** -> `lazygit`
- **`gd`, `ga`, `gc`, `gp`, `gpl`** -> Git shortcuts for `diff`, `add .`, `commit`, `push`, `pull`.
- Directory jumping is handled seamlessly by `zoxide` (just use `cd <name>`).

## 3. Package Management (CachyOS)
- **System Updates:** Run `sudo pacman -Syu` or simply use the Cachy-Update Systray Applet.
- **Install Official App:** `sudo pacman -S <package_name>`
- **Install Community/AUR App:** `paru -S <package_name>` (do not use `sudo` with `paru`)

## 4. Managing User Services (Systemd)
Custom utilities like the Caelestia Romaji lyrics translator run as user-level systemd services.
- **Check Status:** `systemctl --user status caelestia-romaji.service`
- **Restart a Service:** `systemctl --user restart caelestia-romaji.service`
- **Stop a Service:** `systemctl --user stop caelestia-romaji.service`
- **System-level Services** (e.g., Genshin macro): `sudo systemctl restart genshin-f-macro.service`

## 5. Reloading the Desktop Shell
If the desktop environment (UI/Widgets) freezes or you've made manual changes:
- Press **ALT+F4** (or `SUPER+K`) to access the Session Menu.
- Alternatively, run the Quickshell reload command if configured via `caelestia-cli`.

## Related Notes
- [[shell-terminal-config]]
- [[caelestia-hyprland]]
