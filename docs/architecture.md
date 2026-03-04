# Architecture Overview

Understanding the Claude Code Toolkit structure and component relationships.

## System Architecture

The toolkit provides a modular system of extensions for Claude Code, organized into four main component types:

```
Claude Code
    │
    ├── Skills (18)
    │   ├── Domain expertise
    │   ├── Workflows & references
    │   └── Modular capabilities
    │
    ├── Agents (12)
    │   ├── Autonomous specialists
    │   ├── Isolated contexts
    │   └── Task automation
    │
    ├── Commands (12)
    │   ├── Slash-invoked prompts
    │   ├── Common operations
    │   └── Quick access
    │
    └── Hooks (5)
        ├── Event-driven automation
        ├── Security & validation
        └── Workflow automation
```

## Component Types

### Skills

**What they are:** Modular capabilities that provide domain expertise on demand.

**Key characteristics:**
- Filesystem-based (live in `~/.claude/skills/`)
- Auto-discovered by Claude Code
- Can be invoked explicitly or triggered automatically
- Contain reusable knowledge and workflows
- Follow the [Agent Skills](https://agentskills.io) open standard

**Structure:**
```
skill-name/
├── SKILL.md              # Main skill file (always loaded)
├── workflows/            # Step-by-step procedures
├── references/           # Domain knowledge
├── templates/            # Output structures
└── scripts/              # Executable code
```

**Example usage:**
```
> Use the git skill to commit my changes
> Apply debug-like-expert to investigate this error
```

### Agents

**What they are:** Specialized Claude instances that run autonomously in isolated contexts.

**Key characteristics:**
- Invoked via the Task tool
- Run in isolated contexts (no conversation history)
- Return results to main conversation
- Can have tool restrictions
- Support different models (haiku, sonnet, opus)

**YAML structure:**
```yaml
---
name: agent-name
description: When to use this agent (used for auto-triggering)
tools: Read, Write, Edit, Bash  # Optional tool restrictions
model: sonnet                     # sonnet, opus, haiku, or inherit
color: blue                       # Optional UI color
---

<role>Who the agent is</role>
<workflow>How it operates</workflow>
<constraints>Rules and limits</constraints>
```

**Example usage:**
```
> Commit my changes
# Triggered automatically (matches git-ops description)

> Use the db-expert agent to set up models
# Explicit invocation
```

### Commands

**What they are:** Slash-invoked prompts for common operations.

**Key characteristics:**
- Invoked with `/command-name` in chat
- Expand as prompts in current conversation
- Can have dynamic context loading
- Support argument passing
- Can restrict available tools

**YAML structure:**
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

**Example usage:**
```
> /git-commit
> /db setup
> /spec-interview my-new-app
```

### Hooks

**What they are:** Event-driven automation scripts that execute in response to Claude Code events.

**Key characteristics:**
- Configured in `hooks.json`
- Execute before/after tools or events
- Can block operations (PreToolUse, UserPromptSubmit, Stop)
- Support command execution or LLM-based decisions
- Can match specific tools or patterns

**Hook events:**
- `PreToolUse` — Before tool execution (can block)
- `PostToolUse` — After tool execution
- `UserPromptSubmit` — User submits prompt (can block)
- `Stop` — Claude attempts to stop (can block)
- `SessionStart` — Session begins
- `SessionEnd` — Session ends

**Example:**
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pre-commit-pytest.sh"
          }
        ]
      }
    ]
  }
}
```

## Component Relationships

### Skill Invocation Flow

```
User Request
    │
    ├─> Claude detects task
    │
    ├─> Matches against Skill descriptions
    │
    ├─> Loads SKILL.md
    │
    ├─> Routes to appropriate workflow/reference
    │
    └─> Executes with available tools
```

### Agent Invocation Flow

```
User Request / Auto-trigger
    │
    ├─> Matches against Agent description
    │
    ├─> Creates isolated task context
    │
    ├─> Applies tool restrictions
    │
    ├─> Runs in parallel (non-blocking)
    │
    └─> Returns results to conversation
```

### Command Invocation Flow

```
/command-name [args]
    │
    ├─> Loads command markdown
    │
    ├─> Expands dynamic context (!commands, @files)
    │
    ├─> Passes $ARGUMENTS to prompt
    │
    └─> Executes in current conversation
```

### Hook Execution Flow

```
Tool Use / Event
    │
    ├─> Pre-hook checks (PreToolUse, UserPromptSubmit, Stop)
    │
    ├─> Match tool/event against hook matchers
    │
    ├─> Execute hook (command or prompt)
    │
    ├─> Return decision (approve/block)
    │
    ├─> Continue or block operation
    │
    └─> Post-hook triggers (PostToolUse, SessionEnd)
