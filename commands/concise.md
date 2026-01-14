# /concise - Toggle concise mode

Toggle concise response mode on or off.

## Usage

- `/concise` - Show current status
- `/concise on` - Enable concise mode (brief responses)
- `/concise off` - Disable concise mode (normal responses)

## Execution

Run the toggle command:

```bash
bash ~/.claude/hooks/concise-mode/toggle.sh $ARGUMENTS
```

If the toggle script doesn't exist, check `~/.claude/.concise-mode` file directly:
- File contains "off" = concise mode disabled
- File missing or contains "on" = concise mode enabled

Report the current state to the user after toggling.
