# 🚀 Session Autostart Applications (Disabled)

Autostart applications have been completely removed and disabled per user request.

---

## 📁 Current Status

- `~/.config/autostart/`: Cleared (no `.desktop` autostart files).
- Autostart scripts (`~/.config/hypr/scripts/autostart.sh`, `~/bin/on-unlock-autostart.sh`): Removed.
- `execs.lua`: Only runs core desktop services (gnome-keyring, polkit, cliphist, geoclue, mpris-proxy, nightlight, and lockscreen on boot). Zero applications are started automatically at boot or login.

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[system-profile]]
- [[installed-applications]]
