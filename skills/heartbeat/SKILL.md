---
name: heartbeat
description: Use to run a periodic culture check-in — scans recent GitHub activity, reviews pending feedback, and delivers coaching nudges via Signal or stores observations. Designed to run headlessly via cron every ~2 hours.
---

# Heartbeat — Periodic Culture Check-In

Automated periodic scan that runs headlessly via cron. Reviews recent activity and delivers coaching or stores observations.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:heartbeat` | Run one heartbeat cycle manually |
| Cron trigger | Runs automatically every ~2h (see setup) |

## Process

### Step 1: Determine scope

Read `culture/.config.yaml` to check what's enabled. Identify the repo and any org-level culture folder.

### Step 2: Scan activity since last heartbeat

Check for a timestamp file:
```bash
cat culture/.last-heartbeat 2>/dev/null || echo "no previous heartbeat"
```

Use `@observer` agent to scan GitHub activity since the last heartbeat timestamp.

### Step 3: Check for new feedback

Look for new entries in `culture/feedback/` since last heartbeat (via git log):
```bash
git log --since="2 hours ago" --name-only -- culture/feedback/
```

### Step 4: Decide what to deliver

Evaluate observations against significance threshold:
- **Signal-worthy**: heated discussion detected, pattern threshold reached, milestone celebration
- **Snapshot-worthy**: routine observations, trend data, minor patterns
- **Skip**: nothing meaningful happened

### Step 5: Deliver

For each team member with Signal enabled (from Claude memory):
- Send coaching nudges for significant observations
- Respect frequency caps and quiet hours
- Format: short, conversational, one insight per message

For the repo:
- Write observations to `culture/snapshots/{date}-heartbeat.md` if snapshot-worthy
- Update `culture/.last-heartbeat` with current timestamp

### Step 6: Record

```bash
date -u +%Y-%m-%dT%H:%M:%SZ > culture/.last-heartbeat
git add culture/.last-heartbeat
# Only commit if there are actual changes to culture/
git diff --cached --quiet || git commit -m "culture: heartbeat $(date +%Y-%m-%dT%H:%M)"
```

## Cron Setup

To enable the heartbeat, set up a Claude Code cron job in your session:

```
CronCreate: cron "17 */2 * * *", prompt: contents of hooks/heartbeat-prompt.md
```

Note: Cron jobs are session-only and auto-expire after 7 days. Re-enable in each long-running session, or use `durable: true` for persistence across restarts.

## Silence Policy

If nothing meaningful happened since the last heartbeat:
- Do NOT send Signal messages
- Do NOT create empty snapshot files
- Do NOT commit to git
- Just update `.last-heartbeat` and exit quietly
