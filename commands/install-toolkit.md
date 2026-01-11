---
description: Interactive toolkit installer - asks preferences then installs components
argument-hint: [toolkit-path]
allowed-tools: AskUserQuestion, Bash, Read, Glob
---

<objective>
Install Claude Code Toolkit components to ~/.claude/ by asking the user their preferences and executing the installation on their behalf.
</objective>

<context>
Toolkit location: $ARGUMENTS (default: current directory if contains install.sh, otherwise ~/claude-code-toolkit)

Available components:
- **Skills** (12): git, pytest-best-practices, sqlalchemy-postgres, debug-like-expert, create-plans, spec-interview, create-subagents, create-hooks, create-slash-commands, create-agent-skills, create-meta-prompts, damage-control
- **Agents** (7): git-ops, db-expert, pytest-writer, fullstack-manager, fullstack-api-specialist, fullstack-ui-designer, fullstack-qa-debugger
- **Commands** (6): commit, push, pr, ship, db, spec-interview
- **Hooks**: hooks.json + hook scripts
- **Damage Control**: Security hooks that block dangerous commands (rm -rf, git reset --hard, etc.) and protect sensitive files (.env, ~/.ssh/, credentials)
- **Extras**: statusline.sh, settings.json
</context>

<process>
1. **Locate toolkit**: Check if $ARGUMENTS provided, otherwise check current directory for install.sh, then ~/claude-code-toolkit

2. **Check dependencies**: Run bash commands to check for jq, git, and platform-specific tools (tac/gtac)
   - Report status to user
   - If missing, ask if they want to install them

3. **Check Claude Code CLI**:
   - If installed: show version, offer to check for updates
   - If not installed, offer to install:
     - **macOS**: `brew install --cask claude-code` (preferred)
     - **Linux**: `npm install -g @anthropic-ai/claude-code@latest`
   - If package manager not available: show manual install instructions

4. **Ask installation mode** using AskUserQuestion:
   - "Install All" - Copy everything (recommended)
   - "Select by Category" - Choose which folders to install
   - "Custom Selection" - Pick individual items

5. **If "Select by Category"**, ask for each category:
   - Skills: All / Skip
   - Agents: All / Skip
   - Commands: All / Skip
   - Hooks: All / Skip
   - Damage Control: Yes / No (security hooks)
   - Statusline: Yes / No
   - Settings: Merge / Skip

6. **If "Custom Selection"**, for each category ask which specific items to install

7. **Execute installation**:
   ```bash
   # Create directories
   mkdir -p ~/.claude/{skills,agents,commands,hooks}

   # Copy selected skills (replace existing)
   rm -rf ~/.claude/skills/SKILL_NAME && cp -r TOOLKIT/skills/SKILL_NAME ~/.claude/skills/

   # Copy selected agents
   cp TOOLKIT/agents/AGENT.md ~/.claude/agents/

   # Copy selected commands
   cp TOOLKIT/commands/COMMAND.md ~/.claude/commands/

   # Copy hooks (backup existing)
   cp ~/.claude/hooks.json ~/.claude/hooks.json.bak 2>/dev/null
   cp TOOLKIT/hooks.json ~/.claude/hooks.json

   # Copy statusline
   cp TOOLKIT/statusline.sh ~/.claude/statusline.sh && chmod +x ~/.claude/statusline.sh

   # Merge settings (if jq available)
   cp ~/.claude/settings.json ~/.claude/settings.json.bak 2>/dev/null
   jq -s '.[1] * .[0]' TOOLKIT/settings.json ~/.claude/settings.json > /tmp/merged.json && mv /tmp/merged.json ~/.claude/settings.json
   ```

8. **Install Damage Control** (if selected):
   - Check for UV runtime: `which uv`
   - If UV not found, offer to install: `curl -LsSf https://astral.sh/uv/install.sh | sh`
   - Create hooks directory: `mkdir -p ~/.claude/hooks/damage-control`
   - Copy Python scripts: `cp TOOLKIT/skills/damage-control/scripts/*.py ~/.claude/hooks/damage-control/`
   - Copy patterns.yaml: `cp TOOLKIT/skills/damage-control/scripts/patterns.yaml ~/.claude/hooks/damage-control/`
   - Make executable: `chmod +x ~/.claude/hooks/damage-control/*.py`
   - Merge settings with damage-control hooks and permissions:
     ```bash
     # Backup existing
     cp ~/.claude/settings.json ~/.claude/settings.json.bak 2>/dev/null
     # Merge hooks and permissions
     jq -s '
       def merge_hooks: (.[0].hooks.PreToolUse // []) + (.[1].hooks.PreToolUse // []) | unique_by(.matcher);
       def merge_permissions: {
         deny: ((.[0].permissions.deny // []) + (.[1].permissions.deny // []) | unique),
         ask: ((.[0].permissions.ask // []) + (.[1].permissions.ask // []) | unique)
       };
       .[0] * .[1] | .hooks.PreToolUse = (.[0] | merge_hooks) | .permissions = ([.[0], .[1]] | merge_permissions)
     ' ~/.claude/settings.json TOOLKIT/skills/damage-control/scripts/settings-template.json > /tmp/merged.json && mv /tmp/merged.json ~/.claude/settings.json
     ```
   - Verify files exist:
     - `~/.claude/hooks/damage-control/bash-tool-damage-control.py`
     - `~/.claude/hooks/damage-control/edit-tool-damage-control.py`
     - `~/.claude/hooks/damage-control/write-tool-damage-control.py`
     - `~/.claude/hooks/damage-control/patterns.yaml`
   - **IMPORTANT**: Remind user to restart Claude Code for hooks to take effect
   - Tell user to run `/hooks` after restart to verify registration

9. **Verify and report**: Show what was installed with counts
</process>

<output_format>
After each step, report progress clearly:
- Checking dependencies...
- Asking user preferences...
- Installing X skills...
- Installing X agents...
- etc.

Final summary:
```
Installation Complete!
- Skills: X installed
- Agents: X installed
- Commands: X installed
- Hooks: installed
- Damage Control: installed (blocks rm -rf, git reset --hard, protects .env, ~/.ssh/)
- Statusline: installed
- Settings: merged

IMPORTANT: Restart Claude Code for hooks to take effect!

Next: Run `claude` and try /commit, /ship, or /db
```
</output_format>

<constraints>
- ALWAYS backup hooks.json and settings.json before overwriting
- ALWAYS replace skill folders entirely (rm -rf then cp -r) to avoid stale files
- If settings.json merge fails, inform user and provide manual instructions
- Never install without user confirmation
- Report any errors clearly
</constraints>

<success_criteria>
- All selected components installed successfully
- Existing files backed up before overwriting
- No errors during installation
- Summary of installed components displayed
</success_criteria>
