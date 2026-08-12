# 🛠️ Fix: Discord Launch Failure & Updater Loop on Linux

Solutions for Discord failing to launch via keybindings (`SUPER + D`) and host update loop fixes.

---

## 1. 🛑 Keybinding / Launch Failure (`SUPER + D`)

### Issue
Pressing `SUPER + D` or executing `discord` failed to launch Discord.

### Root Cause
Two configuration issues pointing to an uninstalled `flatpak` binary:
1. **Wrapper Script**: [`~/bin/discord`](file:///home/youki/bin/discord) contained `exec flatpak run com.discordapp.Discord "$@"`, which took precedence in `$PATH`.
2. **Caelestia CLI Config**: [`~/.config/caelestia/cli.json`](file:///home/youki/.config/caelestia/cli.json) specified `["flatpak", "run", "com.discordapp.Discord"]` for the `communication` workspace toggle.

### Fix
- Updated [`~/bin/discord`](file:///home/youki/bin/discord) to execute `/usr/bin/discord "$@"`.
- Updated [`~/.config/caelestia/cli.json`](file:///home/youki/.config/caelestia/cli.json) to use `["uwsm", "app", "--", "discord"]`.
- Executed `hyprctl reload`.

---

## 2. ⚡ Bypass Host Update Loop ("Downloading / Installing Discord")

### Issue
Discord showed an update splash screen every launch.

### Fix
Added `"SKIP_HOST_UPDATE": true` to [`~/.config/discord/settings.json`](file:///home/youki/.config/discord/settings.json):

```json
{
  "SKIP_HOST_UPDATE": true
}
```

---

## Related Notes
- [[installed-applications]]
- [[xdg-autostart-apps]]
- [[desktop-caelestia-hyprland]]
- [[caelestia-sidebar-indicators]]
