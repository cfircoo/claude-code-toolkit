# Workflow: Create a New Hook

<required_reading>
**Read these reference files NOW:**
1. references/command-vs-prompt.md
2. references/matchers.md
3. references/input-output-schemas.md
</required_reading>

<process>
## Step 1: Understand the Goal

**If user provided context** (e.g., "block rm -rf", "auto-format after edits"):
→ Analyze what's stated, infer the event and type, note gaps
→ Skip to confirming the approach

**If user just said "create a hook":**
→ Ask: "What should the hook do? What behavior do you want to automate or control?"

## Step 2: Choose the Event

Based on the goal, recommend the appropriate event from the quick reference table in SKILL.md.

Common mappings:
| Goal | Event |
|------|-------|
| Block or validate before tool runs | PreToolUse |
| React after tool succeeds | PostToolUse |
| Validate user input | UserPromptSubmit |
| Check completion before stopping | Stop |
| Inject context on session start | SessionStart |
| Re-inject context after compaction | SessionStart (matcher: `compact`) |
| Desktop notifications | Notification |
| Guard config changes | ConfigChange |

If the choice isn't obvious, explain trade-offs and let the user decide.

## Step 3: Choose the Hook Type

Apply this decision tree:
1. **Is the check deterministic?** (file exists, pattern match, run a linter) → **command**
2. **Does it need reasoning but not codebase access?** (semantic check, natural language) → **prompt**
3. **Does it need to inspect files, run tests, or take multiple steps?** → **agent**

When in doubt, start with **command** — it's fastest and most predictable.

## Step 4: Configure the Matcher

**Tool-based events** (PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest):
```json
"matcher": "Bash"              // Exact tool name
"matcher": "Write|Edit"        // Multiple tools (regex OR)
"matcher": "mcp__.*"           // All MCP tools
"matcher": "mcp__github__.*"   // Specific MCP server
```

**Session/context events**:
```json
"matcher": "compact"           // SessionStart: only after compaction
"matcher": "startup"           // SessionStart: only fresh start
"matcher": "permission_prompt" // Notification: only permission prompts
```

**Events with no matcher support** (UserPromptSubmit, Stop, TeammateIdle, TaskCompleted): always fire on every occurrence.

## Step 5: Write the Hook Configuration

Build the JSON config and add it to the appropriate settings file.

**For command hooks:**
```json
{
  "hooks": {
    "<EVENT>": [
      {
        "matcher": "<PATTERN>",
        "hooks": [
          {
            "type": "command",
            "command": "<COMMAND_OR_SCRIPT_PATH>",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

**For prompt hooks:**
```json
{
  "hooks": {
    "<EVENT>": [
      {
        "matcher": "<PATTERN>",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "<INSTRUCTION> $ARGUMENTS",
            "model": "haiku",
            "timeout": 30
          }
        ]
      }
    ]
  }
}
```

**For agent hooks:**
```json
{
  "hooks": {
    "<EVENT>": [
      {
        "matcher": "<PATTERN>",
        "hooks": [
          {
            "type": "agent",
            "prompt": "<INSTRUCTION> $ARGUMENTS",
            "timeout": 120
          }
        ]
      }
    ]
  }
}
```

If the hook needs a script file:
1. Create the script at `.claude/hooks/<script-name>.sh` (or project-appropriate location)
2. Make it executable: `chmod +x .claude/hooks/<script-name>.sh`
3. Reference with: `"$CLAUDE_PROJECT_DIR"/.claude/hooks/<script-name>.sh`

## Step 6: Add Safety Guards

Apply based on hook type and event:

**Stop/SubagentStop hooks** — prevent infinite loops:
```bash
INPUT=$(cat)
if [ "$(echo "$INPUT" | jq -r '.stop_hook_active')" = "true" ]; then
  exit 0
fi
```

**Blocking hooks** — use exit 2 with clear stderr message:
```bash
echo "Blocked: reason why" >&2
exit 2
```

**All hooks** — set a reasonable timeout (seconds, not ms).

## Step 7: Test the Hook

1. **Validate JSON**: `jq . <settings-file>`
2. **Test script manually** (if command hook):
   ```bash
   echo '{"tool_name":"Bash","tool_input":{"command":"ls"}}' | .claude/hooks/my-hook.sh
   echo $?
   ```
3. **Run with debug mode**: `claude --debug`
4. **Toggle verbose mode**: `Ctrl+O` during a session
5. Trigger the hook and verify it fires, produces expected output, and doesn't break the workflow
</process>

<success_criteria>
Hook creation is complete when:
- [ ] JSON config is valid (passes `jq` validation)
- [ ] Correct event chosen for the use case
- [ ] Matcher targets the right tools/contexts
- [ ] Hook executes without errors
- [ ] Blocking behavior works as expected (exit 2 blocks, exit 0 proceeds)
- [ ] Safety guards in place (stop_hook_active check, timeouts, permissions)
- [ ] Tested with `--debug` or `Ctrl+O` showing expected behavior
</success_criteria>
