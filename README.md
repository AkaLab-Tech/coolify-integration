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
`read`, `deploy`, and `write` scopes (avoid `root` unless you need it). Then
configure the plugin in one of two ways.

**With atelier** — pick it during `install.sh`, or run any time:

```
/atelier:setup-coolify
```

**Standalone** — run the configure command, which links the `atelier-coolify`
CLI onto your `PATH`, grants the [allowlist](#how-permissions-work), and prompts
for the token (stored in the macOS Keychain) and base URL:

```sh
atelier-coolify configure
# or, inside a Claude Code session:
/coolify-integration:setup
```

The script also accepts `COOLIFY_API_TOKEN` directly (overriding the Keychain
lookup) for non-macOS or CI use.

## Usage

Run `atelier-coolify --help`, or let the `coolify` skill drive it. Common flow:

```sh
atelier-coolify list                         # find the app UUID
atelier-coolify validate <uuid>              # status + logs if unhealthy
atelier-coolify set-env <uuid> API_URL=https://api.example.com
atelier-coolify deploy <uuid>                # apply the change
```

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
"Bash(atelier-coolify deploy:*)",
"Bash(atelier-coolify set-env:*)",
"Bash(atelier-coolify health:*)",
"Bash(atelier-coolify version:*)",
"Skill(coolify-integration:*)"
```

The merge is idempotent and order-preserving, and touches nothing else in the
file. The gated commands (`create-app-public`, `delete-app`) are deliberately
omitted so they fall back to operator confirmation. Undo with
`atelier-coolify disable-permissions`.

## API compatibility

Targets Coolify v4's `/api/v1` endpoints. If your instance differs, adjust the
paths in [`scripts/atelier-coolify`](scripts/atelier-coolify).

## License

MIT — see [LICENSE](LICENSE).
