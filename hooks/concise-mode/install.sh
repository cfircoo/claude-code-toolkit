#!/bin/bash
set -e

SETTINGS_FILE="$HOME/.claude/settings.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/settings-template.json"

# Create settings file if it doesn't exist
if [ ! -f "$SETTINGS_FILE" ]; then
    mkdir -p "$(dirname "$SETTINGS_FILE")"
    echo '{}' > "$SETTINGS_FILE"
fi

# Merge settings
jq -s '
  (.[0].hooks.UserPromptSubmit // []) + (.[1].hooks.UserPromptSubmit // []) | unique as $merged_hooks |
  .[0] * .[1] | .hooks.UserPromptSubmit = $merged_hooks
' "$SETTINGS_FILE" "$TEMPLATE_FILE" > /tmp/claude-settings-merged.json

mv /tmp/claude-settings-merged.json "$SETTINGS_FILE"

echo "Concise mode hook installed to $SETTINGS_FILE"
