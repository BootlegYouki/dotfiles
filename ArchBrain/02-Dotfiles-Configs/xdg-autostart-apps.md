# 🚀 Session Autostart Applications (Steam, Spotify, Discord)

Configuration for desktop applications launching automatically on Hyprland session login via XDG Autostart and UWSM systemd scope wrappers.

---

## 📁 Autostart Location & Files

All startup desktop entries are stored in `~/.config/autostart/`:

- **Steam**: [`~/.config/autostart/steam.desktop`](file:///home/youki/.config/autostart/steam.desktop)
- **Spotify**: [`~/.config/autostart/spotify.desktop`](file:///home/youki/.config/autostart/spotify.desktop)
- **Discord**: [`~/.config/autostart/discord.desktop`](file:///home/youki/.config/autostart/discord.desktop)

---

## ⚙️ Execution Commands & Launch Flags

Each application is configured to launch under UWSM (`uwsm app -- <cmd>`) to preserve systemd session scoping and clean process tracking:

```ini
# Steam (starts minimized in system tray)
Exec=uwsm app -- steam -silent %U

# Spotify (starts minimized)
Exec=uwsm app -- spotify --minimized %U

# Discord (starts minimized in background)
Exec=uwsm app -- discord --start-minimized %U
```

> [!NOTE]
> UWSM and `systemd-xdg-autostart-generator` convert these `.desktop` files into systemd user units:
> - `app-steam@autostart.service`
> - `app-spotify@autostart.service`
> - `app-discord@autostart.service`

---

## 🔒 Deferred Autostart on Initial Lockscreen Unlock

To prevent autostart apps from opening windows before the user enters their password on boot:
1. `execs.lua` masks `xdg-desktop-autostart.target` on Hyprland startup (`systemctl --user mask xdg-desktop-autostart.target`).
2. Caelestia Shell (`Lock.qml`) listens for the session unlock signal (`onLockedChanged` when `!lock.locked`).
3. Upon initial unlock, [`~/bin/on-unlock-autostart.sh`](file:///home/youki/bin/on-unlock-autostart.sh) runs, unmasking and launching `xdg-desktop-autostart.target` cleanly AFTER password entry.

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[system-profile]]
- [[installed-applications]]
