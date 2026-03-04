# Matchers and Pattern Matching

Complete guide to matching tools and contexts with hook matchers.

## What are matchers?

Matchers are regex patterns that filter when a hook fires. Each event type matches on a different field:

| Event | What matcher filters | Example values |
|-------|---------------------|----------------|
| `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PermissionRequest` | tool name | `Bash`, `Edit\|Write`, `mcp__.*` |
| `SessionStart` | how the session started | `startup`, `resume`, `clear`, `compact` |
| `SessionEnd` | why the session ended | `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other` |
| `Notification` | notification type | `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog` |
| `SubagentStart`, `SubagentStop` | agent type | `Bash`, `Explore`, `Plan`, or custom agent names |
| `PreCompact` | what triggered compaction | `manual`, `auto` |
| `ConfigChange` | config type | `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills` |
| `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted` | **no matcher support** | always fires on every occurrence |

---

## Syntax

Matchers use JavaScript regex syntax:

```json
{
  "matcher": "pattern"
}
```

The pattern is tested against the matched field using `new RegExp(pattern).test(value)`.

---

## Tool Name Patterns

### Exact match
```json
{
  "matcher": "Bash"
}
```
Matches: `Bash`
Doesn't match: `bash`, `BashOutput`

### Multiple tools (OR)
```json
{
  "matcher": "Write|Edit"
}
```
Matches: `Write`, `Edit`
Doesn't match: `Read`, `Bash`

### Starts with
```json
{
  "matcher": "^Bash"
}
```
Matches: `Bash`, `BashOutput`
Doesn't match: `Read`

### Ends with
```json
{
  "matcher": "Output$"
}
```
Matches: `BashOutput`
Doesn't match: `Bash`, `Read`

### Contains
```json
{
  "matcher": ".*write.*"
}
```
Matches: `Write`, `NotebookWrite`, `TodoWrite`
Doesn't match: `Read`, `Edit`

Case-sensitive! `write` won't match `Write`.

### Any tool (no matcher)
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "hooks": [...]  // No matcher = matches all tools
      }
    ]
  }
}
```

---

## Session and Context Patterns

### SessionStart — match source
```json
{"matcher": "startup"}     // Fresh session start
{"matcher": "resume"}      // Resumed session
{"matcher": "clear"}       // After /clear command
{"matcher": "compact"}     // After context compaction
```

**Common use**: Re-inject critical context after compaction:
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing.'"
          }
        ]
      }
    ]
  }
}
```

### SessionEnd — match reason
```json
{"matcher": "clear"}                      // User ran /clear
{"matcher": "logout"}                     // User logged out
{"matcher": "prompt_input_exit"}          // User exited at prompt
```

### Notification — match type
```json
{"matcher": "permission_prompt"}   // Permission dialog shown
{"matcher": "idle_prompt"}         // Claude idle, waiting for input
{"matcher": "auth_success"}        // Authentication succeeded
{"matcher": "elicitation_dialog"}  // Elicitation dialog shown
```

### PreCompact — match trigger
```json
{"matcher": "manual"}   // User triggered /compact
{"matcher": "auto"}     // Automatic compaction
```

### SubagentStart/SubagentStop — match agent type
```json
{"matcher": "Bash"}      // Bash subagent
{"matcher": "Explore"}   // Explore subagent
{"matcher": "Plan"}      // Plan subagent
```

### ConfigChange — match config type
```json
{"matcher": "user_settings"}      // ~/.claude/settings.json
{"matcher": "project_settings"}   // .claude/settings.json
{"matcher": "skills"}             // Skill files
```

---

## MCP Tool Matching

MCP tools follow the pattern: `mcp__{server}__{tool}`

Examples:
- `mcp__memory__store`
- `mcp__filesystem__read`
- `mcp__github__create_issue`

**Match all MCP tools**:
```json
{"matcher": "mcp__.*"}
```

**Match all tools from a server**:
```json
{"matcher": "mcp__github__.*"}
```

**Match specific tool across all servers**:
```json
{"matcher": "mcp__.*__read.*"}
```

**Match write operations across servers**:
```json
{"matcher": "mcp__.*__write.*"}
```

---

## Tool Categories

### All file operations
```json
{"matcher": "Read|Write|Edit|Glob|Grep"}
```

