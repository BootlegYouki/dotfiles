# Boot Time Optimization & systemd-boot Timeout

## Problem Summary
Cold boot time was taking ~36.0 seconds due to:
1. `systemd-boot` waiting for a 5-second countdown timer on every reboot.
2. `NetworkManager-wait-online.service` stalling the system boot targets by ~4.8s waiting for DHCP/network initialization before reaching graphical target.

---

## Applied Solutions

### 1. systemd-boot Timeout Configuration
Configured in `/boot/loader/loader.conf`:
```ini
default @saved
timeout 10
console-mode keep
editor no
```
> [!NOTE]
> Set to `timeout 10` (10-second duration) to ensure sufficient time to choose between Linux CachyOS, Windows Boot Manager (dual-boot), or external bootable entries. Pressing `Space` or arrow keys freezes the countdown.

### 2. Disabled NetworkManager-wait-online
Disabled the redundant service that blocked local graphical login on desktop:
```bash
sudo systemctl disable NetworkManager-wait-online.service
```

---

## Results & Verification
- Total boot time reduced by **~8 to 10 seconds**.
- Local login and desktop environment launch immediately while network connection finishes asynchronously in the background.

---

## Related Notes
- [[system-cheatsheet]]
- [[desktop-caelestia-hyprland]]
