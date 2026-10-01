#!/usr/bin/env bash
# Overlay dlr-webkit into the parent directory (typical: kit cloned inside a new project).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(basename "$SCRIPT_DIR")" = "bin" ]; then
  DEVKIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  DEVKIT_DIR="$SCRIPT_DIR"
fi

PARENT_DIR="$(cd "$DEVKIT_DIR/.." && pwd)"
PARENT_FOLDER_NAME="$(basename "$PARENT_DIR")"

copy_file() {
  local src="$1"
  local dest="$2"
  if [ -f "$src" ]; then
    mkdir -p "$(dirname "$dest")"
    cp "$src" "$dest"
    echo "  · $(basename "$src")"
  fi
}

copy_dir() {
  local src="$1"
  local dest="$2"
  if [ -d "$src" ]; then
    mkdir -p "$dest"
    cp -R "$src"/. "$dest"/
    echo "  · $(basename "$src")/"
  fi
}

echo "=========================================="
echo "   dlr-webkit Parent Directory Installer  "
echo "=========================================="
echo "DevKit Location : $DEVKIT_DIR"
echo "Target Location : $PARENT_DIR"
echo "------------------------------------------"

read -r -p "Enter Project Name [$PARENT_FOLDER_NAME]: " APP_NAME
APP_NAME="${APP_NAME:-$PARENT_FOLDER_NAME}"

echo "🚀 Copying AI DevKit files to parent directory..."

copy_dir "$DEVKIT_DIR/docs" "$PARENT_DIR/docs"
copy_dir "$DEVKIT_DIR/prompts" "$PARENT_DIR/prompts"
copy_dir "$DEVKIT_DIR/bin" "$PARENT_DIR/bin"
copy_dir "$DEVKIT_DIR/.husky" "$PARENT_DIR/.husky"
copy_dir "$DEVKIT_DIR/.github" "$PARENT_DIR/.github"
copy_dir "$DEVKIT_DIR/.vscode" "$PARENT_DIR/.vscode"
copy_dir "$DEVKIT_DIR/.cursor" "$PARENT_DIR/.cursor"

# Ensure src layout exists without clobbering existing app code
mkdir -p "$PARENT_DIR/src"
if [ -d "$DEVKIT_DIR/src" ]; then
  # copy only missing scaffolding files
  find "$DEVKIT_DIR/src" -type f | while read -r f; do
    rel="${f#"$DEVKIT_DIR/"}"
    if [ ! -e "$PARENT_DIR/$rel" ]; then
      mkdir -p "$(dirname "$PARENT_DIR/$rel")"
      cp "$f" "$PARENT_DIR/$rel"
    fi
  done
fi

copy_file "$DEVKIT_DIR/CLAUDE.md" "$PARENT_DIR/CLAUDE.md"
copy_file "$DEVKIT_DIR/.cursorrules" "$PARENT_DIR/.cursorrules"
copy_file "$DEVKIT_DIR/.mcp.json" "$PARENT_DIR/.mcp.json"
copy_file "$DEVKIT_DIR/eslint.config.js" "$PARENT_DIR/eslint.config.js"
copy_file "$DEVKIT_DIR/.prettierrc" "$PARENT_DIR/.prettierrc"
copy_file "$DEVKIT_DIR/.lintstagedrc.json" "$PARENT_DIR/.lintstagedrc.json"
copy_file "$DEVKIT_DIR/tsconfig.json" "$PARENT_DIR/tsconfig.json"
copy_file "$DEVKIT_DIR/docker-compose.yml" "$PARENT_DIR/docker-compose.yml"
copy_file "$DEVKIT_DIR/Dockerfile" "$PARENT_DIR/Dockerfile"
copy_file "$DEVKIT_DIR/.env.example" "$PARENT_DIR/.env.example"

# Merge-friendly gitignore append for missing patterns
if [ -f "$DEVKIT_DIR/.gitignore" ]; then
  if [ ! -f "$PARENT_DIR/.gitignore" ]; then
    cp "$DEVKIT_DIR/.gitignore" "$PARENT_DIR/.gitignore"
  else
    echo "  · .gitignore (left existing; review kit .gitignore for missing entries)"
  fi
fi

# README: only seed if missing/empty
if [ ! -s "$PARENT_DIR/README.md" ] && [ -f "$DEVKIT_DIR/README.md" ]; then
  cp "$DEVKIT_DIR/README.md" "$PARENT_DIR/README.md"
  echo "  · README.md"
fi

echo "🏷️ Personalizing documents for '$APP_NAME'..."
cd "$PARENT_DIR"

replace_placeholder() {
  local path="$1"
  if [ ! -e "$path" ]; then
    return 0
  fi
  if [[ "$OSTYPE" == "darwin"* ]]; then
    find "$path" -type f -exec sed -i '' "s/\[APP_NAME\]/$APP_NAME/g" {} + 2>/dev/null || true
  else
    find "$path" -type f -exec sed -i "s/\[APP_NAME\]/$APP_NAME/g" {} + 2>/dev/null || true
  fi
}

replace_placeholder docs
replace_placeholder CLAUDE.md
replace_placeholder .cursorrules
replace_placeholder README.md

chmod +x bin/*.sh 2>/dev/null || true

echo "✨ DevKit files placed in '$PARENT_FOLDER_NAME'."
echo "Next: copy .env.example → .env, run bun install, then bun run doctor."

DEVKIT_FOLDER_NAME="$(basename "$DEVKIT_DIR")"
echo "------------------------------------------"
read -r -p "Remove the nested '$DEVKIT_FOLDER_NAME' folder now? (y/N): " REMOVE_DEVKIT
REMOVE_DEVKIT="${REMOVE_DEVKIT:-N}"

if [[ "$REMOVE_DEVKIT" =~ ^[Yy]$ ]]; then
  echo "🧹 Cleaning up $DEVKIT_FOLDER_NAME..."
  rm -rf "$DEVKIT_DIR"
  echo "✅ Cleanup complete!"
else
  echo "ℹ️ Kept $DEVKIT_FOLDER_NAME folder in project."
fi

echo "=========================================="
echo "🎉 Setup finished for $APP_NAME!"
echo "=========================================="
