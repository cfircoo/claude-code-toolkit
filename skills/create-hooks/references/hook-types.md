# Hook Types and Events

Complete reference for all 15 Claude Code hook events.

## PreToolUse

**When it fires**: Before any tool is executed

**Can block**: Yes — exit 2, or JSON with `permissionDecision: "deny"`

**Matcher**: Tool name (e.g., `Bash`, `Edit|Write`, `mcp__.*`)

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm install",
    "description": "Install dependencies"
  }
}
```

**Output — exit code method**:
```bash
# Allow (exit 0, no output needed)
exit 0

# Block (exit 2 + reason to stderr)
echo "Blocked: force push not allowed" >&2
exit 2
```

**Output — structured JSON method** (exit 0 + JSON to stdout):
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "allow|deny|ask",
    "permissionDecisionReason": "Explanation for the decision",
    "updatedInput": {
      "command": "npm install --save-exact"
    }
  },
  "systemMessage": "Message for Claude"
}
```

**Permission decisions**:
- `"allow"`: Proceed without showing permission prompt
- `"deny"`: Cancel tool call, send reason to Claude as feedback
- `"ask"`: Show permission prompt to user as normal

**Use cases**:
- Validate commands before execution
- Block dangerous operations
- Modify tool inputs (via `updatedInput`)
- Log command attempts
- Escalate to user for confirmation

**Example**: Block force pushes to main
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-git-safety.sh"
          }
        ]
      }
    ]
  }
}
```

---

## PostToolUse

**When it fires**: After a tool completes execution successfully

**Can block**: Yes — top-level `"decision": "block"` prevents further processing

**Matcher**: Tool name (e.g., `Edit|Write`)

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/file.js",
    "content": "..."
  },
  "tool_response": {
    "filePath": "/path/to/file.js",
    "success": true
  },
  "tool_use_id": "toolu_01ABC123..."
}
```

**Output**:
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

**Note**: Cannot undo the tool action since it already executed.

**Use cases**:
- Auto-format code after Write/Edit
- Run linters after code changes
- Trigger CI builds
- Send notifications
- Log file operations

**Example**: Auto-format after edits
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

---

## PostToolUseFailure

**When it fires**: After a tool call fails

**Can block**: No

**Matcher**: Tool name

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PostToolUseFailure",
  "tool_name": "Bash",
  "tool_input": {
    "command": "npm test",
    "description": "Run test suite"
  },
  "tool_use_id": "toolu_01ABC123...",
  "error": "Command exited with non-zero status code 1",
  "is_interrupt": false
}
```

**Event-specific fields**:
- `error`: String describing what went wrong
- `is_interrupt`: Optional boolean — whether failure was caused by user interruption

**Output**: Can return `additionalContext` for Claude:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PostToolUseFailure",
    "additionalContext": "Additional information about the failure for Claude"
  }
}
```

**Use cases**:
- Log failures for analysis
- Alert on repeated tool failures
- Track error patterns
- Provide corrective feedback to Claude

---

## PermissionRequest

**When it fires**: When a permission dialog appears for the user

**Can block**: Yes — via `hookSpecificOutput.decision.behavior`

**Matcher**: Tool name

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PermissionRequest",
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf node_modules",
    "description": "Remove node_modules directory"
  },
  "permission_suggestions": [
    { "type": "toolAlwaysAllow", "tool": "Bash" }
  ]
}
```

**Event-specific fields**:
- `permission_suggestions`: Array of "always allow" options the user would see in the dialog

**Important**: Does NOT fire in non-interactive/headless mode (`-p`). Use `PreToolUse` hooks for automated permission decisions.

**Output — structured JSON**:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "PermissionRequest",
    "decision": {
      "behavior": "allow",
      "updatedInput": {
        "command": "npm run lint"
      },
      "updatedPermissions": [
        { "type": "toolAlwaysAllow", "tool": "Bash" }
      ]
    }
  }
}
```

**Decision fields**:
- `behavior`: `"allow"` grants, `"deny"` denies
- `updatedInput`: For `"allow"` — modifies tool input before execution
- `updatedPermissions`: For `"allow"` — applies permission rule updates
- `message`: For `"deny"` — tells Claude why permission was denied
- `interrupt`: For `"deny"` — if `true`, stops Claude

**Use cases**:
- Auto-approve known-safe operations
- Log permission requests
- Custom permission logic
- Modify commands during approval

---

## UserPromptSubmit

**When it fires**: When user submits a prompt, before Claude processes it

**Can block**: Yes

