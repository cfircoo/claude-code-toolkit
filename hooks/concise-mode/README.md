# Concise Mode Hook

Forces Claude to give brief responses without code blocks, tables, or verbose formatting.

## Behavior

- Default: Responses are 1-3 sentences max, no code blocks or tables
- Bypass words: `elaborate`, `explain`, `detail`, `show code`, `example`

## Installation

```bash
./hooks/concise-mode/install.sh
```

Or manually add to your `~/.claude/settings.json`:

```json
{
  "hooks": {
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "if ! echo \"$CLAUDE_USER_PROMPT\" | grep -qiE '(elaborate|explain|detail|show code|example)'; then echo '{\"userPromptPrefix\": \"[STYLE: Be extremely brief. No code blocks, no tables, no bullet lists unless essential. 1-3 sentences max.]\"}'; fi"
          }
        ]
      }
    ]
  }
}
```

Or merge `settings-template.json` with your existing settings.
