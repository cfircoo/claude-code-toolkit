# Claude Code Toolkit

A curated collection of skills, agents, commands, and hooks to supercharge your Claude Code experience. Copy what you need to `~/.claude/` and start using immediately.

## Prerequisites

Before installation, ensure you have:

- **jq** - Required for statusline JSON parsing and settings management
- **git** - Recommended for git workflow features
- **uv** - Required for Python scripts (auto-installs dependencies via PEP 723)
- **Platform-specific**:
  - **macOS**: `coreutils` (for `gtac` command used by statusline)
  - **Linux**: `coreutils` (usually pre-installed, provides `tac` command)

The automated installer will detect and offer to install missing dependencies.

## Automatic Installation (Recommended)

The easiest way to install the toolkit is using the interactive installer:

```bash
# Clone the toolkit
git clone https://github.com/cfircoo/claude-code-toolkit.git
cd claude-code-toolkit

# Run the installer (auto-detects macOS or Linux, installs everything by default)
./install.sh
```

The installer runs non-interactively by default, installing all components. Use `-i` for interactive mode:

```bash
# Interactive mode - choose components individually
./install.sh -i
```

### Interactive Installation Modes

When running in interactive mode (`-i`), the installer offers:

**1. Install All**
- One-click installation of all components
- Installs: skills, agents, commands, hooks, statusline, and settings

**2. Select by Folder**
- Choose which component types to install
- For each folder (skills/agents/commands/hooks), you can:
  - **All** - Copy all items in that folder
  - **One-by-one** - Review and select each item individually
  - **Skip** - Skip that entire folder

**3. Skip Installation**
- Exit without copying anything
- Useful if you just want to browse the code

### What the Installer Does

- ✓ Checks for required dependencies (jq, git, coreutils, pip)
- ✓ Offers to install missing packages via package manager
- ✓ Creates necessary directories (`~/.claude/*`)
- ✓ **Replaces existing skill folders** (ensures clean updates, no file conflicts)
- ✓ Copies selected components with detailed logging
- ✓ **Installs Python scripts** (dependencies auto-managed by uv)
- ✓ Sets up statusline with proper permissions
- ✓ **Installs damage-control security hooks** (protects .env, credentials, blocks destructive commands)
- ✓ **Installs concise-mode hook** (brief responses, toggleable with `/concise`)
- ✓ **Intelligently merges settings.json** (preserves your existing settings)
- ✓ **Configures Perplexity API key** (searches environment and shell configs, or prompts for key)
- ✓ **Configures Gemini API key** (for Nano Banana image generation)
- ✓ Automatically backs up `hooks.json` and `settings.json` to `.bak` files

### Platform-Specific Installers

You can also run the platform-specific installer directly:

```bash
# For macOS
./install-mac.sh

# For Linux
./install-linux.sh
```

### Command-Line Options

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

## Manual Installation

If you prefer manual installation or want selective components:

```bash
# Create directories
mkdir -p ~/.claude/{skills,agents,commands,hooks,scripts}

# Copy everything
cp -r skills/* ~/.claude/skills/
cp -r agents/* ~/.claude/agents/
cp -r commands/* ~/.claude/commands/
cp -r scripts/* ~/.claude/scripts/
cp hooks.json ~/.claude/hooks.json
cp statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh
chmod +x ~/.claude/scripts/*.py
# Note: Python dependencies are handled by uv (PEP 723 inline metadata)

# Or copy selectively - pick only what you need
cp -r skills/git ~/.claude/skills/
cp agents/git-ops.md ~/.claude/agents/
```

## What's Included

### Skills (16)

Skills are modular capabilities that provide domain expertise on demand. They live in `~/.claude/skills/`.

| Skill | Description | Use When |
|-------|-------------|----------|
| **git** | Git operations with safety protocols | Committing, pushing, creating PRs |
| **pytest-best-practices** | Expert pytest patterns | Writing tests, fixtures, mocking |
| **sqlalchemy-postgres** | SQLAlchemy 2.0 + Pydantic + PostgreSQL | Database layers, models, migrations |
| **debug-like-expert** | Methodical debugging with hypothesis testing | Complex bugs that resist standard fixes |
| **damage-control** | Security hooks blocking dangerous operations | Protecting .env, credentials, destructive commands |
| **create-plans** | Hierarchical project planning | Planning projects for solo dev + Claude |
| **spec-interview** | Interview-driven specification building | Starting new projects, defining requirements |
| **create-subagents** | Guide to creating custom subagents | Building specialized agents |
| **create-hooks** | Guide to creating event hooks | Automating workflows, validations |
| **create-slash-commands** | Guide to creating slash commands | Building reusable command prompts |
| **create-agent-skills** | Guide to creating skills | Building modular capabilities |
| **create-meta-prompts** | Claude-to-Claude pipeline prompts | Multi-stage workflows (research -> plan -> implement) |
| **ralph-orchestrator** | Orchestrates Ralph autonomous agent loop — story-by-story execution with verification | Building features with spec → PRD → prd.json → autonomous execution loop |
| **generate-images** | Image generation/editing via Nano Banana (Gemini) | Creating icons, banners, mockups, editing images |
| **generate-prd** | Creates PRDs through guided discovery | Defining feature requirements |
| **ralph-convert-prd** | Converts PRDs to atomic user stories | Preparing PRDs for Ralph execution |