### All bash tools
```json
{"matcher": "Bash.*"}
```
Matches: `Bash`, `BashOutput`, `BashKill`

### All MCP tools
```json
{"matcher": "mcp__.*"}
```

### Specific MCP server
```json
{"matcher": "mcp__memory__.*"}
```

---

## Real-World Examples

### Log all bash commands
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> ~/.claude/command-log.txt"
          }
        ]
      }
    ]
  }
}
```

### Format code after any file write
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit|NotebookEdit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write"
          }
        ]
      }
    ]
  }
}
```

### Log all GitHub MCP tool calls
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__github__.*",
        "hooks": [
          {
            "type": "command",
            "command": "echo \"GitHub tool called: $(jq -r '.tool_name')\" >&2"
          }
        ]
      }
    ]
  }
}
```

### Clean up on /clear
```json
{
  "hooks": {
    "SessionEnd": [
      {
        "matcher": "clear",
        "hooks": [
          {
            "type": "command",
            "command": "rm -f /tmp/claude-scratch-*.txt"
          }
        ]
      }
    ]
  }
}
```

---

## Multiple Matchers

You can have multiple matcher blocks for the same event. Each is evaluated independently:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {"type": "command", "command": "/path/to/bash-validator.sh"}
        ]
      },
      {
        "matcher": "Write|Edit",
        "hooks": [
          {"type": "command", "command": "/path/to/file-validator.sh"}
        ]
      },
      {
        "matcher": "mcp__.*",
        "hooks": [
          {"type": "command", "command": "/path/to/mcp-logger.sh"}
        ]
      }
    ]
  }
}
```

A tool can match multiple matcher blocks. Matching hooks across different blocks run in parallel.

---

## Debugging Matchers

### Enable debug mode
```bash
claude --debug
```

Debug output shows:
```
[DEBUG] Getting matching hook commands for PreToolUse with query: Bash
[DEBUG] Found 3 hook matchers in settings
[DEBUG] Matched 1 hooks for query "Bash"
```

### Test your matcher

```bash
node -e "console.log(/mcp__memory__.*/.test('mcp__memory__store'))"
```

### Common mistakes

**Case sensitivity**:
```json
{"matcher": "bash"}   // Won't match "Bash"
{"matcher": "Bash"}   // Correct
```

**Missing escape for regex wildcard**:
```json
{"matcher": "mcp__memory__*"}    // * is literal, not wildcard
{"matcher": "mcp__memory__.*"}   // .* is regex "any characters"
```

**Unintended partial match**:
```json
{"matcher": "Write"}     // Matches "Write", "TodoWrite", "NotebookWrite"
{"matcher": "^Write$"}   // Matches only "Write"
```

---

## Advanced Patterns

### Negative lookahead (exclude tools)
```json
{"matcher": "^(?!Read).*"}
```
Matches: Everything except `Read`

### Match any file operation except Grep
```json
{"matcher": "^(Read|Write|Edit|Glob)$"}
```

### Case-insensitive match
```json
{"matcher": "(?i)bash"}
```
Matches: `Bash`, `bash`, `BASH`

(Note: Claude Code tools are PascalCase by convention, so this is rarely needed)

---

## Performance Considerations

**Broad matchers** (e.g., no matcher or `.*`) run on every tool use:
- Simple command hooks: negligible impact
- Prompt/agent hooks: can slow down significantly

**Recommendation**: Be as specific as possible with matchers to minimize unnecessary hook executions.

Instead of matching all tools and checking inside the hook:
```json
{"matcher": ".*", "hooks": [{"type": "command", "command": "if [[ $(jq -r '.tool_name') == 'Bash' ]]; then ...; fi"}]}
```

Do this:
```json
{"matcher": "Bash", "hooks": [{"type": "command", "command": "..."}]}
```

---

## Tool Name Reference

Common Claude Code tool names:
- `Bash`
- `BashOutput`
- `KillShell`
- `Read`
- `Write`
- `Edit`
- `Glob`
- `Grep`
- `TodoWrite`
- `NotebookEdit`
- `WebFetch`
- `WebSearch`
- `Task`
- `Skill`
- `SlashCommand`
- `AskUserQuestion`
- `ExitPlanMode`

MCP tools: `mcp__{server}__{tool}` (varies by installed servers)

Run `claude --debug` and watch tool calls to discover available tool names.
