# Post-Session Hook

Instructions for configuring a Claude Code hook that triggers culture observation after sessions.

## Purpose

After a work session ends, analyze the session for culture signals:
- Communication patterns observed
- Decision-making style
- Collaboration moments
- Emotional signals

## Hook Configuration

Add to Claude Code settings (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "post-session": [
      {
        "command": "echo 'culture-post-session'",
        "description": "Signal Culture Engine to analyze session"
      }
    ]
  }
}
```

Note: Claude Code hooks are evolving. This documents the intended behavior. The actual hook mechanism depends on Claude Code's current hook API.

## What the Hook Triggers

When triggered, the Culture Engine should:

1. Review the session transcript for culture-relevant patterns
2. Compare patterns to `culture/values.md`
3. Note any coaching opportunities for the next session
4. Store observations in Claude memory (per-person, private)
5. If Signal is enabled and something is significant, send a nudge

## Privacy

Session analysis stays in the user's Claude memory. It never reaches `culture/` in git unless the user explicitly chooses to share via `/culture:feedback`.
