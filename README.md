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

1. In Coolify, create an API token (Settings → API / Keys & Tokens) with the
   `read`, `deploy`, and `write` scopes. Avoid `root` unless you need it.

2. Store the token in the macOS Keychain:

   ```sh
   security add-generic-password -s coolify-api -a "$USER" -w '<COOLIFY_API_TOKEN>'
   ```

3. Export your instance URL (e.g. in `~/.zshrc`):

   ```sh
   export COOLIFY_BASE_URL="https://coolify.example.com"
   ```

4. Put the CLI on your `PATH` (one-time symlink — this plugin ships no
   installer):

   ```sh
   ln -sf "$HOME/.claude/plugins/coolify-integration/scripts/atelier-coolify" \
     "$HOME/.local/bin/atelier-coolify"
   ```

   Adjust the source path to wherever Claude Code installed the plugin.

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

## Allowlisting in atelier

Add the read/write commands to atelier's `templates/settings.template.json`
(`permissions.allow`). The gated commands are deliberately omitted so they fall
back to operator confirmation:

```json
"Bash(atelier-coolify list:*)",
"Bash(atelier-coolify status:*)",
"Bash(atelier-coolify logs:*)",
"Bash(atelier-coolify deployments:*)",
"Bash(atelier-coolify validate:*)",
"Bash(atelier-coolify deploy:*)",
"Bash(atelier-coolify set-env:*)",
"Skill(coolify-integration:*)"
```

## API compatibility

Targets Coolify v4's `/api/v1` endpoints. If your instance differs, adjust the
paths in [`scripts/atelier-coolify`](scripts/atelier-coolify).

## License

MIT — see [LICENSE](LICENSE).
