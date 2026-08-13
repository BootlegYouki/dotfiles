#!/bin/bash
# Dynamic XDG Autostart script - executes all enabled ~/.config/autostart/*.desktop entries upon initial session unlock
LOCK_FILE="/tmp/autostart_unlocked_${USER}"

if [ -f "$LOCK_FILE" ]; then
    exit 0
fi
touch "$LOCK_FILE"

AUTOSTART_DIR="$HOME/.config/autostart"

if [ -d "$AUTOSTART_DIR" ]; then
    for desktop_file in "$AUTOSTART_DIR"/*.desktop; do
        [ -f "$desktop_file" ] || continue

        # Parse Exec= command from [Desktop Entry] section
        exec_cmd=$(awk -F'=' '/^\[Desktop Entry\]/{flag=1; next} /^\[/{flag=0} flag && /^Exec=/{print $2; exit}' "$desktop_file")

        [ -z "$exec_cmd" ] && continue

        # Clean XDG specifiers (%u, %U, %f, %F, %i, %c, %k)
        cleaned_cmd=$(echo "$exec_cmd" | sed -E 's/%[uUfFiIcK]//g')

        # Ensure UWSM systemd scope wrapping
        if [[ "$cleaned_cmd" != uwsm* ]]; then
            cleaned_cmd="uwsm app -- $cleaned_cmd"
        fi

        # Launch app asynchronously
        eval "$cleaned_cmd &"
    done
fi
