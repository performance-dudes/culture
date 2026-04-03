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
- `/culture:retro` – Facilitate async team retrospectives
- `/culture:mediate` – AI-facilitated decision resolution for disagreements
- `/culture:values` – Track team values alignment and detect drift
- `/culture:report` – Generate culture health reports and snapshots

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
- **Values drift**: automatic detection when behavior diverges from stated values
- **Weekly snapshots**: culture health reports generated in `culture/snapshots/`

## Language

All feedback and culture documents in **English**.
