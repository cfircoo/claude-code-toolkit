# Component Reference

Quick reference for all toolkit components organized by type.

## Skills (18 Total)

### Development & Testing
| Skill | Description | Use For |
|-------|-------------|---------|
| [git](skills/git.md) | Git operations with safety | Commits, pushes, PRs |
| [pytest-best-practices](skills/pytest-best-practices.md) | Expert pytest patterns | Writing tests, fixtures |
| [sqlalchemy-postgres](skills/sqlalchemy-postgres.md) | Database layers | ORM models, migrations |
| [debug-like-expert](skills/debug-like-expert.md) | Methodical debugging | Complex issues |

### Project Management
| Skill | Description | Use For |
|-------|-------------|---------|
| [create-plans](skills/create-plans.md) | Hierarchical planning | Project planning |
| [spec-interview](skills/spec-interview.md) | Specification interviews | Requirements gathering |
| [create-meta-prompts](skills/create-meta-prompts.md) | Multi-stage workflows | Pipeline prompts |

### Content & Automation
| Skill | Description | Use For |
|-------|-------------|---------|
| [generate-images](skills/generate-images.md) | Image generation | Icons, banners, mockups |
| [generate-prd](skills/generate-prd.md) | PRD creation | Feature requirements |

### Orchestration
| Skill | Description | Use For |
|-------|-------------|---------|
| [ralph-orchestrator](skills/ralph-orchestrator.md) | Autonomous loop | Story execution |
| [ralph-convert-prd](skills/ralph-convert-prd.md) | PRD conversion | User stories |

### Extension Development
| Skill | Description | Use For |
|-------|-------------|---------|
| [manage-skills](skills/manage-skills.md) | Skill creation | Building skills |
| [manage-subagents](skills/manage-subagents.md) | Agent creation | Building agents |
| [manage-slash-commands](skills/manage-slash-commands.md) | Command creation | Building commands |
| [manage-hooks](skills/manage-hooks.md) | Hook creation | Building hooks |

### Security & Utilities
| Skill | Description | Use For |
|-------|-------------|---------|
| [damage-control](skills/damage-control.md) | Security hooks | Safety mechanisms |
| [docs-master](skills/docs-master.md) | Documentation | Writing docs |
| [file-search](skills/file-search.md) | Advanced search | Finding content |

## Agents (12 Total)

### Development
| Agent | Model | Use For |
|-------|-------|---------|
| [git-ops](agents/git-ops.md) | Sonnet | Git automation |
| [db-expert](agents/db-expert.md) | Sonnet | Database setup |
| [pytest-writer](agents/pytest-writer.md) | Sonnet | Test generation |
| [perplexity-research](agents/perplexity-research.md) | Sonnet | Web research |

### Ralph Pipeline
| Agent | Model | Use For |
|-------|-------|---------|
| [ralph-coder](agents/ralph-coder.md) | Sonnet | Story implementation |
| [ralph-tester](agents/ralph-tester.md) | Sonnet | Story verification |

### Fullstack
| Agent | Model | Use For |
|-------|-------|---------|
| [fullstack-manager](agents/fullstack-manager.md) | Opus | Frontend orchestration |
| [fullstack-api-specialist](agents/fullstack-api-specialist.md) | Sonnet | API mapping |
| [fullstack-ui-designer](agents/fullstack-ui-designer.md) | Sonnet | UI design |
| [fullstack-qa-debugger](agents/fullstack-qa-debugger.md) | Sonnet | Integration testing |

### Utilities
| Agent | Model | Use For |
|-------|-------|---------|
| [docs-master](agents/docs-master.md) | Haiku | Documentation |
| [file-search](agents/file-search.md) | Haiku | Advanced search |

## Commands (12 Total)

### Git Workflow
| Command | Trigger | Function |
|---------|---------|----------|
| [git-commit](commands/git-commit.md) | `/git-commit` | Stage & commit |
| [git-push](commands/git-push.md) | `/git-push` | Push to remote |
| [git-pr](commands/git-pr.md) | `/git-pr` | Create PR |
| [git-ship](commands/git-ship.md) | `/git-ship` | Commit+push+PR |

### Project Setup
| Command | Trigger | Function |
|---------|---------|----------|
| [spec-interview](commands/spec-interview.md) | `/spec-interview` | Build spec |
| [generate-prd](commands/generate-prd.md) | `/generate-prd` | Create PRD |

### Content Generation
| Command | Trigger | Function |
|---------|---------|----------|
| [generate-image](commands/generate-image.md) | `/generate-image` | Generate images |

### Ralph Orchestration
| Command | Trigger | Function |
|---------|---------|----------|
| [ralph](commands/ralph.md) | `/ralph` | Orchestrate loop |
| [ralph-convert-prd](commands/ralph-convert-prd.md) | `/ralph-convert-prd` | Convert to stories |

