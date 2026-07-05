# CLAUDE.md

coolify-integration is a standalone Claude Code plugin that lets atelier agents
operate a Coolify VPS: validate deployments, read logs, trigger deploys, set
environment variables, and create or delete applications — all via Coolify's v1
REST API. It is optional and independent of atelier; install it only when
deploying with Coolify.

## Stack

- **Language**: Bash (single-file CLI — `scripts/atelier-coolify`, v0.4.1)
- **Framework**: None — plain shell + `curl` + optional `jq`
- **Package manager**: None (no build step; `atelier-coolify link` installs a self-resolving launcher onto PATH)
- **Test runner**: TBD — no test files found
- **Linter / formatter**: TBD — no linter config found

## Architecture

The repo has a flat layout with no `src/` or `lib/`:

- `scripts/atelier-coolify` — the entire CLI; subcommands map 1:1 to Coolify API
  calls (`list`, `status`, `logs`, `deployments`, `validate`, `deploy-mode`,
  `deploy`, `set-env`, `create-app-public`, `delete-app`, plus setup helpers)
- `skills/coolify/SKILL.md` — Claude Code skill that drives the CLI within an
  atelier session; encodes the validate-and-fix flow and deploy-mode rules
- `commands/setup.md` — `/coolify-integration:setup` slash command; wires the
  PATH launcher, user-level allowlist, and per-project `.env` auth
- `.claude-plugin/plugin.json` — Claude Code plugin manifest (name, version,
  description, homepage)

Auth is per project: `COOLIFY_BASE_URL` and `COOLIFY_API_TOKEN` live in each
project's `.env` (kept gitignored by atelier's `.env*` guardrail). Permissions
are merged into the user-level `settings.json` — never the per-task template.

## Conventions

- **CLI entrypoint**: `scripts/atelier-coolify <command>` — or `atelier-coolify`
  after `atelier-coolify link` places a self-resolving launcher on PATH (it
  follows the active plugin-cache version across `claude plugin update`)
- **Setup**: `atelier-coolify configure` (interactive) or
  `/coolify-integration:setup` (from a Claude Code session)
- **Permissions**: `atelier-coolify enable-permissions` merges the allowlist into
  `$ATELIER_CONFIG_DIR/settings.json`; `disable-permissions` removes it
- **Deploy-mode cache**: `.coolify-deploy-mode.json` — live Coolify application
  reads return `unknown` because the API does not expose auto-deploy; add the
  cache to the target project's `.gitignore`, and use a hand-edited cache entry
  only when the operator has confirmed the app is auto-deployed
- **No CI**: no `.github/workflows/` directory found

## What this project is NOT

- TBD

## Out of scope for AI agents

- `create-app-public` and `delete-app` are intentionally outside the allowlist
  and require explicit operator confirmation before running
- Agents must never `git add` a project's `.env` — it holds live API tokens
