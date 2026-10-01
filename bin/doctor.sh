#!/usr/bin/env bash
# Diagnose common environment and kit problems for dlr-webkit projects.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

PASS=0
WARN=0
FAIL=0

ok() { echo "  ✔ $1"; PASS=$((PASS + 1)); }
warn() { echo "  ⚠ $1"; WARN=$((WARN + 1)); }
bad() { echo "  ✖ $1"; FAIL=$((FAIL + 1)); }

echo "=========================================="
echo "  dlr-webkit doctor"
echo "  root: $ROOT_DIR"
echo "=========================================="

echo ""
echo "Runtime"
if command -v bun >/dev/null 2>&1; then
  ok "bun $(bun --version)"
else
  bad "bun not found (required for JS/TS projects)"
fi

if command -v docker >/dev/null 2>&1; then
  ok "docker available"
  if docker info >/dev/null 2>&1; then
    ok "docker daemon reachable"
  else
    warn "docker installed but daemon not reachable"
  fi
else
  warn "docker not found (needed for compose-based workflows)"
fi

echo ""
echo "Kit / project files"
for f in .cursorrules CLAUDE.md package.json docker-compose.yml Dockerfile .env.example docs/00-context/project.md; do
  if [ -e "$f" ]; then
    ok "$f present"
  else
    bad "missing $f"
  fi
done

if [ -d src ]; then
  ok "src/ directory present"
else
  bad "src/ directory missing"
fi

echo ""
echo "Dependencies"
if [ -f package.json ]; then
  if [ -d node_modules ]; then
    ok "node_modules present"
  else
    warn "node_modules missing — run: bun install"
  fi
  if [ -f bun.lock ] || [ -f bun.lockb ]; then
    ok "bun lockfile present"
  else
    warn "no bun.lock — run bun install and commit the lockfile"
  fi
fi

echo ""
echo "Environment"
if [ -f .env ]; then
  ok ".env present"
  if [ -f .env.example ]; then
    missing=0
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in
        ''|\#*) continue ;;
      esac
      key="${line%%=*}"
      key="$(echo "$key" | tr -d '[:space:]')"
      [ -z "$key" ] && continue
      if ! grep -q "^${key}=" .env 2>/dev/null; then
        warn ".env missing key from .env.example: $key"
        missing=1
      fi
    done < .env.example
    if [ "$missing" -eq 0 ]; then
      ok ".env covers keys declared in .env.example"
    fi
  fi
else
  warn ".env missing — copy .env.example to .env and fill secrets"
fi

echo ""
echo "Docker Compose"
if [ -f docker-compose.yml ]; then
  if [ -f Dockerfile ]; then
    ok "Dockerfile referenced by compose exists"
  else
    bad "docker-compose expects Dockerfile but it is missing"
  fi
  if grep -qE "ports:|[[:space:]]- ['\"]?[0-9]+:[0-9]+" docker-compose.yml 2>/dev/null; then
    if grep -qE '\$\{APP_PORT|\$\{DB_PORT' docker-compose.yml; then
      ok "compose uses dynamic APP_PORT/DB_PORT substitutions"
    else
      # soft check: hardcoded ports are discouraged
      warn "review compose ports — prefer \${APP_PORT}/\${DB_PORT} substitutions"
    fi
  fi
fi

echo ""
echo "Database (optional)"
if [ -f .env ] && grep -q '^DATABASE_URL=' .env 2>/dev/null; then
  if command -v bun >/dev/null 2>&1; then
    # Best-effort TCP check is intentionally light; full connectivity is app-specific.
    ok "DATABASE_URL is set (connectivity not probed)"
  fi
elif [ -f .env ] && grep -q '^DB_DATABASE=' .env 2>/dev/null; then
  ok "DB_* variables present (compose-style)"
else
  warn "no DATABASE_URL or DB_* vars detected"
fi

echo ""
echo "Quality hooks"
if [ -f .husky/pre-commit ]; then
  ok "husky pre-commit present"
  if grep -q 'bunx lint-staged\|lint-staged' .husky/pre-commit; then
    ok "pre-commit invokes lint-staged"
  else
    warn "pre-commit does not appear to run lint-staged"
  fi
else
  warn "missing .husky/pre-commit"
fi

echo ""
echo "=========================================="
echo "  Result: $PASS passed, $WARN warnings, $FAIL failures"
echo "=========================================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
