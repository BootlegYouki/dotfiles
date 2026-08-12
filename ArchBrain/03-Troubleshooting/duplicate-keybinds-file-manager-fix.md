# 🐛 Fix: Super + E Launching Duplicate File Managers

## Problem Description
Pressing `Super + E` (or `Windows + E`) launched **two instances** of the file manager (Nautilus) simultaneously under Hyprland with Caelestia Shell.

---

## Root Cause Analysis
The keybinding `SUPER + E` was registered twice across configuration files:
1. Natively in [`~/.config/hypr/hyprland/keybinds.lua`](file:///home/youki/.config/hypr/hyprland/keybinds.lua#L154) using `vars.kbFileExplorer` from [`variables.lua`](file:///home/youki/.config/hypr/variables.lua#L116) (`hl.dsp.exec_cmd(vars.fileExplorer)`).
2. Redundantly in [`~/.config/caelestia/hypr-user.lua`](file:///home/youki/.config/caelestia/hypr-user.lua#L41) (`hl.bind("SUPER + E", hl.dsp.exec_cmd("nautilus"))`).

Because Hyprland triggers all matching keybindings when a shortcut key combo is pressed, both dispatchers fired on a single keystroke, causing Nautilus to launch twice.

> [!NOTE]
> Other duplicate keybindings (`SUPER + V`, `SUPER + .`, `SUPER + L`, `CTRL + SHIFT + Escape`) were also defined in `hypr-user.lua` despite already being handled in Caelestia's `keybinds.lua` & `variables.lua`.

---

## Resolution Steps
1. **Cleaned `~/.config/caelestia/hypr-user.lua`**:
   - Removed the duplicate `SUPER + E` binding (`hl.bind("SUPER + E", ...)`).
   - Removed redundant duplicate shortcuts (`SUPER + V`, `SUPER + .`, `SUPER + L`, `CTRL + SHIFT + Escape`).
2. **Cleaned `~/.config/hypr/userprefs.conf`**:
   - Commented out duplicate legacy `bind = SUPER, E, exec, nautilus`.
3. **Applied changes**:
   - Ran `hyprctl reload`.
   - Verified via `hyprctl binds | grep -A 8 -B 2 'key: E'` that `SUPER + E` is now registered exactly once.

---

## Verification
- Checked active Hyprland keybindings via `hyprctl binds`.
- `modmask: 64, key: E` maps strictly to a single dispatcher (arg: 150).

---

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[linux-essential-commands]]
