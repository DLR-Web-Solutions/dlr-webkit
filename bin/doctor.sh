#!/usr/bin/env bash
# Diagnose common environment and kit problems for dlr-webkit projects.
# Never prints secret values from .env.
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
if command -v python3 >/dev/null 2>&1; then
  ok "python3 $(python3 --version)"
else
  bad "python3 not found (required for Python projects)"
fi

if command -v uv >/dev/null 2>&1; then
  ok "uv $(uv --version)"
else
  if [ -f pyproject.toml ]; then
    bad "uv not found (required when pyproject.toml is present)"
  else
    warn "uv not found"
  fi
fi

echo ""
echo "Kit / project files"
for f in .cursorrules CLAUDE.md docs/00-context/project.md .env.example; do
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

if [ -f pyproject.toml ]; then
  ok "package manifest present (pyproject.toml)"
else
  warn "no pyproject.toml yet (expected after scaffolding)"
fi

echo ""
echo "bin scripts"
for s in doctor.sh verify.sh init.sh install.sh; do
  if [ -f "bin/$s" ]; then
    if [ -x "bin/$s" ]; then
      ok "bin/$s executable"
    else
      warn "bin/$s exists but is not executable"
    fi
  else
    bad "missing bin/$s"
  fi
done

echo ""
echo "Dependencies"
if [ -f pyproject.toml ]; then
  if [ -d .venv ]; then
    ok ".venv present"
  else
    warn ".venv missing — run: uv sync"
  fi
  if [ -f uv.lock ]; then
    ok "uv.lock present"
  else
    warn "no uv.lock — run uv lock and commit the lockfile"
  fi
fi

echo ""
echo "Environment"
if [ -f .env ]; then
  ok ".env present (values not printed)"
  if [ -f .env.example ]; then
    missing=0
    while IFS= read -r line || [ -n "$line" ]; do
      case "$line" in
        ''|\#*) continue ;;
      esac
      key="${line%%=*}"
      key="${key%"${key##*[![:space:]]}"}"
      key="${key#"${key%%[![:space:]]*}"}"
      [ -z "$key" ] && continue
      # Skip commented-style optional keys that were left as comments only
      if ! grep -qE "^${key}=" .env 2>/dev/null; then
        # Keys present only as comments in .env.example are optional — already skipped via \#*
        warn ".env missing key from .env.example: $key"
        missing=1
      fi
    done < .env.example
    if [ "$missing" -eq 0 ]; then
      ok ".env covers keys declared in .env.example"
    fi
  fi

  echo ""
  echo "Database (config only — connectivity not probed)"
  if grep -qE '^DATABASE_URL=.+' .env 2>/dev/null; then
    ok "DATABASE_URL is set"
  elif grep -qE '^DB_DATABASE=.+' .env 2>/dev/null; then
    ok "DB_* variables present (compose-style)"
  else
    warn "no DATABASE_URL or DB_DATABASE set in .env"
  fi
else
  warn ".env missing — copy .env.example to .env and fill secrets (do not commit .env)"
fi

echo ""
echo "Docker"
if [ -f docker-compose.yml ]; then
  ok "docker-compose.yml present"
  if grep -qE 'dockerfile:\s*Dockerfile|build:' docker-compose.yml; then
    if [ -f Dockerfile ]; then
      ok "Dockerfile present (referenced by compose)"
    else
      bad "compose references a build/Dockerfile but Dockerfile is missing"
    fi
  fi
  if grep -qE '\$\{APP_PORT|\$\{DB_PORT' docker-compose.yml; then
    ok "compose uses dynamic APP_PORT/DB_PORT substitutions"
  else
    warn "prefer \${APP_PORT}/\${DB_PORT} for host port mappings"
  fi
  if grep -vE '^\s*#' docker-compose.yml | grep -qE -- '--version'; then
    bad "app healthcheck must not use a runtime --version flag — probe HTTP /health"
  fi
  if grep -qE 'PASSWORD:-\s*secret|PASSWORD:-secret' docker-compose.yml; then
    bad "compose must not default DB passwords to 'secret' — require DB_PASSWORD from .env"
  elif grep -qE 'DB_PASSWORD:\?|POSTGRES_PASSWORD: \$\{DB_PASSWORD' docker-compose.yml; then
    ok "compose requires DB_PASSWORD from environment"
  fi
  if command -v docker >/dev/null 2>&1; then
    ok "docker CLI available"
    if docker info >/dev/null 2>&1; then
      ok "docker daemon reachable"
    else
      warn "docker installed but daemon not reachable"
    fi
  else
    warn "docker CLI not found (needed to run compose)"
  fi
else
  warn "no docker-compose.yml (optional until you containerize)"
fi

echo ""
echo "Quality hooks"
if [ -f .pre-commit-config.yaml ]; then
  ok ".pre-commit-config.yaml present"
  if grep -q "ruff" .pre-commit-config.yaml; then
    ok "pre-commit runs ruff"
  else
    warn "pre-commit does not appear to run ruff"
  fi
else
  warn "missing .pre-commit-config.yaml"
fi

if [ -f .git/hooks/pre-commit ]; then
  if grep -q "pre-commit" .git/hooks/pre-commit; then
    ok "git pre-commit hook installed"
  else
    warn "pre-commit hook not installed — run: uv run pre-commit install"
  fi
else
  warn "pre-commit hook not installed — run: uv run pre-commit install"
fi

echo ""
echo "=========================================="
echo "  Result: $PASS passed, $WARN warnings, $FAIL failures"
echo "=========================================="

if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
