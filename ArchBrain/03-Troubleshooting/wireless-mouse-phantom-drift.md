# Wireless Mouse Phantom Cursor Drift & Event Flooding

Documentation of the issue where the mouse cursor was continuously pulling/jumping across monitor boundaries to the far right edge (`x=2999`) without user intervention.

---

## Symptoms & Misconceptions

### Symptoms
- The mouse cursor kept flying or getting stuck on the edge of the secondary monitor (`DP-1`).
- Dragging the cursor back to the main display (`HDMI-A-1`) immediately resulted in it drifting back to the far edge.

### Misconception
- Initial suspicion was Hyprland window focus grabbing, `no_warps` cursor warping, or monitor coordinate dead zones due to the rotated portrait layout (`position = 1920x-420`).

---

## Diagnostic Method & Root Cause

### Diagnostic Command
Directly attached to the Linux input subsystem (`evdev`) across all `/dev/input/event*` devices to capture raw hardware motion deltas:

```bash
sudo python3 -c "
import evdev, select, time
devs = [evdev.InputDevice(p) for p in evdev.list_devices()]
fd_map = {d.fd: d for d in devs}
t_end = time.time() + 5.0
counts = {}
while time.time() < t_end:
    r, _, _ = select.select(list(fd_map.keys()), [], [], 0.1)
    for fd in r:
        try:
            for ev in fd_map[fd].read():
                counts[fd_map[fd].name] = counts.get(fd_map[fd].name, 0) + 1
                if ev.type == evdev.ecodes.EV_REL:
                    print(f'[{fd_map[fd].name}] type={ev.type} code={ev.code} val={ev.value}')
        except Exception:
            pass
print('Event counts per device:', counts)
"
```

### Root Cause
- The `CX Wireless mouse 1k dongle Mouse` device flooded the kernel with **5,352 continuous relative motion packets (`EV_REL / REL_X`) in under 5 seconds** (~1,000+ packets/sec).
- When wireless mouse battery levels drop below the operating threshold of the optical sensor MCU, the controller fails to parse optical flow frames and gets stuck in an infinite delta transmission loop.

---

## Resolution

- **Primary Fix:** Connected the wireless mouse to its USB-C charging cable.
- **Alternative Checks:** If the issue recurs while fully charged:
  1. Inspect the optical sensor lens for stray hairs or dust fibers.
  2. Power cycle the mouse switch (OFF -> ON) to reset the onboard MCU.
  3. Re-plug the 2.4GHz USB wireless dongle.

---

## Related Notes
- [[caelestia-hyprland]]
- [[system-services]]
