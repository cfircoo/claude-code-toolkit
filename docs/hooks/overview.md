# Hooks Overview

Event-driven automation scripts that execute in response to Claude Code events.

## What are Hooks?

Hooks are automation scripts that respond to Claude Code events. They can:
- Validate operations before they execute
- Automate repetitive tasks
- Enforce security policies
- Inject context into conversations
- Block dangerous operations

## Hook Events

Hooks can trigger on these events:

| Event | When | Can Block? |
|-------|------|-----------|
| `PreToolUse` | Before tool execution | Yes |
| `PostToolUse` | After tool execution | No |
| `UserPromptSubmit` | User submits prompt | Yes |
| `Stop` | Claude attempts to stop | Yes |
| `SessionStart` | Session begins | No |
| `SessionEnd` | Session ends | No |

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

Return format:
```json
{
  "decision": "approve",
  "message": "Optional message"
}
```

### Prompt Hooks

LLM evaluates a prompt and makes decision:

```json
{
  "type": "prompt",
  "prompt": "Evaluate if this is safe: $ARGUMENTS\nReturn: {\"decision\": \"approve\" or \"block\"}"
}
```

## Tool Matchers

Filter which tools trigger the hook:

```json
{
  "matcher": "Bash",                    // Exact match
  "matcher": "Write|Edit",              // Multiple tools (OR)
  "matcher": "mcp__.*",                 // All MCP tools
  "matcher": "mcp__memory__.*",         // Specific MCP server
  "matcher": "Bash(git *)",             // Command pattern
  "matcher": "Bash(gh *, git *)"        // Multiple patterns
}
```

## Configuration

Hooks are configured in `~/.claude/hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/safety-check.sh",
            "timeout": 30000
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": ".*",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "Is this request safe and appropriate? Return {\"decision\": \"approve\" or \"block\"}"
          }
        ]
      }
    ]
  }
}
```

## Hook Execution Flow

```
Event Triggered
    │
    ├─> Match hooks for this event
    │
    ├─> For each matching hook:
    │   ├─> Match tool/pattern
    │   ├─> Execute hook (command or prompt)
    │   ├─> Get decision (approve/block)
    │   └─> Block operation if needed
    │
    └─> Continue or block operation
```

## Available Hooks

### Built-in Hooks

The toolkit includes:

| Hook | Event | Purpose |
|------|-------|---------|
| [concise-mode](concise-mode.md) | UserPromptSubmit | Brief responses |
| [damage-control](damage-control.md) | PreToolUse | Security blocks |
| [delegate-first](delegate-first.md) | UserPromptSubmit | Agent routing |
| [pre-commit-pytest](pre-commit-pytest.md) | PreToolUse | Test validation |

### Installation

The installer automatically installs all default hooks. To install individually:

```bash
# View hook configuration
cat hooks.json

# Copy to Claude Code
cp hooks.json ~/.claude/hooks.json
```

## Creating Custom Hooks

### Simple Shell Script Hook

```bash
#!/bin/bash
# ~/.claude/hooks/my-hook.sh

# Check the operation
if [[ "$ARGUMENTS" == *"dangerous-operation"* ]]; then
  echo '{"decision": "block", "message": "Blocked dangerous operation"}'
  exit 1
fi

echo '{"decision": "approve"}'
exit 0
```

Add to `hooks.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "~/.claude/hooks/my-hook.sh",
            "timeout": 5000
          }
        ]
      }
    ]
  }
}
```

### Prompt-based Hook

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "prompt",
            "prompt": "This user request asks to: $ARGUMENTS\n\nIs this request appropriate? Return {\"decision\": \"approve\" or \"block\"}"
          }
        ]
      }
    ]
  }
}
```

## Hook Variables

Available in hook environment:

| Variable | Content |
|----------|---------|
| `$ARGUMENTS` | Tool arguments or prompt text |
| `$CLAUDE_PROJECT_DIR` | Project directory path |
| `$CLAUDE_SYSTEM_MESSAGE` | Current system message |

## Best Practices

### Design

- Keep hooks focused and simple
- One responsibility per hook
- Document hook behavior
- Make decision logic clear

### Performance

- Set reasonable timeouts (30000ms max)
- Optimize shell scripts
- Cache results when possible
- Fail fast on invalid input

### Security

- Validate all inputs
- Don't log sensitive data
- Use quotes carefully in shell
- Test with various inputs

### Maintenance

- Version control hooks
- Document any dependencies
- Test changes before deploying
- Keep logs for debugging

## Debugging

### View Hook Execution

Run Claude Code with debug flag:

```bash
claude --debug
```

This shows:
- Hook matches
- Hook execution
- Decisions made
- Timing information

### Validate Configuration

Check hook JSON is valid:

```bash
jq . ~/.claude/hooks.json
```

### Test Hooks

Create test cases:

```bash
# Test command hook directly
~/.claude/hooks/my-hook.sh "test argument"

# Check exit code
echo $?

# Validate JSON output
~/.claude/hooks/my-hook.sh "test" | jq .
```

## Common Patterns

### Block Dangerous Commands

```bash
if [[ "$ARGUMENTS" == *"rm -rf"* ]] || \
   [[ "$ARGUMENTS" == *"git reset --hard"* ]]; then
  echo '{"decision": "block", "message": "Dangerous command blocked"}'
  exit 1
fi
echo '{"decision": "approve"}'
```

### Require Approval for Deployments

```bash
if [[ "$ARGUMENTS" == *"deploy"* ]] || \
   [[ "$ARGUMENTS" == *"production"* ]]; then
  echo '{"decision": "block", "message": "Deployment requires explicit approval"}'
  exit 1
fi
echo '{"decision": "approve"}'
```

### Rate Limiting

```bash
# Count requests
count=$(redis-cli INCR "api-requests-$(date +%s)") || 0

if [ "$count" -gt 100 ]; then
  echo '{"decision": "block", "message": "Rate limit exceeded"}'
  exit 1
fi

echo '{"decision": "approve"}'
```

## Troubleshooting

### Hook not firing

- Check hook is registered in `hooks.json`
- Validate JSON syntax: `jq . ~/.claude/hooks.json`
- Verify matcher matches the tool/event
- Run `claude --debug` to see hook execution

### Hook blocks valid operation

- Review hook logic
- Test hook script with sample input
- Adjust matcher or conditions
- Add exception for valid cases

### Hook times out

- Check timeout value (in milliseconds)
- Optimize hook script
- Check for infinite loops
- Add debug logging

### Hook returns wrong decision

- Check JSON output format
- Verify decision is "approve" or "block"
- Test with `claude --debug`
- Review hook logic

## Integration with Skills

Hooks integrate with:
- [damage-control skill](../skills/damage-control.md) — Security hooks
- [manage-hooks skill](../skills/manage-hooks.md) — Hook creation guide

## Related Documentation

- [damage-control](damage-control.md) — Security hooks
- [concise-mode](concise-mode.md) — Response formatting
- [pre-commit-pytest](pre-commit-pytest.md) — Test validation

## Tips

1. **Start simple** — Test basic hooks first
2. **Use patterns** — Learn from existing hooks
3. **Document decisions** — Explain blocking reasons
4. **Monitor performance** — Hooks shouldn't slow you down
5. **Version control** — Keep hooks in git
6. **Test thoroughly** — Test with real scenarios
7. **Plan error cases** — What if hook fails?
