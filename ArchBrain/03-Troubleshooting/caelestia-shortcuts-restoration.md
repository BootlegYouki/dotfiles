---
title: Caelestia Shell Keybinding & Shortcut Restoration
description: Documentation of restored custom Hyprland & Caelestia Shell shortcuts (ALT+TAB monitor warp, SUPER+TAB window cycling, per-monitor relative workspace navigation, wallpaper shifts, and direct screenshots).
date: 2026-08-12
---

# 🎨 Caelestia Shell Keybinding & Shortcut Restoration

## Overview & Issue
After system setup or configuration reset, several custom Caelestia Shell shortcuts disappeared because active configuration files (`~/.config/hypr/variables.lua`, `~/.config/hypr/hyprland/keybinds.lua`, and `~/.config/hypr/utils/functions.lua`) were reverted to default templates.

## Restored Shortcuts & Keybindings

| Shortcut | Description | Target / Dispatcher |
|---|---|---|
| **`ALT + TAB`** | Mouse Monitor Warp | Warps cursor & focus between Monitor 0 (`HDMI-A-1`) and Monitor 1 (`DP-1`) |
| **`SUPER + TAB`** | Window Cycle Next | `hl.dsp.window.cycle_next()` |
| **`SUPER + SHIFT + TAB`** | Window Cycle Prev | `hl.dsp.window.cycle_next({ next = false })` |
| **`CTRL + SUPER + TAB`** | Window Group Cycle Next | `hl.dsp.group.next()` |
| **`CTRL + SUPER + SHIFT + TAB`** | Window Group Cycle Prev | `hl.dsp.group.prev()` |
| **`SUPER + Left` / `SUPER + Right`** | Per-Monitor Relative Workspaces | `fn.relative_ws(-1)` and `fn.relative_ws(1)` (navigates 1..10 on HDMI-A-1, 11..20 on DP-1) |
| **`SUPER + ,`** | Previous Wallpaper | `caelestia-wallpaper-shift prev` |
| **`SUPER + .`** | Next Wallpaper | `caelestia-wallpaper-shift next` |
| **`SUPER + C`** | Dev Special Workspace | `fn.toggle("dev")` |
| **`SUPER + F`** | Bordered Fullscreen / Maximized | `hl.dsp.window.fullscreen({ mode = "maximized" })` |
| **`F11`** | True Fullscreen | `hl.dsp.window.fullscreen({ mode = "fullscreen" })` |
| **`ALT + F4`** | Power / Session Menu | `hl.dsp.global("caelestia:session")` |
| **`Print`** | Fullscreen Screenshot | `~/.config/hypr/scripts/screenshot.sh fullscreen` |
| **`SUPER + SHIFT + S`** | Region Screenshot | `~/.config/hypr/scripts/screenshot.sh region` |
| **`SUPER + SHIFT + N`** | Night Light Toggle | `nightlight` (4000K warm blue-light filter) |

## Implementation Details

1. **`~/.config/hypr/variables.lua`**:
   - Added `kbMouseMonitorToggle = "ALT + TAB"`.
   - Rebound `kbWindowCycleNext`, `kbWindowCyclePrev`, `kbWindowGroupCycleNext`, and `kbWindowGroupCyclePrev` to use `SUPER + TAB` variants.
   - Added `kbWallpaperPrev = "SUPER + Comma"` and `kbWallpaperNext = "SUPER + Period"`.
   - Added `kbDevWs = "SUPER + C"`.
   - Set `kbWindowFullscreen = "F11"` and `kbWindowBorderedFullscreen = "SUPER + F"`.
   - Set `kbSession = "ALT + F4"`.

2. **`~/.config/hypr/utils/functions.lua`**:
   - Re-added `relative_ws(delta)` helper function for per-monitor range workspace cycling.

3. **`~/.config/hypr/hyprland/keybinds.lua`**:
   - Bound `vars.kbMouseMonitorToggle` to multi-monitor focus warp.
   - Bound `vars.kbPrevWs` and `vars.kbNextWs` to `fn.relative_ws(-1)` and `fn.relative_ws(1)`.
   - Bound `vars.kbWallpaperPrev` and `vars.kbWallpaperNext` to `caelestia-wallpaper-shift`.
   - Bound `vars.kbDevWs` to `fn.toggle("dev")`.

4. **Applied Session Reload**:
   - Executed `hyprctl reload` to apply all changes live.

## Related Notes
- [[desktop-caelestia-hyprland]]
- [[hyprland-alt-tab-mouse-toggle]]
- [[hyprland-workspace-hover-focus]]
- [[linux-essential-commands]]
- [[system-customizations-master-blueprint]]
