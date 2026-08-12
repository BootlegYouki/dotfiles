# 🖱️ VLC Loop — Cursor Warp to Second Monitor Fix

**Symptom**: When VLC loops a video, the mouse cursor automatically jumps to the secondary monitor where VLC is playing.

**Root Cause**: VLC runs under **XWayland** (`xwayland: 1`). When the video loops, VLC calls `XWarpPointer` — a raw X11 API that physically moves the cursor. This bypasses all Hyprland window rules (`suppressevent`, `follow_mouse`, etc.) entirely.

> [!WARNING]
> `follow_mouse = 2`, `no_cursor_warps`, and `suppressevent activate` do **NOT** fix this. Those only affect passive focus tracking and `_NET_ACTIVE_WINDOW` requests. `XWarpPointer` is a direct X11 call that goes through XWayland and cannot be blocked by Hyprland rules.

---

## Fix: Run VLC as Native Wayland

A native Wayland app has no access to X11 APIs, so it physically cannot call `XWarpPointer`.

### `~/.local/bin/vlc` (wrapper script)
```sh
#!/bin/sh
# Force VLC to run as native Wayland instead of XWayland.
# XWayland VLC calls XWarpPointer on video loop, causing the cursor
# to jump to the monitor where VLC is playing.
exec env QT_QPA_PLATFORM=wayland vlc "$@"
```

This wrapper shadows the system `/usr/bin/vlc` for the user (since `~/.local/bin` is earlier in `$PATH`). VLC uses Qt, and Qt has a native Wayland backend (`libqwayland-egl.so`) available on this system.

### Verify it's working
```bash
hyprctl clients | grep -A5 "class: vlc" | grep xwayland
# Should return nothing (no longer XWayland)
```

---

## Lesson: XWayland vs Wayland cursor events

| Mechanism | Blocked by `follow_mouse=2`? | Blocked by `suppressevent`? | Blocked by native Wayland? |
|---|---|---|---|
| `_NET_ACTIVE_WINDOW` (focus request) | ✅ | ✅ | ✅ |
| Hyprland passive focus warp | ✅ | ✅ | ✅ |
| `XWarpPointer` (direct X11 API) | ❌ | ❌ | ✅ |

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[hyprland-workspace-hover-focus]]
