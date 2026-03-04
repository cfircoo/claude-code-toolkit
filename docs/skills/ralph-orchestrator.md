# ralph-orchestrator Skill

Orchestrate autonomous agent loop for story-by-story feature implementation with verification.

## Overview

Ralph is an autonomous execution framework that takes a product requirement document (PRD) and implements it story-by-story, with each story executed in a fresh Claude instance and verified against acceptance criteria.

## When to Use

Use Ralph when:
- Implementing complete features autonomously
- Building from PRD to production code
- Requiring real verification between stories
- Need full test coverage with each story
- Want story-by-story execution with checkpoints

## Key Concepts

### Story-Based Execution
- Each user story is a unit of work
- Stories execute in isolation (fresh Claude instance)
- No shared conversation context
- Results aggregated in main session

### Verification
- Automated testing of each story
- Expectation matchers (exit_code, contains, matches)
- Real verification (not assertions)
- Blocks on failure, allows retries

### State Management
- Stories track: pending → in_progress → done/failed/blocked
- Atomic story completion
- Progress persistence
- Rollback on failure

## Ralph Workflow

### Step 1: Specification
```bash
> /spec-interview my-feature
```
Creates comprehensive feature specification.

### Step 2: PRD Generation
```bash
> /generate-prd my-feature
```
Creates product requirement document with:
- Feature overview
- User stories
- Acceptance criteria
- Success metrics

### Step 3: Convert to Stories
```bash
> /ralph-convert-prd tasks/prd-my-feature.md
```
Converts PRD to atomic user stories in `tasks/prd.json`.

### Step 4: Execute Loop
```bash
> /ralph
```
Starts autonomous execution:
- Reads stories from `tasks/prd.json`
- Creates fresh Claude instance per story
- Executes story implementation
- Runs verification suite
- Logs results
- Moves to next story

## Story Format

Stories in `prd.json`:

```json
{
  "stories": [
    {
      "id": "US-001",
      "title": "Create user authentication",
      "description": "Implement JWT-based authentication",
      "acceptanceCriteria": [
        "Users can register with email",
        "Users can login",
        "Sessions are validated"
      ],
      "verificationCommands": [
        {
          "command": "npm test -- auth.test.js",
          "expect": {
            "exit_code": 0,
            "contains": "3 passed"
          }
        }
      ],
      "maxAttempts": 3,
      "status": "pending",
      "docsToUpdate": ["README.md", "docs/auth.md"]
    }
  ]
}
```

### Story Fields

| Field | Description |
|-------|-------------|
| `id` | Unique story identifier |
| `title` | Story title |
| `description` | What to implement |
| `acceptanceCriteria` | Success criteria |
| `verificationCommands` | Tests to run |
| `maxAttempts` | Retry limit (default: 3) |
| `status` | pending/in_progress/done/failed/blocked |
| `blockedBy` | Dependencies on other stories |
| `docsToUpdate` | Documentation to update |

## Verification Commands

Each story can have multiple verification commands:

```json
"verificationCommands": [
  {
    "command": "npm test",
    "expect": {
      "exit_code": 0,
      "contains": "passed",
      "matches": "^All tests passed"
    }
  }
]
```

Matchers:
- `exit_code` — Command exit code (0 = success)
- `contains` — Output must contain string
- `matches` — Output must match regex
- `notContains` — Output must not contain
- `notMatches` — Output must not match

## Execution Flow

```
/ralph command
    │
    ├─> Read tasks/prd.json
    │
    ├─> Find pending story
    │
    ├─> Update status to in_progress
    │
    ├─> Create fresh Claude instance
    │
    ├─> Load story details
    │
    ├─> Execute implementation
    │
    ├─> Run verification commands
    │
    ├─> Check expectations
    │
    ├─> Update status (done/failed)
    │
    ├─> Log to tasks/ralph.log
    │
    └─> Move to next story
```

## Logging and Output

Ralph creates detailed logs in `tasks/`:

