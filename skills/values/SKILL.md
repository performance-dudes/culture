---
name: values
description: Use when you want to check, update, or assess alignment with team values — tracks stated values vs actual behavior, detects drift, and suggests where the team is living its values and where gaps exist.
---

# Values — Track and Assess Team Values Alignment

Monitor how well the team's actual behavior aligns with stated values in `culture/values.md`.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:values` | Show current values and alignment assessment |
| `/culture:values check` | Run a drift detection analysis |
| `/culture:values update` | Edit team values interactively |

## Process

### `/culture:values` — Show Values

1. Read `culture/values.md`
2. For each value, show:
   - The stated value and description
   - Recent evidence of alignment (from feedback, PRs, observer data)
   - Recent evidence of drift (from feedback, observer data)
3. Overall assessment: which values are strong, which need attention

### `/culture:values check` — Drift Detection

1. Read `culture/values.md` for stated values
2. Scan sources for behavioral evidence:
   - `culture/feedback/` — recent entries mentioning values
   - `@observer` — GitHub activity patterns
   - `culture/retros/` — retrospective themes
   - `culture/decisions/` — whether decisions reflect values
3. For each value, assess:
   - **Strengthening**: behavior increasingly matches the value
   - **Stable**: consistent alignment
   - **Drifting**: gap between stated value and observed behavior
   - **Unknown**: not enough data
4. Present findings with specific evidence
5. Ask: "Should I create feedback entries for any of these findings?"

### `/culture:values update` — Edit Values

1. Read current `culture/values.md`
2. Walk through each section (values, norms, anti-patterns)
3. Ask what to add, remove, or change
4. Show the diff before committing
5. Commit: `culture: update team values`

## Drift Triggers

Values drift is automatically flagged by `@coach` when:
- A feedback entry contradicts a stated value
- Observer detects a pattern that conflicts with stated norms
- A decision was made that doesn't align with recorded values
- A retro surfaces a tension related to values

These are coaching moments, not accusations. Frame as: "I noticed X, which seems different from your stated value of Y. Worth discussing?"
