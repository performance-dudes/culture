# Culture Engine — Phase B: Automation + Signal

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add automated observation (GitHub activity, heartbeat), Signal delivery, and wire `@coach`/`@moderator`/`@observer` agents so the Culture Engine proactively reaches out instead of waiting for human commands.

**Architecture:** Hooks trigger observation on session events. Cron triggers headless heartbeat. `@observer` agent scans GitHub via `gh` CLI. `@coach` delivers via in-session nudges and optional Signal CLI. All feedback flows through `@moderator` before reaching `culture/`.

**Tech Stack:** Claude Code hooks, cron/scheduled tasks, `gh` CLI, `signal-cli`, YAML config

**Spec:** See `/Users/felix/work/culture/PRODUCT_SPEC.md` (Phase B section)

**Depends on:** Phase A (v0.1.0-alpha) — skills, agents, templates

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `agents/@observer.md` | GitHub activity observer agent |
| Create | `skills/observe/SKILL.md` | `/culture:observe` — scan GitHub activity on demand |
| Create | `skills/heartbeat/SKILL.md` | `/culture:heartbeat` — periodic check-in logic |
| Create | `skills/signal-setup/SKILL.md` | `/culture:signal-setup` — configure Signal per-person |
| Create | `hooks/post-session.md` | Hook instructions for session-end observation |
| Create | `hooks/heartbeat-prompt.md` | Prompt template for cron-triggered heartbeat |
| Modify | `CLAUDE.md` | Add new skills, agents, hooks |
| Modify | `templates/culture-init/.config.yaml` | Add observer and heartbeat config |
| Create | `templates/coaching-nudge.md` | Template for Signal/in-session coaching messages |

---

### Task 1: `@observer` Agent

**Files:**
- Create: `agents/@observer.md`

- [ ] **Step 1: Write the agent definition**

```markdown
# @observer — GitHub Activity Observer

Background observer that scans GitHub activity for culture signals.

## Role

You monitor GitHub activity in the current repo and surface patterns relevant to team culture:

1. **PR reviews** — tone, thoroughness, response time, collaboration quality
2. **Issues** — community health, documentation gaps, response patterns
3. **Discussions** — decision-making patterns, conflict signals, knowledge sharing

## How to Observe

Use `gh` CLI to fetch recent activity:

### PR Reviews
```bash
# Recent PR reviews in the last 7 days
gh pr list --state all --limit 20 --json number,title,author,reviewDecision,reviews,comments,createdAt,closedAt
# Detailed review comments for a specific PR
gh api repos/{owner}/{repo}/pulls/{number}/reviews
gh api repos/{owner}/{repo}/pulls/{number}/comments
```

### Issues
```bash
# Recent issues
gh issue list --state all --limit 20 --json number,title,author,labels,comments,createdAt,closedAt
# Issue comments
gh api repos/{owner}/{repo}/issues/{number}/comments
```

### Response Time
Calculate time between issue/PR creation and first team response. Track trends.

## What to Look For

### Positive signals
- Quick, thorough reviews
- Constructive tone in feedback
- Knowledge sharing in comments
- Welcoming responses to external contributors
- Celebrations of good work

### Concern signals
- Dismissive or terse reviews
- Long response times trending upward
- Repeated conflicts between same people
- External contributors getting ignored
- Rubber-stamp approvals (no substantive feedback)

## Output

Write observations as structured notes. Do NOT write directly to `culture/feedback/` — pass observations to `@moderator` for filtering, or to `@coach` for in-session delivery.

Observations are raw signals. They need moderation before they become feedback.

## Frequency

- **Heartbeat mode**: every ~2 hours, scan activity since last check
- **On-demand**: when `/culture:observe` is invoked
- **Event-driven**: when `@coach` needs context about recent team activity
```

- [ ] **Step 2: Commit**

```bash
git add agents/@observer.md
git commit -m "feat: add @observer agent for GitHub activity monitoring"
```

---

### Task 2: `/culture:observe` Skill

**Files:**
- Create: `skills/observe/SKILL.md`

- [ ] **Step 1: Write the skill**

```markdown
---
name: observe
description: Use when you want to scan recent GitHub activity (PRs, issues, discussions) for culture signals — team collaboration patterns, response times, tone, and community health. Can also run automatically via heartbeat.
---

# Observe — Scan GitHub Activity for Culture Signals

Scan recent GitHub activity and surface patterns relevant to team culture.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:observe` | Scan last 7 days of activity in current repo |
| `/culture:observe [days]` | Scan specified number of days back |

## Process

### Step 1: Check config

Read `culture/.config.yaml` in the current repo. If culture is not enabled, ask to initialize.

### Step 2: Gather activity

Use `gh` CLI to fetch:

