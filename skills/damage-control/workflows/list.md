---
description: List all Damage Control permissions across global, project, and personal levels
---

<purpose>
Display a summary of all Damage Control security configurations across all settings levels (global, project, project personal).
</purpose>

<variables>
GLOBAL_PATTERNS: ~/.claude/hooks/damage-control/patterns.yaml
PROJECT_PATTERNS: .claude/hooks/damage-control/patterns.yaml
</variables>

<instructions>
- Check each settings level for existence
- Read patterns.yaml at each level if it exists
- Present a consolidated view of all protections
- Clearly indicate which levels are active vs not configured
</instructions>

<workflow>

## Step 1: Check Installation Status

1. Check which levels have Damage Control installed:

```bash
# Global
ls ~/.claude/hooks/damage-control/patterns.yaml 2>/dev/null && echo "Global: INSTALLED" || echo "Global: NOT INSTALLED"

# Project
ls .claude/hooks/damage-control/patterns.yaml 2>/dev/null && echo "Project: INSTALLED" || echo "Project: NOT INSTALLED"
```

## Step 2: Read Configurations

2. For each installed level, read the patterns.yaml and extract:
   - `bashToolPatterns` count and first few patterns
   - `zeroAccessPaths` list
   - `readOnlyPaths` list
   - `noDeletePaths` list

## Step 3: Present Report

3. Display the consolidated configuration summary

</workflow>

<report>
## Damage Control Configuration Summary

### Global Level (`~/.claude/`)

**Status**: [Installed / Not Configured]

[If installed:]

**Zero Access Paths** (no operations allowed):
- [list paths or "None configured"]

**Read Only Paths** (read allowed, no modifications):
- [list paths or "None configured"]

**No Delete Paths** (all operations except delete):
- [list paths or "None configured"]

**Blocked Command Patterns**: [count] patterns
- [list first 5 patterns with reasons]
- [if more than 5: "... and [N] more"]

---

### Project Level (`.claude/`)

**Status**: [Installed / Not Configured]

[Same format as Global]

---

### Protection Summary

| Level | Zero Access | Read Only | No Delete | Command Patterns |
|-------|-------------|-----------|-----------|------------------|
| Global | [count] | [count] | [count] | [count] |
| Project | [count] | [count] | [count] | [count] |

---

**Note**: Hooks at all levels run in parallel. If any level blocks an operation, it is blocked.
</report>
