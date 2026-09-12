#!/usr/bin/env bash
# ==============================================================================
#  Caelestia + Hyprland Complete System Uninstaller / Fresh Reset Script
#  Reverts the system back to a clean minimal CLI base (before install.sh)
# ==============================================================================

set -eo pipefail

if [ "$(id -u)" -ne 0 ]; then
    echo "❌ Please run this script with sudo:"
    echo "   sudo ./uninstall.sh"
    exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo "=========================================================="
echo "🧹 Caelestia Desktop & Hyprland Complete Reset"
echo "Target User: $TARGET_USER ($TARGET_HOME)"
echo "=========================================================="
echo ""

# 1. Stop & Disable Services
echo "▶ [1/6] Stopping and disabling display manager and services..."
systemctl disable --now sddm 2>/dev/null || true
systemctl disable --now genshin-f-macro.service 2>/dev/null || true
systemctl set-default multi-user.target 2>/dev/null || true

sudo -u "$TARGET_USER" systemctl --user stop \
    caelestia-auto-reload.service \
    caelestia-romaji.service \
    dotfiles-sync.timer dotfiles-sync.service \
    archbrain-sync.timer archbrain-sync.service 2>/dev/null || true

sudo -u "$TARGET_USER" systemctl --user disable \
    caelestia-auto-reload.service \
    caelestia-romaji.service \
    dotfiles-sync.timer \
    archbrain-sync.timer 2>/dev/null || true

# 2. Remove Packages Installed by install.sh
echo "▶ [2/6] Removing desktop packages and tools..."
PACKAGES_TO_REMOVE=(
    caelestia-shell
    caelestia-cli
    caelestia-sddm-minimalistv2-git
    caelestia-sddm-locklike-git
    caelestia-sddm
    quickshell-git
    quickshell
    noctalia-qs
    hyprland
    uwsm
    waybar
    sddm
    ghostty
    starship
    fastfetch
    polkit-kde-agent
    pamixer
    playerctl
    brightnessctl
    grim
    slurp
    wl-clipboard
    cliphist
    hyprpicker
    hyprsunset
    cava
    micro
    ttf-material-symbols-variable
    ttf-rubik-vf
    spotify
    spicetify-cli
    spicetify-marketplace-bin
    brave-origin-bin
    brave-bin
    twintaillauncher-bin
    steam
    discord
    zed
    vlc
    swappy
)

for pkg in "${PACKAGES_TO_REMOVE[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "  - Removing $pkg..."
        pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    fi
done

# 3. Remove System-Level Configs & Hooks
echo "▶ [3/6] Removing system-level configs, SDDM settings, and hooks..."
rm -f /etc/sddm.conf.d/caelestia.conf /etc/sddm.conf.d/10-theme.conf 2>/dev/null || true
rm -rf /etc/xdg/quickshell/caelestia 2>/dev/null || true
rm -f /etc/systemd/system/genshin-f-macro.service 2>/dev/null || true
rm -f /usr/share/sddm/faces/"$TARGET_USER".face.icon /usr/share/sddm/faces/.face.icon 2>/dev/null || true

# Remove pacman hooks deployed by dotfiles if any
rm -f /etc/pacman.d/hooks/99-caelestia* 2>/dev/null || true
systemctl daemon-reload

# 4. Clean User Configurations
echo "▶ [4/6] Cleaning deployed user configurations in ~/.config and ~/.local..."
USER_CONFIG_DIRS=(
    caelestia
    quickshell
    hypr
    waybar
    ghostty
    fish
    fastfetch
    btop
    cava
    fuzzel
    micro
    uwsm
    qtengine
    spicetify
)

for cfg in "${USER_CONFIG_DIRS[@]}"; do
    rm -rf "$TARGET_HOME/.config/$cfg"
done

rm -f "$TARGET_HOME/.config/starship.toml"
rm -f "$TARGET_HOME/.config/systemd/user/caelestia"* 2>/dev/null || true
rm -f "$TARGET_HOME/.config/systemd/user/dotfiles"* 2>/dev/null || true
rm -f "$TARGET_HOME/.config/systemd/user/archbrain"* 2>/dev/null || true

rm -rf "$TARGET_HOME/.local/state/caelestia"
rm -f "$TARGET_HOME/.local/bin/caelestia"* 2>/dev/null || true
rm -f "$TARGET_HOME/.local/bin/dotfiles"* 2>/dev/null || true
rm -f "$TARGET_HOME/.local/bin/archbrain"* 2>/dev/null || true
rm -f "$TARGET_HOME/.face" "$TARGET_HOME/.face.icon" 2>/dev/null || true
rm -f "$TARGET_HOME/genshin_f_macro.py" 2>/dev/null || true
rm -rf "$TARGET_HOME/Pictures/Wallpapers"
rm -rf "$TARGET_HOME/ArchBrain"

# 5. Reset Default Shell back to Bash
echo "▶ [5/6] Resetting login shell to /bin/bash..."
if [ -x /bin/bash ]; then
    chsh -s /bin/bash "$TARGET_USER" 2>/dev/null || true
fi

# 6. Ensure Clean Dotfiles & Active TTY1
echo "▶ [6/6] Ensuring ~/dotfiles is clean and TTY1 is active..."
if [ -d "$TARGET_HOME/dotfiles" ]; then
    sudo -u "$TARGET_USER" git -C "$TARGET_HOME/dotfiles" reset --hard HEAD 2>/dev/null || true
    sudo -u "$TARGET_USER" git -C "$TARGET_HOME/dotfiles" clean -fd 2>/dev/null || true
fi

# Start TTY login prompt
systemctl restart getty@tty1 2>/dev/null || true

echo ""
echo "=========================================================="
echo "✨ System reset complete! All Caelestia/Hyprland packages,"
echo "   configs, user daemons, and artifacts have been removed."
echo "   The laptop is now in a clean minimal CLI base state."
echo ""
echo "To test the fresh install out of the box, run:"
echo "   cd ~/dotfiles && ./install.sh"
echo "=========================================================="
