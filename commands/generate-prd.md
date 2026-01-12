---
description: Generate PRD for a new feature
argument-hint: [feature name or description]
allowed-tools: Skill(generate-prd)
---

<objective>
Generate a Product Requirements Document for a new feature through guided discovery with clarifying questions.

Invoke the generate-prd skill for: $ARGUMENTS
</objective>

<context>
Feature request: $ARGUMENTS
</context>

<process>
1. Understand feature intent from $ARGUMENTS
2. Ask clarifying questions to gather requirements
3. Define problem statement and goals
4. Specify functional and non-functional requirements
5. Create PRD with verifiable acceptance criteria
6. Save to tasks/prd-[feature-name].md
</process>

<success_criteria>
- Feature requirements fully understood
- PRD covers problem, goals, and requirements
- Acceptance criteria are specific and testable
- PRD saved to correct location
</success_criteria>
