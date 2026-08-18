# VLC Default Media Player & Wrapper Recursion Fix

Documentation of the fix for VLC not launching when playing videos from the Caelestia Shell screen recording widget or file managers.

---

## Symptoms & Root Cause

### 1. Symptoms
- Clicking the play button on recordings in the Caelestia Shell screen recorder card did nothing.
- Running `vlc` from terminal hung indefinitely without opening a window.

### 2. Root Cause
1. **Recursive Wrapper Script**:
   - `~/.local/bin/vlc` contained `exec env QT_QPA_PLATFORM=wayland vlc "$@"`.
   - Because `~/.local/bin` was prioritized in `$PATH`, invoking `vlc` caused the wrapper to execute itself endlessly in an infinite fork loop.
2. **Missing Caelestia Shell Playback Config**:
   - In `~/.config/caelestia/shell.json`, `general.apps.playback` was not configured.
   - `RecordingList.qml` uses `GlobalConfig.general.apps.playback` to spawn the video player.
3. **MIME Associations**:
   - `~/.config/mimeapps.list` had not explicitly registered VLC as the default handler for video/audio MIME types.

---

## Resolution

1. **Fixed Wrapper Script**:
   - Updated `~/.local/bin/vlc` to execute `/usr/bin/vlc` explicitly:
     ```sh
     #!/bin/sh
     exec env QT_QPA_PLATFORM=wayland /usr/bin/vlc "$@"
     ```
2. **Configured Caelestia Shell**:
   - Added `"apps": { "playback": ["vlc", "--started-from-file"] }` under `"general"` in `~/.config/caelestia/shell.json`.
   - Reloaded Caelestia Shell via `caelestia shell -k && caelestia shell -d`.
3. **Set Default MIME Handlers**:
   - Assigned VLC as the default application for `video/*` and `audio/*` formats in `~/.config/mimeapps.list`.

---

## Related Notes
- [[caelestia-hyprland]]
- [[custom-scripts]]
- [[core-packages]]
