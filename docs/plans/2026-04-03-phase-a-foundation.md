# Culture Engine — Phase A: Foundation

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build the Culture Engine Claude Code plugin with core skills (`/culture:feedback`, `/culture:reflect`), templates, and `culture/` folder scaffolding so feedback can be expressed, moderated, and stored in any git repo.

**Architecture:** Claude Code plugin following the standard `CLAUDE.md` + `skills/` + `agents/` + `templates/` structure. Skills are markdown-based SKILL.md files. The plugin writes feedback entries to a `culture/` folder in target repos. Moderation is embedded in every skill — no unfiltered human text reaches `culture/`.

**Tech Stack:** Claude Code plugin (markdown skills, YAML config), Git, GitHub CLI (`gh`)

**Spec:** See `/Users/felix/work/culture/PRODUCT_SPEC.md`

---

## File Map

| Action | Path | Responsibility |
|--------|------|----------------|
| Create | `CLAUDE.md` | Plugin manifest — skills list, agents, core principles |
| Create | `skills/feedback/SKILL.md` | `/culture:feedback` — express anonymous/public feedback |
| Create | `skills/reflect/SKILL.md` | `/culture:reflect` — private reflection session |
| Create | `templates/feedback-entry.md` | Feedback entry template with frontmatter |
| Create | `templates/culture-init/values.md` | Default values.md for new `culture/` folders |
| Create | `templates/culture-init/.config.yaml` | Default per-repo config |
| Create | `agents/@coach.md` | Personal coaching agent definition |
| Create | `agents/@moderator.md` | Moderation agent definition |
| Create | `docs/setup.md` | Setup guide for individuals and repos |

---

### Task 1: Plugin Manifest (CLAUDE.md)

**Files:**
- Create: `CLAUDE.md`

- [ ] **Step 1: Write CLAUDE.md**

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

## Agents

- `@coach` – Personal coaching: weaves feedback into work sessions, delivers via Signal (optional)
- `@moderator` – Filters and reformulates feedback before it reaches `culture/`

## Shared State

This plugin reads and writes `culture/` folders in target repos:

- **Org repo** (named after GitHub org): org-wide culture
- **Per-repo**: repo-specific feedback, opt-in via `culture/.config.yaml`
- Single-repo projects: `culture/` in that repo directly

## Language

All feedback and culture documents in **English**.
```

- [ ] **Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "feat: add plugin manifest (CLAUDE.md)"
```

---

### Task 2: Feedback Entry Template

**Files:**
- Create: `templates/feedback-entry.md`

- [ ] **Step 1: Create templates directory and feedback-entry.md**

```markdown
---
date: {{DATE}}
type: {{TYPE}}
attribution: {{ATTRIBUTION}}
scope: {{SCOPE}}
---

## Observation

{{OBSERVATION}}

## Impact

{{IMPACT}}

## Suggestion

{{SUGGESTION}}

## Reflection Prompt

{{REFLECTION_PROMPT}}
```

Field reference:
- `DATE`: ISO date (2026-04-03)
- `TYPE`: one of `growth-edge`, `strength`, `impact`, `micro-adjustment`, `reflection`, `praise`, `critique`, `observation`
- `ATTRIBUTION`: `anonymous` or author name
- `SCOPE`: `individual`, `team`, `project`, `org`

- [ ] **Step 2: Commit**

```bash
git add templates/feedback-entry.md
git commit -m "feat: add feedback entry template"
```

---

### Task 3: Culture Init Templates

**Files:**
- Create: `templates/culture-init/values.md`
- Create: `templates/culture-init/.config.yaml`

- [ ] **Step 1: Create values.md template**

```markdown
# Team Values

Define your team's core values here. Claude will track how well actual behavior aligns with these stated values over time.

## Values

1. **[Value Name]** — [One sentence description of what this means in practice]

## Norms

- [Specific behavioral norm, e.g., "PR reviews within 24 hours"]

## Anti-Patterns

- [Behaviors the team explicitly wants to avoid]
```

- [ ] **Step 2: Create .config.yaml**

