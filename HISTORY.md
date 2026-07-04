# History

Completed work log. Newest first. Each entry references the PR(s) that delivered the work.

## 2026-07

### Deploy-mode dead field probe removed — 2026-07-04
**PR:** [#10](https://github.com/AkaLab-Tech/coolify-integration/pull/10) — branch `task/8-deploy-mode-dead-probe`

`atelier-coolify deploy-mode <uuid>` always resolved to `"unknown"` against a
real app: the three-way `is_auto_deploy_enabled` probe in `cmd_deploy_mode`
targeted a field Coolify's `GET /applications/{uuid}` endpoint never
eager-loads (it lives on a `settings` relation), so the probe was
structurally guaranteed to fail.

**Delivered:**
- Removed the dead field probe from `cmd_deploy_mode`; the live path now
  always emits `deploy_mode: "unknown"`, `auto_deploy_enabled: null` instead
  of pretending to resolve `auto` vs `manual`.
- Dropped the same dead `auto_deploy` key from `cmd_status`'s output.
- `usage()` and docs (`skills/coolify/SKILL.md`, `README.md`, `CLAUDE.md`)
  updated: the flag can't currently be read from the API, apps are treated
  as manual unless the operator hand-edits the `.coolify-deploy-mode.json`
  cache override, and `--refresh` resets an entry back to `"unknown"`.
- Version 0.4.0 → 0.4.1 (`plugin.json` + CLI `VERSION`).

**Tests:** `bash -n` and `shellcheck -S warning` clean; 4 hermetic scratch
checks: dead-field live path resolves to the `unknown`/`null` terminal state;
a hand-seeded cache entry is honored and reported with `source: "cache"`;
a pre-fix-format cache entry is read without crashing; `status` no longer
emits an `auto_deploy` key.

### Self-resolving CLI launcher — `link` survives plugin updates — 2026-07-02
**PR:** [#6](https://github.com/AkaLab-Tech/coolify-integration/pull/6) — branch `fix/self-resolving-cli-launcher`

`atelier-coolify link` symlinked `~/.local/bin/atelier-coolify` to the script's
resolved path. Run from Claude Code's plugin cache that path is versioned
(`.../coolify-integration/0.3.0/scripts/atelier-coolify`), so every
`claude plugin update` left the symlink dangling.

**Delivered:**
- `cmd_link` now writes a small executable launcher (regular file, not a
  symlink) that resolves the ACTIVE install on every invocation via Claude
  Code's `installed_plugins.json`
  (`.plugins["coolify-integration@akalab-tech"][0].installPath`), falling back
  to the link-time path for git-clone / dev installs or a missing manifest.
- The launcher is emitted to a temp file and `mv`ed into place after `rm -f`
  of the old target — a bare `>` redirect onto the existing symlink would
  follow it and clobber the plugin-cache script (this exact incident motivated
  the guard).
- Docs aligned: `usage()` (`link` / `configure`), `commands/setup.md`,
  `CLAUDE.md`.
- Version 0.3.0 → 0.4.0 (`plugin.json` + CLI `VERSION`).

**Tests:** `bash -n` + `shellcheck -S warning` clean; hermetic scratch-HOME
suite: `link` run from a fake plugin cache (9.9.9) installs a regular
executable file whose invocation runs the 9.9.9 copy; repointing the fake
manifest at a 10.0.0 copy makes the same launcher run 10.0.0 **without
re-linking**; a pre-existing symlink target is replaced without clobbering the
cached script (byte-identical before/after); clone/dev fallback works with no
manifest; `configure --non-interactive` end-to-end against a scratch
`settings.json`.

### Security hardening: token off argv, in-CLI guards for destructive commands, query-string encoding — 2026-07-01
**PR:** [#5](https://github.com/AkaLab-Tech/coolify-integration/pull/5) — branch `fix/token-and-confirm-guards`

Hardening pass on `scripts/atelier-coolify` from a security audit: the API
token was visible in `ps` for the lifetime of every request, the destructive
commands had no in-CLI confirmation (the allowlist omission was the only
guard), and UUIDs were interpolated into query strings unencoded.

**Delivered:**
- `api()` now passes the `Authorization: Bearer` header to curl via a
  process-substitution fd (`-H @<(printf …)`, curl >= 7.55) instead of argv,
  so the token no longer appears in the process list (verified on macOS
  bash 3.2 under `set -euo pipefail`).
- `delete-app` and `create-app-public` require `--yes` or an interactive
  confirmation before any network call: `delete-app` makes the operator type
  the app uuid back; `create-app-public` asks y/N. Non-TTY without `--yes`
  dies with a message explaining the flag. `usage()`, `skills/coolify/SKILL.md`
  and `README.md` updated.
- New `_uri()` helper (`jq -rn --arg v … '$v|@uri'`) percent-encodes values
  interpolated into query strings (`deploy?uuid=…`, `logs?lines=…`).

**Tests:** `bash -n` and `shellcheck -S warning` clean; `--help` exits 0;
fake-project run against `https://127.0.0.1:1` fails at the connection stage
(header mechanism builds a valid curl call); `set -x` trace of a request shows
no token in curl's argv; non-TTY `delete-app` without `--yes` dies before any
network I/O.
