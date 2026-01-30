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
**Transform PRD to tasks/prd.json**

Invoke the ralph-convert-prd skill:
```
Use Skill tool: ralph-convert-prd
Arguments: [PRD file path]
```

**User checkpoint:** Review tasks/prd.json stories. Ask:
"prd.json created with [N] user stories. Please review:
- Are stories atomic (one context window each)?
- Is ordering correct (no forward dependencies)?
- Does each story have real verification commands (curl, Playwright, DB queries)?
- Are blockedBy dependencies correct?

Ready to execute Ralph?"
</step>

<step name="3_execute_ralph">
**Run autonomous implementation via ralph.sh**

**CRITICAL: ALL implementation MUST go through ralph.sh. NEVER write code or modify project files directly.**

Ask user for iteration limit:
"How many iterations should Ralph run? (default: 5)"

Execute:
```bash
~/projects/claude-code-toolkit/skills/ralph-orchestrator/scripts/ralph.sh [iterations]
```

**After ralph.sh exits, check the exit code:**
- **Exit 0**: All stories completed successfully.
- **Exit 1**: Max iterations reached. **STOP and ask the user for instructions.**
- **Exit 2**: All stories blocked or exhausted. **STOP and show failed stories with `lastAttemptLog`. Ask the user for instructions.**

**NEVER continue past a non-zero exit code without user approval.**
</step>

</process>

<success_criteria>
- [ ] PRD converted to tasks/prd.json with new schema
- [ ] Stories are atomic, ordered, with verificationCommands and blockedBy
- [ ] Ralph executed via ralph.sh
- [ ] All stories have `status: "done"`
</success_criteria>
