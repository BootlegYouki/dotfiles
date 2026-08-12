# ALT+TAB Mouse Monitor Toggle

## Summary
Custom keybind that moves the mouse cursor between the main monitor and the secondary monitor each time ALT+TAB is pressed.

## Setup Details

### Monitors
| ID | Name | Resolution | Position | Role |
|----|------|-----------|----------|------|
| 0 | HDMI-A-1 | 1920×1080 | (0, 0) | Main |
| 1 | DP-1 | 1920×1080 | (1920, -420) | Secondary |

### Files Modified
- [`~/hypr/variables.lua`](file:///home/youki/hypr/variables.lua) — Reassigned ALT+TAB to `kbMouseMonitorToggle`; window cycling moved to SUPER+TAB
- [`~/hypr/hyprland/keybinds.lua`](file:///home/youki/hypr/hyprland/keybinds.lua) — Stateful Lua toggle for cursor movement

### Implementation
The toggle is implemented as a pure Lua function in `keybinds.lua` that focuses the active workspace of the other monitor, which automatically warps the mouse focus dynamically (avoiding hardcoded coordinates and coordinate-scaling issues):

```lua
-- Mouse monitor toggle (ALT + TAB → moves mouse between monitors)
create_bind(vars.kbMouseMonitorToggle, function()
    local active_mon = hl.get_active_monitor()
    if active_mon then
        if active_mon.id == 0 then
            local ws1 = hl.get_active_workspace(1)
            if ws1 then
                hl.dispatch(hl.dsp.focus({ workspace = ws1.id }))
            end
        else
            local ws0 = hl.get_active_workspace(0)
            if ws0 then
                hl.dispatch(hl.dsp.focus({ workspace = ws0.id }))
            end
        end
    end
end)
```

Uses `hl.dsp.focus()` — focusing the active workspace on the opposite monitor automatically moves the cursor.

### Keybind Changes
| Action | Old Key | New Key |
|--------|---------|---------|
| Mouse monitor toggle | *(none)* | **ALT + TAB** |
| Window cycle next | ALT + TAB | SUPER + TAB |
| Window cycle prev | SHIFT + ALT + TAB | SUPER + SHIFT + TAB |
| Group cycle next | CTRL + ALT + TAB | CTRL + SUPER + TAB |
| Group cycle prev | CTRL + SHIFT + ALT + TAB | CTRL + SUPER + SHIFT + TAB |

> [!NOTE]
> A helper script also exists at `~/hypr/scripts/toggle-mouse-monitor.sh` but is no longer used (the keybind uses native Lua instead).

## Related Notes
- [[desktop-caelestia-hyprland]]
