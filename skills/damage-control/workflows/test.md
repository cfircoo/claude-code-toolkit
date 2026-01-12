---
description: Test all Damage Control hooks by running the test script against patterns.yaml
---

<purpose>
Validate that all Damage Control hooks are working correctly by reading patterns.yaml and running test cases against each configured pattern and protected path.
</purpose>

<variables>
PROJECT_HOOKS: .claude/hooks/damage-control
GLOBAL_HOOKS: ~/.claude/hooks/damage-control
</variables>

<instructions>
- Determine which hooks directory to test (project or global)
- Read patterns.yaml to get all configured patterns and paths
- For each pattern/path, call the test script with appropriate arguments
- The test script echoes JSON into the hooks - it does NOT run actual commands
- Track pass/fail counts and report summary

**IMPORTANT**: You are testing hooks by piping mock data. NO actual dangerous commands are executed.
</instructions>

<workflow>

## Step 1: Locate Hooks

1. Check if project hooks exist:
```bash
ls .claude/hooks/damage-control/patterns.yaml 2>/dev/null
```

2. If not found, check global hooks:
```bash
ls ~/.claude/hooks/damage-control/patterns.yaml 2>/dev/null
```

3. Set HOOKS_DIR to the found location

## Step 2: Read Configuration

4. Read `[HOOKS_DIR]/patterns.yaml`

5. Extract:
   - `bashToolPatterns` - command patterns to block
   - `zeroAccessPaths` - paths with no access
   - `readOnlyPaths` - read-only paths
   - `noDeletePaths` - no-delete paths

## Step 3: Test bashToolPatterns

6. For each pattern, generate a matching test command and run:
```bash
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "[test_command]" --expect-blocked
```

**Test cases:**
| Pattern | Test Command |
|---------|-------------|
| `rm -rf` | `rm -rf /tmp/test` |
| `git reset --hard` | `git reset --hard HEAD` |
| `git push --force` | `git push --force origin main` |
| `chmod 777` | `chmod 777 /tmp/test` |

7. Test safe commands are allowed:
```bash
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "ls -la" --expect-allowed
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "git status" --expect-allowed
```

## Step 4: Test zeroAccessPaths

8. For each zero-access path, test ALL access is blocked:
```bash
# Bash access
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "cat [path]/test" --expect-blocked

# Edit access
uv run [HOOKS_DIR]/test-damage-control.py edit Edit "[path]/test.txt" --expect-blocked

# Write access
uv run [HOOKS_DIR]/test-damage-control.py write Write "[path]/test.txt" --expect-blocked
```

## Step 5: Test readOnlyPaths

9. For each read-only path:
```bash
# Read - should be ALLOWED
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "cat [path]" --expect-allowed

# Write - should be BLOCKED
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "echo test > [path]/test" --expect-blocked

# Edit - should be BLOCKED
uv run [HOOKS_DIR]/test-damage-control.py edit Edit "[path]/test.txt" --expect-blocked
```

## Step 6: Test noDeletePaths

10. For each no-delete path:
```bash
# Delete - should be BLOCKED
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "rm [path]/test.txt" --expect-blocked

# Write - should be ALLOWED
uv run [HOOKS_DIR]/test-damage-control.py bash Bash "echo test > [path]/test.txt" --expect-allowed
```

## Step 7: Compile Results

11. Count total passed and failed tests
12. Present the summary report

</workflow>

<report>
## Damage Control Test Results

### bashToolPatterns
| Test | Command | Expected | Result |
|------|---------|----------|--------|
| 1 | `rm -rf /tmp` | BLOCKED | PASS/FAIL |
| 2 | `git reset --hard` | BLOCKED | PASS/FAIL |
| 3 | `ls -la` | ALLOWED | PASS/FAIL |

### zeroAccessPaths
| Path | Tool | Expected | Result |
|------|------|----------|--------|
| ~/.ssh/ | Bash | BLOCKED | PASS/FAIL |
| ~/.ssh/ | Edit | BLOCKED | PASS/FAIL |
| ~/.ssh/ | Write | BLOCKED | PASS/FAIL |

### readOnlyPaths
| Path | Operation | Expected | Result |
|------|-----------|----------|--------|
| /etc/ | Read | ALLOWED | PASS/FAIL |
| /etc/ | Write | BLOCKED | PASS/FAIL |

### noDeletePaths
| Path | Operation | Expected | Result |
|------|-----------|----------|--------|
| .git/ | Delete | BLOCKED | PASS/FAIL |
| .git/ | Write | ALLOWED | PASS/FAIL |

---

### Summary

**Total Tests**: [count]
**Passed**: [count]
**Failed**: [count]

[If all passed]
All Damage Control hooks are working correctly.

[If any failed]
Some tests failed. Review the failed tests and check hook implementations.
</report>
