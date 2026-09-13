# Multi-Monitor Inactivity DPMS Sleep/Wake & Display Quick Toggle Fix

Documentation of the resolution for main monitor (`HDMI-A-1`) auto-waking on inactivity, secondary monitor (`DP-1`) getting stuck in black/sleep state, and the Caelestia Control Center Display Quick Toggle turning off the primary monitor upon re-enabling.

---

## Symptoms & Root Causes

### 1. Inactivity Screen Blanking Auto-Wake & 2nd Monitor Black Freeze
- **Symptoms:**
  1. When stepping away from the PC, the inactivity timer triggers screen off (DPMS off). The main monitor (`HDMI-A-1`, ASUS VA24E) turns off and immediately turns right back on.
  2. The secondary monitor (`DP-1`, Dell P2219H) powers off and does not turn back on. However, Hyprland still recognizes it as active (`dpmsStatus: 1`), allowing windows and mouse cursor to navigate into a completely black screen with no signal.
- **Root Cause:**
  1. ASUS VA24E drops its HDMI 5V Hot-Plug Detect (HPD) pin for ~50ms upon entering standby power-saving mode.
  2. Linux DRM / Aquamarine caught this HPD pulse (`Connector HDMI-A-1 disconnected` -> `Connector HDMI-A-1 connected`) and treated it as a hotplugged monitor, immediately issuing a modeset to wake `HDMI-A-1`.
  3. While `HDMI-A-1` woke up, `DP-1` was mid-shutdown. Aquamarine tried to modeset `DP-1` while atomic page-flips were still in flight (`ERR from aquamarine ]: drm: Cannot commit when a page-flip is awaiting`).
  4. The modeset commit on `DP-1` was rejected by KMS, leaving the physical monitor in sleep without DisplayPort link training. However, Hyprland's compositor state marked `DP-1` as enabled (`dpmsStatus: 1`). Subsequent user input failed to wake `DP-1` because Hyprland believed it was already awake.

### 2. Control Center Display Quick Toggle Blanking Primary Monitor & Scrambling Layout
- **Symptoms:**
  1. Clicking the Display quick toggle to turn off the 2nd monitor worked properly.
  2. Clicking it again to turn the 2nd monitor back ON caused the MAIN monitor (`HDMI-A-1`) to turn off as well, requiring a keyboard press to wake it up.
  3. The secondary monitor's vertical orientation and `-420` Y-offset were lost, causing the screen to revert to landscape (`transform: 0`) and the cursor to jump across monitors.
- **Root Cause:**
  1. In `toggle_monitor.py`, when `action == "on"`, it called `eval_lua("hl.dispatch(hl.dsp.dpms('on'))")`. Passing `'on'` globally without a monitor argument or proper table format caused Hyprland to toggle DPMS on all displays, dropping `HDMI-A-1`.
  2. When `DP-1` was disabled, `hyprctl monitors all -j` returned `0` for `transform` and `0` for `y`. The script used `sec.get("transform", 0)` and `sec.get("y", 0)`, re-enabling `DP-1` in landscape at (1920, 0) instead of portrait (`transform: 3`) at (1920, -420).

---

## Applied Solutions

### 1. Forced DRM Connector State for Main Monitor (`HDMI-A-1`)
Added `video=HDMI-A-1:1920x1080@75e` alongside the existing `video=DP-1:1920x1080@60e` in:
- `/etc/kernel/cmdline`
- `/etc/sdboot-manage.conf`
- Regenerated systemd-boot entries: `sudo sdboot-manage gen`
- Forced connector active at runtime: `echo on | sudo tee /sys/class/drm/card1-HDMI-A-1/status`

> [!NOTE]
> The `e` flag (`DRM_FORCE_ON`) forces the Linux DRM subsystem to keep the connector pinned as permanently connected, preventing HPD drop-and-pull pulses during DPMS sleep from firing spurious hotplug events that wake the compositor.

### 2. Fixed `toggle_monitor.py` Quick Toggle Script
Updated `/etc/xdg/quickshell/caelestia/utils/scripts/toggle_monitor.py` and user configs:
1. Removed `eval_lua("hl.dispatch(hl.dsp.dpms('on'))")` so turning on the 2nd monitor never touches or blanks `HDMI-A-1`.
2. Added proper fallback guards for `DP-1`:
   - `transform` defaults to `3` (portrait).
   - `y` defaults to `-420` (matching the physical desk alignment).
   - `mode` locked to `1920x1080@60`.

---

## Related Notes
- [[caelestia-hyprland]]
- [[wireless-mouse-phantom-drift]]
- [[multi-monitor-sleep-and-proton-idle-inhibit]]
- [[nexus-multi-monitor-geometry-overflow]]
