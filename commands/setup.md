---
description: Set up coolify-integration — link the CLI onto PATH and grant atelier agents the Coolify allowlist (user-level, never atelier's template)
allowed-tools: Bash(mkdir -p:*), Bash(ln:*), Bash(security find-generic-password:*), Bash(${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify:*)
---

Set up the coolify-integration plugin on this machine, then report a short
summary. Do every step:

1. Put the CLI on `PATH` (idempotent symlink):

   ```sh
   mkdir -p "$HOME/.local/bin"
   ln -sf "${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify" "$HOME/.local/bin/atelier-coolify"
   ```

2. Grant atelier agents the routine Coolify allowlist. This merges into the
   **user-level** `settings.json` (which persists across tasks) — it never
   touches atelier's per-task `settings.template.json`, so atelier core stays
   decoupled:

   ```sh
   "${CLAUDE_PLUGIN_ROOT}/scripts/atelier-coolify" enable-permissions
   ```

3. Check the prerequisites and tell the operator exactly what is still missing:
   - `$COOLIFY_BASE_URL` is exported (else suggest adding
     `export COOLIFY_BASE_URL="https://coolify.example.com"` to `~/.zshrc`).
   - A token is stored in the Keychain — test with
     `security find-generic-password -s coolify-api -a "$USER" -w >/dev/null 2>&1`;
     if absent, instruct:
     `security add-generic-password -s coolify-api -a "$USER" -w '<token>'`.
   - `$HOME/.local/bin` is on `PATH`.

Report: PATH link status, whether permissions were merged, and any missing
prerequisite. To undo later, run `atelier-coolify disable-permissions` and
remove the symlink.