```yaml
# Culture Engine — Per-Repo Configuration
enabled: true

# Feedback attribution default: anonymous | public
default_attribution: anonymous

# Signal notifications (optional, per-person)
signal:
  enabled: false
  # recipients configured per-person in their Claude memory, not here

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

- [ ] **Step 3: Commit**

```bash
git add templates/culture-init/
git commit -m "feat: add culture/ init templates (values.md, .config.yaml)"
```

---

### Task 4: `/culture:feedback` Skill

**Files:**
- Create: `skills/feedback/SKILL.md`

- [ ] **Step 1: Write the skill**

```markdown
---
name: feedback
description: Use when a team member wants to express feedback — praise, critique, observation, or growth insight — about the project, team, or anyone. Handles anonymous/public attribution and always moderates before storing in culture/.
---

# Feedback — Express and Store Moderated Feedback

Accept feedback from the user, moderate it, and store it in the repo's `culture/feedback/` folder.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:feedback` | Interactive — Claude asks what's on your mind |
| `/culture:feedback [text]` | Claude moderates and stores the provided feedback |

## Process

### Step 1: Gather input

If no text provided, ask: "What's on your mind? This can be about the project, the team, a specific interaction, or anything you've observed. I'll help shape it into constructive feedback."

### Step 2: Choose attribution

Ask: "Should this be **anonymous** or **public** (attributed to you)?"

Default to the repo's `culture/.config.yaml` `default_attribution` if configured.

### Step 3: Moderate

Before storing, Claude MUST:

1. **Remove personal attacks** — reformulate as behavioral observations
2. **Remove rudeness** — preserve the core message, adjust tone
3. **De-identify if anonymous** — strip contextual clues that could reveal authorship
4. **Ensure actionability** — add a concrete suggestion if the raw feedback lacks one
5. **Coach the sender** — if the feedback was harsh, explain to the user what was adjusted and why. This is a teaching moment for feedback skills.

If moderation changes the meaning significantly, show the moderated version to the user and ask for approval before storing.

### Step 4: Structure

Fill the feedback entry template:
- `date`: today
- `type`: classify based on content (praise, critique, growth-edge, observation, etc.)
- `attribution`: as chosen in Step 2
- `scope`: infer from content (individual, team, project, org)
- Write the Observation, Impact, Suggestion, and Reflection Prompt sections

### Step 5: Store

1. Verify `culture/feedback/` exists in the current repo (create if not — see init process below)
2. Write entry to `culture/feedback/{YYYY}-W{WW}-{attribution}-{seq}.md`
3. Commit: `culture: add {type} feedback ({attribution})`
4. Inform user: "Feedback stored. It will be visible to the team on next pull."

### Init Process

If `culture/` doesn't exist in the repo:

1. Ask: "This repo doesn't have a `culture/` folder yet. Want me to initialize it?"
2. If yes: copy templates from `templates/culture-init/` and ask user to fill in `values.md`
3. Commit: `culture: initialize culture/ folder`

## Quality Gate

Every feedback entry must pass these checks before storage:
- No personal attacks or naming in anonymous entries
- Has a concrete, actionable suggestion
- Tone is direct but respectful
- Could not reasonably identify the anonymous author through context
```

- [ ] **Step 2: Commit**

```bash
git add skills/feedback/SKILL.md
git commit -m "feat: add /culture:feedback skill"
```

---

### Task 5: `/culture:reflect` Skill

**Files:**
- Create: `skills/reflect/SKILL.md`

- [ ] **Step 1: Write the skill**

```markdown
---
name: reflect
description: Use when a team member wants a private reflection session — processing emotions, thinking through a situation before sharing, or personal coaching. Nothing leaves the local session. Helps build self-awareness and feedback readiness.
---

# Reflect — Private Reflection Session

