#!/bin/bash

# Delegate-First Hook Installer
# Reminds Claude to check for subagents and skills before starting tasks

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
DIM='\033[2m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TEMPLATE_FILE="$SCRIPT_DIR/settings-template.json"

echo -e "${BLUE}━━━ Delegate-First Hook Installer ━━━${NC}"
echo

# Check for template
if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}✗${NC} Template not found at: $TEMPLATE_FILE"
    exit 1
fi

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${RED}✗${NC} jq is required but not found"
    echo -e "${DIM}   Install jq first: apt install jq / brew install jq${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} jq found"

# Create settings.json if it doesn't exist
mkdir -p "$CLAUDE_DIR"
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    echo '{}' > "$CLAUDE_DIR/settings.json"
fi

# Backup existing settings
cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak" 2>/dev/null

# Merge settings
echo -e "${BLUE}→ Installing hook...${NC}"
temp_file=$(mktemp)

jq -s '
    .[0] as $existing | .[1] as $template |
    (($existing.hooks.UserPromptSubmit // []) + ($template.hooks.UserPromptSubmit // [])) | unique as $merged_hooks |
    $existing * $template
    | .hooks.UserPromptSubmit = $merged_hooks
' "$CLAUDE_DIR/settings.json" "$TEMPLATE_FILE" > "$temp_file" 2>/dev/null

if [ $? -eq 0 ] && [ -s "$temp_file" ]; then
    mv "$temp_file" "$CLAUDE_DIR/settings.json"
    echo -e "${GREEN}✓${NC} Installed delegate-first hook"
else
    rm -f "$temp_file"
    echo -e "${RED}✗${NC} Could not install hook"
    exit 1
fi

echo
echo -e "${BLUE}Behavior:${NC}"
echo -e "  • Adds a reminder to check for subagents/skills before tasks"
echo -e "  • Keeps context clean by delegating to specialized agents"
echo
echo -e "${BLUE}Available subagents:${NC}"
echo -e "  • Explore - codebase exploration"
echo -e "  • Plan - design and architecture decisions"
echo -e "  • git-ops - commits, pushes, PRs"
echo -e "  • pytest-writer - writing tests"
echo -e "  • perplexity-research - web research"
echo
echo -e "${YELLOW}⚠ IMPORTANT: Restart Claude Code for hook to take effect${NC}"
