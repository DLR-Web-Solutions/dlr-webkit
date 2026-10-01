#!/usr/bin/env bash
# Overlay dlr-webkit into the parent directory (typical: kit nested inside a new project).
# Existing target files are preserved unless DLR_FORCE_OVERWRITE=1.
#
# Non-interactive:
#   DLR_APP_NAME=MyApp DLR_REMOVE_DEVKIT=0 bash bin/install.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ "$(basename "$SCRIPT_DIR")" = "bin" ]; then
  DEVKIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  DEVKIT_DIR="$SCRIPT_DIR"
fi

PARENT_DIR="$(cd "$DEVKIT_DIR/.." && pwd)"
PARENT_FOLDER_NAME="$(basename "$PARENT_DIR")"
FORCE_OVERWRITE="${DLR_FORCE_OVERWRITE:-0}"

if [ "$PARENT_DIR" = "/" ] || [ "$PARENT_DIR" = "$HOME" ]; then
  echo "✖ Refusing to overlay into unsafe path: $PARENT_DIR"
  exit 1
fi

if [ "$PARENT_DIR" = "$DEVKIT_DIR" ]; then
  echo "✖ Devkit and target are the same directory."
  exit 1
fi

# Escape a string for use as the replacement side of sed s/// (use | delimiter).
sed_escape_repl() {
  printf '%s' "$1" | sed -e 's/[\\|&]/\\&/g'
}

copy_file() {
  local src="$1"
  local dest="$2"
  if [ ! -f "$src" ]; then
    return 0
  fi
  if [ -e "$dest" ] && [ "$FORCE_OVERWRITE" != "1" ]; then
    echo "  · skip existing $(basename "$dest")"
    return 0
  fi
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  echo "  · $(basename "$src")"
}

copy_dir_merge() {
  local src="$1"
  local dest="$2"
  if [ ! -d "$src" ]; then
    return 0
  fi
  mkdir -p "$dest"
  local f rel target
  while IFS= read -r -d '' f; do
    rel="${f#"$src"/}"
    target="$dest/$rel"
    if [ -e "$target" ] && [ "$FORCE_OVERWRITE" != "1" ]; then
      continue
    fi
    mkdir -p "$(dirname "$target")"
    cp "$f" "$target"
  done < <(find "$src" -type f -print0)
  echo "  · $(basename "$src")/ (merged, existing files preserved)"
}

echo "=========================================="
echo "   dlr-webkit Parent Directory Installer  "
echo "=========================================="
echo "DevKit Location : $DEVKIT_DIR"
echo "Target Location : $PARENT_DIR"
echo "Overwrite mode  : $([ "$FORCE_OVERWRITE" = "1" ] && echo FORCE || echo preserve-existing)"
echo "------------------------------------------"

if [ -n "${DLR_APP_NAME:-}" ]; then
  APP_NAME="$DLR_APP_NAME"
elif [ -t 0 ]; then
  read -r -p "Enter Project Name [$PARENT_FOLDER_NAME]: " APP_NAME
  APP_NAME="${APP_NAME:-$PARENT_FOLDER_NAME}"
else
  APP_NAME="$PARENT_FOLDER_NAME"
  echo "Non-interactive: using project name '$APP_NAME'"
fi

if [ -z "$APP_NAME" ]; then
  echo "✖ Project name is required."
  exit 1
fi

echo "🚀 Copying AI DevKit files to parent directory..."

copy_dir_merge "$DEVKIT_DIR/docs" "$PARENT_DIR/docs"
copy_dir_merge "$DEVKIT_DIR/prompts" "$PARENT_DIR/prompts"
copy_dir_merge "$DEVKIT_DIR/bin" "$PARENT_DIR/bin"
# husky: only merge tracked hook scripts, not generated _
if [ -d "$DEVKIT_DIR/.husky" ]; then
  mkdir -p "$PARENT_DIR/.husky"
  if [ -f "$DEVKIT_DIR/.husky/pre-commit" ]; then
    copy_file "$DEVKIT_DIR/.husky/pre-commit" "$PARENT_DIR/.husky/pre-commit"
  fi
fi
copy_dir_merge "$DEVKIT_DIR/.github" "$PARENT_DIR/.github"
copy_dir_merge "$DEVKIT_DIR/.vscode" "$PARENT_DIR/.vscode"
copy_dir_merge "$DEVKIT_DIR/.cursor" "$PARENT_DIR/.cursor"

mkdir -p "$PARENT_DIR/src"
if [ -d "$DEVKIT_DIR/src" ]; then
  while IFS= read -r -d '' f; do
    rel="${f#"$DEVKIT_DIR"/}"
    if [ ! -e "$PARENT_DIR/$rel" ]; then
      mkdir -p "$(dirname "$PARENT_DIR/$rel")"
      cp "$f" "$PARENT_DIR/$rel"
    fi
  done < <(find "$DEVKIT_DIR/src" -type f -print0)
  echo "  · src/ (scaffold only where missing)"
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
# Never copy .env

if [ -f "$DEVKIT_DIR/.gitignore" ]; then
  if [ ! -f "$PARENT_DIR/.gitignore" ]; then
    cp "$DEVKIT_DIR/.gitignore" "$PARENT_DIR/.gitignore"
    echo "  · .gitignore"
  else
    echo "  · skip existing .gitignore"
  fi
fi

if [ ! -s "$PARENT_DIR/README.md" ] && [ -f "$DEVKIT_DIR/README.md" ]; then
  cp "$DEVKIT_DIR/README.md" "$PARENT_DIR/README.md"
  echo "  · README.md"
fi

SAFE_NAME="$(sed_escape_repl "$APP_NAME")"
echo "🏷️ Personalizing [APP_NAME] → (redacted in logs) ..."
cd "$PARENT_DIR"

replace_placeholder() {
  local path="$1"
  if [ ! -e "$path" ]; then
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
  done < <(find "$path" -type f -print0 2>/dev/null)
}

replace_placeholder docs
[ -f CLAUDE.md ] && replace_placeholder CLAUDE.md
[ -f .cursorrules ] && replace_placeholder .cursorrules
[ -f README.md ] && replace_placeholder README.md

chmod +x bin/*.sh 2>/dev/null || true

echo "✨ DevKit files placed in '$PARENT_FOLDER_NAME'."
echo "Next: copy .env.example → .env, run bun install, then bun run doctor."

DEVKIT_FOLDER_NAME="$(basename "$DEVKIT_DIR")"
echo "------------------------------------------"

REMOVE_DEVKIT="${DLR_REMOVE_DEVKIT:-}"
if [ -z "$REMOVE_DEVKIT" ]; then
  if [ -t 0 ]; then
    read -r -p "Remove the nested '$DEVKIT_FOLDER_NAME' folder now? (y/N): " REMOVE_DEVKIT
    REMOVE_DEVKIT="${REMOVE_DEVKIT:-N}"
  else
    REMOVE_DEVKIT="N"
  fi
fi

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
