# Troubleshooting

Common issues and solutions when working with hooks.

## Hook Not Firing

### Symptom
Hook never executes, even when expected event occurs.

### Diagnostic steps

**1. Check the /hooks menu**
Run `/hooks` in Claude Code to confirm the hook appears under the correct event.

**2. Enable debug mode**
```bash
claude --debug
```

Look for:
```
[DEBUG] Getting matching hook commands for PreToolUse with query: Bash
[DEBUG] Found 0 hooks
```

**3. Check hook configuration location**

Hooks must be in a `settings.json` file under the `"hooks"` key:
- User-global: `~/.claude/settings.json`
- Project (shared): `.claude/settings.json`
- Project (local): `.claude/settings.local.json`

Verify:
```bash
jq '.hooks' ~/.claude/settings.json
jq '.hooks' .claude/settings.json
```

**4. Validate JSON syntax**

Invalid JSON is silently ignored:
```bash
jq . ~/.claude/settings.json
```

If error: fix JSON syntax. Trailing commas and comments are NOT allowed in JSON.

**5. Check matcher pattern**

Common mistakes:

Case sensitivity:
```json
{"matcher": "bash"}   // Won't match "Bash"
{"matcher": "Bash"}   // Correct
```

Missing regex escape:
```json
{"matcher": "mcp__memory__*"}    // * is literal, not wildcard
{"matcher": "mcp__memory__.*"}   // Correct regex wildcard
```

**6. Check event-specific matchers**

Some events match on specific fields, not tool names:
- `SessionStart` matches on `source` (`startup`, `resume`, `clear`, `compact`)
- `SessionEnd` matches on reason (`clear`, `logout`, etc.)
- `Notification` matches on type (`permission_prompt`, `idle_prompt`, etc.)
- `UserPromptSubmit`, `Stop`, `TeammateIdle`, `TaskCompleted` have **no matcher support** — always fire

**7. Check PermissionRequest in headless mode**

`PermissionRequest` hooks do NOT fire in non-interactive mode (`-p`). Use `PreToolUse` hooks instead for automated permission decisions.

**8. Manual file edits not taking effect**

Hooks added through the `/hooks` menu take effect immediately. If you edit settings files directly while Claude Code is running, changes won't take effect until you review them in `/hooks` or restart your session.

### Solutions

**Missing hooks in settings**: Ensure the hook is in the `"hooks"` key of a settings file, not a standalone file.

**Invalid JSON**: Use `jq` to validate and format:
```bash
jq . ~/.claude/settings.json > /tmp/formatted.json && mv /tmp/formatted.json ~/.claude/settings.json
```

**Wrong matcher**: Check tool names with `--debug` and update matcher.

---

## JSON Validation Failed / Shell Profile Interference

### Symptom
Claude Code shows a JSON parsing error even though your hook script outputs valid JSON. You might see garbled output like:
```
Shell ready on arm64
{"decision": "block", "reason": "Not allowed"}
```

### Cause
When Claude Code runs a hook, it spawns a shell that sources your profile (`~/.zshrc` or `~/.bashrc`). If your profile contains unconditional `echo` statements, that output gets prepended to your hook's JSON.

### Solution
Wrap echo statements in your shell profile so they only run in interactive shells:

```bash
# In ~/.zshrc or ~/.bashrc
if [[ $- == *i* ]]; then
  echo "Shell ready"
fi
```

The `$-` variable contains shell flags, and `i` means interactive. Hooks run in non-interactive shells, so the echo is skipped.

---

## Command Hook Failing

### Symptom
Hook executes but fails with error.

### Diagnostic steps

**1. Check debug output**
```
[DEBUG] Hook command completed with status 1: <error message>
```

**2. Test command directly**

Copy the command and pipe sample JSON:
```bash
echo '{"session_id":"test","tool_name":"Bash","tool_input":{"command":"ls"}}' | /path/to/your/hook.sh
echo $?  # Check the exit code
```

**3. Check permissions**
```bash
ls -l /path/to/hook.sh
chmod +x /path/to/hook.sh  # If not executable
```

**4. Verify dependencies**
```bash
which jq       # Check if jq is installed
which node     # Check Node.js
which python3  # Check Python
```

### Common issues

**Missing executable permission**:
```bash
chmod +x /path/to/hook.sh
```

**Missing dependencies** — install required tools:
```bash
# macOS
brew install jq

# Linux (Debian/Ubuntu)
apt-get install jq
```

**"command not found"** — use absolute paths or `$CLAUDE_PROJECT_DIR`:
```json
{
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/script.sh"
}
```

**Timeout** — increase if command takes too long (value in seconds):
```json
{
  "type": "command",
  "command": "/path/to/slow-script.sh",
  "timeout": 120
}
```

Default timeout is 10 minutes.

---

## Prompt Hook Not Working

### Symptom
Prompt hook blocks everything or doesn't block when expected.

### Diagnostic steps

**1. Check prompt response in debug output**

**2. Check prompt structure**

Ensure prompt uses `$ARGUMENTS` placeholder:
```json
{
  "prompt": "Evaluate this command for safety: $ARGUMENTS"
}
```

