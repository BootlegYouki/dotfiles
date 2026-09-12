#!/usr/bin/env bash
# ==============================================================================
#  Caelestia + Hyprland + SDDM Complete System Installer for CachyOS / Arch
# Designed for fresh minimal installations (no Desktop Environment / CLI only)
# ==============================================================================

set -eo pipefail

# 0. Safety: Ensure script is run as a regular user with sudo privileges
if [ "$(id -u)" -eq 0 ]; then
    echo "❌ Error: Do not run this installer directly as root."
    echo "   makepkg, yay, and paru refuse to build packages as root."
    echo "   Please run as your regular user: ./install.sh"
    exit 1
fi

TARGET_USER="$USER"
TARGET_HOME="$HOME"
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================================="
echo "✨ Caelestia Desktop + Hyprland + SDDM Turnkey Installer"
echo "=========================================================="
echo "Target User: $TARGET_USER ($TARGET_HOME)"
echo "Source:      $DOTFILES_DIR"
echo ""

# 1. Prompt and cache sudo credentials upfront
sudo -v
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
SUDO_KEEP_ALIVE_PID=$!
trap 'kill "$SUDO_KEEP_ALIVE_PID" 2>/dev/null || true' EXIT

# --- Step 1: Package Databases & Mirrors ---
echo "▶ [1/10] Refreshing mirrors and updating package databases..."
sudo cachyos-rate-mirrors 2>/dev/null || true
sudo pacman -Sy --noconfirm archlinux-keyring cachyos-keyring 2>/dev/null || true

# --- Step 2: Build Essentials & AUR Helper ---
echo "▶ [2/10] Installing build essentials and ensuring AUR helper..."
# Remove known conflicting packages before installing
sudo pacman -Rdd --noconfirm \
    noctalia-qs \
    quickshell \
    caelestia-sddm \
    caelestia-sddm-locklike-git \
    caelestia-sddm-minimalist-git \
    caelestia-shell-git \
    jack2 \
    pulseaudio 2>/dev/null || true

sudo pacman -S --noconfirm --needed base-devel git pciutils

if ! command -v paru &>/dev/null && ! command -v yay &>/dev/null; then
    echo "Installing paru from CachyOS repositories..."
    sudo pacman -S --noconfirm --needed paru || sudo pacman -S --noconfirm --needed yay || {
        echo "Building yay-bin fallback..."
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        (cd /tmp/yay-bin && makepkg -si --noconfirm)
        rm -rf /tmp/yay-bin
    }
fi

# Standard non-interactive installer wrappers (properly auto-selects default 1 for provider prompts)
pacman_install() {
    sudo pacman -S --noconfirm --needed --overwrite "*" "$@"
}

aur_install() {
    if command -v paru &>/dev/null; then
        paru -S --noconfirm --needed --skipreview --overwrite "*" "$@"
    elif command -v yay &>/dev/null; then
        yay -S --noconfirm --needed --answerclean None --answerdiff None --overwrite "*" "$@"
    else
        echo "❌ Error: Neither paru nor yay found for AUR installation."
        exit 1
    fi
}

# Resolve audio stack conflict: replace jack2 with pipewire-jack
if pacman -Qi jack2 &>/dev/null; then
    echo "Replacing conflicting jack2 with pipewire-jack..."
    sudo pacman -Rdd --noconfirm jack2 || true
fi

# --- Step 3: GPU Hardware Driver Detection ---
echo "▶ [3/10] Detecting GPU hardware and installing display drivers..."
GPU_INFO="$(lspci | grep -Ei 'vga|3d|display' || true)"
echo "Detected hardware: $GPU_INFO"

if echo "$GPU_INFO" | grep -iq "nvidia"; then
    echo "  → NVIDIA GPU detected: installing nvidia-dkms and utilities..."
    pacman_install nvidia-dkms nvidia-utils libva-nvidia-driver || true
elif echo "$GPU_INFO" | grep -iq "amd"; then
    echo "  → AMD GPU detected: installing mesa and vulkan-radeon..."
    pacman_install mesa lib32-mesa xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon || true
elif echo "$GPU_INFO" | grep -iq "intel"; then
    echo "  → Intel GPU detected: installing intel-media-driver and vulkan-intel..."
    pacman_install mesa lib32-mesa intel-media-driver vulkan-intel || true
fi

# --- Step 4: Official Pacman Packages ---
echo "▶ [4/10] Installing Hyprland, audio, desktop apps, and system utilities..."
pacman_install \
    hyprland uwsm ghostty waybar fish starship fastfetch gnome-keyring polkit-kde-agent \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    pamixer playerctl brightnessctl grim slurp wl-clipboard cliphist hyprpicker hyprsunset \
    jq socat fd ripgrep fzf zoxide direnv eza btop cava micro python-pillow python-pip python-evdev python-pykakasi \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk \
    ttf-roboto ttf-cascadia-code-nerd ttf-material-symbols-variable flatpak brave-origin-bin discord zed vlc steam \
    ddcutil lm_sensors aubio libpipewire libqalculate power-profiles-daemon swappy

