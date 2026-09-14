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
  Waits until the previous Quickshell instance completely terminates before spawning a new one to prevent Layer-Shell and Hyprland IPC race conditions:
  ```bash
  qs -c caelestia kill
  # Wait until old process terminates
  for i in {1..30}; do
      if ! pgrep -f "quickshell.*caelestia" >/dev/null 2>&1; then
          break
      fi
      sleep 0.05
  done
  sleep 0.15
  # Refresh live Hyprland signature
  CURRENT_SIG=$(hyprctl instances -j 2>/dev/null | jq -r '.[0].instance' 2>/dev/null)
  [ -n "$CURRENT_SIG" ] && export HYPRLAND_INSTANCE_SIGNATURE="$CURRENT_SIG"
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
