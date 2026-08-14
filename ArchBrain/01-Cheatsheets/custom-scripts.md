# Custom Scripts

Scripts currently installed in `~/.local/bin/` on this machine.

## Autostart & Display
- **`autostart-manager`**: Startup Applications Manager (mapped to `SUPER + ALT + A`).
- **`nightlight`**: Custom script to toggle Night Light (4000K Warm Color Temperature) (mapped to `SUPER + SHIFT + N`).
- **`caelestia-wallpaper-shift`**: Utility script likely related to shifting or cycling wallpapers in Caelestia.

## System & Sync
- **`agy-sync-desktop`**: Syncs desktop entries/settings for AGY.
- **`backup-system`**: Custom backup utility for the system.
- **`dotfiles-sync`**: Script to synchronize dotfiles across repositories/drives.
- **`hypr-gnome-mouse-sync`**: Synchronizes GNOME Settings mouse speed to Hyprland.

## Caelestia Romaji
- **`caelestia-romaji`**: CLI tool/utility for Romaji lyrics.
- **`caelestia-romaji-daemon`**: Daemon running in the background for Romaji lyrics integration.

## Gaming & Macro
- **`genshin_f_macro.py`**: Genshin Impact rapid F-spam macro daemon (`genshin-f-macro.service`). Event-driven Hyprland focus tracking (`.socket2.sock`) ensures `Ctrl + F` toggle and F-spamming ONLY activate when Genshin Impact (`steam_proton`, `twintaillauncher`, `genshinimpact.exe`) is the active focused window. Automatically pauses and hides status indicator when switching to other apps (browser, terminal, editor). Directly integrated into Caelestia Shell's native notification container (`modules/notifications/Content.qml`).

## Related Notes
- [[caelestia-hyprland]]
- [[system-services]]
