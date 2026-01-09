---
description: Create a pull request using gh CLI
allowed-tools: Skill(git), Bash, Read, Glob, Grep
---

<objective>
Create a pull request for the current branch using GitHub CLI.

Invoke the git skill for: pr $ARGUMENTS
</objective>

<context>
Current branch: !`git branch --show-current`
Base branch: !`git remote show origin 2>/dev/null | grep 'HEAD branch' | cut -d: -f2 | tr -d ' '`
Commits to PR: !`git log --oneline $(git remote show origin 2>/dev/null | grep 'HEAD branch' | cut -d: -f2 | tr -d ' ')..HEAD 2>/dev/null | head -10`
</context>

<process>
1. Analyze all commits on current branch vs base
2. Draft PR title and description summarizing changes
3. Create PR using gh CLI with proper formatting
4. Return the PR URL
</process>

<success_criteria>
- PR created successfully
- Title and description reflect all changes
- PR URL returned to user
</success_criteria>
