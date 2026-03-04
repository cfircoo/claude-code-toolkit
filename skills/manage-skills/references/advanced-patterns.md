<overview>
Advanced skill patterns: string substitutions, dynamic context injection, subagent execution, invocation control, and discovery optimization. These patterns go beyond basic SKILL.md structure to build powerful, production-grade skills.
</overview>

<string_substitutions>
Skills support dynamic values in content. These are replaced BEFORE Claude sees the skill:

| Variable | Description |
|----------|-------------|
| `$ARGUMENTS` | All arguments passed when invoking (`/skill-name arg1 arg2`) |
| `$ARGUMENTS[N]` | Specific argument by 0-based index (`$ARGUMENTS[0]` = first) |
| `$N` | Shorthand for `$ARGUMENTS[N]` (`$0` = first, `$1` = second) |
| `${CLAUDE_SESSION_ID}` | Current session ID (for logging, session-specific files) |

If `$ARGUMENTS` is not present in content, arguments are appended as `ARGUMENTS: <value>`.

<example name="single_argument">
```yaml
---
name: fix-issue
description: Fix a GitHub issue
disable-model-invocation: true
argument-hint: [issue-number]
---

Fix GitHub issue $ARGUMENTS following our coding standards.

1. Read the issue description
2. Understand the requirements
3. Implement the fix
4. Write tests
5. Create a commit
```

`/fix-issue 123` → Claude receives "Fix GitHub issue 123..."
</example>

<example name="multiple_arguments">
```yaml
---
name: migrate-component
description: Migrate a component between frameworks
argument-hint: [component] [from-framework] [to-framework]
---

Migrate the $0 component from $1 to $2.
Preserve all existing behavior and tests.
```

`/migrate-component SearchBar React Vue` → `$0`=SearchBar, `$1`=React, `$2`=Vue
</example>
</string_substitutions>

<dynamic_context_injection>
The `!` backtick syntax runs shell commands BEFORE skill content is sent to Claude. The command output replaces the placeholder — Claude only sees the result, not the command.

<example name="pr_summary">
```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
---

## Pull request context
- PR diff: !`gh pr diff`
- PR comments: !`gh pr view --comments`
- Changed files: !`gh pr diff --name-only`

## Your task
Summarize this pull request...
```
</example>

<how_it_works>
1. Each `!` backtick command executes immediately (before Claude sees anything)
2. The output replaces the placeholder in the skill content
3. Claude receives the fully-rendered prompt with actual data

This is preprocessing, not something Claude executes.
</how_it_works>

<caution>
When writing skills that TEACH about dynamic context syntax, add a space to prevent execution during skill loading:

- ❌ `!` backtick `git status` backtick — executes during skill load
- ✅ `! ` backtick `git status` backtick (space after !) — does not execute, note to remove space in usage
</caution>
</dynamic_context_injection>

<subagent_execution>
Add `context: fork` to run a skill in an isolated subagent. The skill content becomes the prompt driving the subagent — it won't have access to conversation history. CLAUDE.md files are also loaded into the forked context.

<when_to_use>
- Research tasks that shouldn't pollute main context
- Long-running operations
- Tasks needing specific tool restrictions
- Read-only exploration
- Task-execution skills with side effects (deploy, commit)
</when_to_use>

<execution_flow>
When a forked skill runs:

1. A new isolated context is created
2. The subagent receives the skill content as its prompt
3. The `agent` field determines the execution environment (model, tools, and permissions)
4. Results are summarized and returned to your main conversation

The subagent has no access to conversation history. Shell injection (`! ` backtick syntax) still executes before the skill is sent, so the subagent receives pre-rendered data.
</execution_flow>

<skills_vs_subagents>
Skills with `context: fork` and standalone subagents (`.claude/agents/`) are complementary:

| Approach | System prompt | Task | Also loads |
|----------|---------------|------|------------|
| Skill with `context: fork` | From agent type (`Explore`, `Plan`, etc.) | SKILL.md content | CLAUDE.md |
| Subagent with `skills` field | Subagent's markdown body | Claude's delegation message | Preloaded skills + CLAUDE.md |

