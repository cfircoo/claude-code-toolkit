# Delegate-First Hook

Reminds Claude to check for subagents and skills before starting tasks, keeping context clean and leveraging specialized capabilities.

## What It Does

Adds a suffix to every user prompt reminding Claude to:
- Check if there's a subagent (Task tool) that fits the task
- Check if there's a skill that can handle the task
- Delegate when appropriate to keep context clean

## Why Use This

- **Cleaner context**: Subagents run in isolation, preventing context bloat
- **Specialized capabilities**: Each agent is optimized for its task
- **Better results**: Agents like Explore, Plan, and pytest-writer have focused prompts

## Available Subagents

| Agent | Use For |
|-------|---------|
| Explore | Codebase exploration, finding files, understanding structure |
| Plan | Design decisions, architecture planning |
| git-ops | Commits, pushes, PRs |
| pytest-writer | Writing pytest tests |
| perplexity-research | Web research |
| db-expert | SQLAlchemy/PostgreSQL work |

## Installation

```bash
./hooks/delegate-first/install.sh
```

Or via the main installer:
```bash
./install-linux.sh  # or install-mac.sh
```

## Restart Required

After installation, restart Claude Code for the hook to take effect.
