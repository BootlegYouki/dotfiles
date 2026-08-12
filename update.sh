#!/usr/bin/env bash
# update.sh — Pull latest dotfiles from GitHub and apply them to the system.
# Run as your normal user (no sudo needed at the start).

set -e

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=========================================="
echo "🔄 Dotfiles Updater"
echo "=========================================="
echo "Dotfiles directory: $DOTFILES_DIR"

# 0. Ensure proper Quickshell is installed (not the outdated CachyOS noctalia-qs fork)
if pacman -Qi noctalia-qs &>/dev/null; then
    echo ""
    echo "0. Upgrading Quickshell (removing noctalia-qs, building quickshell-git from AUR)..."
    sudo pacman -Rdd --noconfirm noctalia-qs
    rm -rf /tmp/qs-aur-build
    git clone https://aur.archlinux.org/quickshell-git.git /tmp/qs-aur-build
    (cd /tmp/qs-aur-build && makepkg -si --noconfirm)
    rm -rf /tmp/qs-aur-build
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
echo "3. Syncing Quickshell QML to /etc/xdg/quickshell/caelestia (requires sudo)..."
sudo cp -R "$DOTFILES_DIR/.config/quickshell/caelestia/." /etc/xdg/quickshell/caelestia/
echo "  ✓ /etc/xdg/quickshell/caelestia"

# 4. Reload Caelestia shell if it's running
echo ""
echo "4. Reloading Caelestia shell..."
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "  ⚠ Running over SSH — cannot restart Wayland shell remotely."
    echo "  → Run this on your machine: caelestia shell -d"
elif qs -c caelestia kill 2>/dev/null; then
    sleep 1
    # Launch via uwsm so it inherits the correct Wayland environment
    if command -v uwsm &>/dev/null; then
        uwsm app -- caelestia shell -d && echo "  ✓ Shell reloaded via uwsm" || {
            echo "  ⚠ uwsm launch failed — run manually: caelestia shell -d"
        }
    else
        caelestia shell -d && echo "  ✓ Shell reloaded" || {
            echo "  ⚠ Shell reload failed — run manually: caelestia shell -d"
        }
    fi
else
    echo "  ℹ Shell was not running — starting it..."
    if command -v uwsm &>/dev/null; then
        uwsm app -- caelestia shell -d && echo "  ✓ Shell started via uwsm" || echo "  ⚠ Could not start shell — run manually: caelestia shell -d"
    else
        caelestia shell -d && echo "  ✓ Shell started" || echo "  ⚠ Could not start shell — run manually: caelestia shell -d"
    fi
fi

echo ""
echo "=========================================="
echo "✅ Update complete!"
echo "=========================================="
