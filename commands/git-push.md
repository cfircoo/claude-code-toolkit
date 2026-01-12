---
description: Push commits to remote repository
allowed-tools: Skill(git), Bash, Read
---

<objective>
Push local commits to the remote repository.

Invoke the git skill for: push $ARGUMENTS
</objective>

<context>
Current branch: !`git branch --show-current`
Commits ahead: !`git log --oneline @{u}..HEAD 2>/dev/null || echo "No upstream set"`
</context>

<process>
1. Verify current branch and commits to push
2. Check if upstream branch is set
3. Push commits to remote
4. Confirm push was successful
</process>

<success_criteria>
- All local commits pushed to remote
- No errors during push
- Remote branch updated successfully
</success_criteria>
