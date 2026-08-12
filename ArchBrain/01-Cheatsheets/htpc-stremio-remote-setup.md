# Arch Linux HTPC & Stremio Setup Guide (Native + KDE Connect)

## Overview & Architecture
To transform CachyOS into a media center (HTPC), use **Native Stremio** paired with **KDE Connect** for smartphone wireless remote control (or a physical Google TV Bluetooth Remote).

---

## 1. Installing Stremio

Install native Stremio via Flatpak:

```bash
flatpak install --user -y flathub com.stremio.Stremio
```

To launch Stremio under UWSM:
```bash
uwsm app -- flatpak run com.stremio.Stremio
```

---

## 2. Remote Control Setup

### A. KDE Connect (Smartphone Wi-Fi Remote)
Turns any Android or iPhone into a wireless touchpad, keyboard, volume, and media controller over Wi-Fi.

1. **Install KDE Connect on CachyOS**:
   ```bash
   sudo pacman -S kdeconnect
   ```
2. Install **KDE Connect** on your phone (Google Play Store / Apple App Store).
3. Pair your phone and laptop over Wi-Fi.

### B. Physical Google TV Bluetooth Remote
If using a physical **Chromecast / Google TV Bluetooth Remote**:
1. Put the remote in pairing mode (Hold **Back + Home**).
2. Pair via Bluetooth (`bluetoothctl` or GUI).
3. D-Pad navigation, Select, Back, and Volume keys work natively out-of-the-box as standard Linux media keys.

---

## Related Notes
- [[cachyos-features-and-tools]]
- [[desktop-caelestia-hyprland]]