### Database
| Command | Trigger | Function |
|---------|---------|----------|
| [db](commands/db.md) | `/db` | Database ops |

### Settings & Tools
| Command | Trigger | Function |
|---------|---------|----------|
| [concise](commands/concise.md) | `/concise` | Toggle brief mode |
| [install-toolkit](commands/install-toolkit.md) | `/install-toolkit` | Install toolkit |

## Hooks (5 Total)

| Hook | Trigger | Purpose |
|------|---------|---------|
| [concise-mode](hooks/concise-mode.md) | UserPromptSubmit | Brief responses |
| [damage-control](hooks/damage-control.md) | PreToolUse | Security blocks |
| [delegate-first](hooks/delegate-first.md) | UserPromptSubmit | Agent routing |
| [pre-commit-pytest](hooks/pre-commit-pytest.md) | PreToolUse | Test validation |

## Quick Navigation

### By Task

#### Git Workflow
- **Commit**: Use [git skill](skills/git.md) or [/git-commit](commands/git-commit.md)
- **Push**: Use [git skill](skills/git.md) or [/git-push](commands/git-push.md)
- **Create PR**: Use [git skill](skills/git.md) or [/git-pr](commands/git-pr.md)
- **Full workflow**: Use [/git-ship](commands/git-ship.md)
- **Automatic**: Use [git-ops agent](agents/git-ops.md)

#### Database
- **Setup**: Use [sqlalchemy-postgres skill](skills/sqlalchemy-postgres.md) or [/db](commands/db.md)
- **Implement**: Use [db-expert agent](agents/db-expert.md)

#### Testing
- **Patterns**: Use [pytest-best-practices skill](skills/pytest-best-practices.md)
- **Generate**: Use [pytest-writer agent](agents/pytest-writer.md)

#### Planning & Specs
- **Interview**: Use [spec-interview skill](skills/spec-interview.md) or [/spec-interview](commands/spec-interview.md)
- **Plan**: Use [create-plans skill](skills/create-plans.md)
- **PRD**: Use [generate-prd skill](skills/generate-prd.md) or [/generate-prd](commands/generate-prd.md)

#### Autonomous Development
- **Full pipeline**: Use [/ralph](commands/ralph.md)
- **Status**: Use [/ralph status](commands/ralph.md)
- **Implementation**: Uses [ralph-coder agent](agents/ralph-coder.md)
- **Testing**: Uses [ralph-tester agent](agents/ralph-tester.md)

#### Documentation
- **Write docs**: Use [docs-master skill](skills/docs-master.md)
- **Update README**: Use [docs-master skill](skills/docs-master.md)

#### Research
- **Web search**: Use [perplexity-research agent](agents/perplexity-research.md)
- **Codebase search**: Use [file-search skill](skills/file-search.md)

#### Frontend
- **API mapping**: Use [fullstack-api-specialist agent](agents/fullstack-api-specialist.md)
- **UI design**: Use [fullstack-ui-designer agent](agents/fullstack-ui-designer.md)
- **Testing**: Use [fullstack-qa-debugger agent](agents/fullstack-qa-debugger.md)
- **Orchestration**: Use [fullstack-manager agent](agents/fullstack-manager.md)

### By Frequency

#### Daily Use
- [git skill](skills/git.md) — Commits and PRs
- [git-ship command](commands/git-ship.md) — Full workflow
- [/help command](commands/) — See available commands

#### Weekly Use
- [pytest-best-practices skill](skills/pytest-best-practices.md) — Writing tests
- [sqlalchemy-postgres skill](skills/sqlalchemy-postgres.md) — Database work
- [debug-like-expert skill](skills/debug-like-expert.md) — Fixing issues

#### Project Setup
- [spec-interview skill](skills/spec-interview.md) — Start projects
- [create-plans skill](skills/create-plans.md) — Plan implementation
- [install-toolkit command](commands/install-toolkit.md) — Setup toolkit

#### Advanced
- [ralph-orchestrator skill](skills/ralph-orchestrator.md) — Autonomous execution
- [ralph command](commands/ralph.md) — Orchestrate pipeline
- Manage skills/agents/commands/hooks — Extending toolkit

## Finding What You Need

**If you want to...**
- ...commit code → [git skill](skills/git.md)
- ...write tests → [pytest skill](skills/pytest-best-practices.md)
- ...debug an issue → [debug-like-expert skill](skills/debug-like-expert.md)
- ...research something → [perplexity-research agent](agents/perplexity-research.md)
- ...set up database → [sqlalchemy-postgres skill](skills/sqlalchemy-postgres.md)
- ...plan a project → [create-plans skill](skills/create-plans.md)
- ...build automatically → [ralph-orchestrator skill](skills/ralph-orchestrator.md)
- ...design frontend → [fullstack-ui-designer agent](agents/fullstack-ui-designer.md)
- ...write documentation → [docs-master skill](skills/docs-master.md)

See the [index](index.md) for complete navigation.
