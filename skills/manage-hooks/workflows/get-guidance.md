# Workflow: Get Guidance on Hook Design

<required_reading>
**Read these reference files NOW:**
1. references/hook-types.md
2. references/command-vs-prompt.md
3. references/matchers.md
</required_reading>

<process>
## Step 1: Understand the Goal

Ask the user (if not clear from `$ARGUMENTS`):
- What behavior do you want to automate or control?
- Should it block/prevent something, or just observe/log?
- When should it trigger? (before a tool runs, after, on stop, on session start, etc.)

## Step 2: Recommend an Event

Map the goal to the best event:

| Goal | Recommended Event | Why |
|------|------------------|-----|
| Block dangerous commands | PreToolUse | Intercepts before execution |
| Validate tool input | PreToolUse | Can deny or modify before running |
| Auto-format after edits | PostToolUse (Edit\|Write) | Runs after file changes |
| Check completion quality | Stop | Evaluates before Claude stops |
| Inject project context | SessionStart | Loads context at session start |
| Re-inject after compaction | SessionStart (compact) | Restores context lost to compaction |
| Desktop notifications | Notification | Triggers on attention-needed events |
| Validate user prompts | UserPromptSubmit | Checks before Claude processes |
| Guard config changes | ConfigChange | Blocks unwanted settings changes |
| Verify task completion | TaskCompleted | Validates before marking done |

## Step 3: Recommend a Hook Type

Apply the decision tree:

1. **Is the logic deterministic?** (pattern match, file check, run CLI tool)
   → **command** — fastest, most reliable, no LLM cost

2. **Does it need reasoning but the input data is enough?**
   → **prompt** — Haiku evaluates in single turn, returns ok/reason

3. **Does it need to read files, run tests, or take multiple steps?**
   → **agent** — multi-turn with tool access, most powerful but slowest

**Default to command** unless there's a clear reason for prompt/agent.

## Step 4: Recommend a Matcher

Based on the event type:

**Tool events** (PreToolUse, PostToolUse, etc.):
- Single tool: `"Bash"`, `"Write"`, `"Edit"`
- Multiple tools: `"Write|Edit"`, `"Bash|Read"`
- All MCP tools: `"mcp__.*"`
- Specific MCP: `"mcp__github__.*"`

**Session events**:
- Fresh start only: `"startup"`
- After compaction: `"compact"`
- On resume: `"resume"`

**Events without matcher support** (Stop, UserPromptSubmit, TeammateIdle, TaskCompleted):
- No matcher needed — always fires

## Step 5: Show a Concrete Example

Build a minimal working example based on the user's goal. Use the patterns from references/examples.md as starting points.

Example structure:
```json
{
  "hooks": {
    "<recommended-event>": [
      {
        "matcher": "<recommended-matcher>",
        "hooks": [
          {
            "type": "<recommended-type>",
            "command": "<example-command>"
          }
        ]
      }
    ]
  }
}
```

Explain each part: why this event, why this type, why this matcher.

## Step 6: Offer Next Steps

Present options:
1. **Build it now** — switch to create-hook workflow
2. **Package for toolkit** — switch to create-toolkit-hook workflow
3. **Learn more** — point to specific reference files for deeper reading
4. **I have more questions** — continue guidance
</process>

<decision_framework>
## Quick Decision Matrix

| Scenario | Event | Type | Matcher |
|----------|-------|------|---------|
| Block `rm -rf` | PreToolUse | command | Bash |
| Auto-format on save | PostToolUse | command | Write\|Edit |
| Validate commit messages | PreToolUse | prompt | Bash |
| Run tests before stop | Stop | agent | (none) |
| Inject project rules | SessionStart | command | startup |
| Desktop notification | Notification | command | (none) |
| Block secret file edits | PreToolUse | command | Write\|Edit |
| Verify PR before push | PreToolUse | agent | Bash |
</decision_framework>

<success_criteria>
Guidance is complete when:
- [ ] User's goal is understood
- [ ] Event recommendation explained with rationale
- [ ] Hook type recommendation explained with rationale
- [ ] Matcher recommendation explained
- [ ] Concrete example provided
- [ ] User knows their next step (build, package, or learn more)
</success_criteria>
