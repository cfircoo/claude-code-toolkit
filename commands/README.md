# Commands

Commands are slash-invoked prompts for common operations. They expand as prompts in the current conversation when invoked with `/command-name`.

## Available Commands

| Command | Description | Usage |
|---------|-------------|-------|
| [commit](commit.md) | Stage and commit with proper message format | `/commit` |
| [push](push.md) | Push commits to remote | `/push` |
| [pr](pr.md) | Create a pull request | `/pr` |
| [ship](ship.md) | Full workflow: commit + push + PR | `/ship` |
| [db](db.md) | Database operations | `/db setup`, `/db model User` |
| [spec-interview](spec-interview.md) | Build project specification | `/spec-interview my-project` |

## Installation

```bash
# Copy all commands
cp commands/*.md ~/.claude/commands/

# Or copy specific commands
cp commands/{commit,push,pr,ship}.md ~/.claude/commands/
```

## Usage

Invoke with slash prefix:

```
> /commit
# Analyzes changes and creates commit

> /ship
# Full workflow: commit -> push -> create PR

> /db setup
# Initialize database layer

> /spec-interview my-new-app
# Start specification interview
```

## Command Structure

```yaml
---
description: What the command does
argument-hint: [optional-args]
allowed-tools: Read, Edit  # Optional tool restrictions
---

<objective>What to accomplish</objective>
<context>Dynamic state loading</context>
<process>Steps to execute</process>
<success_criteria>When it's done</success_criteria>
```

### Key Fields

| Field | Purpose |
|-------|---------|
| `description` | What the command does (shown in `/help`) |
| `argument-hint` | Hint for arguments (e.g., `[file-path]`) |
| `allowed-tools` | Restrict available tools |

### Dynamic Context

Commands can load dynamic context:

```markdown
## Context
- Git status: !`git status`
- Current branch: !`git branch --show-current`
- Package info: @package.json
```

### Arguments

Use `$ARGUMENTS` for all arguments or `$1`, `$2` for positional:

```markdown
Fix issue #$ARGUMENTS following coding standards

# Or positional
Review PR #$1 with priority $2
```

## Creating Your Own

Use the `create-slash-commands` skill for comprehensive guidance:

```
> Use the create-slash-commands skill to create a new command
```

Or manually:

```bash
cat > ~/.claude/commands/my-command.md << 'EOF'
---
description: What the command does
---

<objective>What to accomplish</objective>
<process>
1. Step one
2. Step two
</process>
<success_criteria>Definition of done</success_criteria>
EOF
```

## Tips

- Commands expand as prompts - they guide Claude but don't restrict tools by default
- Use `allowed-tools` to restrict what Claude can do (e.g., git-only commands)
- Use dynamic context (`!` commands) for state-dependent operations
- Use file references (`@`) to include specific files in context
