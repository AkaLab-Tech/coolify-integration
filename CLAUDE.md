# CLAUDE.md

coolify-integration is a standalone Claude Code plugin that lets atelier agents
operate a Coolify VPS: validate deployments, read logs, trigger deploys, set
environment variables, and create or delete applications — all via Coolify's v1
REST API. It is optional and independent of atelier; install it only when
deploying with Coolify.

## Stack

- **Language**: Bash (single-file CLI — `scripts/atelier-coolify`, v0.2.0)
- **Framework**: None — plain shell + `curl` + optional `jq`
- **Package manager**: None (no build step; CLI is symlinked onto PATH via `atelier-coolify link`)
- **Test runner**: TBD — no test files found
- **Linter / formatter**: TBD — no linter config found

## Architecture

The repo has a flat layout with no `src/` or `lib/`:

- `scripts/atelier-coolify` — the entire CLI; subcommands map 1:1 to Coolify API
  calls (`list`, `status`, `logs`, `deployments`, `validate`, `deploy-mode`,
  `deploy`, `set-env`, `create-app-public`, `delete-app`, plus setup helpers)
- `skills/coolify/SKILL.md` — Claude Code skill that drives the CLI within an
  atelier session; encodes the validate-and-fix flow and deploy-mode rules
- `commands/setup.md` — `/coolify-integration:setup` slash command; wires PATH
  symlink, user-level allowlist, and per-project `.env` auth
- `.claude-plugin/plugin.json` — Claude Code plugin manifest (name, version,
  description, homepage)

Auth is per project: `COOLIFY_BASE_URL` and `COOLIFY_API_TOKEN` live in each
project's `.env` (kept gitignored by atelier's `.env*` guardrail). Permissions
are merged into the user-level `settings.json` — never the per-task template.

## Conventions

- **CLI entrypoint**: `scripts/atelier-coolify <command>` — or `atelier-coolify`
  after `atelier-coolify link` places a symlink on PATH
- **Setup**: `atelier-coolify configure` (interactive) or
  `/coolify-integration:setup` (from a Claude Code session)
- **Permissions**: `atelier-coolify enable-permissions` merges the allowlist into
  `$ATELIER_CONFIG_DIR/settings.json`; `disable-permissions` removes it
- **Deploy-mode cache**: `.coolify-deploy-mode.json` — add to target project's
  `.gitignore`; pass `--refresh` after changing git/auto-deploy settings
- **No CI**: no `.github/workflows/` directory found

## What this project is NOT

- TBD

## Out of scope for AI agents

- `create-app-public` and `delete-app` are intentionally outside the allowlist
  and require explicit operator confirmation before running
- Agents must never `git add` a project's `.env` — it holds live API tokens
