#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "🚀 Caelestia + Hyprland Complete Restoration Script"
echo "=========================================================="

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME="$(eval echo "~$TARGET_USER")"

# Determine dotfiles root directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "Dotfiles directory: $DOTFILES_DIR"
echo "Target User: $TARGET_USER ($TARGET_HOME)"

echo "1. Refreshing package databases & updating mirrors..."
sudo cachyos-rate-mirrors 2>/dev/null || true
sudo pacman -Sy --noconfirm || true

# Ensure base-devel, git, and paru (AUR helper) are available
echo "1.1. Installing build tools & AUR helper..."
sudo pacman -S --noconfirm --needed base-devel git || true

if ! command -v paru &>/dev/null; then
    echo "Installing paru..."
    sudo pacman -S --noconfirm --needed paru || {
        git clone https://aur.archlinux.org/paru-bin.git /tmp/paru-bin
        (cd /tmp/paru-bin && makepkg -si --noconfirm)
        rm -rf /tmp/paru-bin
    }
fi

# Resolve package conflicts (replace jack2 with pipewire-jack for Caelestia)
if pacman -Qi jack2 &>/dev/null; then
    echo "Replacing jack2 with pipewire-jack..."
    sudo pacman -Rdd --noconfirm jack2 || true
fi

echo "1.2. Installing official packages, fonts, CLI tools & multimedia stack..."
sudo pacman -S --noconfirm --needed \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    hyprland uwsm ghostty waybar fish starship fastfetch gnome-keyring \
    flatpak polkit-kde-agent python-evdev python-pykakasi discord zed vlc cava \
    sunshine hyprsunset cliphist pamixer wl-clipboard playerctl grim slurp \
    hyprpicker brightnessctl python-pillow python-pip \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk \
    jq socat fd ripgrep fzf zoxide direnv eza

echo "1.3. Installing Caelestia & AUR dependencies..."
if ! pacman -Qi quickshell-git &>/dev/null; then
    echo "Installing quickshell-git from AUR..."
    su - "$TARGET_USER" -c "paru -S --noconfirm quickshell-git" || true
fi
if ! pacman -Qi caelestia-cli &>/dev/null; then
    echo "Installing caelestia-cli from AUR..."
    su - "$TARGET_USER" -c "paru -S --noconfirm caelestia-cli" || true
fi
if ! pacman -Qi ttf-material-symbols-variable-git &>/dev/null && ! pacman -Qi ttf-material-symbols-variable &>/dev/null; then
    echo "Installing Material Symbols font from AUR..."
    su - "$TARGET_USER" -c "paru -S --noconfirm ttf-material-symbols-variable-git" || true
fi
if ! pacman -Qi brave-bin &>/dev/null; then
    echo "Installing Brave Browser from AUR..."
    su - "$TARGET_USER" -c "paru -S --noconfirm brave-bin" || true
fi
if ! pacman -Qi spotify &>/dev/null; then
    echo "Installing Spotify from AUR..."
    su - "$TARGET_USER" -c "paru -S --noconfirm spotify" || true
fi

echo "1.4. Executing Caelestia CLI component initialization..."
if command -v caelestia &>/dev/null; then
    su - "$TARGET_USER" -c "caelestia install --noconfirm" || true
fi

echo "2. Copying user configurations to $TARGET_HOME/.config/..."
for item in "$DOTFILES_DIR/.config/"*; do
    if [ -e "$item" ]; then
        basename_item="$(basename "$item")"
        if [ "$basename_item" != "rclone" ]; then
            echo " - Restoring $TARGET_HOME/.config/$basename_item"
            if [ -d "$item" ]; then
                mkdir -p "$TARGET_HOME/.config/$basename_item"
                cp -R "$item/"* "$TARGET_HOME/.config/$basename_item/"
            else
                cp "$item" "$TARGET_HOME/.config/"
            fi
        fi
    fi
done

echo "2.5. Installing system-wide Quickshell QML files (/etc/xdg/quickshell/caelestia)..."
sudo mkdir -p /etc/xdg/quickshell/caelestia
if [ -d "$TARGET_HOME/.config/quickshell/caelestia" ]; then
    sudo cp -R "$TARGET_HOME/.config/quickshell/caelestia/"* /etc/xdg/quickshell/caelestia/
fi

