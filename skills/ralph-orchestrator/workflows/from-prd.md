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
**Run autonomous implementation via subagent loop**

**CRITICAL: ALL implementation MUST go through ralph-coder/ralph-tester subagents via the Task tool. NEVER write code or modify project files directly.**

Follow the subagent execution loop defined in `workflows/execute-only.md` step 3 (framework detection) and step 4 (subagent loop).

This will:
1. Detect project framework and build agent routing table
2. Group independent stories into parallel batches
3. For each batch:
   - Phase 1: Spawn ralph-coder Tasks in parallel (one per story, each in a worktree)
   - Phase 2: Spawn ralph-tester Tasks in parallel (in same worktrees)
   - Merge successful stories to main, update prd.json
4. Continue until all stories done or max iterations reached

**After the loop completes:**
- **All stories done**: Report success.
- **Max iterations reached**: **STOP and ask the user for instructions.**
- **All blocked/exhausted**: **STOP and show failed stories with `lastAttemptLog`. Ask the user for instructions.**

**NEVER continue past incomplete execution without user approval.**
</step>

</process>

<success_criteria>
- [ ] PRD converted to tasks/prd.json with new schema
- [ ] Stories are atomic, ordered, with verificationCommands and blockedBy
- [ ] Ralph executed via subagent loop with parallel batches
- [ ] All stories have `status: "done"`
</success_criteria>
