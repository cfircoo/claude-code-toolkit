---
name: {{SKILL_NAME}}
description: This skill should be used when the user asks to "{{trigger phrase 1}}", "{{trigger phrase 2}}", or mentions {{keywords}}. {{What it does}}.
# disable-model-invocation: true   # Uncomment for user-only skills (deploy, commit, etc.)
# user-invocable: false            # Uncomment for Claude-only background knowledge
# allowed-tools: Read, Grep, Glob  # Uncomment to restrict tool access
# argument-hint: [{{hint}}]        # Uncomment if skill takes arguments
# context: fork                    # Uncomment to run in isolated subagent
# agent: Explore                   # Uncomment to specify subagent type
---

<objective>
{{Clear statement of what this skill accomplishes}}
</objective>

<quick_start>
{{Immediate actionable guidance - what Claude should do first}}
</quick_start>

<process>
## Step 1: {{First action}}

{{Instructions for step 1}}

## Step 2: {{Second action}}

{{Instructions for step 2}}

## Step 3: {{Third action}}

{{Instructions for step 3}}
</process>

<success_criteria>
{{Skill name}} is complete when:
- [ ] {{First success criterion}}
- [ ] {{Second success criterion}}
- [ ] {{Third success criterion}}
</success_criteria>
