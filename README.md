# Claude Code Toolkit

A curated collection of skills, agents, commands, and hooks to supercharge your Claude Code experience. Copy what you need to `~/.claude/` and start using immediately.

## Quick Start

```bash
# Clone the toolkit
git clone https://github.com/YOUR_USERNAME/claude-code-toolkit.git

# Copy everything to your Claude Code config
cp -r claude-code-toolkit/skills/* ~/.claude/skills/
cp -r claude-code-toolkit/agents/* ~/.claude/agents/
cp -r claude-code-toolkit/commands/* ~/.claude/commands/
cp claude-code-toolkit/hooks.json ~/.claude/hooks.json
cp claude-code-toolkit/statusline.sh ~/.claude/statusline.sh
chmod +x ~/.claude/statusline.sh

# Or copy selectively - pick only what you need
cp -r claude-code-toolkit/skills/git ~/.claude/skills/
cp claude-code-toolkit/agents/git-ops.md ~/.claude/agents/
```

## What's Included

### Skills (11)

Skills are modular capabilities that provide domain expertise on demand. They live in `~/.claude/skills/`.

| Skill | Description | Use When |
|-------|-------------|----------|
| **git** | Git operations with safety protocols | Committing, pushing, creating PRs |
| **pytest-best-practices** | Expert pytest patterns | Writing tests, fixtures, mocking |
| **sqlalchemy-postgres** | SQLAlchemy 2.0 + Pydantic + PostgreSQL | Database layers, models, migrations |
| **debug-like-expert** | Methodical debugging with hypothesis testing | Complex bugs that resist standard fixes |
| **create-plans** | Hierarchical project planning | Planning projects for solo dev + Claude |
| **spec-interview** | Interview-driven specification building | Starting new projects, defining requirements |
| **create-subagents** | Guide to creating custom subagents | Building specialized agents |
| **create-hooks** | Guide to creating event hooks | Automating workflows, validations |
| **create-slash-commands** | Guide to creating slash commands | Building reusable command prompts |
| **create-agent-skills** | Guide to creating skills | Building modular capabilities |
| **create-meta-prompts** | Claude-to-Claude pipeline prompts | Multi-stage workflows (research -> plan -> implement) |

### Agents (7)

Agents are specialized Claude instances that run autonomously in isolated contexts. They live in `~/.claude/agents/`.

| Agent | Description | Triggered By |
|-------|-------------|--------------|
| **git-ops** | Commits, pushes, and creates PRs safely | "commit my changes", "create a PR" |
| **db-expert** | SQLAlchemy 2.0 database implementation | Database-related tasks |
| **pytest-writer** | Writes high-quality pytest tests | "write tests for...", "add test coverage" |
| **fullstack-manager** | Orchestrates frontend builds from APIs | Building frontends from backend APIs |
| **fullstack-api-specialist** | Maps API endpoints and schemas | API discovery and documentation |
| **fullstack-ui-designer** | Creates distinctive UI components | Frontend component design |
| **fullstack-qa-debugger** | Validates integrations and catches errors | Testing and debugging frontends |

### Commands (6)

Commands are slash-invoked prompts for common operations. They live in `~/.claude/commands/`.

| Command | Description | Usage |
|---------|-------------|-------|
| `/commit` | Stage and commit with proper message format | `/commit` |
| `/push` | Push commits to remote | `/push` |
| `/pr` | Create a pull request | `/pr` |
| `/ship` | Full workflow: commit + push + PR | `/ship` |
| `/db` | Database operations | `/db setup`, `/db model User`, `/db migration` |
| `/spec-interview` | Build project specification through interview | `/spec-interview my-project` |

### Hooks (1)

Hooks are event-driven automation scripts. Configuration lives in `~/.claude/hooks.json`.

| Hook | Trigger | Description |
|------|---------|-------------|
| **pre-commit-pytest** | Before git commit/push | Runs pytest, blocks if tests fail |

### Extras

| File | Description |
|------|-------------|
| **statusline.sh** | Custom terminal status line showing model, directory, git branch, context usage with visual progress bar, and last user prompt |
| **settings.json** | Example settings with statusline and Playwright plugin enabled |

## Installation Options

### Option 1: Full Installation

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
#     "command": "~/.claude/statusline.sh"
#   }
# }
```

### Option 2: Selective Installation

Pick only what you need:

```bash
# Just git workflow
cp -r skills/git ~/.claude/skills/
cp agents/git-ops.md ~/.claude/agents/
cp commands/{commit,push,pr,ship}.md ~/.claude/commands/

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

### Option 3: Project-Level

For project-specific use, copy to `.claude/` in your project:

```bash
mkdir -p .claude/{skills,agents,commands}
cp -r ~/claude-code-toolkit/skills/git .claude/skills/
cp ~/claude-code-toolkit/agents/git-ops.md .claude/agents/
```

## Usage Examples

### Git Workflow

```
> /commit
# Claude analyzes changes, creates commit with proper message format

> /ship
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

## License

MIT - Use freely, modify as needed, share with others.