```

## Skill Categories

### Development & Testing (4)
- **git** — Version control operations
- **pytest-best-practices** — Test writing guidance
- **sqlalchemy-postgres** — Database layer patterns
- **debug-like-expert** — Debugging methodology

### Project Management (3)
- **create-plans** — Hierarchical planning
- **spec-interview** — Specification building
- **create-meta-prompts** — Multi-stage workflows

### Content & Automation (2)
- **generate-images** — Image generation
- **generate-prd** — Product requirement docs

### Orchestration (2)
- **ralph-orchestrator** — Autonomous execution loop
- **ralph-convert-prd** — Story decomposition

### Extension Development (4)
- **manage-skills** — Skill creation guide
- **manage-subagents** — Agent creation guide
- **manage-slash-commands** — Command creation guide
- **manage-hooks** — Hook creation guide

### Utilities (2)
- **docs-master** — Documentation creation
- **file-search** — Advanced search

### Security (1)
- **damage-control** — Safety mechanisms

## Agent Categories

### Development (6)
- **git-ops** — Git automation
- **db-expert** — Database implementation
- **pytest-writer** — Test generation
- **perplexity-research** — Web research
- **ralph-coder** — Feature implementation
- **ralph-tester** — Verification & testing

### Fullstack (4)
- **fullstack-manager** — Frontend orchestration
- **fullstack-api-specialist** — API mapping
- **fullstack-ui-designer** — Component design
- **fullstack-qa-debugger** — Integration testing

### Utilities (2)
- **docs-master** — Documentation specialist
- **file-search** — Search specialist

## Data Flow

### Settings Management

Configuration stored in `~/.claude/settings.json`:

```json
{
  "statusLine": {...},
  "env": {
    "ENABLE_TOOL_SEARCH": "true",
    "PERPLEXITY_API_KEY": "...",
    "GEMINI_API_KEY": "..."
  }
}
```

### Hook Configuration

Hooks configured in `~/.claude/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [...],
    "PostToolUse": [...],
    "UserPromptSubmit": [...]
  }
}
```

### Skill Discovery

Claude Code discovers skills by:
1. Scanning `~/.claude/skills/` (user-level)
2. Scanning `.claude/skills/` (project-level)
3. Reading YAML frontmatter from `SKILL.md` files
4. Matching skill descriptions to user tasks

### Agent Discovery

Claude Code discovers agents by:
1. Scanning `~/.claude/agents/` (user-level)
2. Scanning `.claude/agents/` (project-level)
3. Reading YAML frontmatter from `.md` files
4. Matching agent descriptions to tasks

### Command Discovery

Claude Code discovers commands by:
1. Scanning `~/.claude/commands/` (user-level)
2. Scanning `.claude/commands/` (project-level)
3. Reading YAML frontmatter from `.md` files
4. Showing in `/help` menu

## Tool Restrictions

Components can restrict which tools Claude can use:

```yaml
---
allowed-tools: Read, Write, Edit, Bash  # Whitelist
---
```

Or with patterns:

```yaml
allowed-tools: Bash(git *), Bash(npm *)  # Only git and npm commands
```

Available tools:
- `Read` — File reading
- `Write` — File writing
- `Edit` — File editing
- `Bash` — Shell commands
- `Glob` — File pattern matching
- `Grep` — Content search
- `Skill(name)` — Specific skill invocation

## Security Architecture

### Damage Control Hooks

Multi-layer protection via `damage-control` skill:

1. **Bash Tool** — Blocks dangerous commands
   - `rm -rf`, `git reset --hard`
   - Cloud CLI destructive ops
   - Git branch protection (blocks direct main/master pushes)

2. **Read Tool** — Blocks sensitive files
   - `.env`, `credentials.json`
   - SSH keys, certificates

3. **Write Tool** — Blocks protected paths
   - System directories
   - Lock files

4. **Edit Tool** — Blocks protected files
   - License, readme, CI/CD config

### Git Branch Protection

- Blocks `git commit` and `git push` on `main`/`master`
- Allows tag pushes (`git push origin v*`)
- Requires explicit remote/branch specification for push

## Execution Models

### Inline Execution (Skills)

Skills run inline with conversation context:
- Full conversation history available
- Interactive with user
- Can ask clarifying questions

### Isolated Execution (Agents)

Agents run in isolated task contexts:
- No conversation history
- Non-blocking (run in parallel)
- Return results to conversation
- Can have custom models and tool restrictions

### Subprocess Execution (Hooks)

Hooks run as subprocesses:
- Can block operations
- Command-based or LLM-based decisions
- Can access environment variables and file system

## Integration Points

### With Claude Code

- Extensions loaded by Claude Code runtime
- Triggering via user intent detection
- Tool availability depends on permissions
- Settings merged with user configuration

### With External Services

- **Perplexity API** — Web research via `perplexity-research` agent
- **Gemini API** — Image generation via `generate-images` skill
- **GitHub CLI** — Git operations via `git` skill and `git-ops` agent

### With File System

- Skills: `~/.claude/skills/`
- Agents: `~/.claude/agents/`
- Commands: `~/.claude/commands/`
- Hooks: `~/.claude/hooks/` + `hooks.json`
- Scripts: `~/.claude/scripts/`
- Settings: `~/.claude/settings.json`
- Statusline: `~/.claude/statusline.sh`

## Performance Considerations

### Lazy Loading

- `ENABLE_TOOL_SEARCH` environment variable
- Tools load on-demand instead of all at once
- Saves context tokens

### Progressive Disclosure

- SKILL.md loads immediately
- Workflows and references load on request
- Templates and scripts referenced as needed

### Parallel Execution

- Agents run non-blocking
- Multiple agents can execute simultaneously
- Results streamed back to conversation

## Extension Points

Developers can extend the toolkit by:

1. **Creating custom skills** — Add domain expertise
2. **Creating custom agents** — Automate specialized tasks
3. **Creating custom commands** — Add slash-invoked operations
4. **Creating custom hooks** — Add validation or automation
5. **Writing custom scripts** — Reusable utilities

See [manage-skills](skills/manage-skills.md), [manage-subagents](skills/manage-subagents.md), [manage-slash-commands](skills/manage-slash-commands.md), and [manage-hooks](skills/manage-hooks.md) for guidance.
