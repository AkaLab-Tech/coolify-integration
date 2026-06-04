---
description: Set up coolify-integration — link the CLI onto PATH, grant atelier agents the Coolify allowlist (user-level), and capture the token + base URL
allowed-tools: Bash(security add-generic-password:*), Bash(security find-generic-password:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify:*)
---

Set up the coolify-integration plugin on this machine, then report a short
summary. Do every step in order:

1. Run the non-interactive part of setup (PATH symlink + user-level allowlist
   merge — never atelier's per-task template):

   ```sh
   "${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify" configure --non-interactive
   ```

2. **API token.** Check whether one already exists:
   `security find-generic-password -s coolify-api -a "$USER" -w >/dev/null 2>&1`.
   - If it exists, keep it.
   - If not, ask the operator (in chat) for their Coolify API token, then store
     it: `security add-generic-password -U -s coolify-api -a "$USER" -w '<token>'`.
     Never echo the token back.

3. **Base URL.** If `$COOLIFY_BASE_URL` is unset, ask the operator for their
   Coolify instance URL (e.g. `https://coolify.example.com`) and append
   `export COOLIFY_BASE_URL="<url>"` to their `~/.zshrc` (only if not already
   present). Remind them to open a new shell to load it.

4. Verify the connection if both are now set:
   `atelier-coolify version` (or `${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify version`).

Report: PATH link status, permissions merged, token present (yes/no — never the
value), base URL, and the connection check result. To undo later, run
`atelier-coolify disable-permissions` and remove the symlink.
