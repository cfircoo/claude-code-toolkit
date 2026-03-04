# git-ops Agent

Autonomous git operations: committing, pushing, and creating PRs with safety protocols.

## Overview

The git-ops agent handles version control tasks autonomously. It commits changes with well-crafted messages, pushes to remotes, and creates pull requests using the gh CLI.

## When to Use

The git-ops agent is automatically triggered when you:
- Ask to "commit my changes"
- Request to "push to remote"
- Ask to "create a pull request"
- Request "ship code" (full workflow)
- Mention git-related operations

## Capabilities

### Commit
- Analyzes staged and unstaged changes
- Writes meaningful commit messages
- Follows repository conventions
- Includes Claude attribution
- Respects git safety protocols

### Push
- Verifies remote tracking
- Pushes to appropriate branch
- Respects branch protection (main/master)
- Validates remote configuration

### Pull Request
- Analyzes all commits for context
- Generates comprehensive PR description
- Links related issues
- Includes suggested reviewers
- Follows repository PR conventions

## Configuration

The agent uses:
- **Model**: Sonnet
- **Tools**: Bash, Read, Glob, Grep
- **Context**: Conversation context
- **Invocation**: Automatic on relevant requests

## Safety Constraints

The git-ops agent NEVER:
- Runs `git push --force` or `git push -f`
- Runs `git reset --hard`
- Uses `--no-verify` flag
- Amends commits that have been pushed
- Commits files with secrets (.env, credentials.json)

The git-ops agent ALWAYS:
- Checks `git status` before operations
- Reviews `git log` to match existing commit style
- Includes Claude attribution
- Analyzes ALL commits for PR descriptions

## Commit Format

All commits follow this format:

```
<type>(<scope>): <subject>

<detailed description>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

Example:
```
feat(auth): add JWT token refresh mechanism

Implemented automatic token refresh to maintain user sessions.
Added refresh token rotation for security. Includes tests and
database migrations.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

## Workflow

### For Commits

1. Analyze `git status` and `git diff`
2. Review repository commit history
3. Stage appropriate files
4. Draft commit message
5. Create commit with proper format
6. Verify success

### For Push

1. Check current branch and tracking
2. Verify branch is not main/master (or is feature branch)
3. Push to remote
4. Verify successful push

### For PRs

1. Get list of commits to include
2. Analyze all commit messages
3. Determine PR scope and impact
4. Draft PR title and description
5. Create PR with gh CLI
6. Output PR URL

## Usage Examples

### Automatic Invocation

```
> I've fixed the login bug, can you commit it?
# git-ops agent runs automatically
```

### Explicit Invocation

```
> Use the git-ops agent to create a PR for my changes
# Explicit agent invocation
```

### Full Workflow

```
> Ship these database changes
# Commits, pushes, creates PR
```

## Integration with Skills

The git-ops agent uses:
- [git skill](../skills/git.md) — For guidance on git operations

## Integration with Commands

The git-ops agent powers:
- [/git-commit](../commands/git-commit.md)
- [/git-push](../commands/git-push.md)
- [/git-pr](../commands/git-pr.md)
- [/git-ship](../commands/git-ship.md)

## Branch Naming

The agent respects common branch naming conventions:
- `main`, `master` — Default branches (protected)
- `feature/*`, `feat/*` — Feature branches
- `fix/*`, `hotfix/*` — Bug fix branches
- `docs/*` — Documentation branches
- `refactor/*` — Refactoring branches

## PR Conventions

The agent adapts to repository conventions:
- Reading existing PR templates
- Matching PR title format
- Including appropriate labels
- Linking related issues
- Assigning to relevant reviewers

## Error Handling

If the agent encounters:
- **Uncommitted changes** — Asks for staging confirmation
- **Branch conflicts** — Reports merge conflicts
- **Push failures** — Analyzes and reports network/auth issues
- **PR creation failures** — Reports API or permission issues

## Troubleshooting

### Agent not triggering
- Be explicit: "Use git-ops agent to commit"
- Check if task clearly involves git

### Commit message not ideal
- Provide feedback and ask to try again
- The agent will improve next attempt
- Or use `/git-commit` command for guidance

### Push blocked
- Check if on main/master branch (not allowed)
- Verify remote is configured
- Check authentication status

### PR not created
- Verify branch is pushed
- Check gh CLI is configured
- Confirm sufficient permissions on repository

## Best Practices

### Before Committing
- Review your changes: `git status`, `git diff`
- Ensure tests pass locally
- Don't commit broken code

### For Good Commits
- Group related changes
- Write clear, descriptive commit messages
- One logical change per commit
- Include context in message body

### For Good PRs
- Keep PRs focused and reviewable
- Include tests for new code
- Update documentation
- Reference related issues

### Security
- Never commit secrets (.env files)
- Never use --force push on shared branches
- Always verify changes before committing
- Review what's being committed

## Related Skills

- [git](../skills/git.md) — Git guidance
- [debug-like-expert](../skills/debug-like-expert.md) — Debugging git issues
- [create-plans](../skills/create-plans.md) — Planning branches

## Advanced Usage

### Custom Commit Types

The agent learns from existing commits. If your repository uses custom commit types, document them in a CONTRIBUTING.md file.

### Multiple Remotes

The agent can push to different remotes:
- `origin` — Default
- `upstream` — For forks
- Custom remotes as needed

### Squash and Rebase

The agent does NOT squash or rebase automatically. For these operations:
1. Use explicit git commands
2. Or ask the [git skill](../skills/git.md) for guidance
3. Then ask git-ops to push

## Context Saving

The agent maintains conversation context:
- Remembers your repository structure
- Learns your commit conventions
- Adapts to your branch naming
- Improves with each interaction
