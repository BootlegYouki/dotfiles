# 🖥️ Caelestia Lockscreen Black Screen on Monitor Sleep / DPMS

## Issue Summary
When the system enters idle/sleep and DPMS turns off the monitors, Caelestia's session lock ([`LockSurface.qml`](file:///home/youki/.config/quickshell/caelestia/modules/lock/LockSurface.qml)) uses `ScreencopyView` to capture the desktop background for blur effects. 
Because DPMS turns off display framebuffers during sleep:
1. `(root.screen?.height ?? 0)` evaluated to `0` when monitors re-enumerated upon waking up, causing `lockContent` to collapse to **0 x 0 pixels** (invisible).
2. `ScreencopyView` rendered a pitch-black frame, hiding the lock UI and leaving only a mouse cursor on `HDMI-A-1`.
3. `DP-1` is in `excludedScreens` in `shell.json`, so `DP-1` only showed wallpaper and clock.

---

## Applied Fix (`~/.config/quickshell/caelestia/modules/lock/LockSurface.qml`)

1. **Screen Height Fallback**: Added `readonly property int screenHeight: (root.screen && root.screen.height > 0) ? root.screen.height : 1080` so `lockContent` never collapses to 0x0 size during DPMS monitor re-enumeration.
2. **Backdrop Fallback**: Added a solid `Rectangle { anchors.fill: parent; color: Colours.palette.m3surface }` behind `ScreencopyView` so if screencopy fails or DPMS turns off framebuffers, the surface retains a themed dark backdrop instead of pitch black.

---

## Instant Recovery Command (from TTY3 / SSH)
If the lock screen ever traps input:
```bash
WAYLAND_DISPLAY=wayland-1 HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/1000/hypr/ | head -n 1) qs ipc -c caelestia call lock unlock
```

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[desktop-autologin-gdm-lockscreen-fix]]
