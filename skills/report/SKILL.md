---
name: report
description: Use when you want a comprehensive culture health report — aggregates feedback, observer data, values alignment, retro themes, and decision patterns into a snapshot stored in culture/snapshots/.
---

# Report — Culture Health Report

Generate a comprehensive culture health snapshot that aggregates all available signals.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:report` | Generate a report for the current repo |
| `/culture:report org` | Generate an org-wide report (aggregates across repos) |
| `/culture:report [period]` | Report for a specific period (e.g., "last 2 weeks", "Q1") |

## Process

### Step 1: Gather data

Collect from all available sources:

| Source | Data |
|---|---|
| `culture/feedback/` | All entries in the period |
| `culture/retros/` | Retro themes and action item status |
| `culture/decisions/` | Decisions made, resolution patterns |
| `culture/values.md` | Stated values for drift check |
| `@observer` | GitHub activity analysis |
| `culture/snapshots/` | Previous snapshots for trend comparison |

### Step 2: Analyze

For each dimension:

**Team Health Signals**
- Review quality and response times (from observer)
- Collaboration patterns (from PRs, discussions)
- Feedback volume and sentiment (from feedback entries)
- External contributor experience (from issues, external PRs)

**Values Alignment**
- Run `/culture:values check` logic
- Compare current period to previous snapshot

**Growth Trajectory**
- What coaching nudges were delivered?
- What behavioral changes are visible?
- What retro action items were completed?

**Risk Areas**
- Recurring tensions that aren't resolving
- Values drift accelerating
- External contributor experience declining
- Team communication patterns degrading

### Step 3: Generate snapshot

Create `culture/snapshots/{YYYY}-W{WW}-snapshot.md` from `templates/culture-snapshot.md`.

Fill in all sections with data and analysis.

### Step 4: Org-wide report (if requested)

For `/culture:report org`:
1. Identify all repos with `culture/` folders in the org
2. Read each repo's latest snapshot
3. Aggregate cross-repo patterns
4. Write to org repo: `culture/snapshots/{YYYY}-W{WW}-org-snapshot.md`

### Step 5: Commit and deliver

```bash
git add culture/snapshots/
git commit -m "culture: add {period} culture snapshot"
```

Present key findings to the user. Ask if anything should become feedback or retro input.
