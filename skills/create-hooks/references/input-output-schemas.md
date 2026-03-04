# Input/Output Schemas

Complete JSON schemas for all hook types.

## Common Input Fields

All hooks receive these fields via stdin as JSON:

```typescript
{
  session_id: string           // Unique session identifier
  transcript_path: string      // Path to session transcript (.jsonl file)
  cwd: string                  // Current working directory
  permission_mode: string      // "default" | "plan" | "acceptEdits" | "dontAsk" | "bypassPermissions"
  hook_event_name: string      // Name of the hook event
}
```

---

## Exit Code Behavior (Command Hooks)

Command hooks communicate results via exit codes:

| Exit code | Behavior | Output channel |
|-----------|----------|----------------|
| **0** | Action proceeds | Stdout: added to context for `UserPromptSubmit`/`SessionStart`; or parsed as JSON for structured control |
| **2** | Action blocked | Stderr: message sent to Claude as feedback |
| **Other** | Action proceeds | Stderr: logged (visible in verbose mode `Ctrl+O`) |

**Simple blocking** (exit 2 + stderr):
```bash
echo "Blocked: dropping tables is not allowed" >&2
exit 2
```

**Structured control** (exit 0 + JSON stdout):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "Use rg instead of grep"
  },
  "systemMessage": "Message for Claude"
}
```

**Important**: Don't mix exit 2 with JSON output. Claude Code ignores JSON when you exit 2.

---

## PreToolUse

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm install",
    "description": "Install dependencies"
  }
}
```

**Output — structured JSON** (exit 0):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Why this permission decision",
    "updatedInput": {
      "command": "npm install --save-exact"
    }
  },
  "systemMessage": "Message displayed to Claude",
  "suppressOutput": false,
  "continue": true
}
```

**Fields**:
- `permissionDecision`: `"allow"` (proceed, skip permission prompt), `"deny"` (cancel, send reason to Claude), `"ask"` (show normal permission prompt)
- `permissionDecisionReason`: Explanation fed back to Claude (required if denying)
- `updatedInput`: Modified tool input (partial update — only specify fields to change)
- `systemMessage`: Context added to Claude's next message
- `suppressOutput`: Hide hook output from user
- `continue`: If false, stop execution

---

## PostToolUse

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.js",
    "content": "const x = 1;"
  },
  "tool_response": {
    "filePath": "/path/to/file.js",
    "success": true
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

**Output** (optional):
```json
{
  "decision": "block",
  "reason": "Explanation shown to Claude",
  "hookSpecificOutput": {
    "hookEventName": "PostToolUse",
    "additionalContext": "Additional information for Claude",
    "updatedMCPToolOutput": "Replacement output (MCP tools only)"
  }
}
```

**Fields**:
- `decision`: `"block"` to prompt Claude with the reason (tool already executed)
- `reason`: Explanation shown to Claude when blocking
- `additionalContext`: Additional context for Claude
- `updatedMCPToolOutput`: For MCP tools only — replaces tool output

---

## UserPromptSubmit

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate factorial"
}
```

**Output — command hooks**:
- Exit 0: stdout text added to Claude's context
- Exit 2: prompt blocked, stderr shown as feedback

**Output — structured JSON**:
```json
{
  "hookSpecificOutput": {
    "additionalContext": "Extra context injected alongside the prompt"
  }
}
```

**Fields**:
- `additionalContext`: Text injected into Claude's context alongside the prompt

---

## Stop

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": false,
  "last_assistant_message": "I've completed the refactoring. Here's a summary..."
}
```

**Output**:
```json
{
  "decision": "block",
  "reason": "Tests are still failing - please fix before stopping"
}
```

**Fields**:
- `decision`: `"block"` to prevent stopping (omit or use any other value to allow)
- `reason`: Why Claude should continue (required if blocking, fed back to Claude)
- `stop_hook_active`: If `true` in input, don't block again (prevents infinite loops)

**CRITICAL**: Always check `stop_hook_active` to avoid infinite loops:
```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Allow Claude to stop
fi
```

---

## SubagentStop

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "SubagentStop",
  "stop_hook_active": false,
  "agent_id": "def456",
  "agent_type": "Explore",
  "agent_transcript_path": "~/.claude/projects/.../abc123/subagents/agent-def456.jsonl",
  "last_assistant_message": "Analysis complete. Found 3 potential issues..."
}
```

**Fields**:
- `stop_hook_active`: Same as Stop — check to prevent infinite loops
- `agent_id`: Unique identifier for the subagent
- `agent_type`: Agent name (used for matcher filtering)
- `agent_transcript_path`: Path to the subagent's own transcript
- `last_assistant_message`: Text content of the subagent's final response

**Output**: Same decision format as Stop (`decision: "block"` + `reason`)

---

## SessionStart

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "source": "startup",
  "model": "claude-sonnet-4-6"
}
```

**Source values**: `startup`, `resume`, `clear`, `compact`
**Additional fields**: `model` (model identifier), optional `agent_type` (when using `claude --agent`)

**Output**: Text written to stdout is added to Claude's context:
```bash
echo 'Current branch: main. Sprint: auth refactor.'
```

Or structured JSON:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Current sprint: Sprint 23\nFocus: User authentication"
  }
}
```

