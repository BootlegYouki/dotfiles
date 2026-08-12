#!/usr/bin/env bash
set -e

echo "=========================================================="
echo "🚀 Caelestia + Hyprland Complete Restoration Script"
echo "=========================================================="

# Determine dotfiles root directory
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
echo "Dotfiles directory: $DOTFILES_DIR"

echo "1. Installing system dependencies & user applications..."
sudo cachyos-rate-mirrors 2>/dev/null || true
sudo pacman -Sy --noconfirm || true

# Ensure yay (AUR helper) is available
if ! command -v yay &>/dev/null; then
    echo "Installing yay-bin..."
    sudo pacman -S --noconfirm --needed yay || {
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        (cd /tmp/yay-bin && makepkg -si --noconfirm)
        rm -rf /tmp/yay-bin
    }
fi

# Resolve package conflicts (replace jack2 with pipewire-jack for Caelestia)
if pacman -Qi jack2 &>/dev/null; then
    echo "Replacing jack2 with pipewire-jack..."
    sudo pacman -Rdd --noconfirm jack2 || true
fi

# Install official packages & core dependencies
sudo pacman -S --noconfirm --needed \
    pipewire-jack hyprland uwsm ghostty waybar fish starship fastfetch \
    gnome-keyring flatpak polkit-kde-agent python-evdev python-pykakasi \
    discord zed vlc cava sunshine hyprsunset cliphist pamixer wl-clipboard \
    python-pillow python-pip

# Install AUR dependencies via yay if missing
if ! pacman -Qi quickshell-git &>/dev/null; then
    echo "Installing quickshell-git from AUR..."
    yay -S --noconfirm quickshell-git
fi
if ! pacman -Qi caelestia-cli &>/dev/null; then
    echo "Installing caelestia-cli from AUR..."
    yay -S --noconfirm caelestia-cli
fi
if ! pacman -Qi brave-bin &>/dev/null; then
    echo "Installing Brave Browser from AUR..."
    yay -S --noconfirm brave-bin
fi
if ! pacman -Qi spotify &>/dev/null; then
    echo "Installing Spotify from AUR..."
    yay -S --noconfirm spotify
fi

echo "2. Copying configurations to ~/.config/..."
for item in "$DOTFILES_DIR/.config/"*; do
    if [ -e "$item" ]; then
        basename_item="$(basename "$item")"
        if [ "$basename_item" != "rclone" ]; then
            echo " - Restoring ~/.config/$basename_item"
            if [ -d "$item" ]; then
                mkdir -p "$HOME/.config/$basename_item"
                cp -R "$item/"* "$HOME/.config/$basename_item/"
            else
                cp "$item" "$HOME/.config/"
            fi
        fi
    fi
done

echo "2.5. Installing system-wide Quickshell QML files (/etc/xdg/quickshell/caelestia)..."
sudo mkdir -p /etc/xdg/quickshell/caelestia
if [ -d "$HOME/.config/quickshell/caelestia" ]; then
    sudo cp -R "$HOME/.config/quickshell/caelestia/"* /etc/xdg/quickshell/caelestia/
fi

# Ensure quickshell default symlink
if [ -f "$HOME/.config/quickshell/caelestia/shell.qml" ]; then
    mkdir -p "$HOME/.config/quickshell"
    ln -sfn "$HOME/.config/quickshell/caelestia/shell.qml" "$HOME/.config/quickshell/shell.qml"
fi

echo "3. Copying bin files to ~/.local/bin/..."
mkdir -p "$HOME/.local/bin"
cp "$DOTFILES_DIR/.local/bin/"* "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/"* 2>/dev/null || true

echo "3.5. Restoring Caelestia state & themes..."
if [ -d "$DOTFILES_DIR/.local/state/caelestia" ]; then
    mkdir -p "$HOME/.local/state/caelestia"
    cp -R "$DOTFILES_DIR/.local/state/caelestia/"* "$HOME/.local/state/caelestia/"
fi

echo "3.6. Restoring Wallpapers repository & fixing path symlinks..."
if [ ! -d "$HOME/Pictures/Wallpapers" ]; then
    mkdir -p "$HOME/Pictures"
    git clone https://github.com/laustoic/laustoic-wallpaper-repo.git "$HOME/Pictures/Wallpapers" || true
fi

# Re-link wallpaper symlinks dynamically for current user
if [ -f "$HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" ]; then
    mkdir -p "$HOME/.local/state/caelestia/wallpaper"
    ln -sfn "$HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" "$HOME/.local/state/caelestia/wallpaper/current"
    echo "$HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" > "$HOME/.local/state/caelestia/wallpaper/path.txt"
fi

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
cp "$DOTFILES_DIR/scripts/genshin_f_macro.py" "$HOME/genshin_f_macro.py"
sudo cp "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" "/etc/systemd/system/genshin-f-macro.service"

echo "5. Restoring ArchBrain vault..."
mkdir -p "$HOME/ArchBrain"
cp -R "$DOTFILES_DIR/ArchBrain/"* "$HOME/ArchBrain/"

echo "6. Reloading and enabling systemd user services..."
systemctl --user daemon-reload
systemctl --user enable --now caelestia-romaji.service || true

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
ExecStart=-/sbin/agetty -o "-p -f -- \u" --noclear --autologin $USER %I \$TERM
EOF

sudo systemctl daemon-reload
sudo systemctl enable getty@tty1.service

echo "8. Applying Caelestia Monochrome Scheme & Launching Shell..."
if command -v caelestia &>/dev/null; then
    caelestia scheme set -n dynamic -v monochrome 2>/dev/null || caelestia scheme set -n catppuccin -v monochrome 2>/dev/null || true
fi

if pgrep -x quickshell > /dev/null; then
    pkill -x quickshell || true
fi

echo "=========================================================="
echo "✨ Restoration Complete!"
echo "Please reboot your system (sudo reboot) to launch into Caelestia Shell."
echo "=========================================================="
