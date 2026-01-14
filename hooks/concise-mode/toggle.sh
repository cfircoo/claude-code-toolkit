#!/bin/bash

# Toggle concise-mode on/off
# Usage: toggle.sh [on|off|status]

CLAUDE_DIR="$HOME/.claude"
STATE_FILE="$CLAUDE_DIR/.concise-mode"

case "$1" in
    on)
        echo "on" > "$STATE_FILE"
        echo "Concise mode: ON"
        ;;
    off)
        echo "off" > "$STATE_FILE"
        echo "Concise mode: OFF"
        ;;
    status|"")
        if [ -f "$STATE_FILE" ] && [ "$(cat "$STATE_FILE")" = "off" ]; then
            echo "Concise mode: OFF"
        else
            echo "Concise mode: ON"
        fi
        ;;
    *)
        echo "Usage: toggle.sh [on|off|status]"
        exit 1
        ;;
esac