### Agents (8)

Agents are specialized Claude instances that run autonomously in isolated contexts. They live in `~/.claude/agents/`.

| Agent | Description | Triggered By |
|-------|-------------|--------------|
| **git-ops** | Commits, pushes, and creates PRs safely | "commit my changes", "create a PR" |
| **db-expert** | SQLAlchemy 2.0 database implementation | Database-related tasks |
| **pytest-writer** | Writes high-quality pytest tests | "write tests for...", "add test coverage" |
| **perplexity-research** | Web research via Perplexity API | "research...", "find documentation", "what is..." |
| **fullstack-manager** | Orchestrates frontend builds from APIs | Building frontends from backend APIs |
| **fullstack-api-specialist** | Maps API endpoints and schemas | API discovery and documentation |
| **fullstack-ui-designer** | Creates distinctive UI components | Frontend component design |
| **fullstack-qa-debugger** | Validates integrations and catches errors | Testing and debugging frontends |

### Commands (13)

Commands are slash-invoked prompts for common operations. They live in `~/.claude/commands/`.

| Command | Description | Usage |
|---------|-------------|-------|
| `/git-commit` | Stage and commit with proper message format | `/git-commit` |
| `/git-push` | Push commits to remote | `/git-push` |
| `/git-pr` | Create a pull request | `/git-pr` |
| `/git-ship` | Full workflow: commit + push + PR | `/git-ship` |
| `/db` | Database operations | `/db setup`, `/db model User`, `/db migration` |
| `/concise` | Toggle concise response mode | `/concise on`, `/concise off`, `/concise` |
| `/spec-interview` | Build project specification through interview | `/spec-interview my-project` |
| `/install-toolkit` | Interactive installer - asks preferences then installs | `/install-toolkit [path]` |
| `/ralph` | Orchestrate Ralph autonomous agent pipeline | `/ralph`, `/ralph status`, `/ralph execute` |
| `/generate-prd` | Generate PRD for a new feature | `/generate-prd user-dashboard` |
| `/generate-image` | Generate or edit images via Nano Banana | `/generate-image a logo for my app` |
| `/ralph-convert-prd` | Convert PRD to Ralph prd.json format | `/ralph-convert-prd tasks/prd-feature.md` |

### Hooks

Hooks are event-driven automation scripts. Configuration lives in `~/.claude/settings.json`.

| Hook | Trigger | Description |
|------|---------|-------------|
| **pre-commit-pytest** | Before git commit/push | Runs pytest, blocks if tests fail |

#### Concise Mode Hook

Forces brief responses without code blocks, tables, or verbose formatting. Installed automatically with the toolkit.

| Feature | Description |
|---------|-------------|
| **Default behavior** | 1-3 sentences max, no code blocks or tables |
| **Bypass words** | `elaborate`, `explain`, `detail`, `show code`, `example` |
| **Toggle command** | `/concise [on\|off\|status]` |
| **Statusline indicator** | Shows `💬 concise` or `💬 default` |

**Standalone installation:**
```bash
./hooks/concise-mode/install.sh
```

#### Damage Control Hooks

Security hooks that protect against dangerous operations. Installed automatically with the toolkit.

| Hook | Tool | Protection |
|------|------|------------|
| **bash-tool-damage-control** | Bash | Blocks `rm -rf`, `git reset --hard`, cloud destructive ops, etc. |
| **read-tool-damage-control** | Read | Blocks reading `.env`, credentials, SSH keys |
| **write-tool-damage-control** | Write | Blocks writing to protected paths |
| **edit-tool-damage-control** | Edit | Blocks editing protected files |

**Git branch protection:**
- Blocks `git commit` and `git push` on `main`/`master` (runtime branch detection)
- Allows tag pushes (`git push origin v*`) and `git tag` on protected branches
- Bare `git push` blocked — must specify remote and branch explicitly
- `git push --force` blocked — use `--force-with-lease` instead

