# create-plans Skill

Hierarchical project planning for solo developers building with Claude.

## Overview

Expert guidance on creating comprehensive, phased implementation plans that break large projects into manageable, estimatable tasks.

## When to Use

Use this skill when:
- Starting a new project or feature
- Breaking down a large task into steps
- Planning sprints and milestones
- Creating implementation roadmaps
- Estimating scope and effort

## Plan Structure

Plans are hierarchical with multiple levels:

```
Project
├── Phase 1
│   ├── Section A
│   │   ├── Task 1
│   │   └── Task 2
│   └── Section B
│       └── Task 3
└── Phase 2
    └── ...
```

## Key Concepts

### Phases
- Major milestones or chapters
- Ordered execution (complete phase 1 before 2)
- Clear success criteria
- Estimated duration

### Sections
- Logical groupings within phase
- Related tasks
- Dependencies tracked
- Owner assignment

### Tasks
- Atomic, implementable units
- Clear acceptance criteria
- Effort estimates (hours/days)
- Prerequisite tracking

### Checkpoints
- User approval gates
- Review points
- Deployment boundaries
- Feedback collection

## Usage Example

```
> Create a phased plan for building a SaaS dashboard
```

This will:
1. Interview you about requirements
2. Break down into phases
3. Define clear tasks
4. Estimate effort
5. Identify dependencies
6. Create timeline

## Plan Components

### Metadata
- Project name and description
- Goals and success metrics
- Timeline and milestones
- Owner and stakeholders

### Phases
- Phase number and name
- Description
- Duration estimate
- Success criteria

### Sections
- Section name and purpose
- Related tasks
- Dependencies
- Effort total

### Tasks
- Task ID and name
- Description
- Acceptance criteria
- Effort estimate
- Prerequisites
- Dependencies

### Checkpoints
- Checkpoint name
- Trigger (after task X)
- Decision required
- Next steps

## Best Practices

### Estimation
- Use relative sizing (S, M, L, XL)
- Add 20% buffer for unknowns
- Break down unclear tasks
- Revisit estimates regularly

### Dependencies
- Map task dependencies clearly
- Minimize cross-phase dependencies
- Identify blockers early
- Plan parallel work

### Granularity
- Keep tasks under 8 hours
- One responsibility per task
- Clear success criteria
- Testable/verifiable

### Documentation
- Include spike investigation tasks
- Document design decisions
- Plan for testing and QA
- Include deployment steps

## Integration with Commands

Available through:
- `/spec-interview` — Specification before planning
- Manual planning request

## Integration with Skills

Uses:
- [spec-interview](spec-interview.md) — For understanding requirements
- [debug-like-expert](debug-like-expert.md) — For breaking down complex problems

## Plan Template

Plans are output as `.planning/plan.md` with:
- Table of contents
- Executive summary
- Detailed phases
- Risk analysis
- Timeline view
- Dependency graph
- Checklist for tracking

## Advanced Topics

### Rolling Waves
- High-level phases upfront
- Detailed planning phase-by-phase
- Adjust based on learnings
- Adapt to changes

### User Gates
- Approval checkpoints
- Feedback loops
- Decision points
- Iteration blocks

### Dependency Management
- Identifying critical path
- Parallel work streams
- Resource planning
- Risk mitigation

### Scope Management
- In-scope vs out-of-scope
- Change tracking
- Priority ordering
- Scope creep prevention

## Related Skills

- [spec-interview](spec-interview.md) — Gather requirements first
- [manage-skills](manage-skills.md) — Create custom planning skills
- [debug-like-expert](debug-like-expert.md) — For breaking down problems

## Output Format

Plans are saved in `.planning/` directory:

```
.planning/
├── plan.md              # Main plan document
├── phases/              # Phase details
│   ├── phase-1.md
│   └── phase-2.md
├── tasks.csv            # Flat task list
└── timeline.md          # Visual timeline
```

## Tips

- Start with a specification (use `/spec-interview`)
- Get user approval on phases before detailing
- Keep tasks independently completeable
- Plan for documentation as a task
- Include testing and QA planning
- Build in contingency and learning time
- Review and adjust as you execute

## Related Agents

Planning is used by:
- [ralph-orchestrator](../agents/ralph-orchestrator.md) — For executing plans autonomously
