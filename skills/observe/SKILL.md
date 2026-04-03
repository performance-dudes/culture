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
