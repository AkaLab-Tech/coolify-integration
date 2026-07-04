# coolify-integration

Optional, standalone [Claude Code](https://docs.anthropic.com/claude/docs/claude-code)
plugin that lets [atelier](https://github.com/AkaLab-Tech/atelier) agents operate
a [Coolify](https://coolify.io) VPS: validate deployments, read logs, trigger
deploys, set environment variables, and create or delete applications — all via
Coolify's v1 REST API.

It is independent of atelier; install it only if you deploy with Coolify.

## Install

```
/plugin marketplace add AkaLab-Tech/claude-plugins
/plugin install coolify-integration@akalab-tech
```

## Setup

In Coolify, create an API token (Settings → API / Keys & Tokens) with the
`read`, `deploy`, and `write` scopes (avoid `root` unless you need it).

Setup has two parts: a **machine-wide** part (link the CLI onto `PATH`, grant
the [allowlist](#how-permissions-work)) and a **per-project** part (the token +
URL). Auth is per project so one operator can deploy different projects to
different Coolify instances.

**With atelier** — pick it during `install.sh`, or run any time:

```
/atelier:setup-coolify
```

**Standalone** — `configure` does the machine-wide part, then (run from inside a
project) wires that project's `.env`:

```sh
atelier-coolify configure
# or, inside a Claude Code session:
/coolify-integration:setup
```

### Per-project auth

Each project carries its own credentials in its `.env` (kept gitignored by
atelier's `.env*` guardrail):

```sh
COOLIFY_BASE_URL=https://coolify.example.com
COOLIFY_API_TOKEN=<token>
```

`atelier-coolify` reads these from the project's `.env` (or `$COOLIFY_ENV_FILE`,
or the environment) at call time.

## Usage

Run `atelier-coolify --help`, or let the `coolify` skill drive it. Common flow:

```sh
atelier-coolify list                         # find the app UUID
atelier-coolify deploy-mode <uuid>           # auto-deploy on push, or manual?
atelier-coolify validate <uuid>              # status + logs if unhealthy
atelier-coolify set-env <uuid> API_URL=https://api.example.com
atelier-coolify deploy <uuid>                # apply the change
```

`deploy-mode` is meant to report whether the app auto-deploys on a push to its
watched branch (GitHub App wiring) or needs a manual `deploy`, but Coolify's
`/api/v1/applications/{uuid}` never exposes the `is_auto_deploy_enabled` flag
(it lives on a `settings` relation the endpoint does not eager-load), so this
cannot currently be read from the API. Every app therefore resolves to
`deploy_mode: "unknown"` and the `coolify` skill treats it as **manual** — always
run an explicit `deploy` for code changes; the "skip the redundant deploy on
auto-configured apps" optimization stays dormant until Coolify exposes the flag
or you override it. The result is cached per project in
`.coolify-deploy-mode.json` — add that file to the project's `.gitignore`. To
mark a specific app as known-auto, hand-edit its entry in that cache file
(`deploy_mode: "auto"`); it is read back verbatim (`source: "cache"`) and never
overwritten except by `--refresh`.

## How permissions work

This plugin stays fully decoupled from atelier — it never edits atelier's
shipped `settings.template.json`. Instead, `/coolify-integration:setup` (or
`atelier-coolify enable-permissions`) merges the routine allowlist into your
**user-level** `settings.json` (`$ATELIER_CONFIG_DIR/settings.json`), which
persists across tasks and applies on top of atelier's per-task settings:

```json
"Bash(atelier-coolify list:*)",
"Bash(atelier-coolify status:*)",
"Bash(atelier-coolify logs:*)",
"Bash(atelier-coolify deployments:*)",
"Bash(atelier-coolify validate:*)",
"Bash(atelier-coolify deploy-mode:*)",
"Bash(atelier-coolify deploy:*)",
"Bash(atelier-coolify set-env:*)",
"Bash(atelier-coolify health:*)",
"Bash(atelier-coolify version:*)",
"Skill(coolify-integration:*)"
```

The merge is idempotent and order-preserving, and touches nothing else in the
file. The gated commands (`create-app-public`, `delete-app`) are deliberately
omitted so they fall back to operator confirmation. As defense-in-depth they
also confirm in-CLI: without `--yes`, `create-app-public` asks y/N and
`delete-app` requires typing the app uuid back before anything is sent to the
API; non-interactive runs (no TTY) refuse to proceed unless `--yes` is passed.
Undo the allowlist with `atelier-coolify disable-permissions`.

## API compatibility

Targets Coolify v4's `/api/v1` endpoints. If your instance differs, adjust the
paths in [`scripts/atelier-coolify`](scripts/atelier-coolify).

## License

MIT — see [LICENSE](LICENSE).
