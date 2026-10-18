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

has_test_files() {
  local found
  found="$(find . -type f \( -name 'test_*.py' -o -name '*_test.py' \) \
    ! -path './.venv/*' ! -path './.git/*' 2>/dev/null | head -n 1 || true)"
  [ -n "$found" ]
}

# 0) Kit integrity (always)
run_step "doctor" bash "$ROOT_DIR/bin/doctor.sh"

if [ ! -f pyproject.toml ]; then
  echo ""
  echo "No pyproject.toml — doctor-only verification complete."
  echo "=========================================="
  echo "  ✔ verify passed"
  echo "=========================================="
  exit 0
fi

if [ ! -d .venv ]; then
  echo ""
  echo "→ install (.venv missing)"
  FAILED_STEP="install"
  uv sync
  echo "  ✔ install"
  FAILED_STEP=""
fi

run_step "ruff format --check" uv run ruff format --check .
run_step "ruff check" uv run ruff check .

if grep -q '^\[tool.mypy\]' pyproject.toml; then
  run_step "mypy" uv run mypy .
fi

if [ "${DLR_VERIFY_SKIP_TESTS:-0}" = "1" ]; then
  echo ""
  echo "→ test (skipped — DLR_VERIFY_SKIP_TESTS=1)"
elif has_test_files; then
  run_step "pytest" uv run pytest -q
else
  echo ""
  echo "→ test (skipped — no test_*.py files)"
fi

if [ "${DLR_VERIFY_SKIP_AUDIT:-0}" = "1" ]; then
  echo ""
  echo "→ audit (skipped — DLR_VERIFY_SKIP_AUDIT=1)"
else
  run_step "pip-audit" uvx pip-audit==2.9.0 --progress-spinner off
fi

echo ""
echo "=========================================="
echo "  ✔ verify passed"
echo "=========================================="
