---
description: Interactive workflow to install the Damage Control security hooks system
---

<purpose>
Guide the user through installing the Damage Control security hooks system at their chosen settings level (global, project, or project personal). Uses interactive prompts to determine runtime preference and handle conflicts.
</purpose>

<variables>
SKILL_DIR: skills/damage-control
SCRIPTS_DIR: skills/damage-control/scripts
GLOBAL_SETTINGS: ~/.claude/settings.json
PROJECT_SETTINGS: .claude/settings.json
LOCAL_SETTINGS: .claude/settings.local.json
</variables>

<instructions>
- Use the AskUserQuestion tool at each decision point to guide the user
- Check for existing settings before installation
- Handle merge/overwrite conflicts gracefully
- Copy the Python hook implementation (recommended)
- Ensure the patterns.yaml file is included with the hooks
- Verify installation by checking file existence after copy
</instructions>

<workflow>

## Step 1: Determine Installation Level

1. Use AskUserQuestion:
```
Question: "Where would you like to install Damage Control?"
Options:
- Global (affects all projects) - ~/.claude/settings.json
- Project (shared with team) - .claude/settings.json
- Project Personal (just for you) - .claude/settings.local.json
```

2. Store the chosen path as TARGET_SETTINGS

## Step 2: Check for Existing Settings

3. Use the Read tool to check if TARGET_SETTINGS exists

4. **If settings file does NOT exist**: Proceed to Step 3 (Fresh Install)

5. **If settings file EXISTS**: Use AskUserQuestion:
```
Question: "Existing settings found at [TARGET_SETTINGS]. How would you like to proceed?"
Options:
- Merge (combine existing hooks with damage-control)
- Overwrite (replace with damage-control settings)
- Stop (cancel installation)
```

6. Handle the response:
   - **Merge**: Read existing file, merge hooks arrays, write combined result
   - **Overwrite**: Proceed to Step 3 (Fresh Install)
   - **Stop**: Report "Installation cancelled" and exit workflow

## Step 3: Install Hook Files

7. Determine target hooks directory based on TARGET_SETTINGS:
   - Global: `~/.claude/hooks/damage-control/`
   - Project/Local: `.claude/hooks/damage-control/`

8. Create target hooks directory:
```bash
mkdir -p [TARGET_HOOKS_DIR]
```

9. Copy Python hook scripts from skills directory:
```bash
cp [SCRIPTS_DIR]/*.py [TARGET_HOOKS_DIR]/
cp [SCRIPTS_DIR]/patterns.yaml [TARGET_HOOKS_DIR]/
```

## Step 4: Install Settings Configuration

10. Read the settings template from `[SCRIPTS_DIR]/settings-template.json`

11. **For Fresh Install or Overwrite**:
    - Write the settings template to TARGET_SETTINGS
    - Update paths in settings to match TARGET_HOOKS_DIR

12. **For Merge**:
    - Parse existing settings JSON
    - Parse template settings JSON
    - Use jq to deep merge:
      ```bash
      jq -s '
        def merge_hooks: (.[0].hooks.PreToolUse // []) + (.[1].hooks.PreToolUse // []) | unique_by(.matcher);
        def merge_permissions: {
          deny: ((.[0].permissions.deny // []) + (.[1].permissions.deny // []) | unique),
          ask: ((.[0].permissions.ask // []) + (.[1].permissions.ask // []) | unique)
        };
        .[0] * .[1] | .hooks.PreToolUse = (.[0] | merge_hooks) | .permissions = ([.[0], .[1]] | merge_permissions)
      ' [EXISTING_SETTINGS] [TEMPLATE] > merged.json && mv merged.json [TARGET_SETTINGS]
      ```
    - This merges both hooks.PreToolUse arrays AND permissions (deny/ask rules)

## Step 5: Verify Installation

13. Verify all files exist:
```bash
ls -la [TARGET_HOOKS_DIR]/
```

14. Verify settings file was created/updated:
```bash
cat [TARGET_SETTINGS] | head -20
```

## Step 6: Check UV Runtime

15. Check if UV is installed:
```bash
which uv || echo "UV not installed"
```

16. If UV is not installed, display install command:
```
# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"
```

## Step 7: Restart Reminder

17. **CRITICAL**: Tell the user:

> **Restart your agent for these changes to take effect.**

Hooks are only loaded at agent startup.

</workflow>

<report>
Present the installation summary:

## Damage Control Installation Complete

**Installation Level**: [Global/Project/Project Personal]
**Settings File**: `[TARGET_SETTINGS]`
**Hooks Directory**: `[TARGET_HOOKS_DIR]`

### Files Installed
- `bash-tool-damage-control.py` - Command pattern blocking
- `edit-tool-damage-control.py` - Edit path protection
- `write-tool-damage-control.py` - Write path protection
- `test-damage-control.py` - Hook test runner
- `patterns.yaml` - Security patterns and protected paths

### Runtime
Ensure UV is installed: `curl -LsSf https://astral.sh/uv/install.sh | sh`

### IMPORTANT

**Restart your agent for these changes to take effect.**

### Next Steps
1. Restart your Claude Code session
2. Run `/hooks` to verify hooks are registered
3. Test with: `rm -rf /tmp/test` (should be blocked)
4. Customize `patterns.yaml` to add your own protected paths
</report>
