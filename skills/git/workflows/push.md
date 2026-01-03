# Workflow: Push

<process>

## Step 1: Check Current State

```bash
git status
git branch -vv
```

Determine:
- Current branch name
- Whether branch tracks a remote
- How many commits ahead/behind

## Step 2: Verify Commits to Push

```bash
git log --oneline @{u}..HEAD 2>/dev/null || git log --oneline -5
```

Review what will be pushed.

## Step 3: Push

**If branch tracks remote:**
```bash
git push
```

**If branch is new (no upstream):**
```bash
git push -u origin <branch-name>
```

**Never use `--force` unless explicitly requested by user.**

## Step 4: Verify

```bash
git status
```

Confirm push succeeded and branch is up to date with remote.

</process>

<success_criteria>
- [ ] Verified what commits will be pushed
- [ ] Used `-u` flag for new branches
- [ ] No force push without explicit request
- [ ] Push completed successfully
</success_criteria>
