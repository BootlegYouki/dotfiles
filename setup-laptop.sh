#!/usr/bin/env bash
# ==============================================================================
#  Caelestia + Hyprland + SDDM Laptop Setup & Autologin Script
#  Optimized for Laptop hardware (eDP-1 screen, Touchpad, Autologin, Power)
# ==============================================================================

set -eo pipefail

if [ "$(id -u)" -eq 0 ]; then
    echo "❌ Error: Do not run this script directly as root. Run as your regular user: ./setup-laptop.sh"
    exit 1
fi

TARGET_USER="$USER"
TARGET_HOME="$HOME"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "💻 Caelestia Desktop Laptop Setup & Autologin Installer"
echo "=========================================================="
echo "Target User: $TARGET_USER ($TARGET_HOME)"
echo "Dotfiles:    $DOTFILES_DIR"
echo ""

# 1. Cache sudo credentials (non-interactive friendly)
if ! sudo -n true 2>/dev/null; then
    sudo -v
fi
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEP_ALIVE_PID=$!
trap 'kill "$SUDO_KEEP_ALIVE_PID" 2>/dev/null || true' EXIT

# --- Step 1: SDDM Autologin Configuration ---
echo "▶ [1/6] Configuring SDDM Autologin into Hyprland (UWSM)..."
sudo mkdir -p /etc/sddm.conf.d

sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null << EOF
[Autologin]
User=$TARGET_USER
Session=hyprland-uwsm.desktop
Relogin=false
EOF
echo "  ✓ Created /etc/sddm.conf.d/autologin.conf (Auto-login as '$TARGET_USER')"

# Ensure graphical target & SDDM enabled
sudo systemctl set-default graphical.target
sudo systemctl enable sddm 2>/dev/null || true
echo "  ✓ Default target: graphical.target (sddm enabled)"

# --- Step 2: Sync Dotfiles Configs & Binaries ---
echo "▶ [2/6] Syncing dotfiles configurations and custom scripts..."

# 2.1 Binaries
mkdir -p "$TARGET_HOME/.local/bin"
if [ -d "$DOTFILES_DIR/bin" ]; then
    cp "$DOTFILES_DIR/bin/"* "$TARGET_HOME/.local/bin/" 2>/dev/null || true
    chmod +x "$TARGET_HOME/.local/bin/"* 2>/dev/null || true
    echo "  ✓ Synced ~/.local/bin utilities"
fi

# 2.2 Key configs
mkdir -p "$TARGET_HOME/.config"
for item in "$DOTFILES_DIR/.config/"*; do
    if [ -e "$item" ]; then
        name="$(basename "$item")"
        if [ "$name" != "rclone" ]; then
            if [ -d "$item" ]; then
                mkdir -p "$TARGET_HOME/.config/$name"
                cp -R "$item/"* "$TARGET_HOME/.config/$name/"
            else
                cp "$item" "$TARGET_HOME/.config/"
            fi
        fi
    fi
done
echo "  ✓ Synced ~/.config directories (Ghostty, Fish, Fastfetch, etc.)"

# Ensure shell.qml link for Quickshell
if [ -f "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" ]; then
    mkdir -p "$TARGET_HOME/.config/quickshell"
    ln -sfn "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" "$TARGET_HOME/.config/quickshell/shell.qml"
fi

# --- Step 3: Laptop Hyprland & Caelestia Display Profile ---
echo "▶ [3/6] Generating laptop monitor and touchpad profile for eDP-1..."
mkdir -p "$TARGET_HOME/.config/caelestia"

cat << 'EOF' > "$TARGET_HOME/.config/caelestia/hypr-user.lua"
-- Caelestia Hyprland User Configuration (Laptop Profile)
local home = os.getenv("HOME")
local repeating = { repeating = true }

-- ============================================
-- LAPTOP MONITOR CONFIGURATION
-- ============================================
-- Primary internal laptop display (eDP-1)
hl.monitor({
    output    = "eDP-1",
    mode      = "1920x1080@60",
    position  = "0x0",
    scale     = 1,
    transform = 0,
})

