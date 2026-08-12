#!/usr/bin/env bash
set -eo pipefail

echo "=========================================================="
echo "🚀 Caelestia + Hyprland Complete Restoration Script"
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

# Helper function to run commands as the target non-root user with proper environment
run_as_user() {
    sudo -u "$TARGET_USER" XDG_RUNTIME_DIR="/run/user/$TARGET_UID" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$TARGET_UID/bus" "$@"
}

echo "1. Refreshing package databases & updating mirrors..."
cachyos-rate-mirrors 2>/dev/null || true
pacman -Sy --noconfirm || true

echo "1.1. Installing build tools & AUR helper..."
pacman -S --noconfirm --needed base-devel git || true

if ! command -v yay &>/dev/null; then
    echo "Installing yay-bin..."
    if pacman -Si yay &>/dev/null; then
        pacman -S --noconfirm --needed yay
    else
        git clone https://aur.archlinux.org/yay-bin.git /tmp/yay-bin
        chown -R "$TARGET_USER:$TARGET_USER" /tmp/yay-bin
        (cd /tmp/yay-bin && run_as_user makepkg -si --noconfirm)
        rm -rf /tmp/yay-bin
    fi
fi

# Resolve package conflicts (replace jack2 with pipewire-jack for Caelestia)
if pacman -Qi jack2 &>/dev/null; then
    echo "Replacing jack2 with pipewire-jack..."
    pacman -Rdd --noconfirm jack2 || true
fi

echo "1.2. Installing official packages, fonts, CLI tools & multimedia stack..."
pacman -S --noconfirm --needed \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    hyprland uwsm ghostty waybar fish starship fastfetch gnome-keyring \
    flatpak polkit-kde-agent python-evdev python-pykakasi discord zed vlc cava \
    sunshine hyprsunset cliphist pamixer wl-clipboard playerctl grim slurp \
    hyprpicker brightnessctl python-pillow python-pip \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk \
    jq socat fd ripgrep fzf zoxide direnv eza

echo "1.3. Installing Caelestia & AUR dependencies..."
AUR_PKGS=()
pacman -Qi quickshell-git &>/dev/null || AUR_PKGS+=("quickshell-git")
pacman -Qi caelestia-cli &>/dev/null || AUR_PKGS+=("caelestia-cli")
pacman -Qi ttf-material-symbols-variable-git &>/dev/null || pacman -Qi ttf-material-symbols-variable &>/dev/null || AUR_PKGS+=("ttf-material-symbols-variable-git")
pacman -Qi brave-bin &>/dev/null || AUR_PKGS+=("brave-bin")
pacman -Qi spotify &>/dev/null || AUR_PKGS+=("spotify")

