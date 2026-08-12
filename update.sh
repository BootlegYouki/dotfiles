#!/usr/bin/env bash
# update.sh — Pull latest dotfiles from GitHub and apply them to the system.

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "🔄 Dotfiles Updater"
echo "=========================================="
echo "Dotfiles directory: $DOTFILES_DIR"

# 0. Ensure proper Quickshell is installed (not outdated CachyOS noctalia-qs fork)
if pacman -Qi noctalia-qs &>/dev/null; then
    echo ""
    echo "0. Upgrading Quickshell (removing noctalia-qs, installing quickshell-git)..."
    sudo pacman -Rdd --noconfirm noctalia-qs
    paru -S --noconfirm --skipreview quickshell-git
    echo "  ✓ quickshell-git installed from AUR"
fi

# 1. Pull latest from GitHub
echo ""
echo "1. Pulling latest changes from GitHub..."
git -C "$DOTFILES_DIR" pull

# 2. Sync user config files
echo ""
echo "2. Syncing config files to ~/.config..."

CONFIGS=(
    ".config/quickshell/caelestia"
    ".config/caelestia"
    ".config/hypr"
    ".config/ghostty"
    ".config/fish"
    ".config/fuzzel"
    ".config/btop"
    ".config/cava"
    ".config/micro"
    ".config/uwsm"
    ".config/spicetify/Themes/caelestia"
    ".config/zed/themes"
)

for cfg in "${CONFIGS[@]}"; do
    src="$DOTFILES_DIR/$cfg"
    dst="$HOME/$cfg"
    if [ -d "$src" ]; then
        mkdir -p "$dst"
        cp -R "$src/." "$dst/"
        echo "  ✓ $cfg"
    elif [ -f "$src" ]; then
        mkdir -p "$(dirname "$dst")"
        cp "$src" "$dst"
        echo "  ✓ $cfg"
    fi
done

# 3. Sync system-wide Quickshell QML files
echo ""
echo "3. Syncing Quickshell QML to /etc/xdg/quickshell/caelestia..."
sudo mkdir -p /etc/xdg/quickshell/caelestia
if [ -d "$DOTFILES_DIR/.config/quickshell/caelestia" ]; then
    sudo cp -R "$DOTFILES_DIR/.config/quickshell/caelestia/." /etc/xdg/quickshell/caelestia/
    sudo find /etc/xdg/quickshell/caelestia/ -name "*.qml" -exec sed -i 's/\/\/@ pragma/\/\/ pragma/g' {} + 2>/dev/null || true
    echo "  ✓ /etc/xdg/quickshell/caelestia"
fi

# 4. Reload Caelestia shell if it's running
echo ""
echo "4. Reloading Caelestia shell..."
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "  ⚠ Running over SSH — cannot restart Wayland shell remotely."
elif qs -c caelestia kill 2>/dev/null; then
    sleep 1
    if command -v uwsm &>/dev/null; then
        uwsm app -- caelestia shell -d >/dev/null 2>&1 &
        echo "  ✓ Shell reloaded via uwsm"
    else
        caelestia shell -d >/dev/null 2>&1 &
        echo "  ✓ Shell reloaded"
    fi
else
    echo "  ℹ Shell was not running — starting it..."
    if command -v uwsm &>/dev/null; then
        uwsm app -- caelestia shell -d >/dev/null 2>&1 &
        echo "  ✓ Shell started via uwsm"
    else
        caelestia shell -d >/dev/null 2>&1 &
        echo "  ✓ Shell started"
    fi
fi

echo ""
echo "=========================================="
echo "✅ Update complete!"
echo "=========================================="