**Fields**:
- `additionalContext`: Text injected into session context
- Multiple SessionStart hooks' contexts are concatenated

---

## SessionEnd

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "permission_mode": "default",
  "hook_event_name": "SessionEnd"
}
```

**Matcher values**: `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other`

**Output**: None (ignored)

**Usage**: Cleanup tasks only. Cannot prevent session end.

---

## PreCompact

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "permission_mode": "default",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": "Preserve all git commit messages"
}
```

**Output**: No decision control. Exit 2 shows stderr to user only (cannot block compaction).

---

## Notification

**Input**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/Users/username/project",
  "hook_event_name": "Notification"
}
```

**Matcher values**: `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`

**Output**: None (hook just performs its action)

---

## ConfigChange

**Input**:
```json
{
  "session_id": "abc123",
  "cwd": "/Users/username/project",
  "hook_event_name": "ConfigChange",
  "source": "user_settings",
  "file_path": "/home/user/.claude/settings.json"
}
```

**Matcher values**: `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`

**Output**: Exit 2 to block, or `{"decision": "block"}`

---

## Prompt/Agent Hook Response Format

When using `type: "prompt"` or `type: "agent"`, the model returns:

```json
{"ok": true}
```

Or to block:

```json
{
  "ok": false,
  "reason": "Detailed explanation of what needs to change"
}
```

The `$ARGUMENTS` placeholder in the prompt is replaced with the hook's input JSON.

---

## Tool-Specific Input Fields

Different tools provide different `tool_input` fields:

### Bash
```json
{
  "tool_input": {
    "command": "npm install",
    "description": "Install dependencies",
    "timeout": 120000,
    "run_in_background": false
  }
}
```

### Write
```json
{
  "tool_input": {
    "file_path": "/path/to/file.js",
    "content": "const x = 1;"
  }
}
```

### Edit
```json
{
  "tool_input": {
    "file_path": "/path/to/file.js",
    "old_string": "const x = 1;",
    "new_string": "const x = 2;",
    "replace_all": false
  }
}
```

### Read
```json
{
  "tool_input": {
    "file_path": "/path/to/file.js",
    "offset": 0,
    "limit": 100
  }
}
```

### Grep
```json
{
  "tool_input": {
    "pattern": "function.*",
    "path": "/path/to/search",
    "output_mode": "content"
  }
}
```

### MCP tools
```json
{
  "tool_input": {
    // MCP tool-specific parameters vary by server and tool
  }
}
```

Access these in command hooks:
```bash
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command')
file_path=$(echo "$input" | jq -r '.tool_input.file_path')
```

---

## Modifying Tool Input

PreToolUse hooks can modify `tool_input` before execution via `updatedInput`:

**Original input**:
```json
{
  "tool_input": {
    "command": "npm install lodash"
  }
}
```

**Hook output** (structured JSON):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "updatedInput": {
      "command": "npm install --save-exact lodash"
    }
  }
}
```

**Partial updates**: Only specify fields you want to change:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow",
    "updatedInput": {
      "timeout": 300000
    }
  }
}
```

---

## Common Output Fields

These fields can be included in any hook's JSON output:

```json
{
  "continue": true,
  "stopReason": "Message shown to user when continue is false",
  "suppressOutput": false,
  "systemMessage": "Warning message shown to user"
}
```

- `continue`: If `false`, Claude stops processing entirely (takes precedence over event-specific decisions)
- `stopReason`: Message shown to the user when `continue` is `false` (not shown to Claude)
- `suppressOutput`: If `true`, hide hook's stdout from verbose mode output
- `systemMessage`: Warning message shown to the user

## Common Hook Handler Fields

These fields apply to all hook types in the configuration:

| Field | Required | Description |
|-------|----------|-------------|
| `type` | Yes | `"command"`, `"prompt"`, or `"agent"` |
| `timeout` | No | Seconds. Defaults: 600 (command), 30 (prompt), 60 (agent) |
| `statusMessage` | No | Custom spinner message while hook runs |
| `once` | No | If `true`, runs only once per session (skills/agents only) |

**Command-only fields**:

| Field | Required | Description |
|-------|----------|-------------|
| `command` | Yes | Shell command to execute |
| `async` | No | If `true`, runs in background without blocking. Output delivered on next turn |

**Prompt/Agent-only fields**:

| Field | Required | Description |
|-------|----------|-------------|
| `prompt` | Yes | Prompt text. `$ARGUMENTS` placeholder replaced with hook input JSON |
| `model` | No | Model to use. Defaults to a fast model |

## Decision Control Summary

| Events | Decision pattern | Key fields |
|--------|-----------------|------------|
| UserPromptSubmit, PostToolUse, PostToolUseFailure, Stop, SubagentStop, ConfigChange | Top-level `decision` | `decision: "block"`, `reason` |
| TeammateIdle, TaskCompleted | Exit code only | Exit 2 blocks, stderr as feedback |
| PreToolUse | `hookSpecificOutput` | `permissionDecision` (allow/deny/ask), `permissionDecisionReason` |
| PermissionRequest | `hookSpecificOutput` | `decision.behavior` (allow/deny) |
