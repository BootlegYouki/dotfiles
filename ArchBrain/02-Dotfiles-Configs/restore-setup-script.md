# System Setup & Restoration Script

Documentation for `~/dotfiles/ArchBrain/02-Dotfiles-Configs/restore_setup.sh` which bootstraps this exact Caelestia/Hyprland environment.

## 1. System & Package Base
- Updates mirror lists via `cachyos-rate-mirrors`.
- Installs `paru` (AUR helper) and base development tools (`base-devel`, `git`).
- Installs the core multimedia stack: `pipewire`, `pipewire-alsa`, `pipewire-pulse`, `pipewire-jack` (replacing `jack2`), and `wireplumber`.

## 2. Core Dependencies
- **Wayland/Hyprland**: `hyprland`, `uwsm`, `waybar`, `hyprsunset`, `hyprpicker`.
- **Terminal & Shell**: `ghostty`, `fish`, `starship`, `fastfetch`.
- **CLI & Utilities**: `jq`, `socat`, `fd`, `ripgrep`, `fzf`, `zoxide`, `direnv`, `eza`.
- **Apps**: `discord`, `zed`, `vlc`, `brave-bin`, `spotify`, `steam`, `obsidian`.
- **AUR Components**: `quickshell-git`, `caelestia-cli`, `twintaillauncher-bin`.

## 3. Configuration & State Restoration
- Symlinks / copies all `.config/` components (excluding `rclone`) directly to `~/.config/`.
- Installs the system-wide Quickshell QML files into `/etc/xdg/quickshell/caelestia/`.
- Sets up `.local/bin` executable scripts and user themes/state in `.local/state/caelestia`.
- Clones and links the wallpaper repository (`laustoic-wallpaper-repo`).

## 4. Services & Autologin
- Deploys the `genshin-f-macro.service` to systemd and copies the python script.
- Reloads and enables `caelestia-romaji.service` for user.
- **TTY1 Autologin**: Disables bloated display managers (SDDM/GDM) and configures a 0-RAM overhead auto-login on `tty1` via `agetty`, which automatically launches `uwsm start hyprland-uwsm.desktop` (via the Fish config).
