#!/usr/bin/env bash
#
# Regression test for task #39 (P1): cmd_validate in scripts/atelier-coolify
# must classify Coolify v4's "<state>:<health>" status strings correctly.
#
# The bug: the original `case` arm used `*running*|*healthy*)`. Because glob
# matching is substring-based, `*healthy*` also matched inside "unhealthy",
# so "running:unhealthy" (and "exited:unhealthy", "restarting:unhealthy")
# were misclassified as healthy and cmd_validate returned 0 instead of 2,
# so the agent never read the logs on a broken deploy.
#
# The fix pins the exact accepted values instead of a substring glob, and
# explicitly documents (and this test pins) that a bare "running" with no
# ":<health>" suffix — apps with no healthcheck configured — is treated as
# healthy, since it is the only signal available for them.
#
# Hermetic: no network I/O, no real Coolify API token. This sources
# scripts/atelier-coolify (its unconditional `main "$@"` call, run here with
# positional params cleared, just prints usage to stdout and returns — no
# I/O), then overrides the `api` and `cmd_logs` functions cmd_validate calls,
# so the whole exercise runs purely off a fabricated status string.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${SCRIPT_DIR}/../scripts/atelier-coolify"

pass=0
fail=0

# run_case <status> <expected-exit> <description>
run_case() {
  local status="$1" expected="$2" desc="$3" code
  set +e
  (
    set -euo pipefail
    set --   # clear run_case's positional params before sourcing: the
             # script's trailing `main "$@"` must see no args (-> usage,
             # no I/O), not this function's ($status $expected $desc).

    # shellcheck source=/dev/null
    source "$TARGET" >/dev/null 2>&1

    fake_app_json="{\"uuid\":\"fake-uuid\",\"name\":\"fake-app\",\"status\":\"${status}\",\"fqdn\":\"fake.example.com\"}"
    # shellcheck disable=SC2329  # invoked indirectly by cmd_validate, defined
    # in the sourced $TARGET, which shellcheck cannot trace across files
    api()      { printf '%s' "$fake_app_json"; }
    # shellcheck disable=SC2329  # stub: cmd_validate calls this on the
    # failure path; never let it reach the network in a test
    cmd_logs() { :; }

    cmd_validate "fake-uuid" >/dev/null 2>&1
  )
  code=$?
  set -e

  if [ "$code" -eq "$expected" ]; then
    printf 'ok   - %s (status=%s -> exit %d)\n' "$desc" "$status" "$code"
    pass=$((pass + 1))
  else
    printf 'FAIL - %s (status=%s -> exit %d, expected %d)\n' "$desc" "$status" "$code" "$expected"
    fail=$((fail + 1))
  fi
}

# --- unhealthy: must exit 2 (and thus read logs) --------------------------
run_case "running:unhealthy"    2 "running:unhealthy is not healthy"
run_case "exited:unhealthy"     2 "exited:unhealthy is not healthy"
run_case "restarting:unhealthy" 2 "restarting:unhealthy is not healthy"

# --- healthy: must exit 0 --------------------------------------------------
run_case "running:healthy" 0 "running:healthy is healthy"

# --- no healthcheck configured: bare "running" is treated as healthy ------
# (pinned deliberately: this is the only signal available for apps that
# never configured a healthcheck, and validate must still succeed for them)
run_case "running" 0 "bare running (no healthcheck) is treated as healthy"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