if [ ${#AUR_PKGS[@]} -gt 0 ]; then
    echo "Installing missing AUR packages: ${AUR_PKGS[*]}"
    run_as_user yay -S --noconfirm "${AUR_PKGS[@]}" || true
fi

echo "2. Copying user configurations to $TARGET_HOME/.config/..."
mkdir -p "$TARGET_HOME/.config"
if [ -d "$DOTFILES_DIR/.config" ]; then
    shopt -s dotglob
    for item in "$DOTFILES_DIR/.config/"*; do
        if [ -e "$item" ]; then
            basename_item="$(basename "$item")"
            if [ "$basename_item" != "rclone" ] && [ "$basename_item" != "." ] && [ "$basename_item" != ".." ]; then
                echo " - Restoring $TARGET_HOME/.config/$basename_item"
                mkdir -p "$TARGET_HOME/.config/$basename_item"
                cp -a "$item/." "$TARGET_HOME/.config/$basename_item/" 2>/dev/null || true
            fi
        fi
    done
    shopt -u dotglob
fi

echo "2.5. Installing system-wide Quickshell QML files (/etc/xdg/quickshell/caelestia)..."
mkdir -p /etc/xdg/quickshell/caelestia
if [ -d "$TARGET_HOME/.config/quickshell/caelestia" ]; then
    cp -a "$TARGET_HOME/.config/quickshell/caelestia/." /etc/xdg/quickshell/caelestia/
    
    # Sanitize any unsupported //@ pragma directives in QML files
    find /etc/xdg/quickshell/caelestia/ -name "*.qml" -exec sed -i 's/\/\/@ pragma/\/\/ pragma/g' {} + 2>/dev/null || true
fi

# Ensure quickshell default symlink
if [ -f "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" ]; then
    mkdir -p "$TARGET_HOME/.config/quickshell"
    ln -sfn "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" "$TARGET_HOME/.config/quickshell/shell.qml"
fi

echo "1.4. Executing Caelestia CLI component initialization..."
if command -v caelestia &>/dev/null; then
    run_as_user caelestia install --noconfirm || true
fi

echo "3. Copying bin files to $TARGET_HOME/.local/bin/..."
mkdir -p "$TARGET_HOME/.local/bin"
if [ -d "$DOTFILES_DIR/.local/bin" ]; then
    cp -a "$DOTFILES_DIR/.local/bin/." "$TARGET_HOME/.local/bin/"
    chmod +x "$TARGET_HOME/.local/bin/"* 2>/dev/null || true
fi

echo "3.5. Restoring Caelestia state & themes..."
if [ -d "$DOTFILES_DIR/.local/state/caelestia" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia"
    cp -a "$DOTFILES_DIR/.local/state/caelestia/." "$TARGET_HOME/.local/state/caelestia/"
fi

echo "3.6. Restoring Wallpapers repository & fixing path symlinks..."
if [ ! -d "$TARGET_HOME/Pictures/Wallpapers" ]; then
    mkdir -p "$TARGET_HOME/Pictures"
    run_as_user git clone https://github.com/laustoic/laustoic-wallpaper-repo.git "$TARGET_HOME/Pictures/Wallpapers" || true
fi

if [ -f "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia/wallpaper"
    ln -sfn "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" "$TARGET_HOME/.local/state/caelestia/wallpaper/current"
    echo "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" > "$TARGET_HOME/.local/state/caelestia/wallpaper/path.txt"
fi

echo "3.7. Configuring system locale (/etc/locale.conf -> en_US.UTF-8)..."
tee /etc/locale.conf > /dev/null << 'EOF'
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8
LC_NUMERIC=en_US.UTF-8
LC_MONETARY=en_US.UTF-8
LC_PAPER=en_US.UTF-8
LC_ADDRESS=en_US.UTF-8
LC_TELEPHONE=en_US.UTF-8
LC_MEASUREMENT=en_US.UTF-8
LC_IDENTIFICATION=en_US.UTF-8
EOF

echo "4. Restoring Genshin F-Macro..."
if [ -f "$DOTFILES_DIR/scripts/genshin_f_macro.py" ]; then
    cp "$DOTFILES_DIR/scripts/genshin_f_macro.py" "$TARGET_HOME/genshin_f_macro.py"
fi
if [ -f "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" ]; then
    cp "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" "/etc/systemd/system/genshin-f-macro.service"
fi

echo "5. Restoring ArchBrain vault..."
if [ -d "$DOTFILES_DIR/ArchBrain" ]; then
    mkdir -p "$TARGET_HOME/ArchBrain"
    cp -a "$DOTFILES_DIR/ArchBrain/." "$TARGET_HOME/ArchBrain/"
fi

# Fix ownership across home directory
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.local" "$TARGET_HOME/Pictures" "$TARGET_HOME/ArchBrain" "$TARGET_HOME/genshin_f_macro.py" 2>/dev/null || true

echo "6. Reloading and enabling systemd user services..."
run_as_user systemctl --user daemon-reload 2>/dev/null || true
run_as_user systemctl --user enable --now caelestia-romaji.service 2>/dev/null || true

echo "7. Reloading and enabling systemd system services..."
systemctl daemon-reload
if [ -f "/etc/systemd/system/genshin-f-macro.service" ]; then
    systemctl enable --now genshin-f-macro.service || true
fi

echo "7.5. Configuring Getty tty1 Autologin & Hyprland Auto-Launch..."
systemctl disable sddm 2>/dev/null || true
systemctl disable gdm 2>/dev/null || true

mkdir -p /etc/systemd/system/getty@tty1.service.d
tee /etc/systemd/system/getty@tty1.service.d/autologin.conf > /dev/null << EOF
[Service]
ExecStart=
ExecStart=-/sbin/agetty -o "-p -f -- \u" --noclear --autologin $TARGET_USER %I \$TERM
EOF

systemctl daemon-reload
systemctl enable getty@tty1.service

# Auto-launch Hyprland upon tty1 autologin if not running
PROFILE_FILE="$TARGET_HOME/.bash_profile"
if [ ! -f "$PROFILE_FILE" ]; then
    PROFILE_FILE="$TARGET_HOME/.profile"
fi

if ! grep -q "exec Hyprland" "$PROFILE_FILE" 2>/dev/null; then
    echo -e "\nif [ -z \"\$DISPLAY\" ] && [ \"\$(tty)\" = \"/dev/tty1\" ]; then\n  exec Hyprland\nfi" >> "$PROFILE_FILE"
    chown "$TARGET_USER:$TARGET_USER" "$PROFILE_FILE"
fi

echo "=========================================================="
echo "✨ Restoration Complete!"
echo "Please reboot your system (sudo reboot) to launch into Caelestia Shell."
echo "=========================================================="
