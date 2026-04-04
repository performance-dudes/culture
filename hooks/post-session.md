# Session Logging & Culture Observation Hooks

How session transcripts are captured, stored, and analyzed for culture signals.

## Architecture

```
Session active
    │
    ├── PreCompact (auto/manual) ──→ save snapshot to culture/logs/
    │
    ├── Stop (on /clear) ──────────→ save snapshot to culture/logs/
    │
    └── SessionEnd (user exits) ───→ final save to culture/logs/
                                          │
                                     Heartbeat (cron, every ~2h)
                                          │
                                     Analyze logs for culture signals
                                          │
                                     Store findings in culture/feedback/
```

Session transcripts are saved locally to `culture/logs/`. Analysis happens asynchronously via heartbeat — not at session end (too late for AI work).

## Hook Configuration

Add to project settings (`.claude/settings.json`) or user settings (`~/.claude/settings.json`):

```json
{
  "hooks": {
    "SessionEnd": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '{sid: .session_id, ts: now | todate}' | { read -r meta; LOGS_DIR=\"$(git rev-parse --show-toplevel 2>/dev/null)/culture/logs\"; if [ -d \"$(dirname \"$LOGS_DIR\")\" ]; then mkdir -p \"$LOGS_DIR\"; USER=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]'); DATE=$(date +%Y-%m-%d); SID=$(echo \"$meta\" | jq -r '.sid' | head -c 8); echo \"$meta\" > \"$LOGS_DIR/${DATE}_${USER}_${SID}.json\"; fi; }",
            "timeout": 10,
            "statusMessage": "Saving session for culture analysis..."
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '{sid: .session_id, ts: now | todate, event: \"stop\"}' | { read -r meta; LOGS_DIR=\"$(git rev-parse --show-toplevel 2>/dev/null)/culture/logs\"; if [ -d \"$(dirname \"$LOGS_DIR\")\" ]; then mkdir -p \"$LOGS_DIR\"; USER=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]'); DATE=$(date +%Y-%m-%d); SID=$(echo \"$meta\" | jq -r '.sid' | head -c 8); echo \"$meta\" > \"$LOGS_DIR/${DATE}_${USER}_${SID}.json\"; fi; }",
            "timeout": 10
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "auto",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '{sid: .session_id, ts: now | todate, event: \"precompact\", summary: .summary}' | { read -r meta; LOGS_DIR=\"$(git rev-parse --show-toplevel 2>/dev/null)/culture/logs\"; if [ -d \"$(dirname \"$LOGS_DIR\")\" ]; then mkdir -p \"$LOGS_DIR\"; USER=$(git config user.name | tr ' ' '-' | tr '[:upper:]' '[:lower:]'); DATE=$(date +%Y-%m-%d); SID=$(echo \"$meta\" | jq -r '.sid' | head -c 8); echo \"$meta\" >> \"$LOGS_DIR/${DATE}_${USER}_${SID}.json\"; fi; }",
            "timeout": 10,
            "statusMessage": "Saving context snapshot for culture analysis..."
          }
        ]
      }
    ]
  }
}
```

### What Each Hook Does

| Hook | When | What it saves |
|---|---|---|
| **SessionEnd** | User exits Claude Code | Final session marker with session_id and timestamp |
| **Stop** | `/clear`, end of turn | Session marker — safety net before context is lost |
| **PreCompact** | Before auto-compaction | Compaction summary — captures context about to be compressed |

### Limitation

These hooks save **metadata markers**, not full transcripts. Claude Code stores full transcripts internally at `~/.claude/projects/`. The markers let the heartbeat know which sessions to analyze and when they happened.

For full transcript access during heartbeat analysis, the heartbeat can reference Claude Code's internal transcript storage using the session_id.

## Auto-Push Logs with Commits

To ensure culture/logs are included when pushing code, add a git pre-push hook to repos with culture enabled:

### Option A: Git Hook (recommended for teams)

Add to `.git/hooks/pre-push` (or via a shared hooks directory):

```bash
#!/bin/bash
# Auto-stage culture/logs before push
CULTURE_LOGS="$(git rev-parse --show-toplevel)/culture/logs"
if [ -d "$CULTURE_LOGS" ] && [ "$(ls -A "$CULTURE_LOGS" 2>/dev/null)" ]; then
    git add culture/logs/
    git diff --cached --quiet culture/logs/ || git commit -m "culture: update session logs"
fi
```

### Option B: Claude Code Hook

Add a `PreToolUse` hook that fires before `git push`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "if": "Bash(git push:*)",
            "command": "LOGS_DIR=\"$(git rev-parse --show-toplevel)/culture/logs\"; if [ -d \"$LOGS_DIR\" ] && [ \"$(ls -A \"$LOGS_DIR\" 2>/dev/null)\" ]; then git add \"$LOGS_DIR/\" && git diff --cached --quiet \"$LOGS_DIR/\" || git commit -m 'culture: update session logs'; fi",
            "timeout": 15,
            "statusMessage": "Staging culture session logs..."
          }
        ]
      }
    ]
  }
}
```

## `/clear` Safety Net

`/clear` triggers the `Stop` hook before clearing context. The Stop hook saves a session marker so the session_id is preserved. On the next heartbeat, the analyzer can look up the full transcript using that session_id from Claude Code's internal storage.

If you want an explicit save before clear, you can also run `/culture:heartbeat` manually before `/clear` — but the Stop hook handles this automatically.

## `culture/logs/` Structure

```
culture/logs/
├── 2026-04-04_felix_a1b2c3d4.json
├── 2026-04-04_felix_e5f6g7h8.json
├── 2026-04-04_reza_i9j0k1l2.json
└── .gitkeep
```

Filename format: `{date}_{username}_{session-id-prefix}.json`

Each file contains session markers (not full transcripts):
```json
{"sid": "a1b2c3d4-...", "ts": "2026-04-04T14:30:00Z", "event": "precompact", "summary": "..."}
{"sid": "a1b2c3d4-...", "ts": "2026-04-04T16:00:00Z", "event": "stop"}
```

## Privacy

- Session logs contain metadata only (session_id, timestamps, compaction summaries)
- Full transcripts stay in Claude Code's internal storage (~/.claude/)
- Logs are pushed to git — team members can see that sessions happened, but not their full content
- The heartbeat analyzer reads full transcripts locally, stores only moderated observations in `culture/feedback/`
- Add `culture/logs/` to `.gitignore` if the team prefers fully private session tracking
