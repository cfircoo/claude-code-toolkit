---
name: manage-hooks
description: This skill should be used when the user asks to "create a hook", "add a PreToolUse hook", "debug a hook", "fix a hook", "hook not working", or mentions hook configuration, hook events, hook types, automating workflows, or understanding hooks. Provides expert guidance for creating, configuring, debugging, and managing Claude Code hooks.
context: fork
agent: general-purpose
argument-hint: [create|debug|toolkit|guidance] <details>
allowed-tools: Read, Write, Edit, Bash, Glob, Grep
---

<essential_principles>
Hooks are event-driven automation for Claude Code that execute shell commands, LLM prompts, or multi-turn agents in response to tool usage, session events, and user interactions. They provide deterministic control over Claude's behavior without modifying core code.

**1. Three Hook Types:**
- **command** — shell command, deterministic, fast. Exit 0 = proceed, exit 2 = block. JSON stdout for structured control.
- **prompt** — single-turn LLM evaluation (Haiku default). Returns `{"ok": true}` or `{"ok": false, "reason": "..."}`.
- **agent** — multi-turn subagent with tool access (up to 50 turns). Same ok/reason output. Use when verification needs codebase access.

**2. Event → Matcher → Hook** — Events (PreToolUse, Stop, etc.) trigger matchers (regex on tool name/context) which fire hooks. See `<quick_reference>` for the full event table.

**3. Configuration Locations** (highest priority first):
- User-global: `~/.claude/settings.json`
- Project shared: `.claude/settings.json`
- Project local: `.claude/settings.local.json`
- Or use `/hooks` interactive menu in Claude Code

**4. Environment Variables:**
| Variable | Value |
|----------|-------|
| `$CLAUDE_PROJECT_DIR` | Project root directory |
| `${CLAUDE_PLUGIN_ROOT}` | Plugin directory (plugin hooks only) |
| `$ARGUMENTS` | Hook input JSON (prompt/agent hooks only) |
| `$CLAUDE_ENV_FILE` | Path for persisting environment variables |

**5. Safety Essentials:**
- **Stop hook loops**: Always check `stop_hook_active` field in Stop/SubagentStop hooks — exit 0 if true
- **Timeouts**: Set reasonable values in seconds (default: 10 min commands, 60s agents, 30s prompts)
- **Permissions**: `chmod +x` on script files
- **Path safety**: Quote `"$CLAUDE_PROJECT_DIR"` for spaces
- **Shell profiles**: Wrap echo in `~/.zshrc`/`~/.bashrc` with `[[ $- == *i* ]]` checks — non-interactive shells can corrupt JSON output
- **PermissionRequest**: Doesn't fire in headless mode (`-p`); use PreToolUse instead
</essential_principles>

<intake>
What would you like to do?

1. Create a new hook
2. Debug / fix a hook
3. Create a toolkit hook (distributable)
4. Get guidance on hook design

**If `$ARGUMENTS` provides clear intent, skip the menu and route directly.**
</intake>

<routing>
| Response | Intent Phrases | Workflow |
|----------|---------------|----------|
| 1, "create", "add", "build", "set up" | "create a hook", "add a PreToolUse hook", "block rm -rf" | workflows/create-hook.md |
| 2, "debug", "fix", "not working", "broken" | "hook not firing", "debug my hook", "fix hook" | workflows/debug-hook.md |
| 3, "toolkit", "package", "distribute", "install" | "create toolkit hook", "package hook" | workflows/create-toolkit-hook.md |
| 4, "guidance", "help", "recommend", "which" | "which event?", "how do hooks work?", "recommend" | workflows/get-guidance.md |

**Intent-based routing (when `$ARGUMENTS` provides clear intent):**
- "block dangerous commands" → workflows/create-hook.md
- "my hook isn't triggering" → workflows/debug-hook.md
- "package for toolkit" → workflows/create-toolkit-hook.md
- "what event should I use" → workflows/get-guidance.md

**After reading the workflow, follow it exactly.**
</routing>

<quick_reference>
| Event | When it fires | Can block? | Matcher filters |
|-------|---------------|------------|-----------------|
| **PreToolUse** | Before tool execution | Yes | tool name |
| **PostToolUse** | After tool succeeds | Yes (`decision: "block"`) | tool name |
| **PostToolUseFailure** | After tool fails | No | tool name |
| **PermissionRequest** | Permission dialog appears | Yes | tool name |
| **UserPromptSubmit** | User submits a prompt | Yes | no matcher support |
| **Stop** | Claude finishes responding | Yes | no matcher support |
| **SubagentStart** | Subagent is spawned | No | agent type |
| **SubagentStop** | Subagent finishes | Yes | agent type |
| **SessionStart** | Session begins/resumes | No | source (`startup`, `resume`, `clear`, `compact`) |
| **SessionEnd** | Session terminates | No | reason (`clear`, `logout`, etc.) |
| **PreCompact** | Before context compaction | No | trigger (`manual`, `auto`) |
| **Notification** | Claude needs attention | No | type (`permission_prompt`, `idle_prompt`, etc.) |
| **TeammateIdle** | Agent about to go idle | Yes (exit 2) | no matcher support |
| **TaskCompleted** | Task marked complete | Yes (exit 2) | no matcher support |
| **ConfigChange** | Config file changes | Yes (`decision: "block"`) | config type |

See [references/hook-types.md](references/hook-types.md) for detailed schemas and use cases for each event.
</quick_reference>

<reference_index>
All in `references/`:

**Types & Events:** hook-types.md — complete event schemas and use cases
**Hook Types:** command-vs-prompt.md — decision tree for command vs prompt vs agent
**Matchers:** matchers.md — regex patterns, event-specific matching, MCP tools
**I/O Schemas:** input-output-schemas.md — stdin JSON, exit codes, hookSpecificOutput
**Examples:** examples.md — notifications, file protection, auto-format, logging, Stop hooks
**Troubleshooting:** troubleshooting.md — hooks not triggering, JSON corruption, loops
**Toolkit:** toolkit-structure.md — distributable hook packaging for claude-code-toolkit
</reference_index>

<workflows_index>
All in `workflows/`:

| Workflow | Purpose |
|----------|---------|
| create-hook.md | Build a hook from scratch |
| debug-hook.md | Diagnose and fix broken hooks |
| create-toolkit-hook.md | Package hook for toolkit distribution |
| get-guidance.md | Help decide event, type, and matcher |
</workflows_index>

<success_criteria>
A working hook configuration has:

- Valid JSON in the appropriate settings file (validated with `jq`)
- Appropriate hook event selected for the use case
- Correct matcher pattern matching target tools/contexts
- Command, prompt, or agent that executes without errors
- Proper output (exit codes for commands, ok/reason for prompts/agents)
- Tested with `--debug` flag or `Ctrl+O` verbose mode showing expected behavior
- No infinite loops in Stop/SubagentStop hooks (checks `stop_hook_active` flag)
- Reasonable timeout set in seconds
- Executable permissions on script files
- No shell profile interference with JSON output
</success_criteria>