Guided private reflection. Nothing is stored in `culture/` or shared with the team. This is between the user and their Claude only.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:reflect` | Start an interactive reflection session |
| `/culture:reflect [topic]` | Reflect on a specific situation |

## Process

### Step 1: Set the space

Tell the user: "This is private — nothing from this session will be stored in `culture/` or shared with anyone. Let's think through what's on your mind."

### Step 2: Explore

Use open-ended coaching questions. One at a time. Examples:

- "What happened?"
- "How did that make you feel?"
- "What was your role in this?"
- "What would you do differently?"
- "What's the impact on others?"
- "Is there something you want to communicate to the team about this?"

Adapt questions based on the user's responses. Follow their energy — don't force a structure.

### Step 3: Synthesize

After the user has explored enough, offer a synthesis:

- What pattern does this connect to (if any)?
- What's the core insight?
- Is there a growth edge here?

### Step 4: Bridge to action (optional)

Ask: "Would you like to turn any of this into feedback for the team? I can help you shape it — anonymous or public."

If yes → hand off to `/culture:feedback` with the moderated version.
If no → session ends. Nothing stored.

## Privacy guarantee

- Claude MUST NOT write reflection content to `culture/`
- Claude MUST NOT reference reflection content in team-facing outputs
- Claude MAY use patterns observed across reflections to improve personal coaching within the same user's future sessions (via Claude memory, not git)
- If the user later asks "did I reflect on X?" — Claude can reference it within the same user's sessions only
```

- [ ] **Step 2: Commit**

```bash
git add skills/reflect/SKILL.md
git commit -m "feat: add /culture:reflect skill"
```

---

### Task 6: `@coach` Agent

**Files:**
- Create: `agents/@coach.md`

- [ ] **Step 1: Write the agent definition**

```markdown
# @coach — Personal Coaching Agent

Personal coaching agent that weaves culture feedback naturally into work sessions.

## Role

You are a personal coach embedded in the user's Claude Code session. Your job is to:

1. **Observe** — notice communication patterns, decision habits, collaboration style during the session
2. **Surface** — when relevant, share an observation or coaching nudge naturally in conversation
3. **Deliver** — bring attention to new feedback in `culture/feedback/` that's relevant to this user
4. **Connect** — link current behavior to past feedback or stated team values

## Behavior

- Never interrupt flow — wait for natural pauses or transitions
- Keep coaching to 1-2 sentences inline, not monologues
- Reference specific observations ("In that PR comment you just wrote...")
- If the user seems stressed or frustrated, acknowledge it before coaching
- Respect "not now" — if the user dismisses coaching, back off for the rest of the session

## Signal Delivery (when enabled)

If the user has Signal notifications enabled:
- Send coaching nudges via `signal-cli` for observations that don't fit the current session
- Format: short, conversational, one insight per message
- Never send more than 3 messages per day
- Include a reflection question when appropriate

## Sources

Read from:
- Current session context (conversation, files being edited, PRs being reviewed)
- `culture/feedback/` in the current repo
- `culture/values.md` for team values alignment
- `culture/.config.yaml` for preferences
- User's Claude memory for personal coaching history

## Tone

Like a thoughtful colleague who notices things — not a therapist, not a manager, not a performance reviewer.
```

- [ ] **Step 2: Commit**

```bash
git add agents/@coach.md
git commit -m "feat: add @coach agent definition"
```

---

### Task 7: `@moderator` Agent

**Files:**
- Create: `agents/@moderator.md`

- [ ] **Step 1: Write the agent definition**

