#!/usr/bin/env bash
set -eo pipefail

echo "=========================================================="
echo "🚀 Caelestia + Hyprland Complete Restoration Script (Paru)"
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

echo -e "\n[0/8] 🧹 Wiping existing configurations & cached files..."
rm -rf "$TARGET_HOME/.config" "$TARGET_HOME/.local/state/caelestia" "$TARGET_HOME/ArchBrain" "$TARGET_HOME/genshin_f_macro.py"
rm -rf /etc/xdg/quickshell/caelestia /etc/systemd/system/getty@tty1.service.d/autologin.conf
mkdir -p "$TARGET_HOME/.config" "$TARGET_HOME/.local/bin"

echo -e "\n[1/8] Refreshing package databases & updating mirrors..."
cachyos-rate-mirrors 2>/dev/null || true
pacman -Sy --noconfirm || true

echo -e "\n[1.1/8] Installing build tools & Paru..."
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

# Force remove any conflicting legacy packages from the local database before building
echo "Clearing potential conflicting packages..."
pacman -Rdd --noconfirm jack2 caelestia-shell quickshell 2>/dev/null || true

echo -e "\n[1.2/8] Installing official packages, fonts & CLI tools..."
pacman -S --noconfirm --needed \
    pipewire pipewire-alsa pipewire-pulse pipewire-jack wireplumber \
    hyprland uwsm ghostty waybar fish starship fastfetch gnome-keyring \
    flatpak polkit-kde-agent python-evdev python-pykakasi discord zed vlc cava \
    sunshine hyprsunset cliphist pamixer wl-clipboard playerctl grim slurp \
    hyprpicker brightnessctl python-pillow python-pip \
    ttf-jetbrains-mono-nerd noto-fonts noto-fonts-emoji noto-fonts-cjk \
    jq socat fd ripgrep fzf zoxide direnv eza

echo -e "\n[1.3/8] Installing Caelestia & AUR dependencies via Paru..."
# Use --useask and echo 1 to automatically select option 1 (caelestia-shell-git) if prompted
run_as_user bash -c "echo '1' | paru -S --noconfirm --needed --useask --skipreview \
    caelestia-shell-git \
    quickshell-git \
    caelestia-cli \
    ttf-material-symbols-variable-git \
    brave-bin \
    spotify" || true

echo -e "\n[2/8] Restoring user configurations..."
mkdir -p "$TARGET_HOME/.config"
if [ -d "$DOTFILES_DIR/.config" ]; then
    rm -rf "$TARGET_HOME/.config/starship.toml" 2>/dev/null || true
    cp -a "$DOTFILES_DIR/.config/." "$TARGET_HOME/.config/" 2>/dev/null || true
    rm -rf "$TARGET_HOME/.config/rclone" 2>/dev/null || true
fi

echo -e "\n[2.5/8] Deploying system-wide Quickshell QML files..."
mkdir -p /etc/xdg/quickshell/caelestia
if [ -d "$TARGET_HOME/.config/quickshell/caelestia" ]; then
    cp -a "$TARGET_HOME/.config/quickshell/caelestia/." /etc/xdg/quickshell/caelestia/
    find /etc/xdg/quickshell/caelestia/ -name "*.qml" -exec sed -i 's/\/\/@ pragma/\/\/ pragma/g' {} + 2>/dev/null || true
fi

if [ -f "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" ]; then
    mkdir -p "$TARGET_HOME/.config/quickshell"
    ln -sfn "$TARGET_HOME/.config/quickshell/caelestia/shell.qml" "$TARGET_HOME/.config/quickshell/shell.qml"
fi

echo -e "\n[3/8] Executing Caelestia CLI component initialization..."
if command -v caelestia &>/dev/null; then
    run_as_user caelestia install --noconfirm || true
fi

echo -e "\n[4/8] Restoring local binaries & Caelestia state..."
if [ -d "$DOTFILES_DIR/.local/bin" ]; then
    cp -a "$DOTFILES_DIR/.local/bin/." "$TARGET_HOME/.local/bin/"
    chmod +x "$TARGET_HOME/.local/bin/"* 2>/dev/null || true
fi

if [ -d "$DOTFILES_DIR/.local/state/caelestia" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia"
    cp -a "$DOTFILES_DIR/.local/state/caelestia/." "$TARGET_HOME/.local/state/caelestia/"
fi

echo -e "\n[5/8] Restoring Wallpapers & symlinks..."
if [ ! -d "$TARGET_HOME/Pictures/Wallpapers" ]; then
    mkdir -p "$TARGET_HOME/Pictures"
    run_as_user git clone https://github.com/laustoic/laustoic-wallpaper-repo.git "$TARGET_HOME/Pictures/Wallpapers" || true
fi

if [ -f "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" ]; then
    mkdir -p "$TARGET_HOME/.local/state/caelestia/wallpaper"
    ln -sfn "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" "$TARGET_HOME/.local/state/caelestia/wallpaper/current"
    echo "$TARGET_HOME/Pictures/Wallpapers/wallhaven-zywgxy.jpg" > "$TARGET_HOME/.local/state/caelestia/wallpaper/path.txt"
fi

echo -e "\n[6/8] Restoring scripts & extra vaults..."
if [ -f "$DOTFILES_DIR/scripts/genshin_f_macro.py" ]; then
    cp "$DOTFILES_DIR/scripts/genshin_f_macro.py" "$TARGET_HOME/genshin_f_macro.py"
fi
if [ -f "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" ]; then
    cp "$DOTFILES_DIR/systemd-system/genshin-f-macro.service" "/etc/systemd/system/genshin-f-macro.service"
fi

if [ -d "$DOTFILES_DIR/ArchBrain" ]; then
    mkdir -p "$TARGET_HOME/ArchBrain"
    cp -a "$DOTFILES_DIR/ArchBrain/." "$TARGET_HOME/ArchBrain/"
fi

# Fix ownership across home directory
chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.config" "$TARGET_HOME/.local" "$TARGET_HOME/Pictures" "$TARGET_HOME/ArchBrain" "$TARGET_HOME/genshin_f_macro.py" 2>/dev/null || true

echo -e "\n[7/8] Configuring system locale & services..."
tee /etc/locale.conf > /dev/null << 'EOF'
LANG=en_US.UTF-8
LC_TIME=en_US.UTF-8
EOF

run_as_user systemctl --user daemon-reload 2>/dev/null || true
run_as_user systemctl --user enable --now caelestia-romaji.service 2>/dev/null || true

systemctl daemon-reload
if [ -f "/etc/systemd/system/genshin-f-macro.service" ]; then
    systemctl enable --now genshin-f-macro.service || true
fi

echo -e "\n[8/8] Configuring TTY1 Autologin & Boot Pipeline..."
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

PROFILE_FILE="$TARGET_HOME/.bash_profile"
if [ ! -f "$PROFILE_FILE" ]; then
    PROFILE_FILE="$TARGET_HOME/.profile"
fi

if ! grep -q "exec Hyprland" "$PROFILE_FILE" 2>/dev/null; then
    echo -e "\nif [ -z \"\$DISPLAY\" ] && [ \"\$(tty)\" = \"/dev/tty1\" ]; then\n  exec Hyprland\nfi" >> "$PROFILE_FILE"
    chown "$TARGET_USER:$TARGET_USER" "$PROFILE_FILE"
fi

echo "=========================================================="
echo "✨ Restoration Complete! Reboot now: sudo reboot"
echo "=========================================================="
