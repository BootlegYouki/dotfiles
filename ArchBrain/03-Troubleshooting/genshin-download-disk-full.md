# Genshin Impact Download Failure & System Reboot (Disk Full & Complete Reinstall)

## Symptoms
- System unexpectedly rebooted during Genshin Impact download in Twintail Launcher due to 0-Bytes SSD capacity.
- Twintail Launcher queue retained failed download history in old state files.

---

## Solutions Implemented

### 1. SSD Storage Expansion (Completed)
- Disk expanded to **464 GB** (365 GB free space available).

### 2. Complete Nuclear Reinstall of Twintail Launcher
- Performed complete purge of app data, configuration, state, and caches:
  ```bash
  pkill -9 -f twintaillauncher
  flatpak uninstall --user -y --delete-data app.twintaillauncher.ttl
  rm -rf ~/.var/app/app.twintaillauncher.ttl
  rm -rf ~/.local/share/twintaillauncher ~/.config/twintaillauncher ~/.cache/twintaillauncher
  flatpak install --user -y app.twintaillauncher.ttl
  ```

### 3. Active Sleep Inhibitor
- Active systemd sleep inhibitor (`task-344`) running to prevent laptop sleep during long downloads.

---

## Related Notes
- [[btrfs-live-partition-expansion]]
- [[gaming-genshin-impact-cachyos]]
- [[laptop-thermal-management]]
- [[cachyos-features-and-tools]]
