# Multi-Monitor Idle Lock & Proton Game Idle Inhibit

Documentation of the multi-monitor DPMS screen lock issue and idle inhibition configuration for Wine/Proton games (such as Genshin Impact launched via TwinTailLauncher).

---

## Symptoms & Root Cause

### 1. Inactivity Screen Blanking & Input Freeze
- **Symptom:** When stepping away from a game running on a secondary display (`DP-1`), the main display (`HDMI-A-1`) turned off / went blank. Mouse and keyboard input appeared unresponsive, and the lock screen only appeared on the main display after physically unplugging the secondary monitor.
- **Root Cause:**
  1. Genshin Impact (launched via TwinTailLauncher / Proton runner) ran with window class `steam_proton` or `twintaillauncher`.
  2. Hyprland's `game_tag` rule only matched `steam_app_[0-9]+`, `steam_app_default`, and `gamescope`. Because `steam_proton` was not tagged as `game`, `idle_inhibit = "always"` was not applied, allowing Caelestia/Hyprland's idle daemon to activate DPMS and screen lock.
  3. During multi-monitor DPMS sleep, the lock screen surface grabbed all user input on the active display. Since `HDMI-A-1` was in DPMS power saving mode, input was absorbed by the lock overlay without triggering a display wake-up until a hardware DRM hotplug event occurred upon disconnecting `DP-1`.

### 2. "Missing" Windows After Unlocking
- In Caelestia's multi-monitor layout, Monitor 1 manages Workspaces 1–10, and Monitor 2 manages Workspaces 11–20.
- When `DP-1` was disconnected, Workspace 11 was migrated to Monitor 1. However, upon unlocking to Workspace 1, windows on Workspace 11 were not visible on the standard 1–10 workspace bar.

### 3. Invisible Lock Screen on DPMS Wake-Up & Upside-Down Flip (Caelestia Bug)
- **Symptom:** 
  1. After monitors power off (DPMS standby) and power back on, Monitor 1 was a black void with only a mouse cursor, and Monitor 2 showed desktop windows without a lock screen. Blindly typing the password unlocked the session.
  2. Locking with `Super + L` caused the lock card to start upside-down (180°) before spinning to 360°.
- **Root Cause:**
  1. In [`LockSurface.qml`](file:///home/youki/.config/quickshell/caelestia/modules/lock/LockSurface.qml), `unlockAnim` animated `opacity` and `scale` of all lock components to `0`. On subsequent locks (and DPMS wake-up), `Connections` lacked an `onLockedChanged` handler to re-trigger `initAnim`.
  2. When monitors wake up from DPMS while locked, Wayland security blocks screencopy requests. Because `LockSurface` had `color: "transparent"`, the surface had no fallback background, producing a black void on Monitor 1 and a see-through desktop on Monitor 2.
  3. `lockContent` had default `rotation: 180` with a 180°->360° spin animation.
- **Fix:** 
  1. Added `onLockedChanged` to `Connections` in `~/.config/quickshell/caelestia/modules/lock/LockSurface.qml` to restart `initAnim` on every lock event.
  2. Set `color: Colours.palette.m3surface` on `WlSessionLockSurface` so it always has a guaranteed solid theme background when waking from DPMS.
  3. Removed `rotation: 180` and the spin animation, making the lock card open upright and smoothly.

---

## Resolution & Configuration Fix

### Window Rules (`rules.lua`)
Updated `~/.config/hypr/hyprland/rules.lua` and `~/dotfiles/.config/hypr/hyprland/rules.lua` to include `steam_proton`, `twintaillauncher`, and `genshinimpact.exe` under `game_tag`:

```lua
-- Games
tagged_rule(game_tag, {
    "steam_app_[0-9]+",                          -- Steam games
    "steam_app_default",                         -- Lutris games
    "steam_proton",                              -- TwinTailLauncher / Proton games (Genshin, HSR, ZZZ, etc.)
    "twintaillauncher|app.twintaillauncher.ttl", -- TwinTailLauncher app
    "wine|wine64-preloader",                     -- Generic Wine games
    "heroic|bottles",                            -- Heroic / Bottles games
    "gamescope",                                 -- Gamescope
}, "class")
```

### Navigating Multi-Monitor Workspaces
- `Ctrl + Super + [1-0]` focuses workspace groups (e.g., `Ctrl + Super + 1` -> Workspace 11).
- `hyprctl dispatch 'hl.dsp.window.move({ workspace = "1", window = "address:<addr>" })'` moves windows between workspaces programmatically.

---

## Related Notes
- [[caelestia-hyprland]]
- [[system-services]]
