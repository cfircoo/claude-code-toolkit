---
description: Stage and commit changes with proper message format
allowed-tools: Skill(git), Bash, Read, Glob, Grep
---

<objective>
Create a git commit for current changes following repository conventions.

Invoke the git skill for: commit $ARGUMENTS
</objective>

<context>
Current status: !`git status`
Recent commits: !`git log --oneline -5`
</context>

<process>
1. Review staged and unstaged changes
2. Stage relevant files for commit
3. Analyze changes to draft commit message
4. Write commit message following repository style
5. Create commit with proper formatting
</process>

<success_criteria>
- All relevant changes staged
- Commit message follows repository conventions
- Commit created successfully
</success_criteria>
