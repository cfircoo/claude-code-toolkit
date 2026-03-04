# /ralph Command

Orchestrate autonomous agent loop for story-by-story feature implementation.

## Usage

```bash
/ralph              # Full pipeline: spec → PRD → stories → execution
/ralph status       # Check current prd.json progress
/ralph execute      # Skip interview/PRD, start execution loop
/ralph retry US-001 # Retry a specific story
```

## What It Does

Ralph automates the complete feature development pipeline:

1. **Specification Interview** — Gather requirements
2. **PRD Generation** — Create product requirements document
3. **Story Conversion** — Break PRD into atomic user stories
4. **Autonomous Execution** — Implement stories one by one
5. **Verification** — Test each story meets acceptance criteria
6. **Progress Tracking** — Monitor execution and learnings

## Full Pipeline

```
> /ralph my-feature
# Starts complete workflow

# 1. Specification Interview
> Tell me about your feature requirements
# (Interview questions about scope, users, features)

# 2. PRD Created
tasks/prd-my-feature.md

# 3. Convert to Stories
> /ralph-convert-prd tasks/prd-my-feature.md
# Creates tasks/prd.json with atomic stories

# 4. Execution Loop
# Ralph reads stories from tasks/prd.json
# For each pending story:
#   - Create fresh Claude instance
#   - Load story requirements
#   - Implement code
#   - Run verification commands
#   - Track results and learnings
```

## Story Status

Stories progress through states:

| Status | Meaning |
|--------|---------|
| `pending` | Not yet started |
| `in_progress` | Currently executing |
| `done` | Completed successfully |
| `failed` | Execution failed |
| `blocked` | Blocked by dependency |

## Output Files

Ralph creates these files in `tasks/`:

| File | Purpose |
|------|---------|
| `prd.json` | Stories and verification commands |
| `ralph.log` | Real-time execution log |
| `test-log.md` | Test registry and results |
| `review-notes.md` | Learnings and notes |

## Checking Progress

```
> /ralph status
# Shows:
# - Current story being worked on
# - Completed stories
# - Failed/blocked stories
# - Overall progress

Story Progress:
  US-001: ✓ done       (auth: create user)
  US-002: ⧖ in_progress (auth: login functionality)
  US-003: ○ pending    (auth: password reset)
```

## Story Format

Each story in `prd.json`:

```json
{
  "id": "US-001",
  "title": "Create user authentication",
  "description": "Implement JWT-based user authentication",
  "acceptanceCriteria": [
    "Users can register with email",
    "Passwords are securely hashed",
    "JWT tokens are generated"
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
  "status": "pending",
  "maxAttempts": 3
}
```

## Verification Commands

Stories include commands that verify completion:

```json
"verificationCommands": [
  {
    "command": "npm test",
    "expect": {
      "exit_code": 0,
      "contains": "all tests passed"
    }
  }
]
```

Matchers:
- `exit_code` — Command must exit with this code
- `contains` — Output must contain string
- `matches` — Output must match regex pattern
- `notContains` — Output must not contain
- `notMatches` — Output must not match

## Handling Failures

When a story fails:

1. Ralph logs the error in `tasks/ralph.log`
2. Analyzes the failure
3. Retries if attempts remain
4. Marks as `failed` if max attempts exceeded

To manually fix and retry:

```bash
# Fix the issue (code, tests, etc.)
> /ralph retry US-002

# Or continue from current point
> /ralph execute
```

## Best Practices

### PRD Quality
- Clear, measurable acceptance criteria
- Realistic scope per story
- Proper story ordering
- Document dependencies

### Verification
- Use real test commands, not assertions
- Commands should actually test the feature
- Multiple verification points per story
- Clear pass/fail conditions

### Story Design
- One feature per story
- 2-4 hour stories typically
- Independent implementation when possible
- Clear boundaries and dependencies

### Tracking Progress
- Monitor `tasks/ralph.log` for details
- Review `tasks/review-notes.md` for learnings
- Update story status as you work
- Mark `blockedBy` dependencies clearly

## Advanced Features

### Story Dependencies

Stories can depend on other stories:

```json
{
  "id": "US-002",
  "blockedBy": ["US-001"],
  "title": "Login functionality"
}
```

Ralph respects dependencies and executes in order.

### Documentation Updates

Track docs needing updates:

```json
{
  "id": "US-001",
  "docsToUpdate": [
    "README.md",
    "docs/auth.md",
    "docs/api.md"
  ]
}
```

Ralph logs which docs changed in `review-notes.md`.

### Parallel Execution

Independent stories can be executed in parallel (future enhancement).

## Integration

Ralph uses:
- [ralph-coder agent](../agents/ralph-coder.md) — Implements stories
- [ralph-tester agent](../agents/ralph-tester.md) — Verifies stories
- [generate-prd skill](../skills/generate-prd.md) — Creates PRD
- [ralph-convert-prd skill](../skills/ralph-convert-prd.md) — Converts to stories
- [ralph-orchestrator skill](../skills/ralph-orchestrator.md) — Orchestration logic

## Workflow Examples

### Example 1: New Feature

```bash
> /ralph dashboard-feature
# Interview → PRD → Stories → Execution
# Each story builds on previous: layouts → data → interactions
```

### Example 2: Start with Existing PRD

```bash
> /ralph-convert-prd docs/prd-payments.md
# Converts existing PRD to stories
> /ralph execute
# Executes without interview/PRD generation
```

### Example 3: Resume Interrupted Work

```bash
> /ralph status
# Check which stories are pending/in progress
> /ralph execute
# Continue execution loop
```

## Troubleshooting

### Story won't complete
- Check verification commands work locally
- Review acceptance criteria are testable
- Check story doesn't depend on unfinished story
- Look at `tasks/ralph.log` for details

### Verification always fails
- Simplify verification command first
- Check command syntax and paths
- Verify output format matches expectations
- Run command manually to test

### Progress not saved
- Check `tasks/prd.json` is writable
- Verify disk space available
- Look for permissions issues
- Review `tasks/ralph.log` for errors

## Tips

1. **Start with interview** — Let Ralph understand requirements
2. **Review PRD before execution** — Make sure stories make sense
3. **Keep stories focused** — One feature per story
4. **Write real verification** — Actual tests, not assertions
5. **Monitor logs** — Watch `tasks/ralph.log` during execution
6. **Save learnings** — Review `tasks/review-notes.md`
7. **Update docs** — Don't forget documentation changes

## Related Commands

- [/spec-interview](spec-interview.md) — Create specification
- [/generate-prd](generate-prd.md) — Create PRD manually
- [/ralph-convert-prd](ralph-convert-prd.md) — Convert PRD to stories

## Related Skills

- [ralph-orchestrator](../skills/ralph-orchestrator.md) — Orchestration guide
- [generate-prd](../skills/generate-prd.md) — PRD creation
- [ralph-convert-prd](../skills/ralph-convert-prd.md) — Story conversion

## Related Agents

- [ralph-coder](../agents/ralph-coder.md) — Story implementation
- [ralph-tester](../agents/ralph-tester.md) — Story verification
