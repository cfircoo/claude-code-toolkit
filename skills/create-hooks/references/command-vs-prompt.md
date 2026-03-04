# Command vs Prompt vs Agent Hooks

Decision guide for choosing between the three hook types.

## Decision Tree

```
Need to execute a hook?
│
├─ Simple yes/no validation or pattern matching?
│  └─ Use COMMAND (fastest, free)
│
├─ External tool interaction (formatters, linters, git)?
│  └─ Use COMMAND
│
├─ Logging or notification only?
│  └─ Use COMMAND (no decision needed)
│
├─ Need natural language understanding or reasoning?
│  └─ Use PROMPT (single-turn LLM evaluation)
│
├─ Need to inspect files, run commands, or verify codebase state?
│  └─ Use AGENT (multi-turn with tool access)
│
└─ Complex decision with multiple criteria?
   └─ Use PROMPT (simple reasoning) or AGENT (needs investigation)
```

---

## Command Hooks

### Characteristics

- **Execution**: Shell command
- **Input**: JSON via stdin
- **Output**: Exit code (0/2/other) + optional stdout/stderr
- **Speed**: Fast (no LLM call)
- **Cost**: Free (no API usage)
- **Default timeout**: 10 minutes
- **Complexity**: Limited to shell scripting logic

### When to use

Use command hooks for:
- File operations (check existence, read metadata)
- Running tools (prettier, eslint, git)
- Simple pattern matching (grep, regex)
- Logging to files
- Desktop notifications
- Fast validation (file size, permissions, path checks)
- Anything deterministic

Don't use command hooks for:
- Natural language analysis
- Complex decision logic requiring reasoning
- Context-aware validation
- Semantic understanding

### Exit code behavior

| Exit code | What happens |
|-----------|-------------|
| **0** | Action proceeds. Stdout: added to context for `UserPromptSubmit`/`SessionStart`, or parsed as structured JSON |
| **2** | Action blocked. Stderr message sent to Claude as feedback |
| **Other** | Action proceeds. Stderr logged (visible in verbose mode `Ctrl+O`) |

### Examples

**1. Block with exit code 2** (simple):
```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command')

if echo "$COMMAND" | grep -q "drop table"; then
  echo "Blocked: dropping tables is not allowed" >&2
  exit 2
fi
exit 0
```

**2. Structured JSON output** (exit 0):
```bash
#!/bin/bash
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" == *".env"* ]]; then
  echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "deny", "permissionDecisionReason": ".env files are protected"}}'
  exit 0
fi
echo '{"hookSpecificOutput": {"hookEventName": "PreToolUse", "permissionDecision": "allow"}}'
```

**3. Log bash commands**:
```json
{
  "type": "command",
  "command": "jq -r '.tool_input.command' >> ~/.claude/bash-log.txt"
}
```

**4. Desktop notification** (Linux):
```json
{
  "type": "command",
  "command": "notify-send 'Claude Code' 'Claude Code needs your attention'"
}
```

**5. Auto-format changed file**:
```json
{
  "type": "command",
  "command": "jq -r '.tool_input.file_path' | xargs npx prettier --write",
  "timeout": 10
}
```

### Parsing input in commands

Command hooks receive JSON via stdin. Use `jq` to parse:

```bash
#!/bin/bash
input=$(cat)  # Read stdin

# Extract fields
tool_name=$(echo "$input" | jq -r '.tool_name')
command=$(echo "$input" | jq -r '.tool_input.command')
session_id=$(echo "$input" | jq -r '.session_id')
file_path=$(echo "$input" | jq -r '.tool_input.file_path')

# Your logic here
```

---

## Prompt Hooks

### Characteristics

- **Execution**: Single-turn LLM evaluation (Haiku by default)
- **Input**: Prompt string with `$ARGUMENTS` placeholder
- **Output**: JSON with `ok` (boolean) and `reason` (string)
- **Speed**: Slower (~1-3s per evaluation)
- **Cost**: Uses API credits (small — Haiku by default)
- **Default timeout**: 30 seconds
- **Complexity**: Can reason, understand context, analyze semantics
- **Model**: Haiku by default, configurable with `model` field

### When to use

Use prompt hooks for:
- Natural language validation
- Semantic analysis (intent, safety, appropriateness)
- Complex decision logic
- Context-aware checks
- Reasoning about code quality
- Understanding user intent

Don't use prompt hooks for:
- Simple pattern matching (use regex/grep in command hooks)
- File operations (use command hooks)
- High-frequency events (too slow/expensive)
- Non-decision tasks (logging, notifications)
- Verification that requires reading files or running commands (use agent hooks)

