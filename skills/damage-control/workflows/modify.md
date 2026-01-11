---
description: Interactive workflow to modify existing Damage Control security settings
---

<purpose>
Guide the user through modifying their Damage Control security configuration. Allows adding/removing protected paths, blocking new commands, and adjusting protection levels.
</purpose>

<variables>
GLOBAL_PATTERNS: ~/.claude/hooks/damage-control/patterns.yaml
PROJECT_PATTERNS: .claude/hooks/damage-control/patterns.yaml
</variables>

<instructions>
- Use the AskUserQuestion tool at each decision point
- Always verify settings exist before attempting modifications
- If no settings found, redirect to install workflow
- Validate YAML syntax after modifications
- Show before/after comparison for user confirmation
</instructions>

<workflow>

## Step 1: Determine Settings Level

1. Use AskUserQuestion:
```
Question: "Which settings level do you want to modify?"
Options:
- Global (all projects) - ~/.claude/
- Project (this project) - .claude/
```

2. Store choice and set PATTERNS path accordingly

## Step 2: Verify Installation Exists

3. Use Read tool to check if PATTERNS file exists

4. **If file doesn't exist**:
   - Report: "Damage Control is not installed at this level."
   - Use AskUserQuestion:
   ```
   Question: "Would you like to install Damage Control now?"
   Options:
   - Yes, install it
   - No, cancel
   ```
   - If Yes: Read and execute [install.md](install.md)
   - If No: Exit workflow

## Step 3: Determine Modification Type

5. Use AskUserQuestion:
```
Question: "What would you like to modify?"
Options:
- Add/Remove Protected Paths (restrict file/directory access)
- Add/Remove Blocked Commands (block specific bash commands)
- View Current Configuration
```

## Branch A: Modify Protected Paths

6. **If "Add/Remove Protected Paths"**: Use AskUserQuestion:
```
Question: "What action would you like to take?"
Options:
- Add a new protected path
- Remove an existing protected path
- List all protected paths
```

7. **Add new protected path**:
   a. Use AskUserQuestion:
   ```
   Question: "What protection level should this path have?"
   Options:
   - Zero Access (no operations allowed - for secrets/credentials)
   - Read Only (can read, cannot modify - for configs)
   - No Delete (can read/write/edit, cannot delete - for important files)
   ```

   b. Use AskUserQuestion (text input expected via "Other"):
   ```
   Question: "Enter the path to protect:"
   Options:
   - ~/.ssh/ (SSH keys)
   - ~/.aws/ (AWS credentials)
   - .env (environment file)
   - Other (enter custom path)
   ```

   c. Read current patterns.yaml
   d. Add path to appropriate section:
      - Zero Access → `zeroAccessPaths`
      - Read Only → `readOnlyPaths`
      - No Delete → `noDeletePaths`
   e. Write updated patterns.yaml
   f. Show confirmation

8. **Remove protected path**:
   a. Read patterns.yaml and list all protected paths
   b. Use AskUserQuestion to select path to remove
   c. Remove path from appropriate section
   d. Write updated patterns.yaml

## Branch B: Modify Blocked Commands

9. **If "Add/Remove Blocked Commands"**: Use AskUserQuestion:
```
Question: "What action would you like to take?"
Options:
- Add a new blocked command pattern
- Remove an existing pattern
- List all blocked patterns
```

10. **Add new blocked pattern**:
    a. Use AskUserQuestion:
    ```
    Question: "Enter the command to block (I'll create the regex):"
    Options:
    - npm publish (prevent accidental publishes)
    - docker push (prevent accidental pushes)
    - Other (enter custom command)
    ```

    b. Escape special regex characters
    c. Create pattern: `\b[escaped_command]\b`
    d. Ask for reason/description
    e. Read patterns.yaml
    f. Add to `bashToolPatterns`:
    ```yaml
    - pattern: '[generated_pattern]'
      reason: '[user_reason]'
    ```
    g. Write updated patterns.yaml

## Branch C: View Configuration

11. **If "View Current Configuration"**:
    a. Read patterns.yaml
    b. Display formatted configuration summary

## Step 4: Restart Reminder

12. **CRITICAL**: After any modifications, tell the user:

> **Restart your agent for these changes to take effect.**

</workflow>

<report>
## Damage Control Configuration Updated

**Settings Level**: [Global/Project]
**Modification Type**: [Path Protection/Command Blocking]

### Changes Made
**Action**: Added/Removed
**Item**: `[path or pattern]`
**Category**: [Zero Access/Read Only/No Delete/Blocked Command]

### IMPORTANT

**Restart your agent for these changes to take effect.**

Run `/hooks` after restart to verify the changes are active.
</report>
