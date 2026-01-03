# Workflow: Pull Request

<process>

## Step 1: Gather Context (parallel)

Run these commands in parallel:
```bash
git status
git log --oneline main..HEAD 2>/dev/null || git log --oneline master..HEAD
git diff main..HEAD --stat 2>/dev/null || git diff master..HEAD --stat
gh repo view --json defaultBranchRef -q .defaultBranchRef.name
```

Determine:
- Current branch
- All commits since branching from main
- Files changed
- Default branch name

## Step 2: Ensure Pushed

If local is ahead of remote:
```bash
git push -u origin <branch-name>
```

## Step 3: Analyze All Changes

Review ALL commits that will be in the PR (not just the latest).
Draft a summary covering:
- What changed and why
- Key implementation decisions
- Testing approach

## Step 4: Create PR

```bash
gh pr create --title "<title>" --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>
- <bullet 3>

## Test plan
- [ ] <test item 1>
- [ ] <test item 2>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

**Optional flags (use if user requests):**
- `--reviewer <username>` - Request reviewers
- `--label <label>` - Add labels
- `--draft` - Create as draft PR
- `--assignee @me` - Self-assign

## Step 5: Report

Output the PR URL so user can view it.

</process>

<success_criteria>
- [ ] All commits analyzed (not just latest)
- [ ] Branch pushed to remote
- [ ] PR title is descriptive
- [ ] Summary covers key changes
- [ ] Test plan included
- [ ] PR URL returned to user
</success_criteria>
