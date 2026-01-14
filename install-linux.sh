#!/bin/bash

# Claude Code Toolkit Installer for Linux
# Installs skills, agents, commands, hooks, and statusline to ~/.claude/

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
DIM='\033[2m'
NC='\033[0m' # No Color

# Default options
AUTO_YES=false
SKIP_UPDATE_CHECK=false
SKIP_UV_INSTALL=false
INSTALL_MODE=""  # all, select, skip

# Parse command-line arguments
show_help() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -y, --yes           Auto-yes to all prompts (non-interactive)"
    echo "  --no-update         Skip Claude Code update check"
    echo "  --no-uv             Skip UV installation for damage-control"
    echo "  --all               Install all components (same as -y)"
    echo "  --select            Interactive selection mode"
    echo "  --skip              Skip component installation"
    echo "  -h, --help          Show this help message"
    echo
    echo "Examples:"
    echo "  $0 -y               Install everything non-interactively"
    echo "  $0 --all --no-uv    Install all but skip UV"
    echo "  $0 --select         Interactive component selection"
    exit 0
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes|--all)
            AUTO_YES=true
            INSTALL_MODE="1"
            shift
            ;;
        --no-update)
            SKIP_UPDATE_CHECK=true
            shift
            ;;
        --no-uv)
            SKIP_UV_INSTALL=true
            shift
            ;;
        --select)
            INSTALL_MODE="2"
            shift
            ;;
        --skip)
            INSTALL_MODE="3"
            shift
            ;;
        -h|--help)
            show_help
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            ;;
    esac
done

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Claude Code Toolkit - Linux Installer       ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo

# Detect package manager
PKG_MANAGER=""
INSTALL_CMD=""

if command -v apt-get &> /dev/null; then
    PKG_MANAGER="apt-get"
    INSTALL_CMD="sudo apt-get install -y"
elif command -v dnf &> /dev/null; then
    PKG_MANAGER="dnf"
    INSTALL_CMD="sudo dnf install -y"
elif command -v yum &> /dev/null; then
    PKG_MANAGER="yum"
    INSTALL_CMD="sudo yum install -y"
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman"
    INSTALL_CMD="sudo pacman -S --noconfirm"
else
    echo -e "${YELLOW}⚠${NC} No supported package manager detected (apt, dnf, yum, pacman)"
    PKG_MANAGER="none"
fi

# Check for required tools
echo -e "${BLUE}→ Checking dependencies...${NC}"

MISSING_DEPS=()

# Check for jq
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} jq not found (required for statusline)"
    MISSING_DEPS+=("jq")
else
    echo -e "${GREEN}✓${NC} jq installed"
fi

# Check for git
if ! command -v git &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} git not found (recommended for git workflow features)"
    MISSING_DEPS+=("git")
else
    echo -e "${GREEN}✓${NC} git installed"
fi

# Check for tac (part of coreutils, usually pre-installed)
if ! command -v tac &> /dev/null; then
    echo -e "${YELLOW}⚠${NC} tac not found (required for statusline)"
    # tac is part of coreutils
    if [ "$PKG_MANAGER" = "pacman" ]; then
        MISSING_DEPS+=("coreutils")
    else
        # For apt/dnf/yum, coreutils is usually pre-installed
        echo -e "${RED}✗${NC} coreutils might be missing (unusual)"
    fi
else
    echo -e "${GREEN}✓${NC} tac available (coreutils installed)"
fi

