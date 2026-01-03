# Workflow: Commit

<process>

## Step 1: Gather Context (parallel)

Run these commands in parallel:
```bash
git status
git diff --staged
git diff
git log --oneline -5
```

## Step 2: Analyze Changes

From the output, determine:
- What files are modified/added/deleted
- What's already staged vs unstaged
- Recent commit message style in the repo

## Step 3: Stage Changes

If nothing is staged, stage relevant files:
```bash
git add <files>
```

**Skip files that likely contain secrets:** `.env`, `credentials.json`, `*.pem`, etc.

## Step 4: Draft Commit Message

Analyze the staged changes and write a message that:
- Summarizes the nature of change (feature, fix, refactor, docs, test)
- Focuses on "why" not "what"
- Matches the repo's existing commit style
- Is concise (1-2 sentences for simple changes)

## Step 5: Create Commit

```bash
git commit -m "$(cat <<'EOF'
<commit message here>

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

## Step 6: Verify

```bash
git status
git log -1
```

Confirm the commit was created successfully.

</process>

<success_criteria>
- [ ] Changes analyzed before staging
- [ ] No secrets staged
- [ ] Commit message matches repo style
- [ ] Commit includes Claude attribution
- [ ] Git status shows clean working tree (for staged files)
</success_criteria>
