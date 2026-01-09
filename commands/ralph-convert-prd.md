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
2. Extract features and requirements
3. Break down into atomic user stories (one context window each)
4. Order stories correctly (schema → backend → UI → dashboard)
5. Add verifiable acceptance criteria to each story
6. Generate prd.json with proper structure
</process>

<success_criteria>
- All PRD features converted to user stories
- Each story is atomic (completable in one context window)
- Stories ordered with no forward dependencies
- Acceptance criteria are specific and verifiable
- prd.json created and validated
</success_criteria>