-- Dynamic hotplug rule for external HDMI monitor (if connected)
hl.monitor({
    output    = "HDMI-A-1",
    mode      = "preferred",
    position  = "auto",
    scale     = 1,
    transform = 0,
})

-- Fallback for any other external display
hl.monitor({
    output    = "",
    mode      = "preferred",
    position  = "auto",
    scale     = 1,
})

-- ============================================
-- WORKSPACE PINNING
-- ============================================
-- Internal screen (eDP-1): Workspaces 1..10 (default 1)
for i = 1, 10 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", default = (i == 1) })
end
-- External HDMI monitor: Workspaces 11..20 (default 11)
for i = 11, 20 do
    hl.workspace_rule({ workspace = tostring(i), monitor = "HDMI-A-1", default = (i == 11) })
end

-- ============================================
-- TOUCHPAD & INPUT TUNING
-- ============================================
hl.config({
    input = {
        touchpad = {
            natural_scroll = true,
            tap_to_click   = true,
            scroll_factor  = 1.0,
        },
    },
})

-- ============================================
-- SHORTCUTS & USER PREFERENCES
-- ============================================
-- Windows + Shift + N -> Night Light Toggle (4000K)
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("nightlight"))

-- Super + F5 -> Reload Hyprland config
hl.bind("SUPER + F5", hl.dsp.exec_cmd("hyprctl reload"))

-- Windows + Alt + A -> Startup Applications Manager
hl.bind("SUPER_ALT + A", hl.dsp.exec_cmd("autostart-manager"))

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

-- Ctrl + Super + Down -> Cycle down special workspaces
hl.bind("CTRL + SUPER + Down", cycle_special_workspaces(1), repeating)

-- Ctrl + Super + Up -> Cycle up special workspaces
hl.bind("CTRL + SUPER + Up", cycle_special_workspaces(-1), repeating)
EOF
echo "  ✓ Wrote $TARGET_HOME/.config/caelestia/hypr-user.lua (eDP-1 + Touchpad)"

# --- Step 4: Sync Supercharged Pi Harness ---
echo "▶ [4/6] Synchronizing Pi harness, subagents, and extensions..."
mkdir -p "$TARGET_HOME/.pi/agent/extensions/subagent" \
         "$TARGET_HOME/.pi/agent/agents" \
         "$TARGET_HOME/.pi/agent/prompts" \
         "$TARGET_HOME/.agents/skills"

# Copy extensions if available in dotfiles or source
if [ -d "$DOTFILES_DIR/ArchBrain" ]; then
    mkdir -p "$TARGET_HOME/ArchBrain"
    cp -a "$DOTFILES_DIR/ArchBrain/." "$TARGET_HOME/ArchBrain/" 2>/dev/null || true
    echo "  ✓ Synced ArchBrain vault"
fi

# --- Step 5: Power & System Services ---
echo "▶ [5/6] Enabling laptop power management and essential services..."
sudo pacman -S --noconfirm --needed power-profiles-daemon brightnessctl 2>/dev/null || true
sudo systemctl enable --now power-profiles-daemon 2>/dev/null || true
sudo systemctl enable --now bluetooth 2>/dev/null || true
sudo systemctl enable --now systemd-resolved 2>/dev/null || true
echo "  ✓ Power management & Bluetooth active"

# --- Step 6: Completion ---
echo ""
echo "=========================================================="
echo "🎉 Laptop Setup Completed Successfully!"
echo "=========================================================="
echo "Changes Applied:"
echo "  • SDDM Autologin enabled (User: $TARGET_USER -> Hyprland UWSM)"
echo "  • Monitor eDP-1 configured as primary (Workspaces 1–10)"
echo "  • Touchpad natural scrolling & tap-to-click enabled"
echo "  • Power profiles daemon running for battery efficiency"
echo ""
echo "Restart your laptop or SDDM to verify autologin: sudo systemctl restart sddm"