```bash
# PRs — recent activity
gh pr list --state all --limit 30 --json number,title,author,reviewDecision,reviews,comments,createdAt,closedAt,mergedAt

# Issues — recent activity
gh issue list --state all --limit 30 --json number,title,author,labels,comments,createdAt,closedAt

# For each PR with reviews, fetch review details
gh api repos/{owner}/{repo}/pulls/{number}/reviews
gh api repos/{owner}/{repo}/pulls/{number}/comments
```

### Step 3: Analyze

For each activity item, assess:

| Signal | What to check |
|---|---|
| **Review quality** | Substantive comments vs rubber-stamps. Constructive tone vs dismissive. |
| **Response time** | Hours from PR/issue open to first team response. Trending up or down? |
| **Collaboration** | Back-and-forth discussion vs one-sided. Knowledge sharing happening? |
| **External contributors** | Are they welcomed? Guided? Ignored? |
| **Conflict patterns** | Same people disagreeing repeatedly? Tone escalating? |
| **Documentation** | Are PRs well-described? Do issues have enough context? |

### Step 4: Synthesize

Group findings into:
- **Strengths** — what the team is doing well
- **Growth edges** — where improvement would have high leverage
- **Patterns** — recurring themes across multiple items

### Step 5: Deliver

Present a summary to the user. Ask:
- "Should any of these observations become feedback entries in `culture/feedback/`?"
- If yes → pass through `@moderator` moderation → store

Do NOT auto-generate feedback entries without human approval when run interactively.

In heartbeat mode (non-interactive), write observations to `culture/snapshots/` as raw data for the next human session.
```

- [ ] **Step 2: Commit**

```bash
git add skills/observe/SKILL.md
git commit -m "feat: add /culture:observe skill for GitHub activity scanning"
```

---

### Task 3: Signal Setup Skill

**Files:**
- Create: `skills/signal-setup/SKILL.md`

- [ ] **Step 1: Write the skill**

```markdown
---
name: signal-setup
description: Use when a team member wants to enable or configure Signal notifications for culture coaching nudges. Sets up signal-cli delivery preferences in Claude memory.
---

# Signal Setup — Configure Signal Notifications

Configure optional Signal CLI notifications for personal coaching nudges.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:signal-setup` | Interactive setup wizard |
| `/culture:signal-setup off` | Disable Signal notifications |

## Process

### Step 1: Check prerequisites

Verify `signal-cli` is available:
```bash
which signal-cli
```

If not installed, inform the user: "Signal notifications require `signal-cli` installed and linked to your Signal account. Want to proceed with setup instructions, or skip Signal for now?"

### Step 2: Configure account

Ask: "What's your Signal phone number? (format: +1234567890)"

Test connectivity:
```bash
signal-cli -a {number} send {number} -m "Culture Engine: Signal notifications enabled ✓"
```

If the test message arrives, proceed. If not, troubleshoot.

### Step 3: Set preferences

Ask:
- **Frequency**: "How often should I reach out? Options: `low` (max 1/day), `medium` (max 3/day), `high` (whenever meaningful)"
- **Quiet hours**: "Any hours I should stay silent? (e.g., 22:00-08:00)"
- **Content**: "What kind of nudges? Options: `coaching` (personal growth), `team` (culture updates), `both`"

### Step 4: Store in Claude memory

Save preferences to Claude memory (NOT to `culture/` — this is private per-person config):

```
Signal preferences:
- Number: {number}
- Frequency: {frequency}
- Quiet hours: {quiet_start}-{quiet_end}
- Content: {content_type}
- Enabled: true
```

### Step 5: Update repo config

If the user consents, update `culture/.config.yaml`:
```yaml
signal:
  enabled: true  # At least one person has Signal enabled
```

This doesn't reveal WHO has it enabled — just that the feature is active for this repo.

## Sending Messages

When `@coach` or heartbeat wants to send a Signal message:

```bash
signal-cli -a {sender_number} send {recipient_number} -m "{message}"
```

Rules:
- Respect quiet hours
- Respect frequency cap
- Never send team feedback attributed to others — only coaching for the recipient
- Keep messages under 500 characters
- Include a reflection question when possible
```

- [ ] **Step 2: Commit**

```bash
git add skills/signal-setup/SKILL.md
git commit -m "feat: add /culture:signal-setup skill for Signal notifications"
```

---

### Task 4: Heartbeat Skill + Prompt Template

**Files:**
- Create: `skills/heartbeat/SKILL.md`
- Create: `hooks/heartbeat-prompt.md`

- [ ] **Step 1: Write the heartbeat skill**

```markdown
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
```

- [ ] **Step 2: Write the heartbeat prompt template**

```markdown
# Heartbeat Prompt

Run a Culture Engine heartbeat cycle. This is an automated check-in.

1. Read `culture/.config.yaml` in the current repo
2. Run `/culture:heartbeat` to scan activity and deliver observations
3. Be silent if nothing meaningful happened — no noise
4. If Signal is enabled for any team member, deliver coaching nudges for significant findings
5. Keep total execution under 2 minutes
```

- [ ] **Step 3: Commit**

