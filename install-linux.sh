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
        echo -e "${BLUE}Check for Claude Code updates? (y/n)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}→ Checking for updates...${NC}"
            LATEST=$(npm view @anthropic-ai/claude-code version 2>/dev/null || echo "unknown")
            CURRENT=$(echo "$CLAUDE_VERSION" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
            if [ "$LATEST" != "unknown" ] && [ "$LATEST" != "$CURRENT" ]; then
                echo -e "${YELLOW}⚠${NC} Update available: $CURRENT → $LATEST"
                echo -e "${BLUE}Update Claude Code now? (y/n)${NC}"
                read -r response
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
        echo -e "${BLUE}Install Claude Code CLI via npm? (y/n)${NC}"
        read -r response
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
        echo -e "${BLUE}Install missing dependencies? (y/n)${NC}"
        read -r response
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
        echo -e "${BLUE}Continue without installing dependencies? (y/n)${NC}"
        read -r response
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
echo -e "How would you like to install components?"
echo -e "  ${GREEN}1${NC}) Install all (recommended)"
echo -e "  ${GREEN}2${NC}) Select by folder"
echo -e "  ${GREEN}3${NC}) Skip installation"
echo -n "Choice [1-3]: "
read -r install_choice

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
                    ((copied++))
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
                    ((copied++))
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
                    ((copied++))
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
            ((total++))
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
                ((copied++))
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
                            ((copied++))
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
        echo -e "${BLUE}Settings:${NC}"
        echo -n "Merge toolkit settings.json into your settings? (y/n): "
        read -r response
        [[ "$response" =~ ^[Yy]$ ]] && copy_settings

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
