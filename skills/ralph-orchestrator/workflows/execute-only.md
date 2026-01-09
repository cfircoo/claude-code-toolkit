# Workflow: Execute Only

<objective>
Run Ralph on an existing prd.json file.
</objective>

<process>

<step name="1_verify_prd_json">
**Check prd.json exists and is valid**

```bash
# Verify file exists
ls -la prd.json

# Check structure
cat prd.json | jq '.project, .branchName, (.userStories | length)'

# Show incomplete stories
cat prd.json | jq '.userStories[] | select(.passes == false) | {id, title}'
```

If no prd.json exists, route to full-pipeline or from-prd workflow.
</step>

<step name="2_review_stories">
**Show current status**

Display stories to user:
```bash
cat prd.json | jq '.userStories[] | {id, title, passes, priority}'
```

Ask: "These are the stories Ralph will work on. The incomplete ones will be implemented in priority order. Ready to execute?"
</step>

<step name="3_execute_ralph">
**Run autonomous implementation**

Ask user for iteration limit:
"How many iterations? (default: 5, remaining stories: [N])"

Execute:
```bash
~/.claude/ralph.sh [iterations]
```

Provide monitoring commands.
</step>

</process>

<success_criteria>
- [ ] prd.json validated
- [ ] Ralph executed
- [ ] All stories have `passes: true`
</success_criteria>