With `context: fork`, you write the task in your skill and pick an agent type to execute it. For the inverse (defining a custom subagent that uses skills as reference material), see [subagents documentation](https://code.claude.com/docs/en/sub-agents#preload-skills-into-subagents).
</skills_vs_subagents>

<example name="research">
```yaml
---
name: deep-research
description: Research a topic thoroughly
context: fork
agent: Explore
---

Research $ARGUMENTS thoroughly:

1. Find relevant files using Glob and Grep
2. Read and analyze the code
3. Summarize findings with specific file references
```
</example>

<example name="task_with_tool_restriction">
```yaml
---
name: pr-summary
description: Summarize changes in a pull request
context: fork
agent: Explore
allowed-tools: Bash(gh *)
---

## Pull request context
- PR diff: ! `gh pr diff`
- PR comments: ! `gh pr view --comments`
- Changed files: ! `gh pr diff --name-only`

## Your task
Summarize this pull request...
```

Combines `context: fork` with `allowed-tools` using tool-specific patterns (`Bash(gh *)` allows only `gh` commands). Shell injection preprocesses PR data before the subagent sees it.
</example>

<agent_types>
The `agent` field specifies which subagent configuration to use. Options include built-in agents or any custom subagent from `.claude/agents/`. If omitted, uses `general-purpose`.

| Agent | Best for |
|-------|----------|
| `Explore` | Read-only codebase exploration, research |
| `Plan` | Architecture planning, design decisions |
| `general-purpose` | Full tool access (default if omitted) |
| Custom agent name | Any agent defined in `.claude/agents/` |
</agent_types>

<important>
`context: fork` only makes sense for skills with explicit instructions/tasks. If the skill just contains guidelines with no actionable prompt, the subagent receives the guidelines but no actionable prompt, and returns without meaningful output.
</important>
</subagent_execution>

<invocation_control_patterns>
Three modes control who triggers a skill:

<pattern name="default">
**Both user and Claude can invoke** (default)

Best for: Reference skills, general-purpose tools, knowledge bases.

```yaml
---
name: api-conventions
description: API design patterns for this codebase
---
```
</pattern>

<pattern name="user_only">
**User-only invocation** (`disable-model-invocation: true`)

Best for: Deploy, commit, send messages, destructive operations — anything with side effects.

```yaml
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
---
```

The skill description is NOT loaded into Claude's context, saving token budget.
</pattern>

<pattern name="claude_only">
**Claude-only invocation** (`user-invocable: false`)

Best for: Background knowledge, legacy system context, coding conventions that aren't meaningful as user commands.

```yaml
---
name: legacy-system-context
description: Context about the legacy billing system
user-invocable: false
---
```

Hidden from the `/` menu but Claude can load it when relevant.
</pattern>

<decision_guide>
**Ask these questions:**
- Does this skill have side effects? → `disable-model-invocation: true`
- Is this background knowledge, not an action? → `user-invocable: false`
- Should both user and Claude be able to trigger it? → default (no flags)
</decision_guide>
</invocation_control_patterns>

<tool_restriction>
Use `allowed-tools` to limit what Claude can do when a skill is active:

```yaml
---
name: safe-reader
description: Read files without making changes
allowed-tools: Read, Grep, Glob
---
```

Tools listed in `allowed-tools` are granted without per-use approval. Your permission settings still govern all other tools.
</tool_restriction>

<discovery_optimization>
Skill descriptions are loaded into Claude's context so it knows what's available. Optimize for discovery:

<best_practices>
- Include specific trigger phrases in quotes: `"create a hook"`, `"add an endpoint"`
- Use third person: "This skill should be used when..."
- Be concrete, not vague
- Include keywords users would naturally say
- Test discovery by asking questions that should trigger the skill
</best_practices>

<character_budget>
Skill descriptions consume ~2% of context window (fallback 16,000 chars). If you have many skills:
- Keep descriptions concise but specific
- Use `disable-model-invocation: true` for skills that don't need auto-discovery (removes them from context budget)
- Run `/context` to check for warnings about excluded skills
- Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` environment variable
</character_budget>

<monorepo_discovery>
Claude auto-discovers skills from nested `.claude/skills/` directories. If editing `packages/frontend/`, skills in `packages/frontend/.claude/skills/` are also available.

Skills from `--add-dir` directories are loaded and support live change detection.
</monorepo_discovery>
</discovery_optimization>

<agent_skills_standard>
Claude Code skills follow the [Agent Skills](https://agentskills.io) open standard, which works across multiple AI tools. Claude Code extends the standard with invocation control, subagent execution, and dynamic context injection.
</agent_skills_standard>
