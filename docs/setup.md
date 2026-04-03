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
