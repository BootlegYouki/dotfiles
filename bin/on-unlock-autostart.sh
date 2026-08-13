#!/bin/bash
# Script executed once upon session unlock after boot to launch deferred autostart apps
LOCK_FILE="/tmp/autostart_unlocked_${USER}"

if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"

# Launch Discord, Spotify, and Steam under UWSM after initial password unlock
if command -v discord >/dev/null 2>&1; then
    uwsm app -- discord --start-minimized &
elif [ -f "$HOME/.config/discord/app-1.0.153/Discord" ]; then
    uwsm app -- "$HOME/.config/discord/app-1.0.153/Discord" --start-minimized &
fi

if command -v spotify >/dev/null 2>&1; then
    uwsm app -- spotify --minimized &
fi

if [ -f "$HOME/bin/autostart-steam.sh" ]; then
    uwsm app -- "$HOME/bin/autostart-steam.sh" &
elif command -v steam >/dev/null 2>&1; then
    uwsm app -- steam -silent &
fi