```markdown
# @moderator — Feedback Moderation Agent

Moderation agent that filters and reformulates all feedback before it reaches `culture/`.

## Role

You are the moderation layer for the Culture Engine. Every piece of feedback passes through you before storage. Your job is to:

1. **Filter** — remove personal attacks, rudeness, and unconstructive content
2. **Reformulate** — preserve the sender's intent while ensuring respectful, actionable tone
3. **De-identify** — for anonymous feedback, strip contextual clues that could reveal authorship
4. **Coach** — explain to the sender what you changed and why (teaching feedback skills)

## Moderation Rules

### Always remove
- Personal attacks ("X is incompetent", "X always does Y wrong")
- Sarcasm or passive-aggression
- Absolute language that shuts down dialogue ("never", "always", "everyone knows")
- Emotional venting without constructive content

### Always preserve
- The core observation or concern
- Specific examples (de-identified if anonymous)
- The sender's emotional signal (frustrated → "there's tension around...")
- Actionable suggestions

### Reformulation examples

| Input | Output |
|---|---|
| "Felix's code reviews are useless nitpicking" | "Code reviews in this repo tend to focus heavily on style details. The team might benefit from prioritizing logic and architecture feedback first." |
| "Nobody cares about documentation here" | "Documentation has been declining in recent PRs. This creates onboarding friction and increases bus factor risk." |
| "Great job on the release!" | "The release process was smooth — coordination between team members was effective." (add specificity if possible) |

### De-identification for anonymous feedback

- Remove time-specific references that narrow authorship ("in yesterday's standup")
- Generalize role references ("a team member" not "the frontend developer")
- Avoid quoting messages that could be searched
- If the feedback is too specific to de-identify without losing meaning, tell the sender and ask if they want to go public instead

## Quality Gate

Before approving any entry for `culture/`:
- [ ] No personal attacks
- [ ] Tone is direct but respectful
- [ ] Has actionable content
- [ ] Anonymous entries cannot reasonably identify the author
- [ ] Feedback type classification is accurate
```

- [ ] **Step 2: Commit**

```bash
git add agents/@moderator.md
git commit -m "feat: add @moderator agent definition"
```

---

### Task 8: Setup Documentation

**Files:**
- Create: `docs/setup.md`

- [ ] **Step 1: Write setup guide**

```markdown
# Culture Engine — Setup Guide

## Install the Plugin

Add the culture plugin to your Claude Code installation:

```bash
# From the plugin directory
claude plugins add /path/to/culture
```

Or add to your Claude Code settings manually.

## Initialize Culture in a Repo

In any git repo where you want culture tracking:

```bash
# Claude will offer to initialize automatically when you first use /culture:feedback
# Or initialize manually:
mkdir -p culture/feedback culture/snapshots culture/retros culture/decisions
```

Then edit `culture/values.md` with your team's values and norms.

## Per-Person Configuration

### Signal Notifications (Optional)

To enable Signal coaching nudges, tell Claude in any session:
"Enable Signal notifications for culture feedback"

Claude will store this preference in your personal Claude memory. Requires `signal-cli` installed and linked.

### Attribution Default

Your repo's `culture/.config.yaml` sets the default. You can override per-feedback when using `/culture:feedback`.

## Multi-Repo Setup

For organizations with multiple repos:

1. **Create an org repo** named after your GitHub org (e.g., `myorg/myorg`)
2. Initialize `culture/` in the org repo — this is your org-wide culture home
3. Initialize `culture/` in individual repos for repo-specific feedback
4. Claude reads both levels when coaching

## Team Onboarding

When a new team member joins:

1. They install the Culture Engine plugin
2. On first session in the repo, Claude reads `culture/values.md` and recent feedback
3. Claude catches them up on team norms and active culture themes
4. They can browse `culture/` at any time for full history
```

- [ ] **Step 2: Commit**

```bash
git add docs/setup.md
git commit -m "docs: add setup guide"
```

---

### Task 9: Self-Review and Final Commit

- [ ] **Step 1: Verify all files exist**

```bash
ls -R skills/ agents/ templates/ docs/
```

Expected:
```
skills/feedback/SKILL.md
skills/reflect/SKILL.md
agents/@coach.md
agents/@moderator.md
templates/feedback-entry.md
templates/culture-init/values.md
templates/culture-init/.config.yaml
docs/setup.md
```

- [ ] **Step 2: Verify CLAUDE.md references match actual skills**

Read `CLAUDE.md` and confirm every skill and agent listed actually exists as a file.

- [ ] **Step 3: Test skill discovery**

Open a new Claude Code session in the plugin directory and verify:
- `/culture:feedback` is discoverable
- `/culture:reflect` is discoverable

- [ ] **Step 4: Tag Phase A**

```bash
git tag v0.1.0-alpha -m "Phase A: Foundation — skills, agents, templates"
```