**3. Verify response format**

Prompt hooks must return:
```json
{"ok": true}
```
or
```json
{"ok": false, "reason": "explanation"}
```

### Common issues

**Ambiguous instructions**:
```json
{"prompt": "Is this ok? $ARGUMENTS"}          // Too vague
{"prompt": "Check if this bash command modifies production resources: $ARGUMENTS"}  // Clear
```

**Missing $ARGUMENTS**:
```json
{"prompt": "Validate this command"}                      // No context
{"prompt": "Validate this command: $ARGUMENTS"}          // Has context
```

**Wrong model for complexity** — specify a more capable model if needed:
```json
{
  "type": "prompt",
  "prompt": "Complex analysis: $ARGUMENTS",
  "model": "sonnet"
}
```

---

## Hook Blocks Everything

### Symptom
Hook blocks all operations, even safe ones.

### Diagnostic steps

**1. Test with known-safe input**
```bash
echo '{"tool_name":"Read","tool_input":{"file_path":"test.txt"}}' | /path/to/hook.sh
echo $?  # Should be 0 for safe operations
```

**2. Check for overly broad conditions**

### Solutions

**Default to allow** — only block on specific dangerous patterns:
```bash
# Default
exit 0

# Only block if dangerous
if [[ "$command" == *"rm -rf"* ]]; then
  echo "Blocked: destructive command" >&2
  exit 2
fi
```

**Check script for errors that cause non-zero exit**:
```bash
#!/bin/bash
set -euo pipefail  # Note: set -e will exit on ANY error
```

If using `set -e`, any failing command causes exit 1 (which proceeds but logs). Use explicit error handling instead.

---

## Infinite Loop in Stop Hook

### Symptom
Stop hook runs repeatedly, Claude never stops.

### Cause
Hook blocks stop without checking `stop_hook_active` flag.

### Solution

**Always check the flag**:
```bash
#!/bin/bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0  # Allow Claude to stop
fi

# Your logic here
```

For prompt hooks, include it in the prompt:
```json
{
  "type": "prompt",
  "prompt": "Check if all tasks are complete. If stop_hook_active is true in the input, respond with {\"ok\": true}. Otherwise, verify completion. $ARGUMENTS"
}
```

---

## Hook Output Not Visible

### Symptom
Hook runs but output not shown to user.

### Cause
Output goes to stderr or `suppressOutput` is set.

### Solutions

**Use stdout for visible output**:
```bash
echo "This is visible"      # stdout - shown to user
echo "This is hidden" >&2   # stderr - only visible in verbose mode
```

**Use systemMessage in JSON output**:
```json
{
  "systemMessage": "This message will be shown to Claude"
}
```

**Toggle verbose mode** with `Ctrl+O` to see all hook output including stderr.

---

## Permission Errors

### Symptom
Hook script can't read files or execute commands.

### Solutions

**Make script executable**:
```bash
chmod +x /path/to/hook.sh
```

**Quote paths with spaces**:
```json
{
  "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/script.sh"
}
```

**Use cwd from input** (not $PWD or cd):
```bash
#!/bin/bash
input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd')
```

---

## Hook Timeouts

### Symptom
```
[DEBUG] Hook command timed out after 600s
```

### Solutions

**Set appropriate timeout** (in seconds):
```json
{
  "type": "command",
  "command": "/path/to/slow-script.sh",
  "timeout": 120
}
```

Defaults: 10 min (command), 60s (agent), 30s (prompt).

**Optimize script** — reduce unnecessary operations, cache results.

**Run expensive operations in background**:
```bash
#!/bin/bash
/path/to/long-operation.sh &
exit 0  # Return immediately
```

---

## Matcher Conflicts

### Symptom
Multiple hooks triggering when only one expected.

### Diagnostic
```
[DEBUG] Matched 3 hooks for query "Bash"
```

### Solutions

**Be more specific**:
```json
{"matcher": "^Bash$"}  // Exact match only, not BashOutput
```

**Check overlapping patterns**:
```json
{
  "hooks": {
    "PreToolUse": [
      {"matcher": "Bash"},      // Matches Bash
      {"matcher": "Bash.*"},    // Also matches Bash!
      {"matcher": ".*"}         // Also matches everything!
    ]
  }
}
```

Remove overlaps or make them mutually exclusive.

---

## Debugging Workflow

**Step 1**: Use the `/hooks` menu to verify configuration
```
/hooks
```

**Step 2**: Enable debug mode
```bash
claude --debug
```

**Step 3**: Toggle verbose mode during a session
```
Ctrl+O
```

**Step 4**: Test hook in isolation
```bash
echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | /path/to/hook.sh
echo $?
```

**Step 5**: Add logging to hook scripts
```bash
#!/bin/bash
echo "Hook started at $(date)" >> /tmp/hook-debug.log
input=$(cat)
echo "Input: $input" >> /tmp/hook-debug.log
# ... your logic
echo "Exit code: $?" >> /tmp/hook-debug.log
```

**Step 6**: Verify JSON output
```bash
echo '{"ok":true}' | jq .  # Must parse without errors
```
