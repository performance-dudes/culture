# Culture Engine

A Claude Code plugin that makes team culture visible, measurable, and improvable — through AI-moderated feedback, coaching, and collaboration.

## Installation

Requires the [base workspace repo](https://github.com/performance-dudes/performance-dudes) as parent directory.

```bash
cd performance-dudes          # base workspace
git clone git@github.com:performance-dudes/culture.git
claude plugin marketplace add ./culture
claude plugin install culture
```

Run `/reload-plugins` to activate. All 10 skills (`/culture:init`, `/culture:feedback`, etc.) are then available in any Claude Code session.

To add the marketplace permanently so new clones get it automatically, add to `.claude/settings.json`:

```json
{
  "pluginMarketplaces": [
    { "type": "local", "path": "./culture" }
  ]
}
```

## Adding a skill

1. Create `skills/<name>/SKILL.md` with `name` and `description` frontmatter
2. Reference docs go in `skills/<name>/references/`
3. Commit, push, `/reload-plugins`

## Why

Culture is the operating system of a team. It determines how decisions get made, how conflicts resolve, how newcomers feel, and whether people grow or stagnate. But in most teams, culture is invisible — it lives in unspoken norms, accumulated habits, and gut feelings that never get examined.

The result: feedback doesn't happen because it's awkward. Patterns repeat because nobody tracks them. Values exist on a wiki page nobody reads. Retrospectives become rituals without follow-through. And when someone finally speaks up, it's too late — frustration has calcified into resentment.

**Culture Engine changes this by making Claude your team's culture partner.**

Each team member works with their own Claude. Each Claude observes how its human works, communicates, and collaborates. Together, the Claudes form a shared culture layer — coaching individuals privately, moderating feedback so it's constructive, facilitating retrospectives, and tracking whether stated values match actual behavior.

Humans don't need to think about feedback. They act and react. Claude handles the rest.

## How It Works

### For You (Individual)

Install the plugin, run `/culture:init` in your project. Claude starts observing your work patterns — how you write PR reviews, how you respond to issues, how you communicate decisions. At natural moments, Claude offers a quiet coaching nudge:

> "I noticed your last three PR reviews focused on formatting before logic. Want to try leading with architecture feedback?"

That's it. No forms to fill out. No feedback cycles to remember. Claude learns what matters to your team from `culture/values.md` and coaches you toward it.

When something is on your mind — praise, frustration, an observation about the team — say it to Claude. It will shape your raw thoughts into constructive, actionable feedback and store it in `culture/feedback/` for the team to see. Anonymous or public, your choice.

Need to process something privately first? `/culture:reflect` gives you a space to think out loud with Claude before deciding whether to share anything.

### For Your Team (Collaboration)

Every team member's Claude reads from and writes to the same `culture/` folder in git. This is the team's shared culture space — feedback entries, retrospective records, decision journals, and health snapshots.

When Reza leaves anonymous feedback about documentation practices, Felix's Claude will mention it at an appropriate moment. When the team runs a retrospective, each person contributes through their own Claude session and the engine synthesizes themes across all input.

**Nobody communicates directly through this system.** Claude always moderates. Harsh criticism gets reformulated into behavioral observations. Anonymous entries get de-identified so context clues can't reveal the author. The goal is growth, not blame.

### For Your Project (Health)

Culture Engine tracks signals from GitHub — PR review patterns, issue response times, external contributor experience — and synthesizes them into culture health snapshots. Over time, these snapshots reveal trends:

- Are reviews getting more substantive or more rushed?
- Are external contributors being welcomed or ignored?
- Are stated values strengthening or drifting?

When disagreements arise, `/culture:mediate` provides neutral analysis. Claude gathers perspectives, maps trade-offs, and proposes resolutions — recorded in a decision journal so institutional memory survives beyond the people who were there.

## Getting Started

### 1. Install

Add the plugin to your Claude Code:

```bash
claude plugins add /path/to/culture
```

### 2. Initialize

In any git repo:

```
/culture:init
```

This walks you through:
- Creating the `culture/` folder with a values template
- Enabling ambient mode (Claude coaches automatically)
- Setting up heartbeat scheduling (automatic check-ins every 2h)
- Optionally configuring Signal notifications

### 3. Define Your Values

Edit `culture/values.md` with what matters to your team. Be specific:

```markdown
## Values

1. **Thorough reviews** — Review logic and architecture first, style second. Every PR deserves substantive feedback.
2. **Welcome newcomers** — First-time contributors get extra attention and patience. Remember your own first PR.
3. **Decide and move** — Disagreements get 48 hours of discussion, then a decision. Revisit in 2 weeks if needed.
```

Claude measures actual behavior against these values over time.

### 4. Tell Your Team

Each team member installs the plugin and runs `/culture:init` in the same repo. Their Claude will automatically pick up the team's values and existing feedback. No onboarding document needed — Claude catches them up.

## Project Isolation

Culture Engine is installed globally but thinks locally. Culture never leaks between projects.

If you contribute to GitHub org A and org B, these are completely separate cultures with separate teams, values, and feedback histories. Claude detects the org from `git remote` and scopes everything accordingly:

- Observations from org A are invisible when working in org B
- Coaching in org A references only org A's values
- Private reflections are namespaced per org
- No cross-org aggregation, ever

## Multi-Repo Organizations

For orgs with multiple repos:

```
my-org/                         ← GitHub org
├── my-org/                     ← Org repo (central culture home)
│   └── culture/                ← Org-wide values, cross-team patterns
├── api-service/
│   └── culture/                ← API team feedback, repo-specific
├── web-app/
│   └── culture/                ← Frontend team feedback, repo-specific
└── mobile/
    └── culture/                ← Mobile team feedback, repo-specific
```

The org repo aggregates. Per-repo folders capture what's specific to each sub-team. `/culture:report org` pulls it all together.

## Skills

| Skill | What it does |
|---|---|
| `/culture:init` | One-command setup — creates `culture/`, enables ambient mode, configures scheduling |
| `/culture:feedback` | Express feedback (anonymous or public). Claude moderates before storing. |
| `/culture:reflect` | Private reflection session. Nothing stored, nothing shared. |
| `/culture:observe` | Scan GitHub PRs and issues for collaboration patterns |
| `/culture:heartbeat` | Automated check-in every ~2h — scans activity, delivers nudges |
| `/culture:signal-setup` | Configure optional Signal notifications for coaching |
| `/culture:retro` | Facilitate async retrospectives — gather input, synthesize themes, track action items |
| `/culture:mediate` | AI mediation for disagreements — neutral analysis, recorded decisions |
| `/culture:values` | Track values alignment, detect drift between aspiration and practice |
| `/culture:report` | Generate culture health snapshots — per-repo or org-wide |

## Agents

| Agent | Role |
|---|---|
| `@coach` | Weaves coaching into work sessions. Quiet, contextual, non-intrusive. Optional Signal delivery. |
| `@moderator` | Filters all feedback before it reaches `culture/`. Removes attacks, ensures tone, de-identifies anonymous entries. |
| `@observer` | Scans GitHub activity for culture signals — review quality, response times, collaboration health. |

## The `culture/` Folder

```
culture/
├── values.md                      # Team values and norms
├── .config.yaml                   # Per-repo configuration
├── feedback/                      # Moderated feedback entries
│   ├── 2026-W14-anonymous-01.md
│   └── 2026-W14-felix-01.md
├── snapshots/                     # Periodic health reports
│   └── 2026-W14-snapshot.md
├── retros/                        # Retrospective records
│   └── 2026-W14-retro.md
└── decisions/                     # Decision journal
    └── 2026-04-03-api-strategy.md
```

Everything is markdown. Everything is in git. Everyone can read it. History is preserved.

## Feedback Flow

```
Human has a thought
       ↓
  Tells Claude
       ↓
  Claude coaches sender
  (teaches feedback skills)
       ↓
  @moderator filters
  (removes attacks, adjusts tone,
   de-identifies if anonymous)
       ↓
  Human approves moderated version
       ↓
  Stored in culture/feedback/
       ↓
  Team Claudes read it
       ↓
  @coach surfaces it to relevant
  team members at natural moments
```

No human ever communicates directly through this system. Claude always stands between sender and receiver, ensuring feedback is constructive, actionable, and safe.

## Ambient Mode

When ambient mode is enabled, Claude doesn't wait for commands. It:

- **Reads** culture context at session start (values, recent feedback, last snapshot)
- **Observes** communication patterns during work (silently)
- **Coaches** at natural pauses (1-2 sentences, never interrupting)
- **Enriches** PRs with culture context when relevant
- **Records** observations in memory at session end

This is the default after `/culture:init`. Disable with `/culture:init off`. Skills remain available for explicit use.

## Scheduling

Culture Engine runs automatically via heartbeat — a periodic scan every ~2 hours:

| What it checks | What it does with findings |
|---|---|
| New commits, PRs, issues | Surfaces patterns to `@coach` |
| PR review tone and quality | Flags concerns or celebrates improvements |
| Issue response times | Tracks trends, nudges if declining |
| New feedback entries | Notifies relevant team members |
| Values alignment signals | Flags drift to `@coach` |

Heartbeat is configured during `/culture:init`. Choose durable (survives restarts), session-only (7-day expiry), or manual.

Optional: Signal CLI for async coaching nudges between sessions.

## Design Decisions

**Why git, not a database?**
Git is where developers already work. No new infrastructure. Version-controlled. Transparent. Everyone can read the history. PRs for culture feel natural alongside PRs for code.

**Why Claude as moderator, not humans?**
Humans avoid giving feedback because it's socially costly. Claude removes that cost by always standing between sender and receiver. The sender gets coached on feedback skills. The receiver gets constructive, depersonalized input. Both grow.

**Why anonymous as default?**
Psychological safety comes first. Once the team builds trust through the system, people naturally shift to public attribution. The system supports both, but starts safe.

**Why per-org isolation?**
You are a different collaborator in different contexts. Your startup team and your open-source project have different values, norms, and relationships. Mixing them would make coaching meaningless.

**Why not a Slack bot / web app?**
Culture Engine lives where the work happens — in the terminal, in the IDE, in the git repo. No context switching. No separate tool to remember. Claude is already there.

## License

MIT
