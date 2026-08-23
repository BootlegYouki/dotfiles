# Brave Origin Browser Migration & Configuration

Documentation for the installation of Brave Origin (`brave-origin-bin`) and user profile migration from standard Brave (`brave-bin`).

---

## Overview
Brave Origin is a minimalist browser from the makers of Brave, optimized for speed and stripped of non-essential components.

- **Package**: `brave-origin-bin` (Installed via `paru -Sy brave-origin-bin` from the CachyOS repository)
- **Binary / Command**: `brave-origin` (`/usr/bin/brave-origin` -> `/opt/brave-origin-bin/brave-origin`)
- **Desktop Entry**: `/usr/share/applications/brave-origin.desktop`
- **WM Class**: `brave-origin`

---

## Profile & Storage Paths

| Application | Config Directory (`$XDG_CONFIG_HOME`) | Cache Directory (`$XDG_CACHE_HOME`) | Flags File |
| :--- | :--- | :--- | :--- |
| **Brave** | `~/.config/BraveSoftware/Brave-Browser/` | `~/.cache/BraveSoftware/Brave-Browser/` | `~/.config/brave-flags.conf` |
| **Brave Origin** | `~/.config/BraveSoftware/Brave-Origin/` | `~/.cache/BraveSoftware/Brave-Origin/` | `~/.config/brave-origin-flags.conf` |

---

## Data Migration Procedure

1. **Graceful Browser Termination**:
   Ensure all active Brave processes are cleanly stopped with `SIGTERM` so SQLite databases (`History`, `Cookies`, `Login Data`, `Web Data`, `Sessions`) checkpoint WAL files and release locks.
2. **Profile & Cache Copy**:
   ```bash
   mkdir -p ~/.config/BraveSoftware/Brave-Origin ~/.cache/BraveSoftware/Brave-Origin
   cp -a ~/.config/BraveSoftware/Brave-Browser/. ~/.config/BraveSoftware/Brave-Origin/
   cp -a ~/.cache/BraveSoftware/Brave-Browser/. ~/.cache/BraveSoftware/Brave-Origin/
   ```
3. **Lock Symlink Cleanup**:
   Remove stale `Singleton*` socket and lock links in the destination folder to prevent launch errors:
   ```bash
   rm -f ~/.config/BraveSoftware/Brave-Origin/Singleton*
   rm -f ~/.config/BraveSoftware/Brave-Origin/Default/LOCK
   ```
4. **Desktop & System Integration**:
   - `~/.config/hypr/variables.lua`: `browser = "brave-origin"`
   - `~/.config/caelestia/shell.json`: favouriteApps updated to `brave-origin`
   - Default MIME associations: `xdg-settings set default-web-browser brave-origin.desktop`

---

## Related Notes
- [[core-packages]]
- [[launching-apps]]
- [[desktop-caelestia-hyprland]]
