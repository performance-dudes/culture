---
name: retro
description: Use when the team wants to run a retrospective — gathers input from all members (anonymous by default), synthesizes themes, proposes discussion points, records decisions and action items. Works async via culture/ in git.
---

# Retro — Async Retrospective Facilitation

Facilitate team retrospectives asynchronously through `culture/retros/` in git.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:retro` | Start a new retro or continue an in-progress one |
| `/culture:retro review` | Review action items from previous retros |

## Process

### Step 1: Check for in-progress retro

Look for retro files with `status: gathering` or `status: synthesizing` in `culture/retros/`.

If found, resume that retro. If not, start a new one.

### Step 2: Initialize retro

Create `culture/retros/{YYYY}-W{WW}-retro.md` from `templates/retro-agenda.md`.

Set `status: gathering` and commit:
```bash
git add culture/retros/
git commit -m "culture: start retro for week {WW}"
```

### Step 3: Gather input

Ask the current user for their input on:
- What went well?
- What could improve?
- What surprised you?

All input is anonymous by default. Store responses in the retro file under the appropriate sections.

Each team member runs `/culture:retro` in their own session. Their Claude appends to the same retro file (via git commit/push/pull).

### Step 4: Synthesize (when all input gathered)

When the facilitator (or any team member) triggers synthesis:

1. Read all gathered input
2. Cross-reference with:
   - Recent `culture/feedback/` entries
   - `@observer` findings from the period
   - Previous retro action items
3. Identify themes: group similar observations, find patterns
4. Propose 3-5 discussion points ranked by impact
5. Update retro file with synthesized themes
6. Set `status: synthesizing`
7. Commit and push

### Step 5: Record decisions

After team discussion (async in comments or sync in a meeting):

1. Record decisions and action items in the retro file
2. Each action item gets an owner and due date
3. Set `status: complete`
4. Commit: `culture: complete retro for week {WW}`

### Step 6: Follow-up tracking

When `/culture:retro review` is called:
1. Find the most recent completed retro
2. Check status of each action item
3. Report what's done, what's overdue, what's in progress
4. Carry forward incomplete items to the next retro

## Multi-Person Workflow

Each person's Claude works with the same retro file via git:

1. Person A runs `/culture:retro` → adds their input → commits → pushes
2. Person B runs `/culture:retro` → pulls → sees retro in progress → adds their input → commits → pushes
3. Last person (or any person) triggers synthesis
4. Everyone can review the synthesized retro in `culture/retros/`

Merge conflicts in retro files should be resolved by appending (input sections are additive).
