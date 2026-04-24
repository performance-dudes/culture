---
name: signal-setup
description: Use when a team member wants to enable or configure Signal notifications for culture coaching nudges. Sets up signal-cli delivery preferences in Claude memory.
---

# Signal Setup — Configure Signal Notifications

Configure optional Signal CLI notifications for personal coaching nudges.

## Invocation

| Invocation | Action |
|---|---|
| `/culture:signal-setup` | Interactive setup wizard |
| `/culture:signal-setup off` | Disable Signal notifications |

## Process

### Step 1: Check prerequisites

Verify `signal-cli` is available:
```bash
which signal-cli
```

If not installed, inform the user: "Signal notifications require `signal-cli` installed and linked to your Signal account. Want to proceed with setup instructions, or skip Signal for now?"

### Step 2: Configure account

Ask: "What's your Signal phone number? (format: +1234567890)"

Test connectivity:
```bash
signal-cli -a {number} send {number} -m "Culture Engine: Signal notifications enabled ✓"
```

If the test message arrives, proceed. If not, troubleshoot.

### Step 3: Set preferences

Ask:
- **Frequency**: "How often should I reach out? Options: `low` (max 1/day), `medium` (max 3/day), `high` (whenever meaningful)"
- **Quiet hours**: "Any hours I should stay silent? (e.g., 22:00-08:00)"
- **Content**: "What kind of nudges? Options: `coaching` (personal growth), `team` (culture updates), `both`"

### Step 4: Store in Claude memory

Save preferences to Claude memory (NOT to `culture/` — this is private per-person config):

```
Signal preferences:
- Number: {number}
- Frequency: {frequency}
- Quiet hours: {quiet_start}-{quiet_end}
- Content: {content_type}
- Enabled: true
```

### Step 5: Update repo config

If the user consents, update `culture/.config.yaml`:
```yaml
signal:
  enabled: true  # At least one person has Signal enabled
```

This doesn't reveal WHO has it enabled — just that the feature is active for this repo.

## Sending Messages

When `@coach` or heartbeat wants to send a Signal message:

```bash
signal-cli -a {sender_number} send {recipient_number} -m "{message}"
```

Rules:
- Respect quiet hours
- Respect frequency cap
- Never send team feedback attributed to others — only coaching for the recipient
- Keep messages under 500 characters
- Include a reflection question when possible
