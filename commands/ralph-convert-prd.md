---
description: Convert PRD to Ralph prd.json format
argument-hint: [PRD content or path]
allowed-tools: Skill(ralph-convert-prd)
---

<objective>
Convert a Product Requirements Document into prd.json format for the Ralph autonomous agent system.

Invoke the ralph-convert-prd skill for: $ARGUMENTS
</objective>

<context>
PRD source: $ARGUMENTS (can be file path or inline content)
</context>

<process>
1. Read PRD from provided path or content
2. Read SPEC.md if available (for verification environment info)
3. Extract features and requirements
4. Break down into atomic user stories (one context window each)
5. Classify each story with storyType (database, backend, api, frontend, infra, test)
6. Order stories correctly (schema → backend → UI → dashboard)
7. Set blockedBy dependencies between stories
8. Add verifiable acceptance criteria to each story
9. Generate verificationCommands with real runtime checks per storyType
10. Generate prd.json with new schema (status, attempts, maxAttempts, verificationCommands, blockedBy)
</process>

<success_criteria>
- All PRD features converted to user stories
- Each story is atomic (completable in one context window)
- Each story has storyType and verificationCommands with real runtime checks
- Stories ordered with no forward dependencies, blockedBy set
- Acceptance criteria are specific and verifiable
- prd.json created with new schema and validated
</success_criteria>