**Matcher**: No matcher support — always fires on every prompt

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "UserPromptSubmit",
  "prompt": "Write a function to calculate factorial"
}
```

**Output** (command hooks):
- Exit 0: stdout text is added to Claude's context via `additionalContext`
- Exit 2: prompt is blocked, stderr shown as feedback

**Output** (structured JSON):
```json
{
  "hookSpecificOutput": {
    "additionalContext": "Extra context injected alongside the prompt"
  }
}
```

**Use cases**:
- Inject context alongside user prompts (e.g., delegation checks, reminders)
- Validate prompt format
- Preprocess user input
- Enforce prompt templates

---

## Stop

**When it fires**: When Claude finishes responding (not only at task completion)

**Can block**: Yes

**Matcher**: No matcher support — always fires

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "Stop",
  "stop_hook_active": false,
  "last_assistant_message": "I've completed the refactoring. Here's a summary..."
}
```

**Event-specific fields**:
- `stop_hook_active`: `true` when Claude is already continuing from a previous stop hook
- `last_assistant_message`: Text content of Claude's final response (access without parsing transcript)

**Output** (to prevent stopping):
```json
{
  "decision": "block",
  "reason": "Tests are still failing - please fix before stopping"
}
```

**Important**: Does NOT fire on user interrupts.

**CRITICAL — Prevent infinite loops**: Always check `stop_hook_active`:
```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Allow Claude to stop
fi
# ... rest of your hook logic
```

**Use cases**:
- Verify all tasks completed
- Check for errors that need fixing
- Ensure tests pass before stopping
- Custom completion criteria

**Example**: Prompt-based task verification
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains to be done\"}."
          }
        ]
      }
    ]
  }
}
```

---

## SubagentStart

**When it fires**: When a subagent is spawned

**Can block**: No

**Matcher**: Agent type (e.g., `Bash`, `Explore`, `Plan`, or custom agent names)

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "SubagentStart",
  "agent_id": "agent-abc123",
  "agent_type": "Explore"
}
```

**Event-specific fields**:
- `agent_id`: Unique identifier for the subagent
- `agent_type`: Agent name (built-in: `"Bash"`, `"Explore"`, `"Plan"`, or custom)

**Output**: Can inject context into the subagent:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SubagentStart",
    "additionalContext": "Follow security guidelines for this task"
  }
}
```

**Use cases**:
- Log subagent spawning
- Track agent usage patterns
- Inject context into subagents

---

## SubagentStop

**When it fires**: When a subagent finishes

**Can block**: Yes

**Matcher**: Agent type (same values as SubagentStart)

**Input schema**:
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

**Event-specific fields**:
- `stop_hook_active`: Same as Stop — check to prevent infinite loops
- `agent_id`: Unique identifier for the subagent
- `agent_type`: Agent name (used for matcher filtering)
- `agent_transcript_path`: Path to the subagent's own transcript
- `last_assistant_message`: Text content of the subagent's final response

**Output**: Same decision format as Stop (`decision: "block"` + `reason`)

**Use cases**:
- Verify subagent completed its task
- Check quality before accepting results
- Validate subagent deliverables

---

## SessionStart

**When it fires**: When a session begins or resumes

**Can block**: No

**Matcher**: Source — `startup`, `resume`, `clear`, `compact`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "SessionStart",
  "source": "startup",
  "model": "claude-sonnet-4-6"
}
```

**Event-specific fields**:
- `source`: How the session started (`startup`, `resume`, `clear`, `compact`)
- `model`: Model identifier
- `agent_type`: Optional — present when started with `claude --agent <name>`

**Output**: Text written to stdout is added to Claude's context:
```bash
echo 'Reminder: use Bun, not npm. Run bun test before committing.'
```

Or structured JSON:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "Context to inject into session"
  }
}
```

**Use cases**:
- Load project context at startup
- Re-inject critical context after compaction (matcher: `compact`)
- Inject sprint information
- Display environment info

**Example**: Re-inject context after compaction
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Current sprint: auth refactor.'"
          }
        ]
      }
    ]
  }
}
```

---

## SessionEnd

**When it fires**: When a session terminates

**Can block**: No (cannot prevent session end)

**Matcher**: Reason — `clear`, `logout`, `prompt_input_exit`, `bypass_permissions_disabled`, `other`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "SessionEnd",
  "reason": "other"
}
```

**Event-specific fields**:
- `reason`: Why the session ended (used for matcher filtering)

**Output**: None (hook output ignored)

**Use cases**:
- Save session state
- Cleanup temporary files
- Archive transcripts
- Send analytics

**Example**: Clean up temp files on `/clear`
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

## PreCompact

**When it fires**: Before context window compaction

**Can block**: No (exit 2 shows stderr to user only)

**Matcher**: Trigger — `manual`, `auto`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "PreCompact",
  "trigger": "manual",
  "custom_instructions": ""
}
```

