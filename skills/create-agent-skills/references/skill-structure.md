<overview>
Skills have three structural components: YAML frontmatter (metadata), pure XML body structure (content organization), and progressive disclosure (file organization). This reference defines requirements and best practices for each component.
</overview>

<xml_structure_requirements>
<critical_rule>
**Remove ALL markdown headings (#, ##, ###) from skill body content.** Replace with semantic XML tags. Keep markdown formatting WITHIN content (bold, italic, lists, code blocks, links).
</critical_rule>

<required_tags>
Every skill MUST have these three tags:

- **`<objective>`** - What the skill does and why it matters (1-3 paragraphs)
- **`<quick_start>`** - Immediate, actionable guidance (minimal working example)
- **`<success_criteria>`** or **`<when_successful>`** - How to know it worked
</required_tags>

<conditional_tags>
Add based on skill complexity and domain requirements:

- **`<context>`** - Background/situational information
- **`<workflow>` or `<process>`** - Step-by-step procedures
- **`<advanced_features>`** - Deep-dive topics (progressive disclosure)
- **`<validation>`** - How to verify outputs
- **`<examples>`** - Multi-shot learning
- **`<anti_patterns>`** - Common mistakes to avoid
- **`<security_checklist>`** - Non-negotiable security patterns
- **`<testing>`** - Testing workflows
- **`<common_patterns>`** - Code examples and recipes
- **`<reference_guides>` or `<detailed_references>`** - Links to reference files

See [use-xml-tags.md](use-xml-tags.md) for detailed guidance on each tag.
</conditional_tags>

<tag_selection_intelligence>
**Simple skills** (single domain, straightforward):
- Required tags only
- Example: Text extraction, file format conversion

**Medium skills** (multiple patterns, some complexity):
- Required tags + workflow/examples as needed
- Example: Document processing with steps, API integration

**Complex skills** (multiple domains, security, APIs):
- Required tags + conditional tags as appropriate
- Example: Payment processing, authentication systems, multi-step workflows
</tag_selection_intelligence>

<xml_nesting>
Properly nest XML tags for hierarchical content:

```xml
<examples>
<example number="1">
<input>User input</input>
<output>Expected output</output>
</example>
</examples>
```

Always close tags:
```xml
<objective>
Content here
</objective>
```
</xml_nesting>

<tag_naming_conventions>
Use descriptive, semantic names:
- `<workflow>` not `<steps>`
- `<success_criteria>` not `<done>`
- `<anti_patterns>` not `<dont_do>`

Be consistent within your skill. If you use `<workflow>`, don't also use `<process>` for the same purpose (unless they serve different roles).
</tag_naming_conventions>
</xml_structure_requirements>

<yaml_requirements>
<frontmatter_fields>
All fields are optional. Only `description` is recommended.

| Field | Required | Description |
|-------|----------|-------------|
| `name` | No | Display name. If omitted, uses directory name. Lowercase, numbers, hyphens only (max 64 chars). |
| `description` | Recommended | What the skill does and when to use it. Claude uses this for auto-discovery. If omitted, uses first paragraph of markdown content. |
| `disable-model-invocation` | No | `true` = only user can invoke via `/name`. Use for side-effect skills. Default: `false`. |
| `user-invocable` | No | `false` = hidden from `/` menu. Use for background knowledge. Default: `true`. |
| `allowed-tools` | No | Tools Claude can use without per-use permission prompts when skill is active (e.g., `Read, Grep, Glob`). |
| `argument-hint` | No | Autocomplete hint (e.g., `[issue-number]`, `[filename] [format]`). |
| `model` | No | Model to use when skill is active. |
| `context` | No | Set to `fork` to run in a forked subagent context. Skill content becomes the subagent's prompt. CLAUDE.md is also loaded. |
| `agent` | No | Which subagent type to use when `context: fork` is set (`Explore`, `Plan`, `general-purpose`, or custom from `.claude/agents/`). Default: `general-purpose`. |
| `hooks` | No | Hooks scoped to this skill's lifecycle. |
</frontmatter_fields>

<name_field>
**Validation rules**:
- Maximum 64 characters
- Lowercase letters, numbers, hyphens only
- No XML tags
- No reserved words: "anthropic", "claude"
- If provided, should match directory name
- If omitted, defaults to directory name

**Examples**:
- ✅ `process-pdfs`
- ✅ `manage-facebook-ads`
- ✅ `setup-stripe-payments`
- ❌ `PDF_Processor` (uppercase)
- ❌ `helper` (vague)
- ❌ `claude-helper` (reserved word)
</name_field>

<description_field>
**Validation rules**:
- Non-empty, maximum 1024 characters
- No XML tags
- Third person (never first or second person)
- Include what it does AND trigger phrases for when to use it

**Best practice**: Include specific quoted trigger phrases for reliable discovery:
```yaml
description: This skill should be used when the user asks to "create a hook", "add a PreToolUse hook", "validate tool use", or mentions hook events. Provides comprehensive hooks API guidance.
```

**Also effective**:
```yaml
description: Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
```

**Avoid**:
- ❌ `"Helps with documents"` (vague, no triggers)
- ❌ `"I can help you process Excel files"` (first person)
- ❌ `"Processes data"` (too generic)
</description_field>

<invocation_control>
Three invocation modes control who can trigger a skill:

| Frontmatter | User can invoke | Claude can invoke | When loaded |
|-------------|-----------------|-------------------|-------------|
| (default) | Yes | Yes | Description always in context, full skill loads when invoked |
| `disable-model-invocation: true` | Yes | No | Description NOT in context, full loads when user invokes |
| `user-invocable: false` | No | Yes | Description always in context, full loads when invoked |

**Use `disable-model-invocation: true` for:**
- Deploy/ship actions
- Commit/push workflows
- Destructive operations
- Anything with side effects you want to control timing of

**Use `user-invocable: false` for:**
- Background knowledge (legacy system context, coding conventions)
- Skills that aren't meaningful as user commands
</invocation_control>

<content_types>
Two types of skill content guide what to include:

**Reference content** — conventions, patterns, domain knowledge. Runs inline alongside conversation:
```yaml
---
name: api-conventions
description: API design patterns for this codebase
---

When writing API endpoints:
- Use RESTful naming conventions
- Return consistent error formats
```

**Task content** — step-by-step actions, often with side effects:
```yaml
---
name: deploy
description: Deploy the application to production
disable-model-invocation: true
---

Deploy the application:
1. Run the test suite
2. Build the application
3. Push to the deployment target
```
</content_types>
</yaml_requirements>

<naming_conventions>
Use **verb-noun convention** for skill names:

<pattern name="create">
Building/authoring tools

Examples: `manage-skills`, `manage-hooks`, `create-landing-pages`
</pattern>

<pattern name="manage">
Managing external services or resources

Examples: `manage-facebook-ads`, `manage-zoom`, `manage-stripe`, `manage-supabase`
</pattern>

<pattern name="setup">
Configuration/integration tasks

Examples: `setup-stripe-payments`, `setup-meta-tracking`
</pattern>

<pattern name="generate">
Generation tasks

Examples: `generate-ai-images`
</pattern>

<avoid_patterns>
- Vague: `helper`, `utils`, `tools`
- Generic: `documents`, `data`, `files`
- Reserved words: `anthropic-helper`, `claude-tools`
- Inconsistent: Directory `facebook-ads` but name `facebook-ads-manager`
</avoid_patterns>
</naming_conventions>

<progressive_disclosure>
<principle>
SKILL.md serves as an overview that points to detailed materials as needed. This keeps context window usage efficient.
</principle>

<practical_guidance>
- Keep SKILL.md body under 500 lines
- Split content into separate files when approaching this limit
- Keep references one level deep from SKILL.md
- Add table of contents to reference files over 100 lines
</practical_guidance>

<pattern name="high_level_guide">
Quick start in SKILL.md, details in reference files:

```markdown
---
name: pdf-processing
description: Extracts text and tables from PDF files, fills forms, and merges documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction.
---

<objective>
Extract text and tables from PDF files, fill forms, and merge documents using Python libraries.
</objective>

<quick_start>
Extract text with pdfplumber:

```python
import pdfplumber
with pdfplumber.open("file.pdf") as pdf:
    text = pdf.pages[0].extract_text()
```
</quick_start>

<advanced_features>
**Form filling**: See [forms.md](forms.md)
**API reference**: See [reference.md](reference.md)
</advanced_features>
```

Claude loads forms.md or reference.md only when needed.
</pattern>

<pattern name="domain_organization">
For skills with multiple domains, organize by domain to avoid loading irrelevant context:

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When user asks about revenue, Claude reads only finance.md. Other files stay on filesystem consuming zero tokens.
</pattern>

<pattern name="conditional_details">
Show basic content in SKILL.md, link to advanced in reference files:

```xml
<objective>
Process DOCX files with creation and editing capabilities.
</objective>

<quick_start>
<creating_documents>
Use docx-js for new documents. See [docx-js.md](docx-js.md).
</creating_documents>

<editing_documents>
For simple edits, modify XML directly.

**For tracked changes**: See [redlining.md](redlining.md)
**For OOXML details**: See [ooxml.md](ooxml.md)
</editing_documents>
</quick_start>
```

Claude reads redlining.md or ooxml.md only when the user needs those features.
</pattern>

<critical_rules>
**Keep references one level deep**: All reference files should link directly from SKILL.md. Avoid nested references (SKILL.md → advanced.md → details.md) as Claude may only partially read deeply nested files.

**Add table of contents to long files**: For reference files over 100 lines, include a table of contents at the top.

**Use pure XML in reference files**: Reference files should also use pure XML structure (no markdown headings in body).
</critical_rules>
</progressive_disclosure>

<file_organization>
<filesystem_navigation>
Claude navigates your skill directory using bash commands:

- Use forward slashes: `reference/guide.md` (not `reference\guide.md`)
- Name files descriptively: `form_validation_rules.md` (not `doc2.md`)
- Organize by domain: `reference/finance.md`, `reference/sales.md`
</filesystem_navigation>

<directory_structure>
Typical skill structure:

```
skill-name/
├── SKILL.md           # Main instructions (required)
├── template.md        # Template for Claude to fill in (optional)
├── references/        # Detailed docs, loaded when needed (optional)
│   ├── guide-1.md
│   └── guide-2.md
├── examples/          # Example outputs showing expected format (optional)
│   └── sample.md
└── scripts/           # Executable code Claude runs (optional)
    ├── validate.py
    └── process.py
```

**For complex router-pattern skills**, also add:
```
├── workflows/         # Step-by-step procedures (optional)
│   ├── create.md
│   └── debug.md
└── templates/         # Output structures to copy + fill (optional)
    └── plan-template.md
```
</directory_structure>

<skill_locations>
Where you store a skill determines who can use it (higher priority wins):

| Level | Path | Applies to |
|-------|------|------------|
| Enterprise | Managed settings | All users in organization |
| Personal | `~/.claude/skills/<name>/SKILL.md` | All your projects |
| Project | `.claude/skills/<name>/SKILL.md` | This project only |
| Plugin | `<plugin>/skills/<name>/SKILL.md` | Where plugin is enabled |

Nested `.claude/skills/` directories are auto-discovered (monorepo support). Skills from `--add-dir` directories are also loaded with live change detection.

**Precedence**: When skills share the same name across levels, higher-priority locations win (enterprise > personal > project). Plugin skills use `plugin-name:skill-name` namespace, so they cannot conflict. If a skill and a command (`.claude/commands/`) share the same name, the skill takes precedence.

**Commands merger**: `.claude/commands/*.md` files still work and support the same frontmatter. Skills are recommended since they support additional features like supporting files.

**Character budget**: Skill descriptions consume ~2% of context window (fallback 16,000 chars). Too many skills may exceed this. Check with `/context`. Override with `SLASH_COMMAND_TOOL_CHAR_BUDGET` env var.
</skill_locations>
</file_organization>

<anti_patterns>
<pitfall name="markdown_headings_in_body">
❌ Do NOT use markdown headings in skill body:

```markdown
# PDF Processing

## Quick start
Extract text...

## Advanced features
Form filling...
```

✅ Use pure XML structure:

```xml
<objective>
PDF processing with text extraction, form filling, and merging.
</objective>

<quick_start>
Extract text...
</quick_start>

<advanced_features>
Form filling...
</advanced_features>
```
</pitfall>

<pitfall name="vague_descriptions">
- ❌ "Helps with documents"
- ✅ "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDF files or when the user mentions PDFs, forms, or document extraction."
</pitfall>

<pitfall name="inconsistent_pov">
- ❌ "I can help you process Excel files"
- ✅ "Processes Excel files and generates reports"
</pitfall>

<pitfall name="wrong_naming_convention">
- ❌ Directory: `facebook-ads`, Name: `facebook-ads-manager`
- ✅ Directory: `manage-facebook-ads`, Name: `manage-facebook-ads`
- ❌ Directory: `stripe-integration`, Name: `stripe`
- ✅ Directory: `setup-stripe-payments`, Name: `setup-stripe-payments`
</pitfall>

<pitfall name="deeply_nested_references">
Keep references one level deep from SKILL.md. Claude may only partially read nested files (SKILL.md → advanced.md → details.md).
</pitfall>

<pitfall name="windows_paths">
Always use forward slashes: `scripts/helper.py` (not `scripts\helper.py`)
</pitfall>

<pitfall name="missing_required_tags">
Every skill must have: `<objective>`, `<quick_start>`, and `<success_criteria>` (or `<when_successful>`).
</pitfall>
</anti_patterns>

<validation_checklist>
Before finalizing a skill, verify:

- ✅ YAML frontmatter valid (description in third person with trigger phrases)
- ✅ No markdown headings in body (pure XML structure)
- ✅ Required tags present: objective, quick_start, success_criteria
- ✅ Conditional tags appropriate for complexity level
- ✅ All XML tags properly closed
- ✅ Progressive disclosure applied (SKILL.md < 500 lines)
- ✅ Reference files use pure XML structure
- ✅ File paths use forward slashes
- ✅ Descriptive file names
- ✅ Invocation control set appropriately (disable-model-invocation for side-effect skills)
- ✅ Content type matches invocation mode (reference = inline, task = often user-only)
- ✅ `allowed-tools` set if skill should restrict tool access
</validation_checklist>
