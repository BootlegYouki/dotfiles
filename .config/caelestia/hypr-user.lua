-- Caelestia Hyprland user configuration
local home = os.getenv("HOME")
local repeating = { repeating = true }

-- ============================================
-- MONITOR CONFIGURATION
-- ============================================
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@74.99",
    position = "0x0",
    scale    = 1,
    transform = 0,
})

hl.monitor({
    output   = "DP-1",
    mode     = "1920x1080@60",
    position = "1920x-420",
    scale    = 1,
    transform = 3,
})

-- ============================================
-- WORKSPACE MONITOR ASSIGNMENTS
-- ============================================
-- Monitor 1 (HDMI-A-1): Workspaces 1..10 (default 1)
-- Monitor 2 (DP-1): Workspaces 11..20 (default 11)
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = (i == 1) })
end
for i = 11, 20 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "DP-1", default = (i == 11) })
end

-- ============================================
-- WINDOWS-STYLE SHORTCUTS & USER PREFERENCES
-- ============================================

-- Windows + Shift + N -> Night Light Toggle (4000K Warm Color Temperature)
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("nightlight"))

-- Super + F5 -> Reload Hyprland config (apply HyprMod changes)
hl.bind("SUPER + F5", hl.dsp.exec_cmd("hyprctl reload"))

-- Note: SUPER + E, SUPER + V, SUPER + period, SUPER + L, and CTRL + SHIFT + Escape
-- are already handled natively in hyprland/keybinds.lua & variables.lua


-- ============================================
-- CAELESTIA SPECIAL WORKSPACE NAVIGATION
-- ============================================

local special_order = {
    ["special:music"]         = 1,
    ["special:dev"]           = 2,
    ["special:communication"] = 3,
    ["special:todo"]          = 4,
    ["special:sysmon"]        = 5,
    ["special:special"]       = 6,
}

local function cycle_special_workspaces(dir)
    return function()
        local active_special = hl.get_active_special_workspace()

        if active_special then
            local windows = hl.get_windows() or {}
            local special_list = {}
            local special_set = {}

            for _, w in ipairs(windows) do
                if w.workspace and w.workspace.name and w.workspace.name:find("^special:") then
                    local name = w.workspace.name
                    if not special_set[name] then
                        special_set[name] = true
                        table.insert(special_list, name)
                    end
                end
            end

            -- Sort by top-to-bottom visual bar order
            table.sort(special_list, function(a, b)
                local order_a = special_order[a] or 99
                local order_b = special_order[b] or 99
                if order_a ~= order_b then
                    return order_a < order_b
                end
                return a < b
            end)

            if #special_list > 1 then
                local idx = 1
                for i, sname in ipairs(special_list) do
                    if sname == active_special.name then
                        idx = i
                        break
                    end
                end

                if dir > 0 then
                    idx = (idx % #special_list) + 1
                else
                    idx = ((idx - 2 + #special_list) % #special_list) + 1
                end

                local target_special = special_list[idx]
                if target_special ~= active_special.name then
                    local cur_tag = active_special.name:gsub("^special:", "")
                    local tgt_tag = target_special:gsub("^special:", "")
                    hl.dispatch(hl.dsp.workspace.toggle_special(cur_tag))
                    hl.dispatch(hl.dsp.workspace.toggle_special(tgt_tag))
                end
            end
        end
    end
end

-- Ctrl + Super + Down -> Moves DOWN the sidebar (towards bottom icon)
hl.bind("CTRL + SUPER + Down", cycle_special_workspaces(1), repeating)

-- Ctrl + Super + Up -> Moves UP the sidebar (towards top icon)
hl.bind("CTRL + SUPER + Up", cycle_special_workspaces(-1), repeating)
