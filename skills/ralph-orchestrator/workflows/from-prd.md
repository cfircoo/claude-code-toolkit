# Workflow: Continue from PRD

<objective>
Convert an existing PRD to prd.json and execute Ralph.
</objective>

<process>

<step name="1_locate_prd">
**Find the PRD file**

Ask user for PRD location if not provided:
"Where is your PRD file? (e.g., tasks/prd-feature-name.md)"

Read and review the PRD to understand the feature scope.
</step>

<step name="2_convert_to_ralph">
**Transform PRD to prd.json**

Invoke the ralph-convert-prd skill:
```
Use Skill tool: ralph-convert-prd
Arguments: [PRD file path]
```

**User checkpoint:** Review prd.json stories. Ask:
"prd.json created with [N] user stories. Please review:
- Are stories atomic (one context window each)?
- Is ordering correct (no forward dependencies)?
- Are acceptance criteria verifiable?

Ready to execute Ralph?"
</step>

<step name="3_execute_ralph">
**Run autonomous implementation**

Ask user for iteration limit:
"How many iterations should Ralph run? (default: 5)"

Execute Ralph in background:
```bash
~/.claude/ralph.sh [iterations]
```

Inform user of monitoring commands:
```bash
cat prd.json | jq '.userStories[] | {id, title, passes}'
cat progress.txt
git log --oneline -10
```
</step>

</process>

<success_criteria>
- [ ] PRD converted to prd.json
- [ ] Stories are atomic and ordered correctly
- [ ] Ralph executed
- [ ] All stories have `passes: true`
</success_criteria>
