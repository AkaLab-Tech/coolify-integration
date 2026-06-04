---
name: coolify
description: >-
  Validate, deploy, and manage applications on a Coolify VPS via the
  atelier-coolify CLI. Use when the operator asks to deploy a project, check a
  deployment's status, read deploy logs, diagnose or fix a failed deployment,
  set environment variables, or create/delete an app on the VPS.
---

# Coolify

`atelier-coolify` is a thin client for the Coolify v1 API. It reads the API
token from the macOS Keychain (service `coolify-api`) and the instance URL from
`$COOLIFY_BASE_URL`. Run `atelier-coolify --help` for the full reference.

## Commands

| Command | Purpose |
| --- | --- |
| `atelier-coolify list` | List applications and their UUIDs |
| `atelier-coolify status <uuid>` | Application status |
| `atelier-coolify logs <uuid> [lines]` | Recent logs |
| `atelier-coolify deployments` | Running deployments |
| `atelier-coolify validate <uuid>` | Status + logs if unhealthy (exit 2 on failure) |
| `atelier-coolify deploy <uuid> [--force]` | Trigger a deployment |
| `atelier-coolify set-env <uuid> KEY=VALUE` | Upsert an env var |
| `atelier-coolify create-app-public …` | Create an app (operator confirmation) |
| `atelier-coolify delete-app <uuid>` | Delete an app (operator confirmation) |

## Validate-and-fix flow

1. `validate <uuid>` — if it exits non-zero, read the logs it prints.
2. Diagnose from the logs (missing env var, build failure, wrong branch).
3. Apply the fix: `set-env` for config, then `deploy <uuid>` to re-run.
4. `validate <uuid>` again to confirm the deployment is healthy.

## Rules

- Resolve the target app with `list` first; never guess a UUID.
- `create-app-public` and `delete-app` are not in the allowlist — confirm with
  the operator before running them.
- After `set-env`, a `deploy` is required for the change to take effect.
