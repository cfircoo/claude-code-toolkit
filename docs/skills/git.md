# git Skill

Git operations with safety protocols for committing, pushing, and creating pull requests.

## Overview

The git skill provides expert guidance on version control operations. It's invoked when you ask to "commit", "push", "create a PR", "ship code", or mention git workflow.

## When to Use

Use the git skill when:
- Committing changes to a repository
- Pushing code to remote
- Creating pull requests
- Reviewing git status or history
- Staging files for commit

## Key Features

- **Safety-first approach** — Never destructive without explicit approval
- **Branch protection** — Blocks direct pushes to `main`/`master`
- **Proper commit formatting** — Includes Claude attribution
- **PR creation** — Generates comprehensive PR descriptions
- **Workflow automation** — Full commit → push → PR pipeline

## Safety Protocols

### Never Allowed

The git skill never runs these commands without explicit user request:
- `git push --force` to main/master
- `git reset --hard`
- `--no-verify` flag (skip hooks)
- `git commit --amend` on pushed commits

### Branch Protection

- Blocks direct commits/pushes to `main` or `master`
- Requires creating a feature branch first
- Allows tag pushes (`git push origin v*`)
- Requires explicit remote/branch specification

### Secret Protection

Never commits files containing:
- `.env` files
- `credentials.json`
- SSH keys or certificates
- API keys or secrets

## Usage Examples

### Basic Commit

```
> Commit my changes
# Claude reviews staged changes, creates meaningful commit
```

### Full Workflow (Ship)

```
> Ship my code
# Commits changes, pushes to remote, creates PR with summary
```

### Create PR

```
> Create a PR for these changes
# Analyzes commits, creates PR with description
```

## Commit Format

All commits follow this format:

```
<type>(<scope>): <subject>

<body>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Commit types:
- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code refactoring
- `docs` — Documentation
- `test` — Tests
- `perf` — Performance
- `chore` — Maintenance

## Integration with Commands

The git skill is used by these commands:
- `/git-commit` — Stage and commit
- `/git-push` — Push to remote
- `/git-pr` — Create pull request
- `/git-ship` — Full workflow

## Related Skills

- [manage-skills](manage-skills.md) — For customizing git workflow
- [debug-like-expert](debug-like-expert.md) — For investigating git conflicts
- [create-plans](create-plans.md) — For planning feature branches

## Related Agents

- [git-ops](../agents/git-ops.md) — Autonomous git automation

## Configuration

The git skill respects:
- Repository conventions (detected from git log)
- Existing branch naming patterns
- Local git configuration
- Permission rules for branch protection

No additional configuration needed.