### ralph.log
Real-time execution log with timestamps and story progress.

### test-log.md
Registry of all test runs with:
- Story ID and title
- Test commands executed
- Results and output
- Timestamp

### review-notes.md
Learning notes after each story:
- What worked
- What didn't
- Patterns discovered
- Improvements for next stories

## Commands

### Full Pipeline
```bash
/ralph
```
Complete flow: spec-interview → PRD → prd.json → execution

### Status Check
```bash
/ralph status
```
Shows current prd.json progress and story statuses.

### Execute Only
```bash
/ralph execute
```
Skip interview/PRD, start execution loop.

### Story Retry
```bash
/ralph retry US-001
```
Retry a specific story.

## Handling Failures

### When Story Fails

Ralph will:
1. Log failure details
2. Increment attempt counter
3. If attempts remaining: retry with analysis
4. If max attempts reached: mark as failed/blocked

### User Intervention

When a story is blocked:
1. Review failure logs in `tasks/ralph.log`
2. Fix issue (code, tests, environment)
3. Retry: `/ralph retry US-001`
4. Continue: `/ralph execute`

## Best Practices

### PRD Quality
- Clear, measurable acceptance criteria
- Realistic scope per story
- Proper story ordering
- Documented dependencies

### Verification
- Actual tests, not just assertions
- Real commands (npm test, python -m pytest, etc.)
- Multiple verification points
- Clear pass/fail conditions

### Story Granularity
- One feature per story
- 2-4 hour stories typically
- Independent implementation
- Clear boundaries

### Documentation
- Update README with features
- Add API documentation
- Include usage examples
- Document configuration

## Integration with Commands

Available as:
- `/ralph` — Full orchestration
- `/ralph status` — Check progress
- `/generate-prd` — Create PRD first
- `/ralph-convert-prd` — Convert PRD to stories

## Integration with Agents

Ralph uses these agents:
- [ralph-coder](../agents/ralph-coder.md) — Story implementation
- [ralph-tester](../agents/ralph-tester.md) — Story verification

## Advanced Topics

### Branching Stories

Stories with dependencies:
```json
{
  "id": "US-002",
  "blockedBy": ["US-001"],
  ...
}
```

### Conditional Execution

Stories can have conditions or prerequisites that block execution.

### Performance Optimization

- Parallel story execution (when independent)
- Caching build artifacts
- Reusing environments
- Minimizing context overhead

## Troubleshooting

### Story Won't Complete
1. Check verification commands in prd.json
2. Run commands locally to verify they work
3. Review failure logs in tasks/ralph.log
4. Check acceptance criteria are testable

### Verification Always Fails
1. Simplify verification commands first
2. Check command syntax and paths
3. Verify output format matches expectations
4. Run locally before adding to prd.json

### Progress Tracking
1. Check tasks/prd.json for current status
2. Review tasks/ralph.log for details
3. Use `/ralph status` for overview

## Output Artifacts

Ralph creates in `tasks/` directory:

```
tasks/
├── prd.json              # Stories and verification
├── ralph.log             # Execution log
├── test-log.md           # Test registry
├── review-notes.md       # Learnings
└── archive/              # Previous runs
    └── branch-name/
        ├── prd.json.bak
        └── ralph.log.bak
```

## Related Skills

- [generate-prd](generate-prd.md) — Create PRD first
- [ralph-convert-prd](ralph-convert-prd.md) — Convert to stories
- [create-plans](create-plans.md) — Project planning
- [git](git.md) — Commit progress

## Related Agents

- [ralph-coder](../agents/ralph-coder.md) — Implements stories
- [ralph-tester](../agents/ralph-tester.md) — Verifies stories

## Key Principles

- **Never direct implementation** — All code changes through fresh Claude
- **Real verification** — Actual test commands, not assertions
- **Failure isolation** — One failed story doesn't block others
- **Full test suite** — Must pass after each story
- **Documented changes** — Track what docs need updating
