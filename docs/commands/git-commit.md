# /git-commit Command

Stage and commit changes with proper message format.

## Usage

```
/git-commit
```

## What It Does

1. Reviews current `git status`
2. Analyzes staged and unstaged changes
3. Stages relevant files
4. Drafts meaningful commit message
5. Creates commit with proper formatting
6. Shows commit summary

## Example

```
> /git-commit
# Claude analyzes your changes:
# Modified: src/auth/login.py (added 2FA support)
# Modified: tests/test_auth.py (added 2FA tests)
# Untracked: docs/2fa.md
#
# Stages relevant files and creates:
# commit abc1234: feat(auth): add two-factor authentication
```

## Commit Message Format

All commits follow this format:

```
<type>(<scope>): <subject>

<body explaining what and why>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Commit Types

- `feat` — New feature
- `fix` — Bug fix
- `refactor` — Code refactoring without behavior change
- `docs` — Documentation only
- `test` — Test additions or modifications
- `perf` — Performance improvements
- `chore` — Build, dependencies, tooling

## Related

- [git-push](git-push.md) — Push commits to remote
- [git-pr](git-pr.md) — Create pull request
- [git-ship](git-ship.md) — Full workflow
- [git skill](../skills/git.md) — Git operations guide
- [git-ops agent](../agents/git-ops.md) — Autonomous git operations

## Tips

- Use `/git-commit` to commit staged changes
- Use `/git-ship` for full workflow (commit + push + PR)
- The command respects your repository's commit conventions
- Review changes with `git status` and `git diff` first
- Don't commit files with secrets (.env, credentials)

## Under the Hood

This command:
1. Invokes the [git skill](../skills/git.md)
2. Uses the [git-ops agent](../agents/git-ops.md) for autonomous operation
3. Follows all safety protocols (no --force, no destructive commands)
4. Respects branch protection (never directly to main/master)
