# Hooks

Hooks are event-driven automation scripts that execute in response to Claude Code events. They can validate commands, automate workflows, inject context, and implement safety checks.

## Available Hooks

| Hook | File | Trigger | Description |
|------|------|---------|-------------|
| pre-commit-pytest | [pre-commit-pytest.sh](pre-commit-pytest.sh) | Before git commit/push | Runs pytest, blocks if tests fail |

## Configuration

Hooks are configured in `~/.claude/hooks.json` (user-level) or `.claude/hooks.json` (project-level):

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Task|Skill",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/pre-commit-pytest.sh",
            "timeout": 120000
          }
        ]
      }
    ]
  }
}
```

## Installation

```bash
# Copy hook configuration
cp hooks.json ~/.claude/hooks.json

# Copy hook scripts
mkdir -p ~/.claude/hooks
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh
```

## Hook Events

| Event | When | Can Block? |
|-------|------|------------|
| PreToolUse | Before tool execution | Yes |
| PostToolUse | After tool execution | No |
| UserPromptSubmit | User submits prompt | Yes |
| Stop | Claude attempts to stop | Yes |
| SubagentStop | Subagent attempts to stop | Yes |
| SessionStart | Session begins | No |
| SessionEnd | Session ends | No |
| PreCompact | Before context compaction | Yes |
| Notification | Claude needs input | No |

## Hook Types

### Command Hooks

Execute shell commands:

```json
{
  "type": "command",
  "command": "/path/to/script.sh",
  "timeout": 30000
}
```

### Prompt Hooks

LLM evaluates a prompt:

```json
{
  "type": "prompt",
  "prompt": "Evaluate if this is safe: $ARGUMENTS\nReturn: {\"decision\": \"approve\" or \"block\"}"
}
```

## Matchers

Filter which tools trigger the hook:

```json
{
  "matcher": "Bash",           // Exact match
  "matcher": "Write|Edit",     // Multiple tools (regex OR)
  "matcher": "mcp__.*",        // All MCP tools
  "matcher": "mcp__memory__.*" // Specific MCP server
}
```

## Creating Your Own

Use the `create-hooks` skill for comprehensive guidance:

```
> Use the create-hooks skill to create a new hook
```

### Example: Desktop Notification

```json
{
  "hooks": {
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "osascript -e 'display notification \"Claude needs input\" with title \"Claude Code\"'"
          }
        ]
      }
    ]
  }
}
```

### Example: Block Destructive Commands

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Check if destructive: $ARGUMENTS\nBlock if: 'rm -rf', 'git push --force', 'git reset --hard'\nReturn: {\"decision\": \"approve\" or \"block\"}"
          }
        ]
      }
    ]
  }
}
```

## Debugging

Run Claude Code with debug flag to see hook execution:

```bash
claude --debug
```

Validate hook configuration:

```bash
jq . ~/.claude/hooks.json
```

## Tips

- Use `timeout` to prevent hanging (default: 60s)
- Set executable permissions: `chmod +x script.sh`
- Use `$CLAUDE_PROJECT_DIR` for project-relative paths
- Check `stop_hook_active` in Stop hooks to prevent infinite loops
