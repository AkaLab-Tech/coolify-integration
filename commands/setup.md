---
description: Set up coolify-integration — link the CLI onto PATH, grant atelier agents the Coolify allowlist (user-level), and wire this project's .env to a Coolify instance
allowed-tools: Bash(${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify:*), Read(.env), Edit(.env), Write(.env)
---

Set up the coolify-integration plugin, then report a short summary. Do every
step in order:

1. Run the machine-wide part of setup (PATH symlink + user-level allowlist
   merge — never atelier's per-task template):

   ```sh
   "${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify" configure --non-interactive
   ```

2. **Per-project auth.** Coolify auth is per project so one operator can deploy
   different projects to different instances. If the current directory is a
   project, wire its `.env`:
   - Read `.env` (create it if missing). If `COOLIFY_BASE_URL` is absent, ask
     the operator for the project's Coolify instance URL (e.g.
     `https://coolify.example.com`) and add `COOLIFY_BASE_URL=<url>`.
   - If `COOLIFY_API_TOKEN` is absent, ask for the project's Coolify API token
     and add `COOLIFY_API_TOKEN=<token>`. Never echo the token back.
   - `.env` stays gitignored by atelier's `.env*` guardrail — never `git add` it.

3. Verify the connection if both are set: `atelier-coolify version`.

Report: PATH link status, permissions merged, whether `.env` now has
`COOLIFY_BASE_URL` + `COOLIFY_API_TOKEN` (token presence only, never the value),
and the connection check result. To undo the machine-wide part later, run
`atelier-coolify disable-permissions` and remove the symlink.
