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

Fill the feedback entry template (`templates/feedback-entry.md`):
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
2. If yes: copy templates from the plugin's `templates/culture-init/` directory and ask user to fill in `values.md`
3. Commit: `culture: initialize culture/ folder`

## Quality Gate

Every feedback entry must pass these checks before storage:
- No personal attacks or naming in anonymous entries
- Has a concrete, actionable suggestion
- Tone is direct but respectful
- Could not reasonably identify the anonymous author through context
