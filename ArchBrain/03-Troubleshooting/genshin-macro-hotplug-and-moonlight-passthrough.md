# Genshin Impact Macro Daemon: Moonlight Passthrough & Keyboard Hotplugging

Detailed root-cause analysis and permanent resolution for `genshin-f-macro.service` failing to trigger `Ctrl + F` rapid spamming under Moonlight streaming or after device disconnections.

---

## Symptoms
- Pressing `Ctrl + F` inside Genshin Impact failed to toggle the loot macro daemon.
- Journal logs for `genshin-f-macro.service` displayed thousands of consecutive `Device read error: [Errno 19] No such device` loops.
- Daemon only recognized a single physical keyboard and ignored Moonlight/Sunshine virtual input.

---

## Root Cause Analysis
1. **Key Count Filtering Discarded Secondary Keyboards**:
   - `find_keyboards()` selected only devices matching `max(len(keys))` across candidates.
   - The physical keyboard (`hfd.cn USB DEVICE`) registered 163 keys, while Sunshine's `Keyboard passthrough` registered 126 keys.
   - Consequently, `Keyboard passthrough` was dropped from monitoring, completely blinding the macro to any keystrokes sent over Moonlight streaming.
2. **Missing Dynamic Hotplugging / Device Disconnect Handling**:
   - Keyboard devices were only detected once during initial daemon startup. Sunshine's virtual devices, dynamic USB reconnections, and Bluetooth keyboards plugged in later were never monitored.
   - When a monitored device disconnected (such as Sunshine terminating a stream session), `dev.read()` threw `OSError(ENODEV)`. The service failed to remove the dead file descriptor, causing `select.select()` to spin infinitely with `[Errno 19] No such device`.
3. **Quickshell IPC Root Ownership**:
   - The daemon ran `qs ipc` as `root` inside `/run/user/1000/`, creating `/run/user/1000/quickshell` owned by `root:root` and preventing the user's desktop Caelestia Quickshell instance from binding IPC endpoints.

---

## Resolution & Implementation
1. **Dynamic Hotplug Scanner & Multi-Device Monitoring**:
   - Updated `~/custom_scripts/genshin_f_macro.py` to monitor all valid keyboards (full A-Z key set, Ctrl, and F) without filtering by `max_keys`.
   - Added periodic hotplug scanning (every 2.0s in the select loop) to automatically discover and attach new keyboards (including Moonlight `Keyboard passthrough`).
   - Added clean device removal on `OSError` / `ENODEV` to prevent infinite error loops upon disconnect.
2. **Robust Multi-Keyboard Modifier Tracking**:
   - Key modifier state (`held_ctrl_keys`) tracks `(fd, code)` combinations across all keyboards with active key fallback.
3. **Quickshell Permissions & Drop-in Execution**:
   - Fixed ownership of `/run/user/1000/quickshell` to `youki:youki`.
   - Updated `set_macro_indicator()` to execute `qs ipc` via `sudo -u target_user`.
4. **Synchronization**:
   - Mirrored changes across `~/custom_scripts/genshin_f_macro.py` and `~/dotfiles/custom_scripts/genshin_f_macro.py`.

---

## Related Notes
- [[custom-scripts]]
- [[streaming-tailscale-sunshine-moonlight]]
- [[remote-wake-on-lan-and-moonlight-geometry-handoff]]
- [[caelestia-hyprland]]
