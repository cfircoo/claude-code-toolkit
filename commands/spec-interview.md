---
description: Interview to build comprehensive project specification
argument-hint: [SPEC.md path or project name]
allowed-tools: Skill(spec-interview)
---

<objective>
Gather comprehensive requirements through guided discovery to build a project specification.

Invoke the spec-interview skill with context: $ARGUMENTS
</objective>

<context>
If a file path is provided, read it first.
If a project name is provided, use it to contextualize the interview.
If nothing is provided, start fresh.
</context>

<process>
1. Determine starting context from $ARGUMENTS
2. If file path provided, read existing spec
3. Conduct structured interview with clarifying questions
4. Build comprehensive SPEC.md from responses
5. Save specification to agreed location
</process>

<success_criteria>
- All key requirement areas covered
- Specification is comprehensive and unambiguous
- SPEC.md created or updated with gathered requirements
</success_criteria>
