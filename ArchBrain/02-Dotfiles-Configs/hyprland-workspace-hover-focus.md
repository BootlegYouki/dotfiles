# Hyprland Per-Monitor Workspace Range Navigation

## Architecture & Problem
Caelestia uses grouped workspace ranges per monitor:
- **Monitor 1 (`HDMI-A-1`)**: Workspaces `1..10` (base 0)
- **Monitor 2 (`DP-1`)**: Workspaces `11..20` (base 10)

Built-in Hyprland `m+1` / `m-1` failed on Screen 2 when only a single workspace (e.g. 12) was open because `m+1` only cycles through pre-existing open workspaces.

## Solution
Implemented `fn.relative_ws(delta)` helper function in [`utils/functions.lua`](file:///home/youki/.config/hypr/utils/functions.lua#L287-L300):
```lua
local function relative_ws(delta)
    return function()
        local activews = hl.get_active_workspace()
        if activews and activews.id and type(activews.id) == "number" and activews.id > 0 then
            local base = math.floor((activews.id - 1) / 10) * 10
            local local_idx = activews.id - base
            local target_idx = math.max(1, math.min(10, local_idx + delta))
            local target_id = base + target_idx
            if target_id ~= activews.id then
                return hl.dispatch(hl.dsp.focus({ workspace = tostring(target_id) }))
            end
        end
    end
end
```

### Files Modified
- [`/home/youki/.config/hypr/utils/functions.lua`](file:///home/youki/.config/hypr/utils/functions.lua#L287-L300): Added and exported `relative_ws(delta)`.
- [`/home/youki/.config/hypr/hyprland/keybinds.lua`](file:///home/youki/.config/hypr/hyprland/keybinds.lua#L80-L90): Bound `vars.kbPrevWs` and `vars.kbNextWs` to `fn.relative_ws(-1)` and `fn.relative_ws(1)`.
- [`/home/youki/.config/caelestia/hypr-user.lua`](file:///home/youki/.config/caelestia/hypr-user.lua#L23-L33): Added explicit `hl.workspace_rule` loops mapping Workspaces `1..10` to `HDMI-A-1` (default: 1) and Workspaces `11..20` to `DP-1` (default: 11) to prevent Hyprland from placing Workspace 2 on Monitor 2 at boot.

> [!NOTE]
> `Super + Left` and `Super + Right` now seamlessly create/switch between workspaces `1..10` on Screen 1, and `11..20` on Screen 2 without jumping screens or placing Workspace 2 on Monitor 2.

## Related Notes
- [[desktop-caelestia-hyprland]]
