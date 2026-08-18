#!/usr/bin/env bash
set -eo pipefail

echo "=========================================================="
echo "🚀 Caelestia + Hyprland Minimal Restoration Script"
echo "=========================================================="

# Ensure running with root privileges
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Please run this script with sudo."
  exit 1
fi

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(getent passwd "$TARGET_USER" | cut -d: -f6)"
TARGET_UID="$(id -u "$TARGET_USER")"

# Determine dotfiles root directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Target User: $TARGET_USER ($TARGET_HOME)"

# Helper function to run commands as non-root user
run_as_user() {
    sudo -u "$TARGET_USER" XDG_RUNTIME_DIR="/run/user/$TARGET_UID" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" "$@"
}

echo -e "\n[0/6] 🧹 Wiping existing configurations & cached files..."
rm -rf "$TARGET_HOME/.config/caelestia" "$TARGET_HOME/.config/quickshell" "$TARGET_HOME/.config/hypr"
rm -rf "$TARGET_HOME/.local/state/caelestia" /etc/xdg/quickshell/caelestia
mkdir -p "$TARGET_HOME/.config" "$TARGET_HOME/.local/bin"

echo -e "\n[1/6] Refreshing package databases..."
cachyos-rate-mirrors 2>/dev/null || true
pacman -Sy --noconfirm || true

echo -e "\n[1.1/6] Installing build tools & Paru..."
pacman -S --noconfirm --needed base-devel git || true

if ! command -v paru &>/dev/null; then
    echo "Installing paru-bin..."
    if pacman -Si paru &>/dev/null; then
        pacman -S --noconfirm --needed paru
    else
        git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
        chown -R "$TARGET_USER:$TARGET_USER" /tmp/paru-bin
        (cd /tmp/paru-bin && run_as_user makepkg -si --noconfirm)
        rm -rf /tmp/paru-bin
    fi
fi

# Force remove any conflicting legacy packages
echo "Clearing potential conflicting packages..."
pacman -Rdd --noconfirm jack2 caelestia-shell quickshell noctalia-qs 2>/dev/null || true

echo -e "\n[1.2/6] Installing core Hyprland stack & CLI utilities..."
pacman -S --noconfirm --needed \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    hyprland uwsm polkit-kde-agent pamixer wl-clipboard playerctl \
    brightnessctl grim slurp hyprpicker gnome-keyring seahorse \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk \
    jq socat fd ripgrep fzf

echo -e "\n[1.3/6] Installing Caelestia core packages from AUR..."
AUR_LIST=(
    "quickshell-git"
    "caelestia-shell-git"
    "caelestia-cli"
    "ttf-material-symbols-variable-git"
)

for pkg in "${AUR_LIST[@]}"; do
    echo "--> Installing $pkg..."
    run_as_user paru -S --noconfirm --needed --skipreview "$pkg" || \
    run_as_user paru -S --noconfirm --needed --nodeps --skipreview "$pkg" || true
done

echo -e "\n[2/6] Restoring Caelestia & Hyprland configurations..."
mkdir -p "$TARGET_HOME/.config"
if [ -d "$DOTFILES_DIR/.config" ]; then
    cp -a "$DOTFILES_DIR/.config/." "$TARGET_HOME/.config/" 2>/dev/null || true
fi

echo -e "\n[2.5/6] Deploying system-wide Quickshell QML files..."
sudo mkdir -p /etc/xdg/quickshell/caelestia
if [ -d "$DOTFILES_DIR/.config/quickshell/caelestia" ]; then
    sudo cp -a "$DOTFILES_DIR/.config/quickshell/caelestia/." /etc/xdg/quickshell/caelestia/
    sudo find /etc/xdg/quickshell/caelestia/ -name "*.qml" -exec sed -i 's/\/\/@ pragma/\/\/ pragma/g' {} + 2>/dev/null || true
fi

# Ensure root shell entry point symlink exists
mkdir -p "$TARGET_HOME/.config/quickshell"
if [ -f "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" ]; then
    ln -sfn "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" "$TARGET_HOME/.config/quickshell/shell.qml"
fi

echo -e "\n[3/6] Restoring local state & binaries..."
if [ -d "$DOTFILES_DIR/.local/bin" ]; then
    cp -a "$DOTFILES_DIR/.local/bin/." "$TARGET_HOME/.local/bin/"
    chmod +x "$TARGET_HOME/.local/bin/"* 2>/dev/null || true
fi

if [ -d "$DOTFILES_DIR/.local/state/caelestia" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia"
    cp -a "$DOTFILES_DIR/.local/state/caelestia/." "$TARGET_HOME/.local/state/caelestia/"
fi

echo -e "\n[4/6] Resetting GNOME Keyring store..."
rm -rf "$TARGET_HOME/.local/share/keyrings"
mkdir -p "$TARGET_HOME/.local/share/keyrings"
tee "$TARGET_HOME/.local/share/keyrings/default" > /dev/null << 'EOF'
Default
EOF
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/share/keyrings"

# Fix ownership across home directory configs
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.local" 2>/dev/null || true

echo -e "\n[5/6] Enabling user services..."
run_as_user systemctl --user daemon-reload 2>/dev/null || true
run_as_user systemctl --user enable --now caelestia-romaji.service 2>/dev/null || true

echo -e "\n[6/6] Finalizing display manager..."
# SDDM remains enabled for KDE Plasma / Hyprland session selection
systemctl enable sddm 2>/dev/null || true

echo "=========================================================="
echo "✨ Installation complete! Rebooting in 3 seconds..."
echo "=========================================================="
sleep 3
sudo reboot
