# Getting Started with Claude Code Toolkit

Complete setup and installation guide for the toolkit.

## Prerequisites

Before installation, ensure you have:

- **jq** — Required for statusline JSON parsing and settings management
- **git** — Recommended for git workflow features
- **uv** — Required for Python scripts (auto-installs dependencies via PEP 723)
- **Platform-specific**:
  - **macOS**: `coreutils` (for `gtac` command used by statusline)
  - **Linux**: `coreutils` (usually pre-installed, provides `tac` command)

The automated installer will detect and offer to install missing dependencies.

## Quick Start

The easiest way to get started is using the automated installer:

```bash
# Clone the toolkit
git clone https://github.com/cfircoo/claude-code-toolkit.git
cd claude-code-toolkit

# Run the installer (auto-detects platform, installs everything)
./install.sh
```

The installer runs non-interactively by default, installing all components. Use `-i` for interactive mode:

```bash
# Interactive mode - choose components individually
./install.sh -i
```

## Installation Methods

### Method 1: Automated Installation (Recommended)

The interactive installer guides you through setup:

```bash
./install.sh          # Install everything (default)
./install.sh -i       # Interactive mode
./install.sh --help   # Show all options
```

#### Interactive Installation Modes

When running with `-i`, you can:

**1. Install All**
- One-click installation of all components
- Installs: skills, agents, commands, hooks, statusline, and settings

**2. Select by Folder**
- Choose which component types to install
- For each folder (skills/agents/commands/hooks), you can:
  - **All** — Copy all items in that folder
  - **One-by-one** — Review and select each item individually
  - **Skip** — Skip that entire folder

**3. Skip Installation**
- Exit without copying anything

#### What the Installer Does

- ✓ Checks for required dependencies (jq, git, coreutils, uv)
- ✓ Offers to install missing packages via package manager
- ✓ Creates necessary directories (`~/.claude/*`)
- ✓ **Replaces existing skill folders** (ensures clean updates)
- ✓ Copies selected components with detailed logging
- ✓ **Installs Python scripts** (dependencies auto-managed by uv)
- ✓ Sets up statusline with proper permissions
- ✓ **Installs security hooks** (protects .env, credentials, blocks destructive commands)
- ✓ **Installs concise-mode hook** (brief responses, toggleable with `/concise`)
- ✓ **Intelligently merges settings.json** (preserves your existing settings)
- ✓ **Configures Perplexity API key** (searches environment and shell configs)
- ✓ **Configures Gemini API key** (for Nano Banana image generation)
- ✓ Automatically backs up `hooks.json` and `settings.json` to `.bak` files

#### Platform-Specific Installers

You can also run platform-specific installers directly:

```bash
# For macOS
./install-mac.sh

# For Linux
./install-linux.sh
```

#### Command-Line Options

```bash
# Install everything (default)
./install.sh

# Interactive mode
./install.sh -i

# Skip update check
./install.sh --no-update

# Skip UV installation (for damage-control)
./install.sh --no-uv

# Show help
./install.sh --help
```

| Option | Description |
|--------|-------------|
| `-i, --interactive` | Interactive mode (prompt for each component) |
| `-y, --yes, --all` | Auto-yes to all prompts (default) |
| `--no-update` | Skip Claude Code update check |
| `--no-uv` | Skip UV installation for damage-control hooks |
| `--select` | Interactive selection mode |
| `--skip` | Skip component installation |
| `-h, --help` | Show help message |

### Method 2: Full Manual Installation

Copy everything to get the complete toolkit:

```bash
# Create directories if they don't exist
mkdir -p ~/.claude/{skills,agents,commands,hooks}

# Copy all components
cp -r skills/* ~/.claude/skills/
cp -r agents/* ~/.claude/agents/
cp -r commands/* ~/.claude/commands/
cp hooks.json ~/.claude/hooks.json
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh

# Enable statusline in settings
# Add to ~/.claude/settings.json:
# {
#   "statusLine": {
#     "type": "command",
#     "command": "~/.claude/statusline.sh",
#     "padding": 0
#   }
# }
```

