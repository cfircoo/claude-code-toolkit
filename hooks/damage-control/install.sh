#!/bin/bash

# Damage Control Hook Installer
# Installs security hooks that block dangerous commands and protect sensitive files

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
DIM='\033[2m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLKIT_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
CLAUDE_DIR="$HOME/.claude"
HOOKS_TARGET="$CLAUDE_DIR/hooks/damage-control"
SKILL_SOURCE="$TOOLKIT_DIR/skills/damage-control"
SCRIPTS_SOURCE="$SKILL_SOURCE/scripts"
TEMPLATE_FILE="$SCRIPT_DIR/settings-template.json"

# Parse arguments
SKIP_UV_INSTALL=false
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --no-uv) SKIP_UV_INSTALL=true; shift ;;
        -y|--yes) AUTO_YES=true; shift ;;
        *) shift ;;
    esac
done

echo -e "${BLUE}━━━ Damage Control Hook Installer ━━━${NC}"
echo

# Check for required files
if [ ! -d "$SCRIPTS_SOURCE" ]; then
    echo -e "${RED}✗${NC} Scripts not found at: $SCRIPTS_SOURCE"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo -e "${RED}✗${NC} Template not found at: $TEMPLATE_FILE"
    exit 1
fi

# Check for UV runtime
if ! command -v uv &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} UV runtime not found (required for damage-control hooks)"
    if [ "$SKIP_UV_INSTALL" = true ]; then
        echo -e "${YELLOW}⚠${NC} Skipping UV installation (--no-uv flag)"
        exit 1
    elif [ "$AUTO_YES" = true ]; then
        response="y"
    else
        echo -e "${BLUE}Install UV now? (y/n)${NC}"
        read -r response
    fi
    if [[ "$response" =~ ^[Yy]$ ]]; then
        echo -e "${BLUE}→ Installing UV...${NC}"
        curl -LsSf https://astral.sh/uv/install.sh | sh
        export PATH="$HOME/.local/bin:$PATH"
        if command -v uv &> /dev/null; then
            echo -e "${GREEN}✓${NC} UV installed"
        else
            echo -e "${RED}✗${NC} UV installation failed"
            echo -e "${DIM}   Install manually: curl -LsSf https://astral.sh/uv/install.sh | sh${NC}"
            exit 1
        fi
    else
        echo -e "${YELLOW}⚠${NC} Cannot install without UV"
        exit 1
    fi
else
    echo -e "${GREEN}✓${NC} UV runtime found"
fi

# Create directories
mkdir -p "$HOOKS_TARGET"
mkdir -p "$CLAUDE_DIR/skills"

# Copy Python hook scripts
echo -e "${BLUE}→ Installing hook scripts...${NC}"
cp "$SCRIPTS_SOURCE"/*.py "$HOOKS_TARGET/" 2>/dev/null || true
cp "$SCRIPTS_SOURCE"/patterns.yaml "$HOOKS_TARGET/" 2>/dev/null || true
chmod +x "$HOOKS_TARGET"/*.py 2>/dev/null || true

script_count=$(find "$HOOKS_TARGET" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
echo -e "${GREEN}✓${NC} Installed $script_count hook scripts"

# Copy skill folder
echo -e "${BLUE}→ Installing skill...${NC}"
if [ -d "$SKILL_SOURCE" ]; then
    rm -rf "$CLAUDE_DIR/skills/damage-control" 2>/dev/null || true
    cp -r "$SKILL_SOURCE" "$CLAUDE_DIR/skills/"
    echo -e "${GREEN}✓${NC} Installed damage-control skill"
else
    echo -e "${YELLOW}⚠${NC} Skill folder not found"
fi

# Update settings.json
echo -e "${BLUE}→ Updating settings...${NC}"
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} jq not found - settings.json not updated"
    echo -e "${DIM}   Add damage-control hooks to settings.json manually${NC}"
else
    SETTINGS_FILE="$CLAUDE_DIR/settings.json"

    # Create settings.json if it doesn't exist
    if [ ! -f "$SETTINGS_FILE" ]; then
        echo '{}' > "$SETTINGS_FILE"
    fi

    # Backup existing settings
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak" 2>/dev/null

    if [ -f "$TEMPLATE_FILE" ]; then
        temp_file=$(mktemp)

        jq -s '
            .[0] as $existing | .[1] as $template |
            (($existing.hooks.PreToolUse // []) + ($template.hooks.PreToolUse // [])) | unique_by(.matcher) as $merged_hooks |
            (($existing.permissions.deny // []) + ($template.permissions.deny // [])) | unique as $merged_deny |
            (($existing.permissions.ask // []) + ($template.permissions.ask // [])) | unique as $merged_ask |
            $existing * $template
            | .hooks.PreToolUse = $merged_hooks
            | .permissions = {deny: $merged_deny, ask: $merged_ask}
        ' "$SETTINGS_FILE" "$TEMPLATE_FILE" > "$temp_file" 2>/dev/null

        if [ $? -eq 0 ] && [ -s "$temp_file" ]; then
            mv "$temp_file" "$SETTINGS_FILE"
            echo -e "${GREEN}✓${NC} Updated settings.json with hooks"
            echo -e "${GREEN}✓${NC} Added permissions (deny/ask rules)"
        else
            rm -f "$temp_file"
            echo -e "${YELLOW}⚠${NC} Could not update settings.json"
        fi
    fi
fi

# Verify installation
echo
echo -e "${BLUE}→ Verifying installation...${NC}"
[ -f "$HOOKS_TARGET/bash-tool-damage-control.py" ] && echo -e "${GREEN}✓${NC} bash-tool-damage-control.py"
[ -f "$HOOKS_TARGET/edit-tool-damage-control.py" ] && echo -e "${GREEN}✓${NC} edit-tool-damage-control.py"
[ -f "$HOOKS_TARGET/write-tool-damage-control.py" ] && echo -e "${GREEN}✓${NC} write-tool-damage-control.py"
[ -f "$HOOKS_TARGET/read-tool-damage-control.py" ] && echo -e "${GREEN}✓${NC} read-tool-damage-control.py"
[ -f "$HOOKS_TARGET/patterns.yaml" ] && echo -e "${GREEN}✓${NC} patterns.yaml"
[ -d "$CLAUDE_DIR/skills/damage-control" ] && echo -e "${GREEN}✓${NC} skill folder"

echo
echo -e "${BLUE}Damage Control protects against:${NC}"
echo -e "  • Destructive commands (rm -rf, git reset --hard, etc.)"
echo -e "  • Sensitive file access (.env, ~/.ssh/, credentials)"
echo -e "  • Accidental deletions of important files"
echo
echo -e "${YELLOW}⚠ IMPORTANT: Restart Claude Code for hooks to take effect${NC}"
