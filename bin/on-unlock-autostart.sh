#!/bin/bash
# Script executed once upon session unlock after boot to start autostart apps (Steam, Discord, Spotify)
LOCK_FILE="/tmp/autostart_unlocked_${USER}"

if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"

# Unmask and trigger systemd XDG autostart apps target
systemctl --user unmask xdg-desktop-autostart.target 2>/dev/null
systemctl --user restart xdg-desktop-autostart.target 2>/dev/null
