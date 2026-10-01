#!/usr/bin/env bash
# Single verification entrypoint for AI agents and humans.
# Any failed gate exits non-zero. Skips steps that are not configured.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

FAILED_STEP=""

echo "=========================================="
echo "  dlr-webkit verify"
echo "  root: $ROOT_DIR"
echo "=========================================="

on_err() {
  local code=$?
  if [ -n "$FAILED_STEP" ]; then
    echo ""
    echo "  ✖ verify failed at: $FAILED_STEP (exit $code)"
  else
    echo ""
    echo "  ✖ verify failed (exit $code)"
  fi
  exit "$code"
}
trap on_err ERR

run_step() {
  local name="$1"
  shift
  FAILED_STEP="$name"
  echo ""
  echo "→ $name"
  "$@"
  echo "  ✔ $name"
  FAILED_STEP=""
}

has_script() {
  local key="$1"
  # key is always a literal from this script — never pass untrusted input here
  bun -e "import p from './package.json' with { type: 'json' }; process.exit(p.scripts?.['${key}'] ? 0 : 1)"
}

has_test_files() {
  local found
  found="$(find . -type f \( -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.test.js' -o -name '*.spec.ts' -o -name '*.spec.tsx' \) \
    ! -path './node_modules/*' ! -path './.git/*' 2>/dev/null | head -n 1 || true)"
  [ -n "$found" ]
}

# 0) Kit integrity (always)
run_step "doctor" bash "$ROOT_DIR/bin/doctor.sh"

if [ ! -f package.json ]; then
  echo ""
  echo "No package.json — doctor-only verification complete."
  echo "=========================================="
  echo "  ✔ verify passed"
  echo "=========================================="
  exit 0
fi

if [ ! -d node_modules ]; then
  echo ""
  echo "→ install (node_modules missing)"
  FAILED_STEP="install"
  bun install
  echo "  ✔ install"
  FAILED_STEP=""
fi

if has_script format:check; then
  run_step "format:check" bun run format:check
fi

if has_script lint; then
  run_step "lint" bun run lint
fi

if [ -f tsconfig.json ] && has_script typecheck; then
  run_step "typecheck" bun run typecheck
fi

if [ "${DLR_VERIFY_SKIP_TESTS:-0}" = "1" ]; then
  echo ""
  echo "→ test (skipped — DLR_VERIFY_SKIP_TESTS=1)"
elif has_test_files; then
  if has_script test; then
    run_step "test" bun run test
  else
    run_step "test" bun test
  fi
else
  echo ""
  echo "→ test (skipped — no *.test.* / *.spec.* files)"
fi

if has_script build; then
  run_step "build" bun run build
fi

FAILED_STEP="bun audit"
echo ""
echo "→ bun audit"
bun audit
echo "  ✔ bun audit"
FAILED_STEP=""

if has_script test:e2e; then
  run_step "test:e2e" bun run test:e2e
fi

echo ""
echo "=========================================="
echo "  ✔ verify passed"
echo "=========================================="
