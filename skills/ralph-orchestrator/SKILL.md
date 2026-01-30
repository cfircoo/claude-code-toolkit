---
name: ralph-orchestrator
description: Orchestrates the full Ralph autonomous agent pipeline from requirements gathering to execution. Use when building new features, platforms, or complex tasks that need structured development through spec-interview, PRD generation, and autonomous implementation.
model: claude-opus-4-5
context: fork
---

<objective>
Orchestrate the complete Ralph pipeline for autonomous feature development:

1. **spec-interview** → Gather comprehensive requirements through guided discovery
2. **generate-prd** → Create actionable Product Requirements Document
3. **ralph-convert-prd** → Transform PRD into atomic user stories (prd.json)
4. **ralph.sh** → Execute autonomous implementation loop

This skill coordinates these tools while keeping you in control at decision points.
</objective>

<essential_principles>

<principle name="fresh_context_per_iteration">
Ralph spawns fresh Claude instances for each story. Memory persists only through:
- Git history (committed code)
- tasks/progress.txt (learnings between iterations)
- tasks/prd.json (story status tracking)

**Never assume Ralph "remembers" previous iterations.**
</principle>

<principle name="atomic_stories">
Each user story MUST be completable in ONE context window.

**Right-sized:**
- Add a database column
- Create a UI component
- Update a server action
- Implement a filter

**Too large (will fail):**
- Build entire dashboard
- Add authentication system
- Refactor entire API
</principle>

<principle name="real_verification">
Every story must be verified with **real runtime checks** — not just that it compiles.

- **API stories**: curl endpoints with real data, check response codes and bodies
- **UI stories**: Playwright e2e tests that navigate and interact with real UI
- **Database stories**: Run migrations, query DB directly to confirm schema
- **Infra stories**: Health checks, config validation, service startup

Static checks (typecheck, lint) are baseline. Runtime validation is required.
</principle>

<principle name="quality_gates">
All checks must pass before Ralph commits:
- Story-specific verification commands pass (real runtime checks)
- **Full test suite passes** (unit + integration + e2e) — no regressions allowed
- TypeCheck passes
- UI verified via Playwright (for frontend stories)

After each story, Ralph runs ALL existing tests (via `testCommands` in prd.json root) to catch regressions. A story is NOT done until the entire test suite passes. Broken code compounds across iterations — never skip quality checks.
</principle>

<principle name="status_tracking">
Stories use structured status tracking:
- `"pending"` → not started
- `"in_progress"` → being worked on this iteration
- `"done"` → verified and committed
- `"failed"` → attempted but verification failed
- `"blocked"` → dependencies not met

Stories track `attempts` / `maxAttempts` to prevent infinite retries on broken stories.
</principle>

<principle name="user_control_points">
You approve at each stage:
1. After spec-interview → Review SPEC.md
2. After generate-prd → Review PRD
3. After ralph-convert-prd → Review prd.json stories
4. Before ralph.sh → Confirm ready to execute

Don't rush. Bad requirements = wasted iterations.
</principle>

</essential_principles>

<prd_json_schema>
```json
{
  "project": "[Project Name]",
  "branchName": "ralph/[feature-name-kebab-case]",
  "description": "[Feature description]",
  "testCommands": {
    "unit": "npm test",
    "integration": "npm run test:integration",
    "e2e": "npx playwright test",
    "typecheck": "npm run typecheck"
  },
  "userStories": [
    {
      "id": "US-001",
      "title": "[Story title]",
      "description": "As a [user], I want [feature] so that [benefit]",
      "storyType": "backend | frontend | database | api | infra | test",
      "acceptanceCriteria": ["Specific criterion 1", "Typecheck passes"],
      "verificationCommands": [
        { "command": "npm run typecheck", "expect": "exit_code:0" },
        { "command": "curl -s http://localhost:3000/api/...", "expect": "contains:expected" }
      ],
      "status": "pending",
      "priority": 1,
      "attempts": 0,
      "maxAttempts": 3,
      "notes": "",
      "blockedBy": [],
      "docsToUpdate": ["README.md", "docs/api.md"],
      "completedAt": null,
      "lastAttemptLog": ""
    }
  ]
}
```

**Expect matchers for verificationCommands:**
- `exit_code:0` — command exits with code 0
- `exit_code:N` — command exits with specific code N
- `contains:STRING` — stdout contains STRING
- `not_empty` — stdout is non-empty
- `matches:REGEX` — stdout matches regex pattern
</prd_json_schema>

<intake>
What would you like to do?

1. **Full pipeline** - Start from scratch (spec → PRD → prd.json → execute)
2. **Continue from PRD** - Already have PRD, convert and execute
3. **Execute only** - Already have prd.json, run Ralph
4. **Check status** - View current prd.json progress

**Wait for response before proceeding.**
</intake>

<routing>
| Response | Workflow |
|----------|----------|
| 1, "full", "start", "new feature" | `workflows/full-pipeline.md` |
| 2, "continue", "have PRD", "convert" | `workflows/from-prd.md` |
| 3, "execute", "run ralph", "have prd.json" | `workflows/execute-only.md` |
| 4, "status", "check", "progress" | `workflows/check-status.md` |

**After reading the workflow, follow it exactly.**
</routing>

<quick_reference>

**Key Files:**
| File | Purpose |
|------|---------|
| SPEC.md | Comprehensive requirements from spec-interview |
| tasks/prd-*.md | Product Requirements Document |
| tasks/prd.json | Atomic user stories for Ralph |
| tasks/progress.txt | Learnings between iterations |
| scripts/ralph.sh | Ralph execution script (in this skill folder) |
| scripts/prompt.md | Iteration prompt template |

**Commands:**
```bash
# Run Ralph from your project directory
~/projects/claude-code-toolkit/skills/ralph-orchestrator/scripts/ralph.sh

# Or create an alias in ~/.bashrc:
alias ralph='~/projects/claude-code-toolkit/skills/ralph-orchestrator/scripts/ralph.sh'

# Run with custom iteration limit
ralph 5

# Check story status (new schema)
cat tasks/prd.json | jq '.userStories[] | {id, title, status, attempts}'

# View learnings
cat tasks/progress.txt
```

</quick_reference>

<workflows_index>
| Workflow | Purpose |
|----------|---------|
| full-pipeline.md | Complete flow: spec → PRD → prd.json → execute |
| from-prd.md | Convert existing PRD and execute |
| execute-only.md | Run Ralph on existing prd.json |
| check-status.md | View current progress |
</workflows_index>

<success_criteria>
Pipeline is complete when:
- [ ] Requirements gathered through spec-interview (including verification environment)
- [ ] PRD created with verifiable acceptance criteria
- [ ] prd.json has atomic stories with storyType, verificationCommands, and blockedBy
- [ ] All stories have `status: "done"` in prd.json
- [ ] All verification commands passed (real runtime checks, not just typecheck)
- [ ] Code committed and quality checks passing
</success_criteria>
