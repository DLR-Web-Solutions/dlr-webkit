#!/usr/bin/env bash
# Replace [APP_NAME] placeholders in kit docs/rules for this repository.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$ROOT_DIR"

echo "🚀 Initializing dlr-webkit project context..."
read -r -p "Enter Project Name: " APP_NAME

if [ -z "${APP_NAME}" ]; then
  echo "✖ Project name is required."
  exit 1
fi

replace_in() {
  local target="$1"
  if [ ! -e "$target" ]; then
    return 0
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
    find "$target" -type f -exec sed -i '' "s/\[APP_NAME\]/$APP_NAME/g" {} +
  else
    find "$target" -type f -exec sed -i "s/\[APP_NAME\]/$APP_NAME/g" {} +
  fi
}

replace_in docs
replace_in CLAUDE.md
replace_in .cursorrules
replace_in README.md

echo "✅ Placeholders updated for $APP_NAME."
echo "Next: fill docs/00-context/project.md (or run /init with an AI agent)."
