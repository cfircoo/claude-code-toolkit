# Damage Control Hook

Security hooks that block dangerous commands and protect sensitive files.

## Protection

- **Destructive commands**: rm -rf, git reset --hard, mkfs, dd
- **Sensitive files**: .env, ~/.ssh/, credentials, API keys
- **Dangerous patterns**: Force pushes, hard resets

## Installation

```bash
./hooks/damage-control/install.sh
```

Options:
- `-y, --yes` - Auto-yes to prompts
- `--no-uv` - Skip UV installation (will fail if UV not present)

## Requirements

- **UV runtime** - Required for Python hook scripts
- **jq** - Required for settings.json merge

## What Gets Installed

- Hook scripts to `~/.claude/hooks/damage-control/`
- Skill folder to `~/.claude/skills/damage-control/`
- Settings merged into `~/.claude/settings.json`