### Response format

The model returns:
```json
{"ok": true}
```

Or to block:
```json
{"ok": false, "reason": "Explanation of what needs to change"}
```

### Examples

**1. Validate commit messages**:
```json
{
  "type": "prompt",
  "prompt": "Check if this is a git commit command. If so, validate the message follows conventional commits (feat|fix|docs|refactor|test|chore). $ARGUMENTS"
}
```

**2. Check if tasks are complete** (Stop hook):
```json
{
  "type": "prompt",
  "prompt": "Check if all tasks are complete. If not, respond with {\"ok\": false, \"reason\": \"what remains to be done\"}."
}
```

**3. Validate code changes for security**:
```json
{
  "type": "prompt",
  "prompt": "Analyze this code change for security issues (SQL injection, XSS, auth bypasses, sensitive data exposure): $ARGUMENTS"
}
```

**4. With custom model**:
```json
{
  "type": "prompt",
  "prompt": "Evaluate if this change is architecturally sound: $ARGUMENTS",
  "model": "sonnet",
  "timeout": 45
}
```

### Writing effective prompts

**Be specific about what to check**:
```
Check if this command modifies production resources: $ARGUMENTS

Block if it targets production databases, deploys to prod, or modifies production configs.
```

**Use $ARGUMENTS placeholder** — it's replaced with the hook's input JSON.

---

## Agent Hooks

### Characteristics

- **Execution**: Multi-turn subagent with tool access (read files, run commands, search code)
- **Input**: Prompt string with `$ARGUMENTS` placeholder
- **Output**: JSON with `ok` (boolean) and `reason` (string)
- **Speed**: Slowest (multiple LLM turns + tool execution)
- **Cost**: Higher (multiple LLM calls + tool usage)
- **Default timeout**: 60 seconds
- **Max turns**: Up to 50 tool-use turns
- **Complexity**: Can investigate, verify, and validate against actual codebase state

### When to use

Use agent hooks for:
- Verifying tests pass before stopping
- Checking that generated code compiles/builds
- Validating that changes match requirements by reading specs
- Complex verification requiring file inspection
- Any check that needs to look at files or run commands

Don't use agent hooks for:
- Simple decisions where hook input data is sufficient (use prompt hooks)
- Deterministic checks (use command hooks)
- High-frequency events (too slow/expensive)
- Logging or notifications

### Response format

Same as prompt hooks:
```json
{"ok": true}
```

Or to block:
```json
{"ok": false, "reason": "Tests are failing: 3 assertions failed in auth.test.js"}
```

### Examples

**1. Verify tests pass before stopping**:
```json
{
  "type": "agent",
  "prompt": "Verify that all unit tests pass. Run the test suite and check the results. $ARGUMENTS",
  "timeout": 120
}
```

**2. Validate code changes match requirements**:
```json
{
  "type": "agent",
  "prompt": "Read the requirements in REQUIREMENTS.md and verify the recent code changes implement them correctly. $ARGUMENTS",
  "timeout": 90
}
```

---

## Performance Comparison

| Aspect | Command Hook | Prompt Hook | Agent Hook |
|--------|--------------|-------------|------------|
| **Speed** | <100ms | 1-3s | 5-60s+ |
| **Cost** | Free | ~$0.001 per call | ~$0.01-0.10 per call |
| **Complexity** | Shell scripting | Natural language reasoning | Multi-step investigation |
| **Tool access** | No (only stdin) | No | Yes (read, search, run) |
| **Context awareness** | Limited to input | High (LLM reasoning) | Highest (can explore) |
| **Best for** | Operations, logging, validation | Decisions, analysis | Verification, testing |
| **Default timeout** | 10 min | 30s | 60s |

---

## Combining Multiple Hooks

You can use multiple hooks for the same event — they execute in order within a matcher block. If any hook blocks, execution stops:

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

Matching hooks across different matcher blocks run in parallel. Identical hook commands are automatically deduplicated.

---

## Recommendations

**High-frequency events** (PreToolUse, PostToolUse):
- Prefer command hooks
- Use prompt/agent hooks sparingly
- Be specific with matchers to minimize unnecessary executions

**Low-frequency events** (Stop, UserPromptSubmit):
- Prompt hooks are fine for decision-making
- Agent hooks work well for verification

**Balance**:
- Command hooks for deterministic checks and operations
- Prompt hooks for judgment calls that only need the input data
- Agent hooks for verification that requires codebase inspection
