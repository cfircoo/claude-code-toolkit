# manage-skills Skill

Expert guidance for creating, updating, auditing, and managing Claude Code skills.

## Overview

This skill provides comprehensive guidance on the skill creation process, structure, best practices, and patterns.

## When to Use

Use this skill when:
- Creating a new skill from scratch
- Improving or updating an existing skill
- Auditing a skill for best practices
- Adding components (workflows, references, templates, scripts)
- Learning about skill patterns

## Skill Fundamentals

### What is a Skill?

Skills are modular, filesystem-based capabilities that provide domain expertise on demand. They follow the [Agent Skills](https://agentskills.io) open standard.

### Key Principles

1. **Skills are prompts** — All prompting best practices apply
2. **SKILL.md is always loaded** — Main file drives behavior
3. **Progressive disclosure** — Keep SKILL.md under 500 lines
4. **Router pattern** — Complex skills use directory structure
5. **Pure XML structure** — Semantic tags, not markdown headings
6. **Two content types** — Reference (knowledge) vs Task (action)
7. **Invocation control** — Choose when skill can be invoked
8. **Subagent execution** — Use `context: fork` for isolation
9. **Tool restriction** — Limit available tools if needed
10. **Extended thinking** — Add "ultrathink" for complex reasoning

## Skill Structure

### Simple Skill

```
my-skill/
└── SKILL.md
```

Minimal structure for straightforward guidance.

### Complex Skill (Router Pattern)

```
my-skill/
├── SKILL.md              # Router + principles
├── workflows/            # Step-by-step procedures
│   ├── workflow-1.md
│   └── workflow-2.md
├── references/           # Domain knowledge
│   ├── concepts.md
│   └── patterns.md
├── templates/            # Output structures
│   └── template-1.md
└── scripts/              # Executable code
    └── script.py
```

## SKILL.md Format

### Frontmatter

```yaml
---
name: skill-name
description: What it does and when to use it
model: haiku|sonnet|opus|inherit   # Optional
context: fork|full                  # Optional
agent: agent-name                   # Optional
disable-model-invocation: false      # Optional (true = user-only)
user-invocable: true                 # Optional (false = Claude-only)
allowed-tools: Read, Write, Edit     # Optional (tool restrictions)
argument-hint: [type-hint]           # Optional
---
```

### Body Structure

```xml
<objective>What this skill accomplishes</objective>

<essential_principles>
Core knowledge and safety guidelines
</essential_principles>

<quick_start>
Immediate actionable guidance
</quick_start>

<process>
Step-by-step workflow
</process>

<success_criteria>
How to know it worked
</success_criteria>
```

## Content Organization

### Reference Content (Knowledge)

Skills that provide domain expertise:
- Located in `references/` subdirectory
- Used for learning and context
- Run inline with conversation
- Examples: patterns, best practices, concepts

### Task Content (Actions)

Skills that perform operations:
- Located in `workflows/` subdirectory
- Set `disable-model-invocation: true` for user-only
- Often use `context: fork` for isolation
- Examples: deployment, complex automation

## Router Pattern

For complex skills, SKILL.md acts as a router:

```
What would you like to do?
1. Create new X
2. Update existing X
3. Get guidance
```

Then routes to appropriate workflow based on response.

## Frontmatter Options

### name
Unique identifier, lowercase-with-hyphens.

### description
When Claude should invoke this skill (used for auto-triggering).

### model
Override model for skill execution:
- `haiku` — Fast, cheap, good for straightforward tasks
- `sonnet` — Balanced (default)
- `opus` — Most capable, slower
- `inherit` — Use conversation model

### context
Execution context:
- `fork` — Run in isolated subagent (no conversation history)
- `full` — Run inline with full context (default)

### agent
Custom execution environment:
- Named agent from `.claude/agents/`
- Default: `general-purpose`

### disable-model-invocation
Set `true` to make skill user-invocable only (not auto-triggered).

### user-invocable
Set `false` to make skill Claude-only (not user-invocable).

### allowed-tools
Restrict available tools:
```yaml
allowed-tools: Read, Write, Bash
allowed-tools: Bash(git *), Bash(npm *)  # Patterns
```

## Creating a New Skill

### Option 1: Simple Skill

For straightforward guidance:

```bash
mkdir -p ~/.claude/skills/my-skill
cat > ~/.claude/skills/my-skill/SKILL.md << 'EOF'
---
name: my-skill
description: What it does
---

<objective>Accomplish this task</objective>
<process>Step 1, Step 2, Step 3</process>
<success_criteria>How to verify success</success_criteria>
EOF
```

### Option 2: Complex Skill (Router Pattern)

Use this skill's workflow `/manage-skills` to guide you through:
1. Asking if task or domain skill
2. Choosing appropriate structure
3. Creating SKILL.md
4. Adding components
5. Auditing the skill

## Best Practices

### Content Quality
- Use clear, direct language
- No marketing fluff
- Code examples with output
- Links to related content

### Structure
- Progressive disclosure (SKILL.md → workflows/references)
- Clear section headings with XML tags
- Numbered steps in workflows
- Tables for reference content

### Naming
- Use lowercase-with-hyphens
- Descriptive and memorable
- Match directory names
- Follow existing patterns

### Tool Restrictions
- Restrict only when necessary
- Use patterns for flexibility: `Bash(git *)`
- Document why restrictions exist
- Test with restrictions enabled

### Testing
- Verify skill loads without errors
- Test auto-triggering description
- Test all workflows/branches
- Verify tool restrictions work

### Documentation
- Include usage examples
- Explain when to use
- Link to related skills
- Document any side effects

## Advanced Patterns

### Domain Expertise Skills

Skills that provide knowledge:
```yaml
---
user-invocable: false
---
```
Claude uses automatically, users can't invoke directly.

### Task Automation Skills

Skills that perform operations:
```yaml
---
disable-model-invocation: true
context: fork
---
```
Only users invoke, runs in isolation with safety.

### Subagent Execution

For complex, isolated tasks:
```yaml
---
context: fork
agent: custom-agent
---
```
Runs as separate Claude instance with dedicated context.

### Extended Thinking

For complex problems:
```xml
<objective>Solve ultrathink problem here</objective>
```
Adding "ultrathink" anywhere enables extended thinking mode.

## Integration Points

### With Commands

Commands can invoke skills:
```yaml
---
allowed-tools: Skill(my-skill)
---
```

### With Agents

Agents can trigger skills within their context.

### With Other Skills

Skills can reference related skills:
```markdown
See the [other-skill](../other-skill/SKILL.md) for more details.
```

## Auditing a Skill

When reviewing a skill, check:

- [ ] `name` and `description` in frontmatter
- [ ] Description matches auto-trigger behavior
- [ ] SKILL.md is under 500 lines (unless complex)
- [ ] XML structure for body (no markdown # headings)
- [ ] Clear objective and success criteria
- [ ] Code examples have expected output
- [ ] Links to related skills/agents
- [ ] No broken file references
- [ ] Tool restrictions documented
- [ ] Test coverage described

## Related Skills

- [manage-subagents](manage-subagents.md) — Creating agents
- [manage-slash-commands](manage-slash-commands.md) — Creating commands
- [manage-hooks](manage-hooks.md) — Creating hooks

## Directories and Files

Skills are discovered from:
- `~/.claude/skills/` (user-level)
- `.claude/skills/` (project-level)

Each skill directory contains:
- `SKILL.md` (required)
- `workflows/` (optional)
- `references/` (optional)
- `templates/` (optional)
- `scripts/` (optional)

## Troubleshooting

### Skill not loading
- Check `SKILL.md` exists (case-sensitive)
- Validate YAML frontmatter
- Ensure `name` and `description` fields exist

### Skill not auto-triggering
- Check `description` matches intent
- Verify `disable-model-invocation` is not true
- Try explicit invocation: "Use the skill-name skill"

### Tool restriction not working
- Check `allowed-tools` syntax
- Verify tool name matches Claude Code tool names
- Test with pattern syntax: `Bash(pattern *)`

### Subagent execution failing
- Verify `context: fork` is set
- Check `agent` field names if custom
- Review agent configuration
- Test with simpler context first

## Resources

- [Agent Skills Standard](https://agentskills.io/)
- [Claude Code Documentation](https://claude.com/claude-code)
- [Python Scripts Template](../scripts.md)

## Tips

- Start with simple SKILL.md
- Add workflows/references only when needed
- Use router pattern for complex skills
- Test skill invocation and auto-triggering
- Document all options and choices
- Keep code examples minimal but complete
- Review existing skills for patterns
