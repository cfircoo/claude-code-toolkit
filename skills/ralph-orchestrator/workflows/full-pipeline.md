# Workflow: Full Pipeline

<objective>
Execute the complete Ralph pipeline from requirements gathering to autonomous implementation.
</objective>

<process>

<step name="1_spec_interview">
**Gather comprehensive requirements**

Invoke the spec-interview skill:
```
Use Skill tool: spec-interview
```

This will:
- Ask deep questions about the feature
- Surface hidden assumptions
- Force explicit tradeoffs
- Output SPEC.md

**User checkpoint:** Review SPEC.md before proceeding. Ask user:
"I've completed the spec interview. Please review SPEC.md. Ready to generate the PRD?"
</step>

<step name="2_generate_prd">
**Create actionable PRD**

Invoke the generate-prd skill:
```
Use Skill tool: generate-prd
Arguments: Reference SPEC.md for context
```

This will:
- Ask 3-5 clarifying questions
- Generate structured PRD with user stories
- Save to tasks/prd-[feature-name].md

**User checkpoint:** Review the PRD. Ask user:
"PRD generated at tasks/prd-[feature-name].md. Please review the user stories and acceptance criteria. Ready to convert for Ralph?"
</step>

<step name="3_convert_to_ralph">
**Transform PRD to prd.json**

Invoke the ralph-convert-prd skill:
```
Use Skill tool: ralph-convert-prd
Arguments: Path to the PRD file
```

This will:
- Break down into atomic user stories
- Order by dependency (schema → backend → UI → dashboard)
- Add mandatory criteria ("Typecheck passes")
- Output prd.json

**User checkpoint:** Review prd.json stories. Ask user:
"prd.json created with [N] user stories. Please review:
- Are stories atomic (one context window each)?
- Is ordering correct (no forward dependencies)?
- Are acceptance criteria verifiable?

Ready to execute Ralph?"
</step>

<step name="4_pre_execution_check">
**Verify prerequisites**

Before running Ralph, confirm:
```bash
# Check ralph.sh exists
ls -la ~/.claude/ralph.sh

# Verify prd.json is valid
cat prd.json | jq '.userStories | length'

# Check git status is clean
git status
```

If ralph.sh doesn't exist, inform user they need to set it up.
</step>

<step name="5_execute_ralph">
**Run autonomous implementation**

Ask user for iteration limit:
"How many iterations should Ralph run? (default: 5, max recommended: 10)"

Then execute using Task tool with Bash agent in background:
```
Use Task tool:
  subagent_type: Bash
  run_in_background: true
  prompt: "Run ~/.claude/ralph.sh [iterations] and monitor output"
```

Inform user:
"Ralph is now running autonomously. Each iteration will:
1. Select highest-priority incomplete story
2. Implement the story
3. Run quality checks
4. Commit if passing
5. Update prd.json

You can check progress with:
- cat prd.json | jq '.userStories[] | {id, title, passes}'
- cat progress.txt
- git log --oneline -10

Ralph will exit when all stories pass or iteration limit reached."
</step>

<step name="6_monitor_completion">
**Track progress**

Periodically check:
```bash
# Story status
cat prd.json | jq '.userStories[] | {id, title, passes}'

# Recent commits
git log --oneline -5

# Learnings
tail -20 progress.txt
```

When all stories have `passes: true`, Ralph outputs `<promise>COMPLETE</promise>` and exits.
</step>

</process>

<success_criteria>
Full pipeline is complete when:
- [ ] SPEC.md created and reviewed
- [ ] PRD created with verifiable acceptance criteria
- [ ] prd.json has atomic stories ordered by dependency
- [ ] Ralph executed successfully
- [ ] All stories have `passes: true`
- [ ] Code committed and pushed
</success_criteria>
