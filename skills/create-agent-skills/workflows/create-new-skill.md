# Workflow: Create a New Skill

<required_reading>
**Read these reference files NOW:**
1. references/recommended-structure.md
2. references/skill-structure.md
3. references/core-principles.md
4. references/use-xml-tags.md
5. references/advanced-patterns.md
</required_reading>

<process>
## Step 1: Adaptive Requirements Gathering

**If user provided context** (e.g., "build a skill for X"):
→ Analyze what's stated, what can be inferred, what's unclear
→ Skip to asking about genuine gaps only

**If user just invoked skill without context:**
→ Ask what they want to build

### Using AskUserQuestion

Ask 2-4 domain-specific questions based on actual gaps. Each question should:
- Have specific options with descriptions
- Focus on scope, complexity, outputs, boundaries
- NOT ask things obvious from context

Example questions:
- "What specific operations should this skill handle?" (with options based on domain)
- "Should this also handle [related thing] or stay focused on [core thing]?"
- "What should the user see when successful?"

### Decision Gate

After initial questions, ask:
"Ready to proceed with building, or would you like me to ask more questions?"

Options:
1. **Proceed to building** - I have enough context
2. **Ask more questions** - There are more details to clarify
3. **Let me add details** - I want to provide additional context

## Step 2: Research Trigger (If External API)

**When external service detected**, ask using AskUserQuestion:
"This involves [service name] API. Would you like me to research current endpoints and patterns before building?"

Options:
1. **Yes, research first** - Fetch current documentation for accurate implementation
2. **No, proceed with general patterns** - Use common patterns without specific API research

If research requested:
- Use Context7 MCP to fetch current library documentation
- Or use WebSearch for recent API documentation
- Focus on 2024-2025 sources
- Store findings for use in content generation

## Step 3: Decide Structure

**Simple skill (single workflow, <200 lines):**
→ Single SKILL.md file with all content

**Complex skill (multiple workflows OR domain knowledge):**
→ Router pattern:
```
skill-name/
├── SKILL.md (router + principles)
├── workflows/ (procedures - FOLLOW)
├── references/ (knowledge - READ)
├── templates/ (output structures - COPY + FILL)
└── scripts/ (reusable code - EXECUTE)
```

Factors favoring router pattern:
- Multiple distinct user intents (create vs debug vs ship)
- Shared domain knowledge across workflows
- Essential principles that must not be skipped
- Skill likely to grow over time

**Consider templates/ when:**
- Skill produces consistent output structures (plans, specs, reports)
- Structure matters more than creative generation

**Consider scripts/ when:**
- Same code runs across invocations (deploy, setup, API calls)
- Operations are error-prone when rewritten each time

See references/recommended-structure.md for templates.

## Step 4: Configure Invocation and Behavior

Ask (using AskUserQuestion if appropriate):

**Invocation mode:**
1. **Both user and Claude** (default) — Claude auto-discovers and user can `/invoke`
2. **User-only** (`disable-model-invocation: true`) — for deploy, commit, destructive actions
3. **Claude-only** (`user-invocable: false`) — background knowledge, not a user action

**Additional options to consider:**
- Does the skill take arguments? → Add `argument-hint`
- Should it restrict tools? → Add `allowed-tools`
- Should it run in isolation? → Add `context: fork` + `agent`
- Does it need dynamic data? → Use `!` backtick commands or `$ARGUMENTS`

See references/advanced-patterns.md for details on each pattern.

## Step 5: Create Directory

```bash
mkdir -p ~/.claude/skills/{skill-name}
# If complex:
mkdir -p ~/.claude/skills/{skill-name}/workflows
mkdir -p ~/.claude/skills/{skill-name}/references
# If needed:
mkdir -p ~/.claude/skills/{skill-name}/templates  # for output structures
mkdir -p ~/.claude/skills/{skill-name}/scripts    # for reusable code
```

## Step 6: Write SKILL.md

**YAML frontmatter** (all fields optional, `description` recommended):
```yaml
---
name: skill-name                    # Optional, defaults to directory name
description: This skill should be used when the user asks to "trigger phrase"... # Use trigger phrases
disable-model-invocation: true      # If user-only (omit if default)
user-invocable: false               # If Claude-only (omit if default)
allowed-tools: Read, Grep           # If restricting tools (omit if default)
argument-hint: [arg-name]           # If skill takes arguments (omit if none)
context: fork                       # If running in subagent (omit if inline)
agent: Explore                      # If using specific agent type (omit if default)
---
```

**Simple skill:** Write complete skill file with:
- YAML frontmatter with trigger-phrase description
- `<objective>`
- `<quick_start>`
- Content sections with pure XML
- `<success_criteria>`

**Complex skill:** Write router with:
- YAML frontmatter with trigger-phrase description
- `<essential_principles>` (inline, unavoidable)
- `<intake>` (question to ask user)
- `<routing>` (maps answers to workflows)
- `<reference_index>` and `<workflows_index>`

## Step 7: Write Workflows (if complex)

For each workflow:
```xml
<required_reading>
Which references to load for this workflow
</required_reading>

<process>
Step-by-step procedure
</process>

<success_criteria>
How to know this workflow is done
</success_criteria>
```

## Step 8: Write References (if needed)

Domain knowledge that:
- Multiple workflows might need
- Doesn't change based on workflow
- Contains patterns, examples, technical details

## Step 9: Validate Structure

Check:
- [ ] YAML frontmatter valid
- [ ] Description uses trigger phrases and third person
- [ ] Invocation control set appropriately (disable-model-invocation for side-effect skills)
- [ ] No markdown headings (#) in body - use XML tags
- [ ] Required tags present: objective, quick_start, success_criteria
- [ ] All referenced files exist
- [ ] SKILL.md under 500 lines
- [ ] XML tags properly closed
- [ ] `allowed-tools` set if tool restriction needed
- [ ] `$ARGUMENTS` used correctly if skill takes arguments

## Step 10: Create Slash Command (optional)

```bash
cat > ~/.claude/commands/{skill-name}.md << 'EOF'
---
description: {Brief description}
argument-hint: [{argument hint}]
allowed-tools: Skill({skill-name})
---

Invoke the {skill-name} skill for: $ARGUMENTS
EOF
```

**Note:** Skills already create `/skill-name` automatically. A separate slash command is only needed for custom argument handling or tool restrictions.

## Step 11: Test

Invoke the skill and observe:
- Does it ask the right intake question?
- Does it load the right workflow?
- Does the workflow load the right references?
- Does output match expectations?

Iterate based on real usage, not assumptions.
</process>

<success_criteria>
Skill is complete when:
- [ ] Requirements gathered with appropriate questions
- [ ] API research done if external service involved
- [ ] Invocation mode chosen and frontmatter configured
- [ ] Directory structure correct
- [ ] SKILL.md has valid frontmatter with trigger-phrase description
- [ ] Essential principles inline (if complex skill)
- [ ] Intake question routes to correct workflow
- [ ] All workflows have required_reading + process + success_criteria
- [ ] References contain reusable domain knowledge
- [ ] Tested with real invocation
- [ ] Discovery tested (does Claude find it when expected?)
</success_criteria>