# Ensure quickshell default symlink
if [ -f "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" ]; then
    mkdir -p "$TARGET_HOME/.config/quickshell"
    ln -sfn "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" "$TARGET_HOME/.config/quickshell/shell.qml"
fi

echo "3. Copying bin files to $TARGET_HOME/.local/bin/..."
mkdir -p "$TARGET_HOME/.local/bin"
cp "$DOTFILES_DIR/.local/bin/"* "$TARGET_HOME/.local/bin/"
chmod +x "$TARGET_HOME/.local/bin/"* 2>/dev/null || true

echo "3.5. Restoring Caelestia state & themes..."
if [ -d "$DOTFILES_DIR/.local/state/caelestia" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia"
    cp -R "$DOTFILES_DIR/.local/state/caelestia/"* "$TARGET_HOME/.local/state/caelestia/"
fi

echo "3.6. Restoring Wallpapers repository & fixing path symlinks..."
if [ ! -d "$TARGET_HOME/Pictures/Wallpapers" ]; then
    mkdir -p "$TARGET_HOME/Pictures"
    git clone https://github.com/laustoic/laustoic-wallpaper-repo.git "$TARGET_HOME/Pictures/Wallpapers" || true
fi

# Re-link wallpaper symlinks dynamically for target user
if [ -f "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia/wallpaper"
    ln -sfn "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" "$TARGET_HOME/.local/state/caelestia/wallpaper/current"
    echo "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" > "$TARGET_HOME/.local/state/caelestia/wallpaper/path.txt"
fi

chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.local" "$TARGET_HOME/Pictures" 2>/dev/null || true

echo "3.7. Configuring system locale (/etc/locale.conf -> en_US.UTF-8)..."
sudo tee /etc/locale.conf > /dev/null << 'EOF'
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8
LC_NUMERIC=en_US.UTF-8
LC_MONETARY=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_NAME=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
EOF

echo "4. Restoring Genshin F-Macro..."
cp "$DOTFILES_DIR/scripts/genshin_f_macro.py" "$TARGET_HOME/genshin_f_macro.py"
sudo cp "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" "/etc/systemd/system/genshin-f-macro.service"

echo "5. Restoring ArchBrain vault..."
if [ -d "$DOTFILES_DIR/ArchBrain" ]; then
    mkdir -p "$TARGET_HOME/ArchBrain"
    cp -a "$DOTFILES_DIR/ArchBrain/." "$TARGET_HOME/ArchBrain/"
fi

if [ -d "$DOTFILES_DIR/system/etc/pacman.d/hooks" ]; then
    echo -e "\n[6.5/8] Deploying pacman system hooks..."
    mkdir -p /etc/pacman.d/hooks
    cp -a "$DOTFILES_DIR/system/etc/pacman.d/hooks/." /etc/pacman.d/hooks/
fi
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/ArchBrain" "$TARGET_HOME/genshin_f_macro.py" 2>/dev/null || true

echo "6. Reloading and enabling systemd user services..."
if [ -n "$SUDO_USER" ]; then
    su - "$TARGET_USER" -c "XDG_RUNTIME_DIR=/run/user/$(id -u "$TARGET_USER") systemctl --user daemon-reload" 2>/dev/null || true
    su - "$TARGET_USER" -c "XDG_RUNTIME_DIR=/run/user/$(id -u "$TARGET_USER") systemctl --user enable --now caelestia-romaji.service" 2>/dev/null || true
else
    systemctl --user daemon-reload 2>/dev/null || true
    systemctl --user enable --now caelestia-romaji.service 2>/dev/null || true
fi

echo "7. Reloading and enabling systemd system services..."
sudo systemctl daemon-reload
sudo systemctl enable --now genshin-f-macro.service || true

echo "7.5. Configuring Getty tty1 Autologin (0-RAM Display Manager Replacement)..."
sudo systemctl disable sddm 2>/dev/null || true
sudo systemctl disable gdm 2>/dev/null || true

sudo mkdir -p /etc/systemd/system/getty@tty1.service.d
sudo tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o "-p -f -- \u" --noclear --autologin $TARGET_USER %I \$TERM
EOF

sudo systemctl daemon-reload
sudo systemctl enable getty@tty1.service

echo "=========================================================="
echo "✨ Restoration Complete!"
echo "Please reboot your system (sudo reboot) to launch into Caelestia Shell."
echo "=========================================================="
