<overview>
Structure and templates for creating distributable hooks in the claude-code-toolkit project.
</overview>

<directory_structure>
```
hooks/
└── my-hook/
    ├── README.md                # Documentation
    ├── install.sh               # Standalone installer
    ├── settings-template.json   # Hook configuration to merge
    └── toggle.sh                # Optional: on/off toggle script
```
</directory_structure>

<settings_template>
**settings-template.json** (hook configuration):
```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "your-hook-command-here"
          }
        ]
      }
    ]
  }
}
```
</settings_template>

<installer_template>
**install.sh** (standalone installer):
```bash
#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TEMPLATE_FILE="$SCRIPT_DIR/settings-template.json"

# Check dependencies
command -v jq &>/dev/null || { echo "jq required"; exit 1; }

# Create settings if missing
mkdir -p "$CLAUDE_DIR"
[ -f "$CLAUDE_DIR/settings.json" ] || echo '{}' > "$CLAUDE_DIR/settings.json"

# Backup and merge
cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
jq -s '.[0] * .[1]' "$CLAUDE_DIR/settings.json" "$TEMPLATE_FILE" > /tmp/merged.json
mv /tmp/merged.json "$CLAUDE_DIR/settings.json"

echo "Hook installed"
```
</installer_template>

<root_installer_integration>
After creating a new hook, you MUST update both `install-linux.sh` and `install-mac.sh`:

**1. Add install function:**
```bash
install_my_hook() {
    local INSTALL_SCRIPT="$SCRIPT_DIR/hooks/my-hook/install.sh"
    [ -f "$INSTALL_SCRIPT" ] || { echo "Hook not found"; return; }
    bash "$INSTALL_SCRIPT"
}
```

**2. Add to "install all" section:**
```bash
echo -e "${BLUE}My Hook (description):${NC}"
install_my_hook
```

**3. Add to "select by folder" section:**
```bash
echo
echo -e "${BLUE}━━━ My Hook ━━━${NC}"
echo -e "${DIM}Brief description of what the hook does${NC}"
echo -n "Install my-hook? (y/n): "
read -r choice
[[ "$choice" =~ ^[Yy]$ ]] && install_my_hook
```
</root_installer_integration>

<existing_examples>
**Examples in toolkit:**
- `hooks/concise-mode/` - UserPromptSubmit hook with toggle
- `hooks/damage-control/` - PreToolUse hooks with Python scripts
</existing_examples>