```bash
git add skills/heartbeat/SKILL.md hooks/heartbeat-prompt.md
git commit -m "feat: add /culture:heartbeat skill and cron prompt template"
```

---

### Task 5: Coaching Nudge Template

**Files:**
- Create: `templates/coaching-nudge.md`

- [ ] **Step 1: Write the template**

```markdown
---
channel: signal | in-session
date: {{DATE}}
recipient: {{RECIPIENT}}
trigger: heartbeat | event | observation
---

{{MESSAGE}}

💭 {{REFLECTION_QUESTION}}
```

- [ ] **Step 2: Commit**

```bash
git add templates/coaching-nudge.md
git commit -m "feat: add coaching nudge template"
```

---

### Task 6: Post-Session Hook Instructions

**Files:**
- Create: `hooks/post-session.md`

- [ ] **Step 1: Write hook documentation**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add hooks/post-session.md
git commit -m "feat: add post-session hook documentation"
```

---

### Task 7: Update Config Template

**Files:**
- Modify: `templates/culture-init/.config.yaml`

- [ ] **Step 1: Add observer and heartbeat config**

Update the config to include new Phase B sections:

```yaml
# Culture Engine — Per-Repo Configuration
enabled: true

# Feedback attribution default: anonymous | public
default_attribution: anonymous

# Signal notifications (optional, per-person)
signal:
  enabled: false
  # recipients configured per-person in their Claude memory, not here

# Heartbeat — automated periodic check-in
heartbeat:
  enabled: true
  interval: "2h"
  silence_threshold: "nothing meaningful"  # skip if nothing to report

# GitHub observer
observer:
  enabled: true
  scan_prs: true
  scan_issues: true
  scan_discussions: false  # enable if repo uses GitHub Discussions
  lookback_days: 7  # default scan window for /culture:observe

# Feedback types enabled for this repo
feedback_types:
  - growth-edge
  - strength
  - impact
  - micro-adjustment
  - reflection
  - praise
  - critique
  - observation
```

- [ ] **Step 2: Commit**

```bash
git add templates/culture-init/.config.yaml
git commit -m "feat: add heartbeat and observer config to template"
```

---

### Task 8: Update Plugin Manifest (CLAUDE.md)

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: Update CLAUDE.md with new skills and agents**

Replace the full content with:

```markdown
# Culture Engine Plugin

AI-moderated team culture: feedback, coaching, reflection, and growth — stored in git.

## Core Principles

1. **Always moderated** — Claude filters all feedback. No direct human-to-human channel. No bashing, no rudeness.
2. **Anonymous or public** — author controls attribution. Everything else reaches the shared space.
3. **Everything is a signal** — sessions, PRs, issues, reflections all inform culture understanding.
4. **Growth over performance** — long-term development, not short-term optimization.
5. **Culture is explicit** — values and norms are tracked artifacts, not assumptions.

## Skills

- `/culture:feedback` – Express feedback (anonymous or public), always moderated by Claude
- `/culture:reflect` – Private reflection session (local only, never shared)
- `/culture:observe` – Scan GitHub activity (PRs, issues) for culture signals
- `/culture:heartbeat` – Periodic automated check-in (runs via cron every ~2h)
- `/culture:signal-setup` – Configure optional Signal notifications per person

## Agents

- `@coach` – Personal coaching: weaves feedback into work sessions, delivers via Signal (optional)
- `@moderator` – Filters and reformulates feedback before it reaches `culture/`
- `@observer` – Scans GitHub activity for culture signals (PR tone, issue response times, collaboration patterns)

## Shared State

This plugin reads and writes `culture/` folders in target repos:

- **Org repo** (named after GitHub org): org-wide culture
- **Per-repo**: repo-specific feedback, opt-in via `culture/.config.yaml`
- Single-repo projects: `culture/` in that repo directly

## Automation

- **Heartbeat**: every ~2h via cron, scans GitHub activity and delivers coaching nudges
- **Signal**: optional per-person coaching channel via `signal-cli`
- **Post-session**: analyzes work sessions for culture patterns (stored in Claude memory, private)

## Language

All feedback and culture documents in **English**.
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: update plugin manifest with Phase B skills and agents"
```

---

### Task 9: Self-Review and Tag

- [ ] **Step 1: Verify all new files exist**

```bash
ls agents/@observer.md skills/observe/SKILL.md skills/heartbeat/SKILL.md skills/signal-setup/SKILL.md hooks/heartbeat-prompt.md hooks/post-session.md templates/coaching-nudge.md
```

- [ ] **Step 2: Verify CLAUDE.md lists all skills and agents**

Cross-reference CLAUDE.md skills/agents sections against actual files in `skills/` and `agents/`.

- [ ] **Step 3: Verify config template has all new sections**

Read `templates/culture-init/.config.yaml` and confirm heartbeat and observer sections are present.

- [ ] **Step 4: Tag Phase B**

```bash
git tag v0.2.0-alpha -m "Phase B: Automation — observer, heartbeat, Signal, hooks"
```
