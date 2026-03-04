# Workflow: Create a Toolkit Hook (Distributable)

<required_reading>
**Read these reference files NOW:**
1. references/toolkit-structure.md
2. references/examples.md
</required_reading>

<process>
## Step 1: Understand Requirements

If not clear from `$ARGUMENTS`, ask:
- What does the hook do?
- Which event and matcher does it use?
- Should it install to user-global (`~/.claude/settings.json`) or project (`.claude/settings.json`)?

If the hook doesn't exist yet, complete the **create-hook** workflow first, then return here to package it.

## Step 2: Create the Hook Directory

Follow the toolkit structure from references/toolkit-structure.md:
```
hooks/<hook-name>/
├── install.sh          # Installer script
├── settings-template.json  # Hook configuration
├── scripts/            # Hook scripts (if any)
│   └── <script>.sh
└── README.md           # Documentation
```

## Step 3: Create settings-template.json

Extract the hook configuration into a standalone template:
```json
{
  "hooks": {
    "<EVENT>": [
      {
        "matcher": "<PATTERN>",
        "hooks": [
          {
            "type": "command",
            "command": "<COMMAND>"
          }
        ]
      }
    ]
  }
}
```

If the hook references scripts, use `$HOOK_DIR` placeholder for paths that install.sh will resolve.

## Step 4: Write install.sh

The installer should:
1. Determine the install target (user-global or project)
2. Copy script files to the appropriate location
3. Merge hook config into the target settings file using `jq`
4. Set executable permissions on scripts
5. Validate the resulting JSON

Follow existing hook installers in the toolkit for conventions.

## Step 5: Update Root Installers

If this hook is part of the claude-code-toolkit:
1. Add it to the hooks index in `hooks/README.md` (if it exists)
2. Register it in the root installer so `install-toolkit` can include it

## Step 6: Test the Package

1. Run `install.sh` on a clean environment (or use a test settings file)
2. Verify JSON is valid after installation: `jq . <target-settings>`
3. Verify hook scripts are executable
4. Test the hook with `claude --debug`
5. Test uninstall/reinstall doesn't duplicate entries
</process>

<success_criteria>
Toolkit hook is complete when:
- [ ] Hook directory follows toolkit structure
- [ ] settings-template.json contains valid hook config
- [ ] install.sh merges config correctly without breaking existing settings
- [ ] Script files are copied and made executable
- [ ] Installation tested on clean environment
- [ ] Hook fires correctly after installation
- [ ] Root installers updated (if part of toolkit)
</success_criteria>
