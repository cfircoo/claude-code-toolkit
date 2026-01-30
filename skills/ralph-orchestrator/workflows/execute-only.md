# Workflow: Execute Only

<objective>
Run Ralph on an existing prd.json file.
</objective>

<process>

<step name="1_verify_prd_json">
**Check prd.json exists and is valid**

```bash
# Verify file exists
ls -la tasks/prd.json

# Check structure and schema version
cat tasks/prd.json | jq '{
  project: .project,
  branch: .branchName,
  total_stories: (.userStories | length),
  has_new_schema: (any(.userStories[]; .status != null)),
  with_verification: ([.userStories[] | select(.verificationCommands != null and (.verificationCommands | length) > 0)] | length)
}'

# Show incomplete stories
cat tasks/prd.json | jq '.userStories[] | select(.status != "done" and .passes != true) | {id, title, status: (.status // "pending"), attempts: (.attempts // 0), storyType}'
```

If no tasks/prd.json exists, route to full-pipeline or from-prd workflow.

If using old schema (no `status` field), warn user:
"prd.json uses the old schema (boolean `passes` field). Ralph will auto-migrate stories to the new status-based schema during execution. Consider running ralph-convert-prd again for full verification commands."
</step>

<step name="2_review_stories">
**Show current status**

Display stories to user:
```bash
cat tasks/prd.json | jq '.userStories[] | {id, title, status: (.status // (if .passes then "done" else "pending" end)), priority, storyType, attempts: (.attempts // 0), blockedBy: (.blockedBy // [])}'
```

Ask: "These are the stories Ralph will work on. Incomplete stories will be implemented in priority order, respecting blockedBy dependencies. Ready to execute?"
</step>

<step name="3_execute_ralph">
**Run autonomous implementation**

Ask user for iteration limit:
"How many iterations? (default: 5, remaining stories: [N])"

Execute:
```bash
~/projects/claude-code-toolkit/skills/ralph-orchestrator/scripts/ralph.sh [iterations]
```

Exit codes:
- 0: All stories completed
- 1: Max iterations reached
- 2: All remaining stories blocked or exhausted

Provide monitoring commands.
</step>

</process>

<success_criteria>
- [ ] prd.json validated (preferably with new schema)
- [ ] Ralph executed
- [ ] All stories have `status: "done"` with verification commands passed
</success_criteria>
