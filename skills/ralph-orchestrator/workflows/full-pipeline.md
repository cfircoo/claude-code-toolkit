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
- Gather verification environment info (dev server, DB, test runners, ports)
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
- Classify each story with `storyType` (backend, frontend, database, api, infra, test)
- Order by dependency (schema → backend → UI → dashboard)
- Generate `verificationCommands` with real runtime checks per storyType
- Set `blockedBy` dependencies between stories
- Add mandatory criteria ("Typecheck passes")
- Output tasks/prd.json

**User checkpoint:** Review prd.json stories. Ask user:
"prd.json created with [N] user stories. Please review:
- Are stories atomic (one context window each)?
- Is ordering correct (no forward dependencies)?
- Does each story have real verification commands (curl, Playwright, DB queries)?
- Are blockedBy dependencies correct?

Ready to execute Ralph?"
</step>

<step name="4_pre_execution_check">
**Verify prerequisites**

Before running Ralph, confirm:
```bash
# Check ralph.sh exists
ls -la ~/projects/claude-code-toolkit/skills/ralph-orchestrator/scripts/ralph.sh

# Verify prd.json is valid and has new schema fields
cat tasks/prd.json | jq '{
  stories: (.userStories | length),
  with_status: ([.userStories[] | select(.status != null)] | length),
  with_verification: ([.userStories[] | select(.verificationCommands != null and (.verificationCommands | length) > 0)] | length),
  with_storyType: ([.userStories[] | select(.storyType != null)] | length)
}'

# Check git status is clean
git status
```

If ralph.sh doesn't exist, inform user they need to set it up.
</step>

<step name="5_execute_ralph">
**Run autonomous implementation via ralph.sh**

**CRITICAL: ALL implementation MUST go through ralph.sh. NEVER write code or modify project files directly. You are the orchestrator, not the implementer.**

Ask user for iteration limit:
"How many iterations should Ralph run? (default: 5, max recommended: 10)"

Then execute ralph.sh:
```bash
~/projects/claude-code-toolkit/skills/ralph-orchestrator/scripts/ralph.sh [iterations]
```

**After ralph.sh exits, check the exit code:**
- **Exit 0**: All stories completed. Proceed to step 6.
- **Exit 1**: Max iterations reached. **STOP and inform the user.** Show status summary and ask for instructions (increase iterations? review failures? adjust stories?).
- **Exit 2**: All remaining stories blocked or exhausted. **STOP and inform the user.** Show failed stories with their `lastAttemptLog` and ask for instructions.

**NEVER continue past a non-zero exit code without user approval.**
</step>

<step name="6_monitor_completion">
**Track progress**

Periodically check:
```bash
# Story status
cat tasks/prd.json | jq '.userStories[] | {id, title, status, attempts}'

# Recent commits
git log --oneline -5

# Learnings
tail -20 tasks/progress.txt
```

When all stories have `status: "done"`, Ralph outputs `<promise>COMPLETE</promise>` and exits.
If Ralph exits with code 2, review failed stories and consider revising.
</step>

</process>

<success_criteria>
Full pipeline is complete when:
- [ ] SPEC.md created and reviewed (including verification environment section)
- [ ] PRD created with verifiable acceptance criteria
- [ ] prd.json has atomic stories with storyType, verificationCommands, and blockedBy
- [ ] Ralph executed successfully
- [ ] All stories have `status: "done"`
- [ ] All verification commands passed (real runtime checks)
- [ ] Code committed and pushed
</success_criteria>
