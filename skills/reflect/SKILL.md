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