**Event-specific fields**:
- `trigger`: `"manual"` (user ran `/compact`) or `"auto"` (context window full)
- `custom_instructions`: User's compaction instructions (for `manual`; empty for `auto`)

**Use cases**:
- Save important context before compaction
- Log compaction events
- Custom pre-compaction logic

---

## Notification

**When it fires**: When Claude Code sends a notification (needs attention)

**Can block**: No

**Matcher**: Type — `permission_prompt`, `idle_prompt`, `auth_success`, `elicitation_dialog`

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "Notification",
  "message": "Claude needs your permission to use Bash",
  "title": "Permission needed",
  "notification_type": "permission_prompt"
}
```

**Event-specific fields**:
- `message`: Notification text
- `title`: Optional notification title
- `notification_type`: Which type fired (used for matcher filtering)

**Output**: Can return `additionalContext` to add context to the conversation.

**Use cases**:
- Desktop notifications
- Sound alerts
- Status bar updates
- External notifications (Slack, etc.)

---

## TeammateIdle

**When it fires**: When an agent team teammate is about to go idle

**Can block**: Yes — exit code 2 prevents the teammate from going idle (teammate continues working)

**Matcher**: No matcher support — always fires

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "TeammateIdle",
  "teammate_name": "researcher",
  "team_name": "my-project"
}
```

**Event-specific fields**:
- `teammate_name`: Name of the teammate about to go idle
- `team_name`: Name of the team

**Decision control**: Exit codes only (no JSON decision control):
```bash
#!/bin/bash
if [ ! -f "./dist/output.js" ]; then
  echo "Build artifact missing. Run the build before stopping." >&2
  exit 2
fi
exit 0
```

**Use cases**:
- Enforce quality gates before teammate stops
- Verify output files exist
- Require passing lint checks

---

## TaskCompleted

**When it fires**: When a task is being marked as completed (via TaskUpdate tool or when agent team teammate finishes with in-progress tasks)

**Can block**: Yes — exit code 2 prevents the task from being marked as completed

**Matcher**: No matcher support — always fires

**Input schema**:
```json
{
  "session_id": "abc123",
  "transcript_path": "~/.claude/projects/.../session.jsonl",
  "cwd": "/current/working/directory",
  "permission_mode": "default",
  "hook_event_name": "TaskCompleted",
  "task_id": "task-001",
  "task_subject": "Implement user authentication",
  "task_description": "Add login and signup endpoints",
  "teammate_name": "implementer",
  "team_name": "my-project"
}
```

**Event-specific fields**:
- `task_id`: Identifier of the task being completed
- `task_subject`: Title of the task
- `task_description`: Detailed description (may be absent)
- `teammate_name`: Name of the teammate completing the task (may be absent)
- `team_name`: Name of the team (may be absent)

**Decision control**: Exit codes only (no JSON decision control):
```bash
#!/bin/bash
INPUT=$(cat)
TASK_SUBJECT=$(echo "$INPUT" | jq -r '.task_subject')
if ! npm test 2>&1; then
  echo "Tests not passing. Fix before completing: $TASK_SUBJECT" >&2
  exit 2
fi
exit 0
```

**Use cases**:
- Enforce completion criteria (tests must pass)
- Log task completion
- Trigger downstream workflows
- Send notifications on task completion

---

## ConfigChange

**When it fires**: When a configuration file changes during a session (external process or editor)

**Can block**: Yes — exit 2 or return `{"decision": "block"}`

**Matcher**: Config type — `user_settings`, `project_settings`, `local_settings`, `policy_settings`, `skills`

**Input schema**:
```json
{
  "session_id": "abc123",
  "cwd": "/current/working/directory",
  "hook_event_name": "ConfigChange",
  "source": "user_settings",
  "file_path": "/home/user/.claude/settings.json"
}
```

**Event-specific fields**:
- `source`: Config type that changed (used for matcher filtering)
- `file_path`: Path to the specific file that was modified

**Note**: `policy_settings` changes cannot be blocked. Hooks still fire for audit logging, but blocking decisions are ignored.

**Use cases**:
- Audit configuration changes for compliance
- Block unauthorized modifications
- Log changes

**Example**: Audit log
```json
{
  "hooks": {
    "ConfigChange": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "jq -c '{timestamp: now | todate, source: .source, file: .file_path}' >> ~/claude-config-audit.log"
          }
        ]
      }
    ]
  }
}
```
