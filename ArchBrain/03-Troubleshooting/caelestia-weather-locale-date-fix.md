# Caelestia Shell Weather & Date Locale Fix

## Issue Overview
In the Caelestia Shell weather tab (`WeatherTab.qml`) and calendar widgets, days of the week ("Huw", "Biy", "Sab", "Lin", "Lun", "Mar") and months ("Ago") were displaying in Filipino instead of English.

## Cause
The system locale `/etc/locale.conf` had `LC_TIME=fil_PH` set, which systemd user manager inherited upon boot. Qt's `Qt.locale()` used `LC_TIME` to format dates, causing dates in Quickshell/Caelestia to render in Filipino.

## Solution Executed

1. **System Locale Update**:
   Updated system locale via `localectl`:
   ```bash
   sudo localectl set-locale LC_TIME=en_US.UTF-8
   ```

2. **Environment.d User Override**:
   Created `~/.config/environment.d/10-locale.conf` to guarantee `LC_TIME` persistence across systemd user sessions:
   ```ini
   LC_TIME=en_US.UTF-8
   ```

3. **Session Environment & Caelestia Restart**:
   Updated systemd user environment and restarted Caelestia shell:
   ```bash
   systemctl --user set-environment LC_TIME=en_US.UTF-8
   LC_TIME=en_US.UTF-8 qs -c caelestia kill; sleep 0.5; LC_TIME=en_US.UTF-8 uwsm app -- caelestia shell -d
   ```

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[system-customizations-master-blueprint]]