# Check for Claude Code CLI
echo
echo -e "${BLUE}→ Checking Claude Code CLI...${NC}"
if command -v claude &> /dev/null; then
    CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1)
    echo -e "${GREEN}✓${NC} Claude Code installed: ${DIM}$CLAUDE_VERSION${NC}"

    # Check for updates if npm is available
    if command -v npm &> /dev/null; then
        if [ "$SKIP_UPDATE_CHECK" = true ]; then
            response="n"
        elif [ "$AUTO_YES" = true ]; then
            response="y"
        else
            echo -e "${BLUE}Check for Claude Code updates? (y/n)${NC}"
            read -r response
        fi
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}→ Checking for updates...${NC}"
            LATEST=$(npm view @anthropic-ai/claude-code version 2>/dev/null || echo "unknown")
            CURRENT=$(echo "$CLAUDE_VERSION" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            if [ "$LATEST" != "unknown" ] && [ "$LATEST" != "$CURRENT" ]; then
                echo -e "${YELLOW}⚠${NC} Update available: $CURRENT → $LATEST"
                if [ "$AUTO_YES" = true ]; then
                    response="y"
                else
                    echo -e "${BLUE}Update Claude Code now? (y/n)${NC}"
                    read -r response
                fi
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    echo -e "${BLUE}→ Updating Claude Code...${NC}"
                    npm install -g @anthropic-ai/claude-code@latest
                    echo -e "${GREEN}✓${NC} Claude Code updated to $LATEST"
                fi
            else
                echo -e "${GREEN}✓${NC} Claude Code is up to date"
            fi
        fi
    fi
else
    echo -e "${YELLOW}⚠${NC} Claude Code CLI not found"

    # Check if npm is available for installation
    if command -v npm &> /dev/null; then
        if [ "$AUTO_YES" = true ]; then
            response="y"
        else
            echo -e "${BLUE}Install Claude Code CLI via npm? (y/n)${NC}"
            read -r response
        fi
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}→ Installing Claude Code...${NC}"
            npm install -g @anthropic-ai/claude-code@latest
            if command -v claude &> /dev/null; then
                CLAUDE_VERSION=$(claude --version 2>/dev/null | head -1)
                echo -e "${GREEN}✓${NC} Claude Code installed: $CLAUDE_VERSION"
            else
                echo -e "${RED}✗${NC} Installation failed. Try manually: npm install -g @anthropic-ai/claude-code"
            fi
        fi
    else
        echo -e "${DIM}   Install npm first, then run: npm install -g @anthropic-ai/claude-code${NC}"
    fi
fi

echo

# Offer to install missing dependencies
if [ ${#MISSING_DEPS[@]} -gt 0 ]; then
    echo
    echo -e "${YELLOW}Missing dependencies: ${MISSING_DEPS[*]}${NC}"

    if [ "$PKG_MANAGER" != "none" ]; then
        echo -e "${BLUE}Package manager detected: $PKG_MANAGER${NC}"
        if [ "$AUTO_YES" = true ]; then
            response="y"
        else
            echo -e "${BLUE}Install missing dependencies? (y/n)${NC}"
            read -r response
        fi
        if [[ "$response" =~ ^[Yy]$ ]]; then
            for dep in "${MISSING_DEPS[@]}"; do
                echo -e "${BLUE}→ Installing $dep...${NC}"
                $INSTALL_CMD "$dep"
            done
            echo -e "${GREEN}✓${NC} Dependencies installed"
        else
            echo -e "${YELLOW}⚠${NC} Skipping dependency installation. Some features may not work."
        fi
    else
        echo -e "${YELLOW}⚠${NC} Please install manually: ${MISSING_DEPS[*]}"
        echo
        if [ "$AUTO_YES" = true ]; then
            response="y"
        else
            echo -e "${BLUE}Continue without installing dependencies? (y/n)${NC}"
            read -r response
        fi
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo "Installation cancelled."
            exit 1
        fi
    fi
fi

echo
echo -e "${BLUE}→ Creating directories...${NC}"

# Create directories
mkdir -p "$CLAUDE_DIR"/{skills,agents,commands,hooks}

echo -e "${GREEN}✓${NC} Directories created"

echo
echo -e "${BLUE}→ Installation options...${NC}"
if [ -n "$INSTALL_MODE" ]; then
    install_choice="$INSTALL_MODE"
    case $install_choice in
        1) echo -e "Mode: ${GREEN}Install all${NC} (from command line)" ;;
        2) echo -e "Mode: ${GREEN}Select by folder${NC} (from command line)" ;;
        3) echo -e "Mode: ${GREEN}Skip installation${NC} (from command line)" ;;
    esac
else
    echo -e "How would you like to install components?"
    echo -e "  ${GREEN}1${NC}) Install all (recommended)"
    echo -e "  ${GREEN}2${NC}) Select by folder"
    echo -e "  ${GREEN}3${NC}) Skip installation"
    echo -n "Choice [1-3]: "
    read -r install_choice
fi

if [[ "$install_choice" == "3" ]]; then
    echo -e "${YELLOW}⚠${NC} Skipping component installation"
