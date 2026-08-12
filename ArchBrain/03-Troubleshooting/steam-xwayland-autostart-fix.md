# 🛠️ Fix: Steam "Unable to open a connection to X" Error on Startup

Complete diagnosis and fix for Steam throwing the X11 connection error when autostarted under Wayland / Hyprland / UWSM.

---

## ❓ Root Cause Analysis

Systemd user services (`app-steam@autostart.service`) run in an isolated systemd user session environment that does not inherit shell `$DISPLAY` variables by default.

When systemd launches Steam on boot:
1. `$DISPLAY` is unpopulated in systemd's service environment (`Environment=`).
2. Xwayland initializes asynchronously during Hyprland session startup.
3. Steam attempts to connect to X without `$DISPLAY` set, triggering:
   `Unable to open a connection to X. Check your DISPLAY environment variable...`

---

## 🔧 Solution

Created a dedicated wrapper script [`~/bin/autostart-steam.sh`](file:///home/youki/bin/autostart-steam.sh):

```bash
#!/bin/bash
export DISPLAY="${DISPLAY:-:1}"
export WAYLAND_DISPLAY="${WAYLAND_DISPLAY:-wayland-1}"

# Wait up to 15s for Xwayland server to accept connections
for i in {1..30}; do
    if xprop -root >/dev/null 2>&1; then
        break
    fi
    sleep 0.5
done

exec /usr/bin/steam -silent "$@"
```

And updated [`~/.config/autostart/steam.desktop`](file:///home/youki/.config/autostart/steam.desktop):

```ini
[Desktop Entry]
Type=Application
Name=Steam
Comment=Application for managing and playing games on Steam
Exec=uwsm app -- /home/youki/bin/autostart-steam.sh %U
Icon=steam
Terminal=false
Categories=Network;FileTransfer;Game;
StartupWMClass=Steam
X-GNOME-Autostart-enabled=true
```

Verified via `systemctl --user start app-steam@autostart.service` — active & running cleanly without errors!

---

## Related Notes
- [[gaming-steam-overwatch2]]
- [[xdg-autostart-apps]]
- [[desktop-caelestia-hyprland]]
