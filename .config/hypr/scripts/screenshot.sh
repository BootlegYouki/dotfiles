#!/usr/bin/env bash
# Screenshot helper script - single instance safety

DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/Screenshot_$(date +'%Y-%m-%d_%H-%M-%S').png"

if [ "$1" = "region" ]; then
    if pidof -x slurp >/dev/null 2>&1; then
        exit 0
    fi
    REGION=$(slurp)
    if [ -z "$REGION" ]; then
        exit 0
    fi
    grim -g "$REGION" "$FILE"
else
    grim "$FILE"
fi

if [ -f "$FILE" ]; then
    wl-copy < "$FILE"
    notify-send -i image-x-generic "Screenshot Saved" "Saved to ~/Pictures/Screenshots/$(basename "$FILE")"
fi
