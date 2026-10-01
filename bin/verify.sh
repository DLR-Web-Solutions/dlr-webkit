#!/usr/bin/env bash
# Single verification entrypoint for AI agents and humans.
# Runs the project's applicable quality gates; skips steps that are not configured.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo "=========================================="
echo "  dlr-webkit verify"
echo "=========================================="

run_step() {
  local name="$1"
  shift
  echo ""
  echo "→ $name"
  "$@"
  echo "  ✔ $name"
}

has_script() {
  local key="$1"
  bun -e "import p from './package.json' with { type: 'json' }; process.exit(p.scripts?.['$key'] ? 0 : 1)"
}

# 0) Kit integrity (always)
run_step "doctor" bash "$ROOT_DIR/bin/doctor.sh"

if [ ! -f package.json ]; then
  echo ""
  echo "No package.json — kit integrity only. Done."
  exit 0
fi

if [ ! -d node_modules ]; then
  echo ""
  echo "node_modules missing. Installing with bun..."
  bun install
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

if find . -type f \( -name '*.test.ts' -o -name '*.test.tsx' -o -name '*.test.js' -o -name '*.spec.ts' -o -name '*.spec.tsx' \) \
    ! -path './node_modules/*' ! -path './.git/*' | grep -q .; then
  if has_script test; then
    run_step "test" bun run test
  else
    run_step "test" bun test
  fi
else
  echo ""
  echo "→ test (skipped — no test files found)"
fi

if has_script build; then
  run_step "build" bun run build
fi

echo ""
echo "→ bun audit"
if bun audit; then
  echo "  ✔ bun audit"
else
  echo "  ✖ bun audit reported issues"
  exit 1
fi

if has_script test:e2e; then
  run_step "test:e2e" bun run test:e2e
fi

echo ""
echo "=========================================="
echo "  ✔ verify passed"
echo "=========================================="
