#!/usr/bin/env bash
# ==============================================================================
#  Caelestia / CachyOS Debloat & Launcher Cleaning Script
#  Removes redundant packages and cleans unwanted launcher menu entries
# ==============================================================================

set -eo pipefail

TARGET_USER="${SUDO_USER:-$USER}"
TARGET_HOME=$(getent passwd "$TARGET_USER" | cut -d: -f6)

echo "=========================================================="
echo "🧹 Debloating System & Cleaning Caelestia Menu"
echo "Target User: $TARGET_USER ($TARGET_HOME)"
echo "=========================================================="
echo ""

# 1. Uninstallation of redundant packages
BLOAT_PACKAGES=(
    alacritty
    foot
    thunar
    firefox
    brave-bin
    pwvucontrol
    shelly
    cachyos-hello
    cachyos-packageinstaller
    cachyos-kernel-manager
    scx-manager
    btrfs-assistant
    darkly-bin
    meld
)

echo "▶ [1/4] Removing bloatware packages..."
for pkg in "${BLOAT_PACKAGES[@]}"; do
    if pacman -Qi "$pkg" &>/dev/null; then
        echo "  - Uninstalling $pkg..."
        sudo pacman -Rdd --noconfirm "$pkg" 2>/dev/null || true
    fi
done

# 2. Hide library desktop entries from launcher (without breaking underlying libraries)
echo "▶ [2/4] Hiding library and diagnostic shortcuts from launcher..."
mkdir -p "$TARGET_HOME/.local/share/applications"

HIDDEN_DESKTOP_FILES=(
    Alacritty.desktop
    foot.desktop
    foot-server.desktop
    footclient.desktop
    thunar.desktop
    thunar-settings.desktop
    thunar-bulk-rename.desktop
    xfce4-about.desktop
    firefox.desktop
    com.saivert.pwvucontrol.desktop
    cachyos-hello.desktop
    cachyos-pi.desktop
    org.cachyos.KernelManager.desktop
    org.cachyos.scx-manager.desktop
    btrfs-assistant.desktop
    org.gnome.Meld.desktop
    cmake-gui.desktop
    qv4l2.desktop
    qvidcap.desktop
    lstopo.desktop
    xgps.desktop
    xgpsspeed.desktop
    uuctl.desktop
    avahi-discover.desktop
    bssh.desktop
    bvnc.desktop
    cartes-geo-handler.desktop
    google-maps-geo-handler.desktop
    openstreetmap-geo-handler.desktop
    wheelmap-geo-handler.desktop
    darklystyleconfig.desktop
    kcm_darklydecoration.desktop
    org.freedesktop.Xwayland.desktop
    gcr-viewer.desktop
    gcr-prompter.desktop
    ktelnetservice6.desktop
    vim.desktop
)

for dfile in "${HIDDEN_DESKTOP_FILES[@]}"; do
    target_file="$TARGET_HOME/.local/share/applications/$dfile"
    cat << EOF > "$target_file"
[Desktop Entry]
Type=Application
Name=$dfile
NoDisplay=true
EOF
done

chown -R "$TARGET_USER:$TARGET_USER" "$TARGET_HOME/.local/share/applications" 2>/dev/null || true
update-desktop-database "$TARGET_HOME/.local/share/applications" 2>/dev/null || true

# 3. Update Caelestia shell.json hiddenApps filter
echo "▶ [3/4] Updating Caelestia hiddenApps filter..."
python3 -c "
import json, os

config_path = os.path.expanduser('$TARGET_HOME/.config/caelestia/shell.json')
if os.path.exists(config_path):
    with open(config_path) as f:
        data = json.load(f)

    hidden = data.setdefault('launcher', {}).setdefault('hiddenApps', [])
    patterns = [
        'brave-browser',
        'org\\\\.gnome\\\\.(?!Nautilus).*',
        'avahi-discover',
        'bssh',
        'bvnc',
        'lstopo',
        'nm-connection-editor',
        'qv4l2',
        'qvidcap',
        'xgps.*',
        'uuctl',
        'xfce4-about',
        'Alacritty',
        'alacritty',
        'foot.*',
        'thunar.*',
        'firefox',
        'pwvucontrol',
        'com\\\\.saivert\\\\.pwvucontrol',
        'cachyos-.*',
        'org\\\\.cachyos.*',
        'meld',
        'org\\\\.gnome\\\\.Meld',
        'cmake-gui',
        '.*-geo-handler',
        'darkly.*',
        'kcm_darkly.*',
        'vim',
        'org\\\\.freedesktop\\\\.Xwayland',
        'gcr-viewer',
        'gcr-prompter',
        'ktelnetservice.*',
        'org\\\\.kde\\\\.(kiod|knewstuff|ksecretd|kwalletd).*',
        'polkit-.*-authentication-agent.*',
        'org\\\\.quickshell',
        'xdg-desktop-portal-.*',
        'org\\\\.gnupg\\\\.pinentry.*',
        'com\\\\.shellyorg\\\\.shelly-notifications'
    ]

    for p in patterns:
        if p not in hidden:
            hidden.append(p)

    with open(config_path, 'w') as f:
        json.dump(data, f, indent=4)
" 2>/dev/null || true

# 4. Clear Caelestia app database cache and reload shell
echo "▶ [4/4] Refreshing Caelestia menu..."
rm -f "$TARGET_HOME/.local/state/caelestia/apps.sqlite" 2>/dev/null || true

if command -v qs &>/dev/null; then
    sudo -u "$TARGET_USER" WAYLAND_DISPLAY="\${WAYLAND_DISPLAY:-wayland-1}" \
        XDG_RUNTIME_DIR="/run/user/\$(id -u $TARGET_USER)" \
        HYPRLAND_INSTANCE_SIGNATURE="\$(ls -t /run/user/\$(id -u $TARGET_USER)/hypr 2>/dev/null | head -n1)" \
        caelestia shell >/dev/null 2>&1 || true
fi

echo ""
echo "=========================================================="
echo "✅ Menu cleaned! Redundant apps removed and hidden."
echo "=========================================================="
