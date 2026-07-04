# Roadmap — coolify-integration

Backlog of work for this project. Tasks flow: `ROADMAP.md` → `IN_PROGRESS.md` → `HISTORY.md`.

Format per item: `- [ ] <type> <title> [#id] [~estimate] [blocked_by:...]` (PLAN.md §5).

## 🔥 P0 — Blockers

(Non-negotiable items. Keep this list small — anything here blocks shipping.)

- [ ] [ready] `bug` deploy-mode always resolves to 'unknown' — dead field probe against Coolify's application endpoints `#8` `~1h`
  - Repro: run `atelier-coolify deploy-mode <uuid>` against any real app; `deploy_mode` is always `"unknown"`.
  - Root cause: `GET /applications/{uuid}` never eager-loads the `settings` relation upstream, so `is_auto_deploy_enabled` (and the two other probed field names) never appear in the response — the three-way jq probe in `cmd_deploy_mode` is structurally guaranteed to fail. See #8 for the full trace through Coolify's source.
  - Acceptance: remove the dead probe; `deploy-mode` no longer pretends it can resolve `auto` vs `manual` from these fields. Docs (`SKILL.md`, `README.md`, `CLAUDE.md`) updated to state the flag can't currently be read from the API and the skill always treats apps as manual unless the operator overrides. Existing `.coolify-deploy-mode.json` cache format/behavior degrades gracefully (no crash on old cache entries).

## 🎯 P1 — Next

## 💭 P2 — Backlog
