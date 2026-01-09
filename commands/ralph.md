---
description: Orchestrate Ralph pipeline (spec → PRD → prd.json → execute)
argument-hint: [feature description | "status" | "continue" | "execute"]
allowed-tools: Skill(ralph-orchestrator), Skill(spec-interview), Skill(generate-prd), Skill(ralph-convert-prd), Bash, Read, Write, Edit, Task, AskUserQuestion
---

<objective>
Orchestrate the complete Ralph autonomous agent pipeline for feature development.

This skill coordinates: spec-interview → generate-prd → ralph-convert-prd → ralph.sh execution, keeping you in control at each decision point while enabling autonomous implementation.
</objective>

<context>
User request: $ARGUMENTS

Current state:
- prd.json exists: !`[ -f prd.json ] && echo "YES" || echo "NO"`
- Story status: !`cat prd.json 2>/dev/null | jq -r '(.userStories | length) as $total | ([.userStories[] | select(.passes == true)] | length) as $passed | "\($passed)/\($total) stories complete"' 2>/dev/null || echo "No prd.json"`
</context>

<routing>
Based on $ARGUMENTS, route to the appropriate workflow:

| Argument | Action |
|----------|--------|
| "status", "check", "progress" | Check current prd.json status and suggest next steps |
| "continue", "from-prd" | Convert existing PRD to prd.json and execute |
| "execute", "run" | Run ralph.sh on existing prd.json |
| Feature description or empty | Start full pipeline (spec → PRD → prd.json → execute) |
</routing>

<process>
1. Invoke the ralph-orchestrator skill
2. Present the intake menu if no clear routing from arguments
3. Follow the selected workflow exactly
4. Pause at each user checkpoint for approval
5. For execution, spawn ralph.sh as background task
</process>

<success_criteria>
- Correct workflow selected based on user intent
- User approves at each checkpoint (spec, PRD, prd.json)
- All stories reach `passes: true` status
- Code committed and quality checks passing
</success_criteria>
