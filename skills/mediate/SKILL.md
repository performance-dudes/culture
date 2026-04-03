---
name: mediate
description: Use when team members have a disagreement or need to make a contested decision — Claude gathers perspectives, analyzes trade-offs objectively, proposes a resolution, and records the outcome in the decision journal. Never takes sides.
---

# Mediate — AI-Facilitated Decision Resolution

Neutral mediation for team disagreements. Claude gathers perspectives, presents objective analysis, and records the outcome.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:mediate` | Start a mediation session |
| `/culture:mediate [topic]` | Mediate a specific disagreement |

## Process

### Step 1: Understand the disagreement

Ask: "What's the decision or disagreement? Give me the context — what are the options being debated?"

If the user knows the other party's position, gather that too. If not, note that both perspectives are needed.

### Step 2: Gather perspectives

For each party involved:
1. Ask them to describe their position and reasoning
2. Ask what concerns they have about the other option(s)
3. Ask what outcome they'd accept as fair

Each party can provide input in their own Claude session. Claude stores perspectives privately until both sides are heard.

If only one party is present, Claude can:
- Work with what's available (stated positions from PRs, issues, or discussions)
- Ask the present party to fairly represent the other side
- Flag that this is a one-sided mediation and the outcome should be treated as a recommendation, not a resolution

### Step 3: Analyze objectively

Present an analysis that:
- States each position fairly and completely
- Identifies shared goals and values
- Maps out trade-offs for each option
- References team values from `culture/values.md` where relevant
- Notes precedents from `culture/decisions/` if similar decisions were made before
- Identifies what information might change the analysis

### Step 4: Propose resolution

Offer one or more resolution paths:
- **Recommended option** with clear reasoning
- **Compromise** if elements of both positions have merit
- **Experiment** if uncertainty is high — try one approach with a review date
- **Escalate** if the decision has implications beyond what Claude can assess

### Step 5: Record

If the parties agree on an outcome:
1. Create `culture/decisions/{YYYY-MM-DD}-{topic-slug}.md` from `templates/decision-record.md`
2. Fill in all sections: context, options, analysis, resolution, dissenting views
3. Attribution: participants can choose to be named or anonymous
4. Commit: `culture: record decision on {topic}`

If no agreement is reached:
1. Record the analysis and open questions
2. Set status to `proposed`
3. Suggest revisiting after a cooling period or with more information

## Mediation Rules

- **Never take sides** — present evidence and trade-offs, not opinions
- **Preserve relationships** — the goal is a good decision AND a healthy team
- **Respect autonomy** — Claude proposes, humans decide
- **No forced agreement** — dissent is recorded, not suppressed
- **Confidential input** — what each party says privately stays private; only the synthesized analysis is shared
