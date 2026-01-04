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
echo -e "${BLUE}→ Installing toolkit components...${NC}"

# Copy skills
if [ -d "$SCRIPT_DIR/skills" ]; then
    cp -r "$SCRIPT_DIR/skills/"* "$CLAUDE_DIR/skills/" 2>/dev/null || true
    SKILL_COUNT=$(find "$SCRIPT_DIR/skills" -name "SKILL.md" | wc -l)
    echo -e "${GREEN}✓${NC} Installed $SKILL_COUNT skills"
fi

# Copy agents
if [ -d "$SCRIPT_DIR/agents" ]; then
    cp "$SCRIPT_DIR/agents/"*.md "$CLAUDE_DIR/agents/" 2>/dev/null || true
    AGENT_COUNT=$(find "$SCRIPT_DIR/agents" -name "*.md" -not -name "README.md" | wc -l)
    echo -e "${GREEN}✓${NC} Installed $AGENT_COUNT agents"
fi

# Copy commands
if [ -d "$SCRIPT_DIR/commands" ]; then
    cp "$SCRIPT_DIR/commands/"*.md "$CLAUDE_DIR/commands/" 2>/dev/null || true
    COMMAND_COUNT=$(find "$SCRIPT_DIR/commands" -name "*.md" -not -name "README.md" | wc -l)
    echo -e "${GREEN}✓${NC} Installed $COMMAND_COUNT commands"
fi

# Copy hooks configuration
if [ -f "$SCRIPT_DIR/hooks.json" ]; then
    if [ -f "$CLAUDE_DIR/hooks.json" ]; then
        echo -e "${YELLOW}⚠${NC} hooks.json already exists. Backup to hooks.json.bak? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            cp "$CLAUDE_DIR/hooks.json" "$CLAUDE_DIR/hooks.json.bak"
            echo -e "${GREEN}✓${NC} Backed up existing hooks.json"
        fi
    fi
    cp "$SCRIPT_DIR/hooks.json" "$CLAUDE_DIR/hooks.json"
    echo -e "${GREEN}✓${NC} Installed hooks configuration"
fi

# Copy hook scripts
if [ -d "$SCRIPT_DIR/hooks" ]; then
    cp "$SCRIPT_DIR/hooks/"*.sh "$CLAUDE_DIR/hooks/" 2>/dev/null || true
    chmod +x "$CLAUDE_DIR/hooks/"*.sh 2>/dev/null || true
    HOOK_COUNT=$(find "$SCRIPT_DIR/hooks" -name "*.sh" | wc -l)
    echo -e "${GREEN}✓${NC} Installed $HOOK_COUNT hook scripts"
fi

# Copy statusline
if [ -f "$SCRIPT_DIR/statusline.sh" ]; then
    cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
    chmod +x "$CLAUDE_DIR/statusline.sh"
    echo -e "${GREEN}✓${NC} Installed statusline.sh"
fi

echo
echo -e "${BLUE}→ Checking settings...${NC}"

# Check if settings.json exists and configure statusline
SETTINGS_FILE="$CLAUDE_DIR/settings.json"
if [ ! -f "$SETTINGS_FILE" ]; then
    echo -e "${BLUE}Create settings.json with statusline enabled? (y/n)${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cat > "$SETTINGS_FILE" << 'EOF'
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh"
  }
}
EOF
        echo -e "${GREEN}✓${NC} Created settings.json with statusline enabled"
    fi
else
    # Check if statusline is already configured
    if ! grep -q "statusLine" "$SETTINGS_FILE"; then
        echo -e "${YELLOW}⚠${NC} settings.json exists but statusline not configured"
        echo -e "${DIM}   Add this to enable statusline:${NC}"
        echo -e "${DIM}   {${NC}"
        echo -e "${DIM}     \"statusLine\": {${NC}"
        echo -e "${DIM}       \"type\": \"command\",${NC}"
        echo -e "${DIM}       \"command\": \"~/.claude/statusline.sh\"${NC}"
        echo -e "${DIM}     }${NC}"
        echo -e "${DIM}   }${NC}"
    else
        echo -e "${GREEN}✓${NC} Statusline already configured in settings.json"
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