elif [[ "$install_choice" =~ ^[12]$ ]]; then

    # Function to copy skills
    copy_skills() {
        local mode="$1"
        if [ ! -d "$SCRIPT_DIR/skills" ]; then
            echo -e "${YELLOW}⚠${NC} No skills directory found"
            return
        fi

        if [ "$mode" == "all" ]; then
            local skill_dirs=($(find "$SCRIPT_DIR/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null))
            for skill in "${skill_dirs[@]}"; do
                # Delete existing skill folder if it exists
                if [ -d "$CLAUDE_DIR/skills/$skill" ]; then
                    rm -rf "$CLAUDE_DIR/skills/$skill"
                fi
                cp -r "$SCRIPT_DIR/skills/$skill" "$CLAUDE_DIR/skills/"
            done
            SKILL_COUNT=${#skill_dirs[@]}
            echo -e "${GREEN}✓${NC} Installed $SKILL_COUNT skills"
        else
            local skill_dirs=($(find "$SCRIPT_DIR/skills" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null | sort))
            if [ ${#skill_dirs[@]} -eq 0 ]; then
                echo -e "${YELLOW}⚠${NC} No skills found"
                return
            fi
            echo -e "${DIM}Found ${#skill_dirs[@]} skills: ${skill_dirs[*]}${NC}"
            local copied=0
            for skill in "${skill_dirs[@]}"; do
                echo -n "  Copy $skill? (y/n): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    # Delete existing skill folder if it exists
                    if [ -d "$CLAUDE_DIR/skills/$skill" ]; then
                        rm -rf "$CLAUDE_DIR/skills/$skill"
                    fi
                    cp -r "$SCRIPT_DIR/skills/$skill" "$CLAUDE_DIR/skills/"
                    echo -e "  ${GREEN}✓${NC} $skill"
                    copied=$((copied + 1))
                fi
            done
            echo -e "${GREEN}✓${NC} Installed $copied of ${#skill_dirs[@]} skills"
        fi
    }

    # Function to copy agents
    copy_agents() {
        local mode="$1"
        if [ ! -d "$SCRIPT_DIR/agents" ]; then
            echo -e "${YELLOW}⚠${NC} No agents directory found"
            return
        fi

        if [ "$mode" == "all" ]; then
            cp "$SCRIPT_DIR/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
            AGENT_COUNT=$(find "$SCRIPT_DIR/agents" -name "*.md" -not -name "README.md" 2>/dev/null | wc -l | tr -d ' ')
            echo -e "${GREEN}✓${NC} Installed $AGENT_COUNT agents"
        else
            local agents=($(find "$SCRIPT_DIR/agents" -name "*.md" -not -name "README.md" -exec basename {} \; 2>/dev/null | sort))
            if [ ${#agents[@]} -eq 0 ]; then
                echo -e "${YELLOW}⚠${NC} No agents found"
                return
            fi
            echo -e "${DIM}Found ${#agents[@]} agents: ${agents[*]%.md}${NC}"
            local copied=0
            for agent in "${agents[@]}"; do
                echo -n "  Copy ${agent%.md}? (y/n): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    cp "$SCRIPT_DIR/agents/$agent" "$CLAUDE_DIR/agents/$agent"
                    echo -e "  ${GREEN}✓${NC} ${agent%.md}"
                    copied=$((copied + 1))
                fi
            done
            echo -e "${GREEN}✓${NC} Installed $copied of ${#agents[@]} agents"
        fi
    }

    # Function to copy commands
    copy_commands() {
        local mode="$1"
        if [ ! -d "$SCRIPT_DIR/commands" ]; then
            echo -e "${YELLOW}⚠${NC} No commands directory found"
            return
        fi

        if [ "$mode" == "all" ]; then
            cp "$SCRIPT_DIR/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
            COMMAND_COUNT=$(find "$SCRIPT_DIR/commands" -name "*.md" -not -name "README.md" 2>/dev/null | wc -l | tr -d ' ')
            echo -e "${GREEN}✓${NC} Installed $COMMAND_COUNT commands"
        else
            local commands=($(find "$SCRIPT_DIR/commands" -name "*.md" -not -name "README.md" -exec basename {} \; 2>/dev/null | sort))
            if [ ${#commands[@]} -eq 0 ]; then
                echo -e "${YELLOW}⚠${NC} No commands found"
                return
            fi
            echo -e "${DIM}Found ${#commands[@]} commands: ${commands[*]%.md}${NC}"
            local copied=0
            for cmd in "${commands[@]}"; do
                echo -n "  Copy ${cmd%.md}? (y/n): "
                read -r response
                if [[ "$response" =~ ^[Yy]$ ]]; then
                    cp "$SCRIPT_DIR/commands/$cmd" "$CLAUDE_DIR/commands/$cmd"
                    echo -e "  ${GREEN}✓${NC} ${cmd%.md}"
                    copied=$((copied + 1))
                fi
            done
            echo -e "${GREEN}✓${NC} Installed $copied of ${#commands[@]} commands"
        fi
    }

    # Function to copy hooks
    copy_hooks() {
        local mode="$1"
        local copied=0
        local total=0

        # Copy hooks.json
        if [ -f "$SCRIPT_DIR/hooks.json" ]; then
            total=$((total + 1))
            local should_copy="n"
            if [ "$mode" == "all" ]; then
                should_copy="y"
            else
                echo -n "  Copy hooks.json? (y/n): "
                read -r should_copy
            fi

            if [[ "$should_copy" =~ ^[Yy]$ ]]; then
                if [ -f "$CLAUDE_DIR/hooks.json" ]; then
                    cp "$CLAUDE_DIR/hooks.json" "$CLAUDE_DIR/hooks.json.bak" 2>/dev/null
                    echo -e "  ${BLUE}ℹ${NC} Backed up existing hooks.json"
                fi
                cp "$SCRIPT_DIR/hooks.json" "$CLAUDE_DIR/hooks.json"
                echo -e "  ${GREEN}✓${NC} hooks.json"
                copied=$((copied + 1))
            fi
        fi

        # Copy hook scripts
        if [ -d "$SCRIPT_DIR/hooks" ]; then
            local hook_files=($(find "$SCRIPT_DIR/hooks" -name "*.sh" -exec basename {} \; 2>/dev/null | sort))
            total=$((total + ${#hook_files[@]}))

            if [ ${#hook_files[@]} -gt 0 ]; then
                if [ "$mode" == "all" ]; then
                    cp "$SCRIPT_DIR/hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null || true
                    chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true
                    copied=$((copied + ${#hook_files[@]}))
                    echo -e "${GREEN}✓${NC} Installed ${#hook_files[@]} hook scripts"
                    return
                else
                    echo -e "${DIM}Found ${#hook_files[@]} hook scripts: ${hook_files[*]%.sh}${NC}"
                    for hook in "${hook_files[@]}"; do
                        echo -n "  Copy ${hook%.sh}? (y/n): "
                        read -r response
                        if [[ "$response" =~ ^[Yy]$ ]]; then
                            cp "$SCRIPT_DIR/hooks/$hook" "$CLAUDE_DIR/hooks/$hook"
                            chmod +x "$CLAUDE_DIR/hooks/$hook"
                            echo -e "  ${GREEN}✓${NC} ${hook%.sh}"
                            copied=$((copied + 1))
                        fi
                    done
                fi
            fi
        fi

        if [ "$mode" != "all" ] && [ $total -gt 0 ]; then
            echo -e "${GREEN}✓${NC} Installed $copied of $total hook items"
        fi
    }

    # Function to copy statusline
    copy_statusline() {
        if [ ! -f "$SCRIPT_DIR/statusline.sh" ]; then
            echo -e "${YELLOW}⚠${NC} statusline.sh not found"
            return
        fi
        cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
        chmod +x "$CLAUDE_DIR/statusline.sh"
        echo -e "${GREEN}✓${NC} Installed statusline.sh"
    }

    # Function to install damage-control hooks
    install_damage_control() {
        local DAMAGE_CONTROL_DIR="$SCRIPT_DIR/skills/damage-control/scripts"
        local HOOKS_TARGET="$CLAUDE_DIR/hooks/damage-control"

        if [ ! -d "$DAMAGE_CONTROL_DIR" ]; then
            echo -e "${YELLOW}⚠${NC} Damage control scripts not found"
            return
        fi

        # Check for UV runtime
        if ! command -v uv &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} UV runtime not found (required for damage-control hooks)"
            if [ "$SKIP_UV_INSTALL" = true ]; then
                echo -e "${YELLOW}⚠${NC} Skipping UV installation (--no-uv flag)"
                return
            elif [ "$AUTO_YES" = true ]; then
                response="y"
            else
                echo -e "${BLUE}Install UV now? (y/n)${NC}"
                read -r response
            fi
            if [[ "$response" =~ ^[Yy]$ ]]; then
                echo -e "${BLUE}→ Installing UV...${NC}"
                curl -LsSf https://astral.sh/uv/install.sh | sh
                # Source the updated PATH
                export PATH="$HOME/.local/bin:$PATH"
                if command -v uv &> /dev/null; then
                    echo -e "${GREEN}✓${NC} UV installed"
                else
                    echo -e "${RED}✗${NC} UV installation failed. Install manually: curl -LsSf https://astral.sh/uv/install.sh | sh"
                    return
                fi
            else
                echo -e "${YELLOW}⚠${NC} Skipping damage-control (UV required)"
                return
            fi
        else
            echo -e "${GREEN}✓${NC} UV runtime found"
        fi

        # Create hooks directory
        mkdir -p "$HOOKS_TARGET"

        # Copy Python hook scripts
        cp "$DAMAGE_CONTROL_DIR"/*.py "$HOOKS_TARGET/" 2>/dev/null || true
        cp "$DAMAGE_CONTROL_DIR"/patterns.yaml "$HOOKS_TARGET/" 2>/dev/null || true

        # Make scripts executable
        chmod +x "$HOOKS_TARGET"/*.py 2>/dev/null || true

        local script_count=$(find "$HOOKS_TARGET" -name "*.py" 2>/dev/null | wc -l | tr -d ' ')
        echo -e "${GREEN}✓${NC} Installed $script_count damage-control hook scripts"

        # Update settings.json with damage-control hooks
        if command -v jq &> /dev/null; then
            local SETTINGS_FILE="$CLAUDE_DIR/settings.json"

            # Create settings.json if it doesn't exist
            if [ ! -f "$SETTINGS_FILE" ]; then
                echo '{}' > "$SETTINGS_FILE"
            fi

            # Backup existing settings
            cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak" 2>/dev/null

            # Read the settings template
            local TEMPLATE_FILE="$DAMAGE_CONTROL_DIR/settings-template.json"
            if [ -f "$TEMPLATE_FILE" ]; then
                # Merge damage-control hooks into existing settings
                local temp_file=$(mktemp)

                # Deep merge: combine PreToolUse arrays and permissions
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
                    echo -e "${GREEN}✓${NC} Updated settings.json with damage-control hooks"
                    echo -e "${GREEN}✓${NC} Added permissions (deny/ask rules)"
                else
                    rm -f "$temp_file"
                    echo -e "${YELLOW}⚠${NC} Could not update settings.json - manual merge may be needed"
                fi
            fi
        else
            echo -e "${YELLOW}⚠${NC} jq not found - settings.json not updated"
            echo -e "${DIM}   Add damage-control hooks to settings.json manually${NC}"
        fi

        # Verify installation
        echo
        echo -e "${BLUE}→ Verifying installation...${NC}"
        if [ -f "$HOOKS_TARGET/bash-tool-damage-control.py" ]; then
            echo -e "${GREEN}✓${NC} bash-tool-damage-control.py"
        fi
        if [ -f "$HOOKS_TARGET/edit-tool-damage-control.py" ]; then
            echo -e "${GREEN}✓${NC} edit-tool-damage-control.py"
        fi
        if [ -f "$HOOKS_TARGET/write-tool-damage-control.py" ]; then
            echo -e "${GREEN}✓${NC} write-tool-damage-control.py"
        fi
        if [ -f "$HOOKS_TARGET/patterns.yaml" ]; then
            echo -e "${GREEN}✓${NC} patterns.yaml"
        fi

        echo
        echo -e "${BLUE}Damage Control protects against:${NC}"
        echo -e "  • Destructive commands (rm -rf, git reset --hard, etc.)"
        echo -e "  • Sensitive file access (.env, ~/.ssh/, credentials)"
        echo -e "  • Accidental deletions of important files"
        echo
        echo -e "${YELLOW}⚠ IMPORTANT: Restart Claude Code for hooks to take effect${NC}"
    }

    # Function to install concise-mode hook
    install_concise_mode() {
        local CONCISE_MODE_DIR="$SCRIPT_DIR/hooks/concise-mode"
        local TEMPLATE_FILE="$CONCISE_MODE_DIR/settings-template.json"

        if [ ! -f "$TEMPLATE_FILE" ]; then
            echo -e "${YELLOW}⚠${NC} Concise mode template not found"
            return
        fi

        # Check for jq
        if ! command -v jq &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} jq not found - cannot install concise-mode hook"
            return
        fi

        local SETTINGS_FILE="$CLAUDE_DIR/settings.json"

        # Create settings.json if it doesn't exist
        if [ ! -f "$SETTINGS_FILE" ]; then
            echo '{}' > "$SETTINGS_FILE"
        fi

        # Backup existing settings
        cp "$SETTINGS_FILE" "$SETTINGS_FILE.bak" 2>/dev/null

        # Merge concise-mode hook into existing settings
        local temp_file=$(mktemp)

        jq -s '
            .[0] as $existing | .[1] as $template |
            (($existing.hooks.UserPromptSubmit // []) + ($template.hooks.UserPromptSubmit // [])) | unique as $merged_hooks |
            $existing * $template
            | .hooks.UserPromptSubmit = $merged_hooks
        ' "$SETTINGS_FILE" "$TEMPLATE_FILE" > "$temp_file" 2>/dev/null

        if [ $? -eq 0 ] && [ -s "$temp_file" ]; then
            mv "$temp_file" "$SETTINGS_FILE"
            echo -e "${GREEN}✓${NC} Installed concise-mode hook"
        else
            rm -f "$temp_file"
            echo -e "${YELLOW}⚠${NC} Could not install concise-mode hook"
        fi

        echo -e "${DIM}   Bypass with: elaborate, explain, detail, show code, example${NC}"
    }

    # Function to update settings.json by merging toolkit settings
    copy_settings() {
        # Check if jq is available
        if ! command -v jq &> /dev/null; then
            echo -e "${YELLOW}⚠${NC} jq not found - cannot update settings.json"
            echo -e "${DIM}   Install jq or manually merge settings${NC}"
            return
        fi

        # Check if toolkit settings.json exists
        if [ ! -f "$SCRIPT_DIR/settings.json" ]; then
            echo -e "${YELLOW}⚠${NC} Toolkit settings.json not found"
            return
        fi

        # Create user settings.json if it doesn't exist
        if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
            echo '{}' > "$CLAUDE_DIR/settings.json"
        fi

        # Backup existing settings
        cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak" 2>/dev/null

        # Merge toolkit settings into user settings (user settings take precedence)
        local temp_file=$(mktemp)
        jq -s '.[1] * .[0]' "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json" > "$temp_file"

        if [ $? -eq 0 ]; then
            mv "$temp_file" "$CLAUDE_DIR/settings.json"
            echo -e "${GREEN}✓${NC} Updated settings.json (merged toolkit settings)"
        else
            rm -f "$temp_file"
            echo -e "${RED}✗${NC} Failed to update settings.json"
        fi
    }

    echo
    echo -e "${BLUE}→ Installing toolkit components...${NC}"

    if [[ "$install_choice" == "1" ]]; then
        # Install all
        echo -e "${BLUE}Skills:${NC}"
        copy_skills "all"
        echo -e "${BLUE}Agents:${NC}"
        copy_agents "all"
        echo -e "${BLUE}Commands:${NC}"
        copy_commands "all"
        echo -e "${BLUE}Hooks:${NC}"
        copy_hooks "all"
        echo -e "${BLUE}Statusline:${NC}"
        copy_statusline
        echo -e "${BLUE}Damage Control (security hooks):${NC}"
        install_damage_control
        echo -e "${BLUE}Concise Mode (brief responses):${NC}"
        install_concise_mode
        echo -e "${BLUE}Settings:${NC}"
        copy_settings

    elif [[ "$install_choice" == "2" ]]; then
        # Select by folder
        echo
        echo -e "${BLUE}━━━ Skills ━━━${NC}"
        echo -n "Copy (${GREEN}a${NC})ll / (${GREEN}o${NC})ne-by-one / (${GREEN}s${NC})kip? "
        read -r choice
        [[ "$choice" =~ ^[Aa]$ ]] && copy_skills "all"
        [[ "$choice" =~ ^[Oo]$ ]] && copy_skills "one-by-one"

        echo
        echo -e "${BLUE}━━━ Agents ━━━${NC}"
        echo -n "Copy (${GREEN}a${NC})ll / (${GREEN}o${NC})ne-by-one / (${GREEN}s${NC})kip? "
        read -r choice
        [[ "$choice" =~ ^[Aa]$ ]] && copy_agents "all"
        [[ "$choice" =~ ^[Oo]$ ]] && copy_agents "one-by-one"

        echo
        echo -e "${BLUE}━━━ Commands ━━━${NC}"
        echo -n "Copy (${GREEN}a${NC})ll / (${GREEN}o${NC})ne-by-one / (${GREEN}s${NC})kip? "
        read -r choice
        [[ "$choice" =~ ^[Aa]$ ]] && copy_commands "all"
        [[ "$choice" =~ ^[Oo]$ ]] && copy_commands "one-by-one"

        echo
        echo -e "${BLUE}━━━ Hooks ━━━${NC}"
        echo -n "Copy (${GREEN}a${NC})ll / (${GREEN}o${NC})ne-by-one / (${GREEN}s${NC})kip? "
        read -r choice
        [[ "$choice" =~ ^[Aa]$ ]] && copy_hooks "all"
        [[ "$choice" =~ ^[Oo]$ ]] && copy_hooks "one-by-one"

        echo
        echo -e "${BLUE}━━━ Statusline ━━━${NC}"
        echo -n "Copy statusline.sh? (y/n): "
        read -r choice
        [[ "$choice" =~ ^[Yy]$ ]] && copy_statusline

        echo
        echo -e "${BLUE}━━━ Damage Control ━━━${NC}"
        echo -e "${DIM}Security hooks that block dangerous commands (rm -rf, git reset --hard, etc.)${NC}"
        echo -n "Install damage-control hooks? (y/n): "
        read -r choice
        [[ "$choice" =~ ^[Yy]$ ]] && install_damage_control

        echo
        echo -e "${BLUE}━━━ Concise Mode ━━━${NC}"
        echo -e "${DIM}Forces brief responses without code blocks or tables (bypass: elaborate, explain)${NC}"
        echo -n "Install concise-mode hook? (y/n): "
        read -r choice
        [[ "$choice" =~ ^[Yy]$ ]] && install_concise_mode

        echo
        echo -e "${BLUE}━━━ Settings ━━━${NC}"
        echo -n "Merge toolkit settings.json into your settings? (y/n): "
        read -r choice
        [[ "$choice" =~ ^[Yy]$ ]] && copy_settings
    fi
else
    echo -e "${RED}✗${NC} Invalid choice. Exiting."
    exit 1
fi

if [[ "$install_choice" != "3" ]]; then
    echo
    echo -e "${BLUE}→ Verifying installation...${NC}"

    # Check if statusline is configured
    if [ -f "$CLAUDE_DIR/settings.json" ] && grep -q "statusLine" "$CLAUDE_DIR/settings.json"; then
        echo -e "${GREEN}✓${NC} Statusline configured in settings.json"
    elif [ -f "$CLAUDE_DIR/statusline.sh" ]; then
        echo -e "${YELLOW}⚠${NC} statusline.sh installed but not configured in settings.json"
        echo -e "${DIM}   Run the installer again to update settings.json${NC}"
    fi
fi

echo
echo -e "${GREEN}╔════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║          Installation Complete! 🎉             ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════╝${NC}"
echo
echo -e "${BLUE}Installed to:${NC} $CLAUDE_DIR"
echo
echo -e "${BLUE}Next steps:${NC}"
echo -e "  1. Run ${GREEN}claude${NC} to start using the toolkit"
echo -e "  2. Try ${GREEN}/commit${NC}, ${GREEN}/ship${NC}, or ${GREEN}/db${NC} commands"
echo -e "  3. Use ${GREEN}/help${NC} to see all available commands"
echo
echo -e "${DIM}View the toolkit at: $SCRIPT_DIR${NC}"
echo
