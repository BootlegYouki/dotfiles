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

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[system-profile]]
- [[installed-applications]]