### Method 3: Selective Installation

Pick only what you need:

```bash
# Just git workflow
cp -r skills/git ~/.claude/skills/
cp agents/git-ops.md ~/.claude/agents/
cp commands/{git-commit,git-push,git-pr,git-ship}.md ~/.claude/commands/

# Just database tools
cp -r skills/sqlalchemy-postgres ~/.claude/skills/
cp agents/db-expert.md ~/.claude/agents/
cp commands/db.md ~/.claude/commands/

# Just testing
cp -r skills/pytest-best-practices ~/.claude/skills/
cp agents/pytest-writer.md ~/.claude/agents/

# Just planning & specs
cp -r skills/{create-plans,spec-interview} ~/.claude/skills/
cp commands/spec-interview.md ~/.claude/commands/
```

### Method 4: Project-Level Installation

For project-specific use, copy to `.claude/` in your project:

```bash
mkdir -p .claude/{skills,agents,commands}
cp -r ~/claude-code-toolkit/skills/git .claude/skills/
cp ~/claude-code-toolkit/agents/git-ops.md .claude/agents/
```

## API Key Setup

The installer automatically configures keys for external services:

| Script | Environment Variable | Get Key At |
|--------|----------------------|------------|
| **perplexity_search.py** | `PERPLEXITY_API_KEY` | https://www.perplexity.ai/settings/api |
| **generate_image.py** | `GEMINI_API_KEY` | https://aistudio.google.com/apikey |

For each key, the installer:
1. Checks if the key is in your environment
2. Searches shell config files (`.bashrc`, `.zshrc`, `.profile`)
3. Prompts for the key if not found
4. Stores it in `~/.claude/settings.json` under `env`

**Note:** Gemini image generation requires billing enabled on your Google AI Studio account.

## Verification

After installation, verify everything is working:

```bash
# Check installed skills
ls ~/.claude/skills/

# Check installed agents
ls ~/.claude/agents/

# Check installed commands
ls ~/.claude/commands/

# Validate hooks configuration
jq . ~/.claude/hooks.json

# Test a command
claude> /help
```

## Next Steps

1. **Learn the Components**
   - Read [Architecture Overview](architecture.md)
   - Browse the [skills documentation](skills/)
   - Review available [agents](agents/)

2. **Common Tasks**
   - [Git Workflow](skills/git.md)
   - [Database Setup](skills/sqlalchemy-postgres.md)
   - [Testing with pytest](skills/pytest-best-practices.md)

3. **Project Planning**
   - [Specification Interviews](skills/spec-interview.md)
   - [Creating Plans](skills/create-plans.md)

4. **Advanced Topics**
   - [Ralph Autonomous Loop](ralph.md)
   - [Creating Custom Skills](skills/manage-skills.md)
   - [Managing Hooks](skills/manage-hooks.md)

## Troubleshooting

### Skills not loading?
- Check file is named `SKILL.md` (case-sensitive)
- Verify YAML frontmatter has `name` and `description`

### Agents not triggering?
- Check `description` field matches your task
- Try invoking explicitly: "Use the agent-name agent"

### Commands not found?
- Run `/help` to see available commands
- Check file is in `~/.claude/commands/` or `.claude/commands/`

### Hooks not firing?
- Run `claude --debug` to see hook execution
- Validate JSON: `jq . ~/.claude/hooks.json`

### API keys not working?
- Verify keys are in `~/.claude/settings.json`
- Check environment variables: `echo $PERPLEXITY_API_KEY`
- Re-run installer to reconfigure: `./install.sh -i`

## Support

For issues or questions:
1. Check the [Troubleshooting](README.md#troubleshooting) section
2. Review component-specific documentation
3. Open an issue on GitHub
