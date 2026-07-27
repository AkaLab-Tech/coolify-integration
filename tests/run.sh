#!/usr/bin/env bash
# Tiny hermetic test runner: executes every tests/*.test.sh and reports
# overall pass/fail. No external test framework — this repo has none yet.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

status=0
for f in "$SCRIPT_DIR"/*.test.sh; do
  printf '=== %s ===\n' "$(basename "$f")"
  if ! bash "$f"; then
    status=1
  fi
  printf '\n'
done

exit "$status"
