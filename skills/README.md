# Skills

Skills are modular capabilities that provide domain expertise on demand. When invoked, Claude loads the skill's `SKILL.md` and follows its guidance.

## Available Skills

### Development Workflows

| Skill | Description |
|-------|-------------|
| [git](git/) | Git operations with safety protocols - committing, pushing, PRs |
| [pytest-best-practices](pytest-best-practices/) | Expert pytest patterns for writing maintainable tests |
| [sqlalchemy-postgres](sqlalchemy-postgres/) | SQLAlchemy 2.0 + Pydantic + PostgreSQL database layers |
| [debug-like-expert](debug-like-expert/) | Methodical debugging with hypothesis testing |

### Project Management

| Skill | Description |
|-------|-------------|
| [create-plans](create-plans/) | Hierarchical project planning for solo dev + Claude |
| [spec-interview](spec-interview/) | Interview-driven specification building |
| [create-meta-prompts](create-meta-prompts/) | Claude-to-Claude pipeline prompts |

### Creating Claude Code Extensions

| Skill | Description |
|-------|-------------|
| [create-agent-skills](create-agent-skills/) | Guide to creating skills |
| [create-subagents](create-subagents/) | Guide to creating custom subagents |
| [create-slash-commands](create-slash-commands/) | Guide to creating slash commands |
| [create-hooks](create-hooks/) | Guide to creating event hooks |

## Installation

```bash
# Copy all skills
cp -r skills/* ~/.claude/skills/

# Or copy specific skills
cp -r skills/git ~/.claude/skills/
cp -r skills/pytest-best-practices ~/.claude/skills/
```

## Usage

Skills are invoked automatically when Claude detects a relevant task, or explicitly:

```
> Use the git skill for committing
> Apply the debug-like-expert skill to investigate this error
> Use create-plans to plan my project
```

## Skill Structure

Each skill follows this structure:

```
skill-name/
├── SKILL.md              # Main skill file (always loaded)
├── workflows/            # Step-by-step procedures
├── references/           # Domain knowledge
├── templates/            # Output structures
└── scripts/              # Executable code
```

### SKILL.md Format

```yaml
---
name: skill-name
description: What it does and when to use it.
---

<objective>What this skill accomplishes</objective>
<quick_start>Immediate actionable guidance</quick_start>
<process>Step-by-step procedure</process>
<success_criteria>How to know it worked</success_criteria>
```

## Creating Your Own

Use the `create-agent-skills` skill for comprehensive guidance:

```
> Use the create-agent-skills skill to create a new skill
```

Or manually:

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
