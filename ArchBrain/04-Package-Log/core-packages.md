# Core System Packages

Explicitly installed core packages driving the OS, DE, and Shell experience.

## OS: CachyOS Integration
- `linux-cachyos` / `linux-cachyos-lts` (Custom Cachy kernels)
- `cachyos-settings`, `cachyos-hooks`
- `cachyos-kernel-manager`, `cachyos-packageinstaller`
- `proton-cachyos-slr` (Gaming optimization)

## Window Manager: Hyprland Ecosystem
- `hyprland` (0.56.2-1)
- `hyprlock`, `hyprpicker`, `hyprsunset`
- `xdg-desktop-portal-hyprland`
- `python-hyprland-*` tools (config, monitors, schema, socket, state)
- `hypr-kdeconnect-fix-git`

## Desktop Environment: Caelestia Shell
- `caelestia-shell` (2.3.0-1)
- `caelestia-cli`
- `caelestia-sddm-locklike-git`
- `quickshell-git` (The underlying QML desktop shell engine)

## Core Tools
- `ghostty` (Primary Terminal)
- `zed` (Primary Code & Text Editor)
- `pwvucontrol` (Primary Audio & Device Mixer)
- `fish` (Shell)
- `starship` (Prompt)
- `pamac-aur` / `archlinux-appstream-data` (GUI App Store)
- `hyprmod` (Primary GTK4/Libadwaita System Settings app, bound to `Super + I` and named "Settings")

## Desktop Applications
- `gnome-calculator` (Calculator)
- `loupe` (Image / Photo Viewer)
- `evince` (Document / PDF Viewer)
- `pinta` (Image Editor / Paint.NET equivalent)
- `gnome-system-monitor` (GUI Task & Process Manager)
- `brave-origin-bin` (Web Browser - Brave Origin, minimalist release)
- `brave-bin` (Web Browser - Brave)
- `discord` (Communication)
- `obsidian` (Knowledge Base & Notes)
- `pi` (`@earendil-works/pi-coding-agent` AI coding agent harness with `subagent`, `todo`, `obsidian-vault`, and `bash-guard` extensions)
- `Google Office Suite` (Desktop Web Apps: Docs, Sheets, Slides)
- `twintaillauncher-bin` / `steam` (Gaming Launchers)
- `jdk17-openjdk` / `android-tools` / `android-udev` (Android Development & Emulation)

## File Management
- `nautilus` (GNOME Files - Primary GUI File Explorer, `Super + E`)
- `file-roller` (Archive manager integration)

## Removed Bloat & Unused Desktop Environments
- **GNOME Shell & GDM Stack**: Completely purged (`gdm`, `gnome-shell`, `gnome-session`, `mutter`, `gnome-settings-daemon`, `gnome-system-monitor`, `gnome-calculator`, `seahorse`, `xdg-desktop-portal-gnome`, `ibus`). Frees ~442 MB and prevents conflicting portal/input-method daemons.
- **Bluetooth Stack**: Completely purged (`blueman`, `gnome-bluetooth-3.0`) as no Bluetooth hardware is in use.

## Related Notes
- [[android-sdk-emulator]]
- [[gui-software-managers]]
- [[system-services]]