**Protection levels in `patterns.yaml`:**
- `zeroAccessPaths` - No operations allowed — secrets, SSH keys, cloud credentials, certificates, tfstate
- `readOnlyPaths` - Read allowed, Write/Edit blocked — system dirs, lock files, build artifacts
- `noDeletePaths` - Read/Write allowed, delete blocked — `.git/`, CI/CD files, LICENSE, README
- `destructivePatterns` - Dangerous bash commands blocked — rm -rf, git reset --hard, terraform destroy, DROP TABLE, cloud CLI destructive operations

### Scripts

Python helper scripts for agents. They live in `~/.claude/scripts/`.

| Script | Description | Used By |
|--------|-------------|---------|
| **perplexity_search.py** | Perplexity API wrapper for web search | perplexity-research agent |
| **generate_image.py** | Nano Banana image generation via Gemini API | generate-images skill |

**Dependencies:** Managed via inline PEP 723 metadata - `uv` auto-installs on first run (no pip needed).

**API Key Setup:** The installer automatically configures keys for both scripts:

| Script | Env Variable | Get Key At |
|--------|-------------|------------|
| **perplexity_search.py** | `PERPLEXITY_API_KEY` | https://www.perplexity.ai/settings/api |
| **generate_image.py** | `GEMINI_API_KEY` | https://aistudio.google.com/apikey |

For each key, the installer:
1. Checks if the key is in your environment
2. Searches shell config files (`.bashrc`, `.zshrc`, `.profile`)
3. Prompts for the key if not found
4. Stores it in `~/.claude/settings.json` under `env`

**Note:** Gemini image generation requires billing enabled on your Google AI Studio account.

### Settings

The toolkit's `settings.json` includes these configurations (merged with your existing settings):

| Setting | Description |
|---------|-------------|
| **statusLine** | Terminal status bar showing model, git branch, context usage |
| **env.ENABLE_TOOL_SEARCH** | Enables MCP lazy loading - tools load on-demand instead of all at once, saving context tokens |
| **env.PERPLEXITY_API_KEY** | API key for perplexity-research agent (configured during install) |
| **env.GEMINI_API_KEY** | API key for generate-images skill (configured during install) |

### Extras

| File | Description |
|------|-------------|
| **statusline.sh** | Cross-platform terminal status line (macOS/Linux) showing model, directory, git branch, context usage with visual progress bar, and last user prompt. Automatically detects platform and uses `gtac` (macOS) or `tac` (Linux). |

## Installation Options

### Option 1: Automated Installation (Recommended)

```bash
./install.sh          # Install everything (default)
./install.sh -i       # Interactive mode
```

