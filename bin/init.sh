#!/usr/bin/env bash
# Replace [APP_NAME] placeholders in kit docs/rules for this repository.
#
# Usage:
#   bash bin/init.sh
#   bash bin/init.sh "My App"
#   DLR_APP_NAME="My App" bash bin/init.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

sed_escape_repl() {
  printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'
}

echo "🚀 Initializing dlr-webkit project context..."

if [ -n "${1:-}" ]; then
  APP_NAME="$1"
elif [ -n "${DLR_APP_NAME:-}" ]; then
  APP_NAME="$DLR_APP_NAME"
elif [ -t 0 ]; then
  read -r -p "Enter Project Name: " APP_NAME
else
  echo "✖ Project name required (pass as arg, DLR_APP_NAME, or interactive stdin)."
  exit 1
fi

if [ -z "${APP_NAME}" ]; then
  echo "✖ Project name is required."
  exit 1
fi

SAFE_NAME="$(sed_escape_repl "$APP_NAME")"

replace_in() {
  local target="$1"
  if [ ! -e "$target" ]; then
    return 0
  fi
  local file
  while IFS= read -r -d '' file; do
    if grep -q '\[APP_NAME\]' "$file" 2>/dev/null; then
      if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|\[APP_NAME\]|${SAFE_NAME}|g" "$file"
      else
        sed -i "s|\[APP_NAME\]|${SAFE_NAME}|g" "$file"
      fi
    fi
  done < <(find "$target" -type f -print0 2>/dev/null)
}

replace_in docs
[ -f CLAUDE.md ] && replace_in CLAUDE.md
[ -f .cursorrules ] && replace_in .cursorrules
[ -f README.md ] && replace_in README.md

echo "✅ Placeholders updated for project name."
echo "Next: fill docs/00-context/project.md (or run /init with an AI agent)."
