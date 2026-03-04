# Claude Code Toolkit Documentation

Complete reference guide for all skills, agents, commands, and hooks in the toolkit.

## Getting Started

- [Installation Guide](getting-started.md) — Setup and installation instructions
- [Architecture Overview](architecture.md) — System design and component relationships
- [Component Reference](components.md) — Quick reference for all types of components

## Skills (18)

Skills are modular capabilities providing domain expertise on demand.

### Development & Testing
- [git](skills/git.md) — Git operations with safety protocols
- [pytest-best-practices](skills/pytest-best-practices.md) — Expert pytest patterns
- [sqlalchemy-postgres](skills/sqlalchemy-postgres.md) — Database layer with SQLAlchemy 2.0
- [debug-like-expert](skills/debug-like-expert.md) — Methodical debugging with hypothesis testing

### Project Management
- [create-plans](skills/create-plans.md) — Hierarchical project planning
- [spec-interview](skills/spec-interview.md) — Interview-driven specification building
- [create-meta-prompts](skills/create-meta-prompts.md) — Claude-to-Claude pipeline prompts

### Content Generation
- [generate-images](skills/generate-images.md) — Image generation via Nano Banana (Gemini)
- [generate-prd](skills/generate-prd.md) — PRD creation through guided discovery

### Orchestration & Automation
- [ralph-orchestrator](skills/ralph-orchestrator.md) — Autonomous agent loop for story execution
- [ralph-convert-prd](skills/ralph-convert-prd.md) — Convert PRDs to atomic user stories

### Extension Development
- [manage-skills](skills/manage-skills.md) — Guide to creating and managing skills
- [manage-subagents](skills/manage-subagents.md) — Guide to creating and managing agents
- [manage-slash-commands](skills/manage-slash-commands.md) — Guide to creating and managing commands
- [manage-hooks](skills/manage-hooks.md) — Guide to creating and managing hooks

### Security & Safety
- [damage-control](skills/damage-control.md) — Security hooks blocking dangerous operations

### Documentation & Search
- [docs-master](skills/docs-master.md) — Documentation creation and management
- [file-search](skills/file-search.md) — Advanced file and content search

## Agents (12)

Agents are specialized Claude instances that run autonomously.

### Development
- [git-ops](agents/git-ops.md) — Git workflow automation
- [db-expert](agents/db-expert.md) — Database layer implementation
- [pytest-writer](agents/pytest-writer.md) — Test suite generation
- [perplexity-research](agents/perplexity-research.md) — Web research and synthesis
- [ralph-coder](agents/ralph-coder.md) — Ralph story implementation
- [ralph-tester](agents/ralph-tester.md) — Ralph story verification

### Fullstack Development
- [fullstack-manager](agents/fullstack-manager.md) — Frontend orchestration
- [fullstack-api-specialist](agents/fullstack-api-specialist.md) — API discovery
- [fullstack-ui-designer](agents/fullstack-ui-designer.md) — UI component design
- [fullstack-qa-debugger](agents/fullstack-qa-debugger.md) — Integration testing

### Utilities
- [docs-master](agents/docs-master.md) — Documentation specialist
- [file-search](agents/file-search.md) — Advanced search and discovery

## Commands (12)

Commands are slash-invoked prompts for common operations.

### Git Workflow
- [git-commit](commands/git-commit.md) — `/git-commit` — Stage and commit changes
- [git-push](commands/git-push.md) — `/git-push` — Push to remote
- [git-pr](commands/git-pr.md) — `/git-pr` — Create pull request
- [git-ship](commands/git-ship.md) — `/git-ship` — Full workflow (commit+push+PR)

### Project Setup & Planning
- [spec-interview](commands/spec-interview.md) — `/spec-interview` — Build specification
- [generate-prd](commands/generate-prd.md) — `/generate-prd` — Generate PRD

### Content Generation
- [generate-image](commands/generate-image.md) — `/generate-image` — Generate or edit images

### Ralph Orchestration
- [ralph](commands/ralph.md) — `/ralph` — Orchestrate autonomous agent loop
- [ralph-convert-prd](commands/ralph-convert-prd.md) — `/ralph-convert-prd` — Convert PRD to stories

### Database
- [db](commands/db.md) — `/db` — Database operations

### Settings & Tools
- [concise](commands/concise.md) — `/concise` — Toggle concise response mode
- [install-toolkit](commands/install-toolkit.md) — `/install-toolkit` — Interactive installer

## Hooks

Hooks are event-driven automation scripts that execute in response to Claude Code events.

- [Hooks Overview](hooks/overview.md) — Hook events, types, and configuration
- [concise-mode](hooks/concise-mode.md) — Brief response formatting
- [damage-control](hooks/damage-control.md) — Security restrictions
- [delegate-first](hooks/delegate-first.md) — Agent delegation patterns
- [pre-commit-pytest](hooks/pre-commit-pytest.md) — Test validation before commit

## Advanced Topics

- [Ralph Autonomous Loop](ralph.md) — Story-by-story execution with verification
- [Image Generation](image-generation.md) — Using Nano Banana for image tasks
- [Damage Control Security](damage-control-security.md) — Protection mechanisms and patterns
- [Perplexity Integration](perplexity-integration.md) — Web research setup
- [Settings Management](settings.md) — Configuration and customization

## Tools & Scripts

- [Python Scripts](scripts.md) — Utility scripts and their usage
- [Installer Scripts](installer.md) — Installation and setup tools
- [Statusline](statusline.md) — Terminal status bar configuration

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on:
- Adding new skills
- Creating agents
- Writing hooks
- Improving documentation
