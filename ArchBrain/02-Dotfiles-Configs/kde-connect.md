---
title: KDE Connect Configuration & Firewall Rules
date: 2026-08-11
---

# KDE Connect Configuration

KDE Connect allows seamless integration between your Linux desktop (Hyprland / Caelestia) and your mobile device (Android / iOS).

## Required Firewall Rules (UFW)
KDE Connect requires UDP and TCP ports **1714 to 1764** open on your local firewall:

```bash
sudo ufw allow 1714:1764/udp
sudo ufw allow 1714:1764/tcp
sudo ufw reload
```

## How to Pair Devices
1. Ensure both your computer and your phone/tablet are connected to the same Wi-Fi network.
2. Open the **KDE Connect** app on your phone.
3. Open **KDE Connect** on your computer (search `KDE Connect` in your Caelestia launcher / app menu or run `kdeconnect-app`).
4. Select your phone in the app list and click **Pair** (or accept the pair request on your phone).

## Useful Commands
- **List available devices:** `kdeconnect-cli -l`
- **Pair device directly:** `kdeconnect-cli -d <device_id> --pair`
- **Ping device:** `kdeconnect-cli -d <device_id> --ping`
- **Ring phone:** `kdeconnect-cli -d <device_id> --ring`

---

## Hyprland XDG Portal Setup (Remote Input Fix)

> [!IMPORTANT]
> KDE Connect's **remote input** feature (controlling PC mouse/keyboard from phone) requires a full XDG portal chain under Hyprland. Basic features (notifications, clipboard, file transfer) work without this.

### Required Packages
```bash
paru -S hypr-kdeconnect-fix-git      # provides hypr-kdeconnect-portal
paru -S xdg-desktop-portal-hyprland  # Hyprland portal backend (was missing!)
```

### Required Services
```bash
# Enable on login
systemctl --user enable --now hypr-kdeconnect-portal.service
# xdg-desktop-portal-hyprland starts automatically via xdg-desktop-portal
```

### portals.conf (`~/.config/xdg-desktop-portal/portals.conf`)
```ini
[preferred]
default=hyprland;gtk
org.freedesktop.portal.RemoteDesktop=hypr-kdeconnect
```
This tells xdg-desktop-portal to use `hyprland` for everything by default, but route `RemoteDesktop` specifically to `hypr-kdeconnect` (needed for KDE Connect virtual input).

### Verify All Three Services Are Running
```bash
systemctl --user status xdg-desktop-portal.service
systemctl --user status xdg-desktop-portal-hyprland.service
systemctl --user status hypr-kdeconnect-portal.service
```

### If Something Breaks — Restart Order
```bash
systemctl --user restart xdg-desktop-portal.service
systemctl --user restart hypr-kdeconnect-portal.service
```

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[xdg-autostart-apps]]
