# 🖼️ Caelestia Launcher & Nexus Control Center: Missing Icon & Magenta Checkerboard Fix

## Cause
1. **Unindexed / Non-Standard Desktop Icon Names**: Applications like `Avahi SSH Server Browser` (`bshell`), `Avahi VNC Server Browser` (`bvnc`), `Avahi Zeroconf Browser` (`avahi-discover`), `Hardware Locality lstopo` (`hwloc`), and `uuctl` (`uuctl`) specify icon names that do not exist as standalone PNG/SVG files in icon theme directories.
2. **Qt Missing Texture Placeholder**: When Qt's `image://icon/` provider fails to locate an icon name on disk, it generates a 16x16 magenta & black checkerboard grid (`Image.Ready`).

---

## Resolution
1. **Uninstalled GNOME Software**:
   - Removed GNOME packages (`ptyxis`, `meld`) and unused dependencies via `sudo pacman -Rns`.
2. **Hidden GNOME & Broken No-Thumbnail Desktop Entries**:
   - Created `NoDisplay=true` / `Hidden=true` overrides in `~/.local/share/applications/` for `org.gnome.Ptyxis`, `org.gnome.Meld`, `org.gnome.Zenity`, `avahi-discover`, `bssh`, `bvnc`, `lstopo`, `nm-connection-editor`, `qv4l2`, `qvidcap`, `xgps`, `xgpsspeed`, `uuctl`, and `xfce4-about`.
   - Updated `~/.config/caelestia/shell.json` `launcher.hiddenApps` regex list to filter out `org\\.gnome\\..*`, `avahi-discover`, `bssh`, `bvnc`, `lstopo`, `nm-connection-editor`, `qv4l2`, `qvidcap`, `xgps.*`, `uuctl`, and `xfce4-about`.
3. **Icons & Fallback Engine**:
   - Updated `AppItem.qml`, `AppsPage.qml`, and `AllApps.qml` to use `"application-x-executable"` fallback for icon loading, ensuring Qt never displays a magenta/black checkerboard texture.

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[caelestia-ui-fixes]]
