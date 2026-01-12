---
description: Full workflow - commit, push, and open PR
allowed-tools: Skill(git), Bash, Read, Glob, Grep
---

<objective>
Execute the complete ship workflow: commit changes, push to remote, and create a pull request.

Invoke the git skill for: ship (commit + push + pr) $ARGUMENTS
</objective>

<context>
Current status: !`git status --short`
Current branch: !`git branch --show-current`
</context>

<process>
1. Stage and commit changes with proper message
2. Push commits to remote (set upstream if needed)
3. Create pull request with summary of changes
4. Return the PR URL
</process>

<success_criteria>
- Changes committed with proper message
- Commits pushed to remote
- PR created and URL returned
- Complete workflow executed without errors
</success_criteria>
