# Culture Engine — Product Spec v1.0

A Claude Code plugin that observes, coaches, and cultivates team culture through continuous AI-moderated feedback.

## Vision

Every team member works with their own Claude. Each Claude observes how its human works, communicates, and collaborates. Together, the Claudes form a shared culture layer — coaching individuals, moderating team dynamics, and making culture a visible, evolving artifact in git.

Humans don't think about feedback. They act and react. Claude handles the rest: observing, synthesizing, coaching, moderating, and recording.

## Core Principles

1. **Always moderated** — No human-to-human direct channel through this system. Claude is always the filter. No bashing, no rudeness. Claude coaches the sender and reformulates when needed.
2. **Attribution is a choice** — Feedback is either anonymous or public. The author controls whether their name is attached, not whether the feedback reaches the shared space.
3. **Everything is a signal** — Private reflections, PR tone, issue response times, session patterns — all inform Claude's understanding of culture. The distinction is what's *stored* vs what Claude *learns from*.
4. **Humans grow, not just perform** — Feedback targets long-term personal development, not short-term performance optimization.
5. **Culture is explicit** — Team values, norms, and collaboration patterns are tracked as first-class artifacts, not left implicit.

## Architecture

### Shared State: `culture/` in Git

The `culture/` folder is the persistent, shared truth. It lives in git repositories at two levels:

| Level | Location | Scope |
|---|---|---|
| **Organization** | `culture/` in the org repo (named after GitHub org) | Org-wide values, cross-team patterns, culture health |
| **Per-repo** | `culture/` in any project repo | Repo-specific feedback, contributor dynamics, sub-team coaching |

Single-repo projects use `culture/` in that repo directly. Multi-repo orgs use the org repo as the central overview with per-repo folders for specifics.

Per-repo participation is opt-in (on/off).

### Multi-Claude Sync

Each team member's Claude reads from and writes to `culture/`. Git is the sync mechanism — commit, push, pull. No special infrastructure needed.

- Felix's Claude observes Felix, writes observations to `culture/`
- Reza's Claude observes Reza, writes observations to `culture/`
- Both Claudes read the full `culture/` folder to understand team dynamics
- Moderation and anonymization happen before any write

### Privacy Model

| Layer | Stored in `culture/`? | Attributed? | Claude learns from it? |
|---|---|---|---|
| **Private reflection** | No | N/A | Yes (locally, per-person Claude only) |
| **Anonymous feedback** | Yes | No | Yes (all Claudes via git) |
| **Public feedback** | Yes | Yes | Yes (all Claudes via git) |

Private reflections are temporary states — for working through emotions or processing before sharing. They inform the individual's Claude but never leave the local session/memory.

## Sources

### Internal

| Source | What Claude observes |
|---|---|
| **Claude sessions** | Communication style, decision patterns, thinking habits, emotional signals |
| **`/insights` reports** | Periodic self-assessment data (daily or weekly, scheduled) |
| **PR reviews & discussions** | Tone, thoroughness, collaboration quality, conflict patterns |
| **Explicit feedback** | Team members expressing praise, criticism, feelings about the project/team/anyone |
| **Private reflections** | Raw thoughts before moderation (local only) |

### External

| Source | What Claude observes |
|---|---|
| **GitHub issues** (from anyone) | Community health, documentation gaps, project accessibility, user frustration patterns |
| **External PR contributions** | Onboarding friction, review tone toward newcomers, contributor experience |
| **Issue response patterns** | Time to first response, resolution quality, welcoming signals |

External input is observed to coach the team — never to judge outsiders.

## Delivery Channels

### 1. In-Session (Primary)

Claude weaves coaching and feedback naturally into work conversations. No command needed.

- "I noticed in your last 3 PR reviews you tend to focus on style before logic — want to try flipping that?"
- "Reza left anonymous feedback about documentation practices — worth a look in `culture/feedback/`"
- "The team's response time to external issues has improved this week. Nice trend."

### 2. Signal CLI (Optional, Private)

Async nudges and digests via `signal-cli`. Personal coaching channel that accumulates for re-reading.

- Heartbeat check-ins (~every 2 hours when active)
- Daily/weekly digests
- Coaching moments triggered by events
- Opt-in per person. Not everyone needs or wants this.

### 3. `culture/` in Git (Persistent, Shared)

The reviewable record. Anyone can browse `culture/` at any time to see:

- Recent feedback entries
- Culture health snapshots
- Retrospective summaries
- Decision records
- Team patterns over time

## Trigger Mechanisms

### Heartbeat

Every ~2 hours (via Claude Code cron/remote trigger), Claude reviews recent activity:

- New commits, PRs, issues since last check (via GitHub API)
- Session patterns (via `/insights` output)
- Pending feedback that needs delivery
- Culture signals worth noting

If there's something meaningful to say → deliver via Signal or write to `culture/`. If nothing → stay silent. No noise. Heartbeat runs headless — no active session required.

### Event-Driven

Certain events trigger immediate or near-immediate response:

- Heated PR discussion detected → coach participants privately
- Pattern threshold reached (e.g., 3rd time someone's PR review tone is flagged) → escalate coaching
- External issue reveals team blind spot → surface to team
- Milestone reached → celebrate, reflect

### Scheduled

- `/insights` runs daily or weekly via cron as a source (not user-triggered)
- Weekly culture snapshot generated in `culture/snapshots/`
- Sprint-end or periodic retrospective facilitation

## Feedback Structure

Each feedback entry in `culture/` follows this structure:

```markdown
---
date: 2026-04-03
type: growth-edge | strength | impact | micro-adjustment | reflection | praise | critique | observation
attribution: anonymous | author-name
scope: individual | team | project | org
---

## Observation

[What Claude observed — specific, behavioral, non-judgmental]

## Impact

[How this affects others: trust, clarity, safety, collaboration, authority]

## Suggestion

[One actionable, testable change — executable within 24 hours]

## Reflection Prompt

[One question to strengthen meta-awareness]
```

### Feedback Quality Requirements

Feedback must be:
- Direct but respectful
- Specific and behavior-level, not personality-level
- Leverage-based (amplify strengths), not deficit-based
- Actionable within a concrete timeframe
- Non-judgmental — no diagnostic language, no labeling

Claude must never:
- Pass through unmoderated human criticism
- Use vague praise or motivational filler
- Over-interpret or psychoanalyze
- Create feedback that could identify an anonymous author through context clues

## Culture Evolution Engine

### Values Tracking

`culture/values.md` — explicitly defined team values and norms. Claude measures drift:

- Are stated values reflected in actual behavior?
- Where is the gap between aspiration and practice?
- Which values are strengthening? Which are eroding?

### Retrospective Facilitation

Claude generates and moderates async retrospectives in `culture/retros/`:

- Gathers input from all team members (anonymous by default)
- Synthesizes themes, patterns, tensions
- Proposes discussion points
- Records decisions and action items
- Tracks follow-through on past retro actions

### Decision Journal

When Claude mediates a disagreement or facilitates a decision:

- The options considered are recorded
- The reasoning and resolution are documented in `culture/decisions/`
- No personal attribution unless participants opt in
- Builds institutional memory for "why did we decide X?"

### AI Mediation

Claude as neutral arbiter for team disagreements:

- Either party can ask Claude to mediate
- Claude gathers both perspectives (privately if needed)
- Presents an objective analysis of trade-offs
- Proposes a resolution with reasoning
- Records the outcome in the decision journal
- Never takes sides — presents evidence and trade-offs

## Plugin Structure

```
culture/                           # Plugin root
├── CLAUDE.md                      # Plugin manifest
├── README.md                      # Documentation
├── skills/
│   ├── feedback/SKILL.md          # /culture:feedback — Express feedback (anonymous/public)
│   ├── reflect/SKILL.md           # /culture:reflect — Private reflection session
│   ├── retro/SKILL.md             # /culture:retro — Facilitate team retrospective
│   ├── mediate/SKILL.md           # /culture:mediate — AI mediation for disagreements
│   └── report/SKILL.md            # /culture:report — Generate culture health report
├── agents/
│   ├── @coach.md                  # Personal coaching agent (in-session, Signal)
│   ├── @moderator.md              # Team moderation agent (anonymization, tone)
│   └── @observer.md               # Background observation agent (GitHub, sessions)
├── hooks/
│   ├── post-session.sh            # Analyze session for feedback signals
│   └── heartbeat.sh               # Periodic check-in trigger
├── templates/
│   ├── feedback-entry.md          # Feedback entry template
│   ├── culture-snapshot.md        # Weekly snapshot template
│   ├── retro-agenda.md            # Retrospective template
│   └── decision-record.md         # Decision journal template
└── docs/
    └── setup.md                   # Per-person and per-repo setup guide
```

### `culture/` Folder Structure (in repos)

```
culture/
├── values.md                      # Team values and norms
├── feedback/                      # Feedback entries
│   ├── 2026-W14-anonymous-01.md
│   ├── 2026-W14-felix-01.md
│   └── ...
├── snapshots/                     # Periodic culture health reports
│   ├── 2026-W14-snapshot.md
│   └── ...
├── retros/                        # Retrospective records
│   ├── 2026-W14-retro.md
│   └── ...
├── decisions/                     # Decision journal
│   ├── 2026-04-03-api-strategy.md
│   └── ...
└── .config.yaml                   # Per-repo config (opt-in, Signal prefs, etc.)
```

## Progressive Delivery

### Phase A: Foundation — Git Store + In-Session Coaching

- `culture/` folder structure and templates
- In-session feedback delivery (Claude weaves into conversations)
- Personal coaching based on session observations
- `/culture:feedback` skill for explicit anonymous/public feedback
- `/culture:reflect` skill for private reflection

### Phase B: Automation + Signal

- Heartbeat via cron (every 2h)
- Signal CLI integration (optional, per-person)
- GitHub API integration (PR reviews, issues, discussions)
- `/insights` output parsed and stored as source (daily or weekly via cron)
- `@coach` and `@moderator` agents
- Anonymous feedback pipeline with moderation

### Phase C: Team Culture Engine

- Culture values tracking and drift detection
- Retrospective facilitation (`/culture:retro`)
- Decision journal and AI mediation (`/culture:mediate`)
- External signal processing (community health from issues)
- Cross-repo culture aggregation in org repo
- Weekly culture snapshots
- `/culture:report` skill

## Success Criteria

The system works if over time it increases:

- **Intentional communication** — people say what they mean, with awareness of impact
- **Behavioral flexibility** — team members adapt their style based on context
- **Criticism tolerance** — feedback is received as growth opportunity, not threat
- **Relational awareness** — people understand how they affect each other
- **Decision velocity** — disagreements resolve faster with less friction
- **Culture coherence** — stated values and actual behavior converge
- **Contributor experience** — external contributors feel welcomed and supported
- **Institutional memory** — decisions and their reasoning are preserved and accessible

## Open Questions

- How to handle onboarding — when a new team member joins, how does their Claude catch up on culture context?
- Conflict escalation — when does Claude flag something for human-to-human conversation instead of moderating itself?
- Privacy across orgs — if someone contributes to multiple orgs, how are their private reflections scoped?
- Signal group channels — should there be a team Signal group for shared digests, or keep it strictly 1:1?
- Retention policy — how long do feedback entries live? Archive strategy?
