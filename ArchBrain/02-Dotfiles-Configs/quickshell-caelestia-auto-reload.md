# Caelestia Shell Auto-Reload Watcher Daemon

Automated watcher service that detects file modifications in Caelestia and Quickshell QML directories and restarts the shell automatically without requiring manual keybind triggers (`Ctrl+Super+Alt+R`).

---

## Service Architecture

### 1. Watcher Script (`~/.local/bin/caelestia-auto-reload`)
- **Monitored Directories**:
  - `~/.config/quickshell/caelestia/`
  - `~/.config/caelestia/`
- **Events Tracked**: `close_write`, `moved_to`, `delete`, `create` via `inotifywait`.
- **Debouncing**: `350ms` debounce threshold to avoid restart thrashing during rapid multi-file writes.
- **Restart Trigger**:
  ```bash
  qs -c caelestia kill
  sleep 0.15
  caelestia shell -d
  ```

### 2. Systemd User Unit (`~/.config/systemd/user/caelestia-auto-reload.service`)
- Runs continuously in background as a user daemon (`WantedBy=default.target`).
- Auto-restarts on failure.

---

## Related Notes
- [[caelestia-hyprland]]
- [[quickshell-popouts-camera-nightlight]]
- [[system-cheatsheet]]
