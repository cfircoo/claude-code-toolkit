# Working Examples

Real-world hook configurations ready to use. All configurations go in a settings file (`~/.claude/settings.json` for global, `.claude/settings.json` for project).

## Desktop Notifications

### macOS notification when input needed
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude Code needs your attention\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

### Linux notification (notify-send)
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "notify-send 'Claude Code' 'Claude Code needs your attention'"
          }
        ]
      }
    ]
  }
}
```

### Windows notification (PowerShell)
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "powershell.exe -Command \"[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); [System.Windows.Forms.MessageBox]::Show('Claude Code needs your attention', 'Claude Code')\""
          }
        ]
      }
    ]
  }
}
```

### Play sound on notification (macOS)
```json
{
  "hooks": {
    "Notification": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "afplay /System/Library/Sounds/Glass.aiff"
          }
        ]
      }
    ]
  }
}
```

---

## Logging

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

### Log file operations
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '\"[\" + (now | todate) + \"] \" + .tool_name + \": \" + .tool_input.file_path' >> ~/.claude/file-operations.log"
          }
        ]
      }
    ]
  }
}
```

### Audit trail for MCP operations
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "mcp__.*",
        "hooks": [
          {
            "type": "command",
            "command": "jq '. + {timestamp: now}' >> ~/.claude/mcp-audit.jsonl"
          }
        ]
      }
    ]
  }
}
```

### Audit configuration changes
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

---

## Code Quality

### Auto-format after edits (format only the changed file)
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write 2>/dev/null || true",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### Run linter after code changes
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path' | xargs eslint --fix 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
```

### Format by file type
```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/format-by-type.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/format-by-type.sh`:
```bash
#!/bin/bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path')

case "$file_path" in
  *.js|*.jsx|*.ts|*.tsx)
    npx prettier --write "$file_path" 2>/dev/null
    ;;
  *.py)
    black "$file_path" 2>/dev/null
    ;;
  *.go)
    gofmt -w "$file_path" 2>/dev/null
    ;;
esac
exit 0
```

### Verify tests pass before stopping (prompt-based)
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

### Verify tests pass before stopping (agent-based)
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "agent",
            "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

---

## Safety and Validation

### Block destructive commands (exit code method)
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-command-safety.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/check-command-safety.sh`:
```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

# Check for dangerous patterns
if echo "$COMMAND" | grep -qE "rm -rf /|mkfs|> /dev/sd"; then
  echo "Blocked: destructive command detected" >&2
  exit 2
fi

# Check for force push to main
if echo "$COMMAND" | grep -qE "git push.*--force.*(main|master)"; then
  echo "Blocked: force push to main branch" >&2
  exit 2
fi

exit 0
```

### Block edits to protected files
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/protect-files.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/protect-files.sh`:
```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

PROTECTED_PATTERNS=(".env" "package-lock.json" ".git/")

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if [[ "$FILE_PATH" == *"$pattern"* ]]; then
    echo "Blocked: $FILE_PATH matches protected pattern '$pattern'" >&2
    exit 2
  fi
done

exit 0
```

### Validate commit messages (prompt-based)
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if this is a git commit command. If so, validate the message follows conventional commits format (feat|fix|docs|refactor|test|chore): description. $ARGUMENTS"
          }
        ]
      }
    ]
  }
}
```

---

## Context Injection

### Re-inject context after compaction
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "compact",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'Reminder: use Bun, not npm. Run bun test before committing. Current sprint: auth refactor.'"
          }
        ]
      }
    ]
  }
}
```

### Load sprint context at session start
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/load-context.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/load-context.sh`:
```bash
#!/bin/bash
sprint_info=$(cat "$CLAUDE_PROJECT_DIR/.sprint-context.txt" 2>/dev/null || echo "No sprint context available")

jq -n \
  --arg context "$sprint_info" \
  '{
    "hookSpecificOutput": {
      "hookEventName": "SessionStart",
      "additionalContext": $context
    }
  }'
```

### Load git branch context
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "git branch --show-current 2>/dev/null | jq -Rs '{\"hookSpecificOutput\": {\"hookEventName\": \"SessionStart\", \"additionalContext\": (\"Current branch: \" + .)}}'"
          }
        ]
      }
    ]
  }
}
```

---

## Session Management

### Archive transcript on session end
```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/archive-session.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/archive-session.sh`:
```bash
#!/bin/bash
input=$(cat)
transcript_path=$(echo "$input" | jq -r '.transcript_path')
session_id=$(echo "$input" | jq -r '.session_id')

archive_dir="$HOME/.claude/archives"
mkdir -p "$archive_dir"

timestamp=$(date +%Y%m%d-%H%M%S)
cp "$transcript_path" "$archive_dir/${timestamp}-${session_id}.jsonl" 2>/dev/null || true
```

### Clean up temp files on /clear
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

### Save session stats
```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq '. + {ended_at: now}' >> ~/.claude/session-stats.jsonl"
          }
        ]
      }
    ]
  }
}
```

---

## Advanced Patterns

### Stop hook with infinite loop prevention
```json
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-before-stop.sh"
          }
        ]
      }
    ]
  }
}
```

`.claude/hooks/check-before-stop.sh`:
```bash
#!/bin/bash
INPUT=$(cat)

# CRITICAL: Prevent infinite loops
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi

# Run tests
cd "$(echo "$INPUT" | jq -r '.cwd')" || exit 0
npm test > /dev/null 2>&1

if [ $? -eq 0 ]; then
  exit 0  # Tests pass, allow stop
else
  echo "Tests are failing. Please fix before stopping." >&2
  exit 2  # Block stop
fi
```

### Chain multiple hooks on same event
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.command' >> ~/bash-log.txt"
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check-safety.sh"
          }
        ]
      }
    ]
  }
}
```

Hooks execute in order within a matcher block. First block stops the chain.

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

### Project-specific hooks with $CLAUDE_PROJECT_DIR
```json
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/init-session.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-changes.sh"
          }
        ]
      }
    ]
  }
}
```

This keeps hook scripts versioned with the project.