# --- Step 5: SDDM Display Manager & Caelestia Theme ---
echo "▶ [5/10] Installing SDDM and Caelestia SDDM Locklike theme..."
pacman_install \
    sddm qt6-declarative qt6-5compat qt6-svg qt6-multimedia

# Install Caelestia SDDM minimalistV2 theme from AUR
if ! pacman -Qi caelestia-sddm-minimalistv2-git &>/dev/null && ! pacman -Qi caelestia-sddm &>/dev/null; then
    echo "Installing caelestia-sddm-minimalistv2-git from AUR..."
    aur_install caelestia-sddm-minimalistv2-git
fi

# Deploy SDDM configuration
echo "Deploying /etc/sddm.conf.d/caelestia.conf..."
sudo mkdir -p /etc/sddm.conf.d
sudo rm -f /etc/sddm.conf.d/10-theme.conf 2>/dev/null || true

if [ -f "$DOTFILES_DIR/system/etc/sddm.conf.d/caelestia.conf" ]; then
    sudo cp "$DOTFILES_DIR/system/etc/sddm.conf.d/caelestia.conf" /etc/sddm.conf.d/caelestia.conf
else
    sudo tee /etc/sddm.conf.d/caelestia.conf > /dev/null << 'EOF'
[General]
GreeterEnvironment=QML_XHR_ALLOW_FILE_READ=1,QT_QPA_PLATFORM=xcb

[Theme]
Current=caelestia
EOF
fi

# Deploy SDDM User Avatars
sudo mkdir -p /usr/share/sddm/faces
if [ -f "$DOTFILES_DIR/assets/.face.icon" ]; then
    sudo cp "$DOTFILES_DIR/assets/.face.icon" "/usr/share/sddm/faces/$TARGET_USER.face.icon"
    sudo cp "$DOTFILES_DIR/assets/.face.icon" "/usr/share/sddm/faces/.face.icon"
    sudo chmod 644 "/usr/share/sddm/faces/$TARGET_USER.face.icon" "/usr/share/sddm/faces/.face.icon"
fi

# Enable SDDM display manager and ensure graphical target
sudo systemctl set-default graphical.target
sudo systemctl enable sddm
echo "  ✓ Default target set to graphical.target"
echo "  ✓ SDDM enabled"

# Remove conflicting CachyOS quickshell forks if present
if pacman -Qi noctalia-qs &>/dev/null || pacman -Qi quickshell &>/dev/null; then
    echo "Removing conflicting quickshell/noctalia-qs package..."
    sudo pacman -Rdd --noconfirm noctalia-qs quickshell 2>/dev/null || true
fi

# --- Step 6: Caelestia Shell & AUR Desktop Packages ---
echo "▶ [6/10] Installing Quickshell-git and Caelestia desktop shell dependencies..."
# Force aur/ prefix so CachyOS doesn't hijack quickshell with outdated noctalia-qs
aur_install \
    aur/quickshell-git \
    caelestia-cli \
    caelestia-shell \
    ttf-rubik-vf \
    spotify \
    spicetify-cli \
    spicetify-marketplace-bin \
    twintaillauncher-bin

if command -v caelestia &>/dev/null; then
    echo "Running Caelestia CLI setup..."
    caelestia install --noconfirm 2>/dev/null || true
fi

# --- Step 7: Restoring Dotfiles & User Configurations ---
echo "▶ [7/10] Restoring user configurations to ~/.config and ~/.local..."

# 7.1 .config files
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
            echo "  ✓ ~/.config/$name"
        fi
    fi
done

# Clean up obsolete 2.3.0 QML files if previously present
rm -f "$TARGET_HOME/.config/quickshell/caelestia/services/NetworkUsage.qml" 2>/dev/null || true

# 7.2 System-wide Quickshell QML
sudo mkdir -p /etc/xdg/quickshell/caelestia
if [ -d "$TARGET_HOME/.config/quickshell/caelestia" ]; then
    sudo cp -R "$TARGET_HOME/.config/quickshell/caelestia/"* /etc/xdg/quickshell/caelestia/
fi

# Ensure default shell.qml link
if [ -f "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" ]; then
    mkdir -p "$TARGET_HOME/.config/quickshell"
    ln -sfn "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" "$TARGET_HOME/.config/quickshell/shell.qml"
fi