See [Automatic Installation](#automatic-installation-recommended) section above for details.

### Option 2: Full Manual Installation

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

### Option 3: Selective Installation

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

### Option 4: Project-Level Installation

For project-specific use, copy to `.claude/` in your project:

```bash
mkdir -p .claude/{skills,agents,commands}
cp -r ~/claude-code-toolkit/skills/git .claude/skills/
cp ~/claude-code-toolkit/agents/git-ops.md .claude/agents/
```

## Usage Examples

### Git Workflow

```
> /git-commit
# Claude analyzes changes, creates commit with proper message format

> /git-ship
# Full workflow: commit -> push -> create PR with summary
```

### Database Setup

```
> /db setup
# Initializes SQLAlchemy 2.0 + Pydantic + Alembic structure

> /db model User
# Creates User model with schemas and repository
```

### Project Planning

```
> /spec-interview my-new-app
# Claude interviews you to build comprehensive SPEC.md

> Use the create-plans skill to plan the implementation
# Creates phased implementation plan in .planning/
```

### Testing

```
> Write tests for src/utils/helpers.py
# pytest-writer agent creates comprehensive tests

> Use the debug-like-expert skill to investigate this error
# Methodical debugging with hypothesis testing
```

### Web Research

```
> Research the latest features in Next.js 15
# perplexity-research agent searches web, synthesizes findings with sources

> Find documentation on SQLAlchemy 2.0 async sessions
# Returns structured report with citations
```

### Image Generation

```
> /generate-image a minimalist logo for a task management app
# Generates image using Nano Banana (Gemini) and saves to disk

> /generate-image edit the hero banner to have a sunset background --edit assets/hero.png
# Edits an existing image with natural language instructions
```

### Ralph Autonomous Agent Loop

Ralph is an autonomous execution loop that takes a PRD and implements it story-by-story, each in a fresh Claude instance with real verification.

```
> /ralph
# Full pipeline: spec-interview → PRD → prd.json → autonomous execution

> /ralph status
# Check current prd.json progress and story completion

> /generate-prd user-dashboard
# Create PRD for new feature through guided discovery

> /ralph-convert-prd tasks/prd-dashboard.md
# Convert PRD to atomic user stories for Ralph execution
```

**How the loop works:**
- `ralph.sh` iterates through stories in `tasks/prd.json`, spawning fresh Claude instances per story
- Each story has `verificationCommands` with expect matchers (`exit_code`, `contains`, `matches`)
- Stories track `status` (pending → in_progress → done/failed/blocked) and `maxAttempts` to prevent infinite retries
- Real-time logging to `tasks/ralph.log` — monitor with `tail -f tasks/ralph.log`
- Outputs `test-log.md` (test registry) and `review-notes.md` (learnings) after each story
- Archives previous runs when switching branches
- Exit codes: 0 (complete), 1 (max iterations), 2 (all stories blocked/exhausted)

**Key principles:**
- Never implements directly — all code changes go through ralph.sh → fresh Claude instance
- Stops on errors (non-zero exit codes require user intervention)
- Full test suite must pass after each story (no regressions)
- Each story has `docsToUpdate` to track documentation changes
- Stories support `blockedBy` dependencies for ordered execution

## Customization

### Creating Your Own Skills

```bash
mkdir -p ~/.claude/skills/my-skill
cat > ~/.claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What it does and when to use it.
---

<objective>What this skill accomplishes</objective>
<process>How to do it</process>
<success_criteria>How to know it worked</success_criteria>
EOF
```

See the `create-agent-skills` skill for comprehensive guidance.

### Creating Your Own Agents

```bash
cat > ~/.claude/agents/my-agent.md << 'EOF'
---
name: my-agent
description: What it does and when Claude should invoke it.
tools: Read, Write, Edit, Bash
model: sonnet
---

<role>You are a specialist in...</role>
<workflow>1. Step one 2. Step two</workflow>
<constraints>Never do X. Always do Y.</constraints>
EOF
```

See the `create-subagents` skill for comprehensive guidance.

### Creating Your Own Commands

```bash
cat > ~/.claude/commands/my-command.md << 'EOF'
---
description: What the command does
---

<objective>What to accomplish</objective>
<process>How to do it</process>
<success_criteria>Definition of done</success_criteria>
EOF
```

See the `create-slash-commands` skill for comprehensive guidance.

### Creating Your Own Hooks

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "echo '{\"decision\": \"approve\"}'"
          }
        ]
      }
    ]
  }
}
```

See the `create-hooks` skill for comprehensive guidance.

## Component Reference

### Skill Structure

```
skill-name/
├── SKILL.md              # Main skill file (always loaded)
├── workflows/            # Step-by-step procedures
├── references/           # Domain knowledge
├── templates/            # Output structures
└── scripts/              # Executable code
```

### Agent Structure

```yaml
---
name: agent-name
description: When to use this agent
tools: Read, Write, Edit, Bash  # Optional tool restrictions
model: sonnet                    # sonnet, opus, or haiku
---

<role>Who the agent is</role>
<workflow>How it operates</workflow>
<constraints>Rules and limits</constraints>
<output_format>What it produces</output_format>
```

### Command Structure

```yaml
---
description: What the command does
argument-hint: [optional-args]
allowed-tools: Read, Edit  # Optional tool restrictions
---

<objective>What to accomplish</objective>
<context>Dynamic state loading with !`commands` and @files</context>
<process>Steps to execute</process>
<success_criteria>When it's done</success_criteria>
```

### Hook Events

| Event | When | Can Block? |
|-------|------|------------|
| PreToolUse | Before tool execution | Yes |
| PostToolUse | After tool execution | No |
| UserPromptSubmit | User submits prompt | Yes |
| Stop | Claude attempts to stop | Yes |
| SessionStart | Session begins | No |
| SessionEnd | Session ends | No |

## Best Practices

1. **Start with skills** - They provide guidance without restricting tools
2. **Use agents for automation** - When you want Claude to operate autonomously
3. **Use commands for workflows** - Standardize repeatable operations
4. **Use hooks for safety** - Prevent mistakes, enforce policies

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

## Contributing

1. Fork this repository
2. Add your skill/agent/command/hook
3. Include documentation in the component
4. Submit a PR with usage examples

## Acknowledgments

- **[snarktank](https://github.com/snarktank)** - Ralph autonomous agent pattern and PRD-to-stories workflow
- **[glittercowboy](https://github.com/glittercowboy)** - Inspiration and Claude Code patterns
- **[https://github.com/disler]** - Help with damage control
## License

MIT - Use freely, modify as needed, share with others.
