# Workflow: Debug / Fix a Hook

<required_reading>
**Read these reference files NOW:**
1. references/troubleshooting.md
2. references/input-output-schemas.md
</required_reading>

<process>
## Step 1: Identify the Symptom

Ask the user (if not already clear from `$ARGUMENTS`):
- What is the hook supposed to do?
- What's happening instead? (not firing, firing wrong, error, blocking unexpectedly)
- Where is the hook configured? (which settings file)

Common symptoms:
| Symptom | Likely Cause |
|---------|-------------|
| Hook not firing at all | Wrong event, wrong matcher, wrong settings file |
| Hook fires but doesn't block | Exit code not 2, or using wrong output format |
| Hook errors silently | Script not executable, bad path, timeout |
| JSON output corrupted | Shell profile echoing to stdout |
| Infinite loop on Stop | Missing `stop_hook_active` check |
| Hook fires on wrong tools | Matcher regex too broad |

## Step 2: Read the Configuration

Read the settings file containing the hook:
```bash
jq '.hooks' <settings-file>
```

Check for:
- Valid JSON structure
- Correct event name (case-sensitive: `PreToolUse`, not `pretooluse`)
- Matcher is a string (not array), uses regex syntax
- Hook object has required fields (`type`, `command`/`prompt`)

## Step 3: Enable Diagnostics

Guide the user through diagnostic tools:

1. **Debug mode** — shows hook matching and execution:
   ```bash
   claude --debug
   ```

2. **Verbose mode** — toggle during session with `Ctrl+O` to see hook output in transcript

3. **Manual script test** (for command hooks):
   ```bash
   echo '{"tool_name":"Bash","tool_input":{"command":"test"}}' | /path/to/hook-script.sh
   echo "Exit code: $?"
   ```

## Step 4: Check Common Issues

Work through this checklist:

**Configuration issues:**
- [ ] Settings file is valid JSON (`jq . <file>`)
- [ ] Hook is under the correct event key
- [ ] Event name is exact (PreToolUse, not Pre_Tool_Use)
- [ ] Matcher string matches target tool name exactly (case-sensitive)

**Script issues:**
- [ ] Script file exists at the specified path
- [ ] Script has executable permissions (`chmod +x`)
- [ ] Script path uses `"$CLAUDE_PROJECT_DIR"` or absolute path
- [ ] Script shebang line is correct (`#!/bin/bash` or `#!/usr/bin/env bash`)

**Output issues:**
- [ ] Command hook uses correct exit codes (0 = proceed, 2 = block)
- [ ] Stderr used for block messages (not stdout)
- [ ] Shell profile (`~/.zshrc`, `~/.bashrc`) not echoing to stdout in non-interactive mode
- [ ] JSON stdout is valid if using structured output

**Behavioral issues:**
- [ ] Stop hooks check `stop_hook_active` to prevent loops
- [ ] Timeout is sufficient for the operation
- [ ] PermissionRequest hooks: not running in headless mode (use PreToolUse instead)

## Step 5: Fix and Verify

1. Apply the fix to the configuration or script
2. Validate JSON: `jq . <settings-file>`
3. If script was changed, ensure it's still executable
4. Test with `claude --debug` or `Ctrl+O`
5. Trigger the hook and confirm the fix
</process>

<success_criteria>
Debug is complete when:
- [ ] Root cause identified and explained to user
- [ ] Fix applied to configuration or script
- [ ] JSON validates successfully
- [ ] Hook fires correctly on the target event
- [ ] Output behavior matches expectations
- [ ] Verified with debug mode or verbose mode
</success_criteria>
