---
name: init
description: Use when a user wants to enable the Culture Engine for their project — initializes culture/ folder, sets up ambient mode, configures heartbeat scheduling, and optionally sets up Signal. Also use to disable ambient mode.
---

# Init — Enable Culture Engine for a Project

One-command setup that activates culture tracking and ambient coaching for the current repo/org.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:init` | Interactive setup for current repo |
| `/culture:init off` | Disable ambient mode for current org |
| `/culture:init status` | Show current configuration |

## Process

### Step 1: Detect context

```bash
# Get GitHub org from remote
git remote get-url origin | sed 's|.*github.com[:/]\([^/]*\)/.*|\1|'
# Get repo name
basename $(git rev-parse --show-toplevel)
```

If no git remote: use directory name as scope.
If no git repo: inform user that Culture Engine requires a git repo.

### Step 2: Initialize `culture/` folder

If `culture/` doesn't exist:
1. Copy templates from plugin's `templates/culture-init/`
2. Create subdirectories: `feedback/`, `snapshots/`, `retros/`, `decisions/`
3. Ask user to fill in `culture/values.md` with their team's values
4. Commit: `culture: initialize culture/ for {repo}`

If `culture/` already exists: skip, inform user.

### Step 3: Enable ambient mode

Store in Claude memory (namespaced to org):

```
[culture:{org}] Ambient mode enabled
[culture:{org}] Repos: {repo-name}
[culture:{org}] Initialized: {date}
```

This tells Claude to activate `@coach` behavior in all sessions within this org's repos.

### Step 4: Configure heartbeat

Ask: "Should I set up automatic check-ins? Options:"
- **Durable** (recommended) — survives session restarts, runs every 2h
- **Session-only** — runs while Claude is open, expires after 7 days
- **None** — manual only, use `/culture:heartbeat` when you want

If durable or session-only:
```
CronCreate: cron "17 */2 * * *", durable: true/false
prompt: "Run /culture:heartbeat for {org}/{repo}. Stay silent if nothing meaningful."
```

### Step 5: Optional Signal setup

Ask: "Want coaching nudges via Signal? (requires signal-cli)"

If yes → hand off to `/culture:signal-setup`
If no → skip

### Step 6: Optional `/insights` scheduling

Ask: "Should I periodically analyze your work patterns? Options:"
- **Daily** — run `/insights` daily, feed into culture observations
- **Weekly** — weekly analysis only
- **None** — skip

If daily or weekly, set up corresponding schedule.

### Step 7: Summary

Print:
```
Culture Engine initialized for {org}/{repo}

  ✓ culture/ folder created with values template
  ✓ Ambient mode enabled (coaching active in all {org} sessions)
  ✓ Heartbeat: {choice} (every 2h)
  ✓ Signal: {enabled/disabled}
  ✓ Insights: {daily/weekly/disabled}

Next steps:
  - Edit culture/values.md with your team's values
  - Tell your teammates to run /culture:init in their sessions
  - Culture feedback will flow automatically from here
```

## `/culture:init off`

1. Remove ambient mode flag from Claude memory for current org
2. Do NOT delete `culture/` folder (data is preserved)
3. Skills remain available for explicit invocation
4. Heartbeat schedule removed

## `/culture:init status`

Show:
- Current org scope
- Ambient mode: on/off
- Heartbeat: running/stopped/schedule
- Signal: enabled/disabled
- Repos with `culture/` in this org
- Last heartbeat timestamp
- Feedback count this week
