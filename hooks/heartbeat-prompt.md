# Heartbeat Prompt

Run a Culture Engine heartbeat cycle. This is an automated check-in.

1. Read `culture/.config.yaml` in the current repo
2. Run `/culture:heartbeat` to scan activity and deliver observations
3. Be silent if nothing meaningful happened — no noise
4. If Signal is enabled for any team member, deliver coaching nudges for significant findings
5. Keep total execution under 2 minutes
