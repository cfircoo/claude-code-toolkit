#!/bin/bash

# Universal Claude Code Toolkit Installer
# Detects platform and runs appropriate installation

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║   Claude Code Toolkit - Universal Installer   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
echo

# Detect platform
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="mac"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    PLATFORM="linux"
else
    echo -e "${RED}✗ Unsupported platform: $OSTYPE${NC}"
    echo "This installer supports macOS and Linux only."
    exit 1
fi

echo -e "${GREEN}✓${NC} Detected platform: ${BLUE}$PLATFORM${NC}"
echo

# Check if platform-specific installer exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLATFORM_INSTALLER="$SCRIPT_DIR/install-${PLATFORM}.sh"

if [ ! -f "$PLATFORM_INSTALLER" ]; then
    echo -e "${RED}✗ Platform installer not found: $PLATFORM_INSTALLER${NC}"
    exit 1
fi

# Run platform-specific installer
echo -e "${BLUE}→ Running ${PLATFORM} installer...${NC}"
echo
bash "$PLATFORM_INSTALLER" "$@"