# 7.3 Binary utilities
mkdir -p "$TARGET_HOME/.local/bin"
if [ -d "$DOTFILES_DIR/bin" ]; then
    cp "$DOTFILES_DIR/bin/"* "$TARGET_HOME/.local/bin/"
    chmod +x "$TARGET_HOME/.local/bin/"* 2>/dev/null || true
fi

# 7.4 Caelestia state & themes
if [ -d "$DOTFILES_DIR/.local/state/caelestia" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia"
    cp -R "$DOTFILES_DIR/.local/state/caelestia/"* "$TARGET_HOME/.local/state/caelestia/"
fi

# 7.5 User avatar & bash profile
if [ -f "$DOTFILES_DIR/.bash_profile" ]; then
    cp "$DOTFILES_DIR/.bash_profile" "$TARGET_HOME/.bash_profile"
fi
if [ -f "$DOTFILES_DIR/assets/.face" ]; then
    cp "$DOTFILES_DIR/assets/.face" "$TARGET_HOME/.face"
    cp "$DOTFILES_DIR/assets/.face.icon" "$TARGET_HOME/.face.icon" 2>/dev/null || true
fi

# 7.6 Wallpapers
echo "Syncing wallpapers..."
if [ ! -d "$TARGET_HOME/Pictures/Wallpapers" ]; then
    mkdir -p "$TARGET_HOME/Pictures"
    git clone --depth 1 https://github.com/laustoic/laustoic-wallpaper-repo.git "$TARGET_HOME/Pictures/Wallpapers" 2>/dev/null || true
fi

# Flatten subfolder if present
if [ -d "$TARGET_HOME/Pictures/Wallpapers/Wallpapers" ]; then
    mv "$TARGET_HOME/Pictures/Wallpapers/Wallpapers/"* "$TARGET_HOME/Pictures/Wallpapers/" 2>/dev/null || true
    rmdir "$TARGET_HOME/Pictures/Wallpapers/Wallpapers" 2>/dev/null || true
fi

if [ -f "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia/wallpaper"
    ln -sfn "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" "$TARGET_HOME/.local/state/caelestia/wallpaper/current"
    echo "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" > "$TARGET_HOME/.local/state/caelestia/wallpaper/path.txt"
fi

# Generate initial dynamic color scheme from wallpaper
if command -v caelestia &>/dev/null; then
    echo "Generating dynamic Material 3 color scheme from wallpaper..."
    caelestia scheme -c 2>/dev/null || true
fi

# 7.7 ArchBrain Vault
if [ -d "$DOTFILES_DIR/ArchBrain" ]; then
    mkdir -p "$TARGET_HOME/ArchBrain"
    cp -a "$DOTFILES_DIR/ArchBrain/." "$TARGET_HOME/ArchBrain/"
fi

# 7.8 Spicetify Setup (Themes, Marketplace & Extensions)
if command -v spicetify &>/dev/null && [ -d "/opt/spotify" ]; then
    echo "Configuring Spicetify, themes, and Marketplace..."
    sudo chmod a+wr /opt/spotify 2>/dev/null || true
    sudo chmod a+wr /opt/spotify/Apps -R 2>/dev/null || true

    mkdir -p "$TARGET_HOME/.config/spotify"
    touch "$TARGET_HOME/.config/spotify/prefs"

    mkdir -p "$TARGET_HOME/.config/spicetify/CustomApps"
    mkdir -p "$TARGET_HOME/.config/spicetify/Themes"

    if [ -d "/opt/spicetify-cli/CustomApps/marketplace" ]; then
        ln -sfn "/opt/spicetify-cli/CustomApps/marketplace" "$TARGET_HOME/.config/spicetify/CustomApps/marketplace"
    fi
    if [ -d "/opt/spicetify-cli/Themes/marketplace" ]; then
        ln -sfn "/opt/spicetify-cli/Themes/marketplace" "$TARGET_HOME/.config/spicetify/Themes/marketplace"
    fi

    # Fix prefs_path in config-xpui.ini for target user
    if [ -f "$TARGET_HOME/.config/spicetify/config-xpui.ini" ]; then
        sed -i "s|prefs_path.*=.*|prefs_path = $TARGET_HOME/.config/spotify/prefs|" "$TARGET_HOME/.config/spicetify/config-xpui.ini"
    fi

    echo "Applying Spicetify customization..."
    sudo -u "$TARGET_USER" spicetify backup apply 2>/dev/null || sudo -u "$TARGET_USER" spicetify apply 2>/dev/null || true
fi

# --- Step 8: Debloat Pre-Installed Packages & Clean Launchers ---
echo "▶ [8/10] Removing bloatware and cleaning application launchers..."

# 8.1 Remove redundant and unwanted pre-installed packages
BLOAT_PACKAGES=(
    firefox
    brave-bin
    alacritty
    foot
    pwvucontrol
    cachyos-hello
    cachyos-packageinstaller
    meld
)

for b_pkg in "${BLOAT_PACKAGES[@]}"; do
    if pacman -Qi "$b_pkg" &>/dev/null; then
        echo "  - Removing bloat package: $b_pkg..."
        sudo pacman -Rdd --noconfirm "$b_pkg" 2>/dev/null || true
    fi
done

# 8.2 Hide unwanted library GUI shortcuts from launcher without breaking dependencies
mkdir -p "$TARGET_HOME/.local/share/applications"
HIDDEN_DESKTOP_FILES=(
    qv4l2.desktop
    qvidcap.desktop
    lstopo.desktop
    xgps.desktop
    xgpsspeed.desktop
    uuctl.desktop
    avahi-discover.desktop
    bssh.desktop
    bvnc.desktop
    xfce4-about.desktop
    thunar-settings.desktop
    thunar-bulk-rename.desktop
)

for dfile in "${HIDDEN_DESKTOP_FILES[@]}"; do
    if [ -f "/usr/share/applications/$dfile" ]; then
        echo "  - Hiding launcher shortcut: $dfile"
        cp "/usr/share/applications/$dfile" "$TARGET_HOME/.local/share/applications/$dfile"
        echo "NoDisplay=true" >> "$TARGET_HOME/.local/share/applications/$dfile"
    fi
done
update-desktop-database "$TARGET_HOME/.local/share/applications" 2>/dev/null || true

# --- Step 9: Set Default Login Shell to Fish ---
echo "▶ [9/10] Setting default login shell to Fish..."
FISH_BIN="$(command -v fish || echo "/usr/bin/fish")"
if [ "$SHELL" != "$FISH_BIN" ]; then
    if grep -Fxq "$FISH_BIN" /etc/shells; then
        chsh -s "$FISH_BIN" "$TARGET_USER" 2>/dev/null || sudo chsh -s "$FISH_BIN" "$TARGET_USER"
        echo "  ✓ Default shell changed to $FISH_BIN"
    fi
fi

# Ensure correct home directory permissions (allow SDDM to access face icon)
chmod 755 "$TARGET_HOME"
sudo chown -R "$TARGET_USER:$TARGET_USER" \
    "$TARGET_HOME/.config" \
    "$TARGET_HOME/.local" \
    "$TARGET_HOME/Pictures" \
    "$TARGET_HOME/ArchBrain" \
    "$TARGET_HOME/.face" \
    "$TARGET_HOME/.face.icon" \
    "$TARGET_HOME/.bash_profile" 2>/dev/null || true

# --- Step 10: Enable Services & Pacman Hooks ---
echo "▶ [10/10] Enabling user daemons and system services..."

# Pacman Hooks
if [ -d "$DOTFILES_DIR/system/etc/pacman.d/hooks" ]; then
    sudo mkdir -p /etc/pacman.d/hooks
    sudo cp -a "$DOTFILES_DIR/system/etc/pacman.d/hooks/." /etc/pacman.d/hooks/
    if [ -f /etc/pacman.d/hooks/90-spicetify-apply.hook ]; then
        sudo sed -i "s/youki/$TARGET_USER/g" /etc/pacman.d/hooks/90-spicetify-apply.hook 2>/dev/null || true
    fi
fi

# Genshin macro service
if [ -f "$DOTFILES_DIR/scripts/genshin_f_macro.py" ]; then
    cp "$DOTFILES_DIR/scripts/genshin_f_macro.py" "$TARGET_HOME/genshin_f_macro.py"
    sudo chown "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/genshin_f_macro.py"
fi
if [ -f "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" ]; then
    sudo cp "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" /etc/systemd/system/genshin-f-macro.service
    sudo systemctl daemon-reload
    sudo systemctl enable genshin-f-macro.service 2>/dev/null || true
fi

# User services & timers
systemctl --user daemon-reload 2>/dev/null || true
systemctl --user enable caelestia-romaji.service 2>/dev/null || true
systemctl --user enable dotfiles-sync.timer 2>/dev/null || true
systemctl --user enable archbrain-sync.timer 2>/dev/null || true

echo ""
echo "=========================================================="
echo "🎉 Installation & Configuration Complete!"
echo "=========================================================="
echo "✓ SDDM Display Manager enabled with Caelestia Locklike theme."
echo "✓ Hyprland & UWSM session configured."
echo "✓ Default shell set to Fish with Starship prompt."
echo "✓ Desktop widgets, wallpapers, and fonts restored."
echo ""
echo "Rebooting system in 3 seconds (press Ctrl+C to cancel)..."
echo "=========================================================="
sleep 3
sudo reboot
