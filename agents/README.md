# Agents

Agents are specialized Claude instances that run autonomously in isolated contexts. They're invoked via the Task tool and return their results to the main conversation.

## Available Agents

### Development

| Agent | Model | Description |
|-------|-------|-------------|
| [git-ops](git-ops.md) | Sonnet | Commits, pushes, and creates PRs with safety protocols |
| [db-expert](db-expert.md) | Sonnet | SQLAlchemy 2.0 + Pydantic + PostgreSQL implementation |
| [pytest-writer](pytest-writer.md) | Sonnet | Writes high-quality pytest tests |

### Fullstack Development

| Agent | Model | Description |
|-------|-------|-------------|
| [fullstack-manager](fullstack-manager.md) | Opus | Orchestrates frontend builds from backend APIs |
| [fullstack-api-specialist](fullstack-api-specialist.md) | - | Maps API endpoints and schemas |
| [fullstack-ui-designer](fullstack-ui-designer.md) | - | Creates distinctive UI components |
| [fullstack-qa-debugger](fullstack-qa-debugger.md) | - | Validates integrations and catches errors |

## Installation

```bash
# Copy all agents
cp agents/*.md ~/.claude/agents/

# Or copy specific agents
cp agents/git-ops.md ~/.claude/agents/
cp agents/db-expert.md ~/.claude/agents/
```

## Usage

Agents are triggered automatically based on their `description` field, or explicitly:

```
> Commit my changes
# git-ops agent handles it

> Write tests for src/utils.py
# pytest-writer agent handles it

> Use the db-expert agent to set up the database layer
# Explicit invocation
```

## Agent Structure

```yaml
---
name: agent-name
description: When to use this agent (used for auto-triggering)
tools: Read, Write, Edit, Bash  # Optional tool restrictions
model: sonnet                    # sonnet, opus, or haiku
color: blue                      # Optional UI color
---

<role>Who the agent is</role>
<workflow>How it operates</workflow>
<constraints>Rules and limits</constraints>
<output_format>What it produces</output_format>
```

### Key Fields

| Field | Purpose |
|-------|---------|
| `name` | Unique identifier (lowercase-with-hyphens) |
| `description` | When Claude should invoke this agent |
| `tools` | Restrict available tools (inherits all if omitted) |
| `model` | `sonnet`, `opus`, `haiku`, or `inherit` |

## Creating Your Own

Use the `create-subagents` skill for comprehensive guidance:

```
> Use the create-subagents skill to create a new agent
```

Or manually:

```bash
cat > ~/.claude/agents/my-agent.md << 'EOF'
---
name: my-agent
description: What it does and when Claude should invoke it.
tools: Read, Write, Edit, Bash
model: sonnet
---

<role>You are a specialist in...</role>
<workflow>
1. Step one
2. Step two
</workflow>
<constraints>
- Never do X
- Always do Y
</constraints>
EOF
```

## Important Notes

- Agents run in **isolated contexts** - they cannot interact with users
- Agents return their **final output** to the main conversation
- Use agents for autonomous tasks that don't need user input during execution
- The main conversation handles user interaction, agents handle work
