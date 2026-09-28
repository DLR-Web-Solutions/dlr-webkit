#!/usr/bin/env bash

set -e

# 1. Determine absolute paths regardless of where script is called from
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# If script lives in bin/, devkit root is one level up; otherwise it's SCRIPT_DIR
if [ "$(basename "$SCRIPT_DIR")" = "bin" ]; then
  DEVKIT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
else
  DEVKIT_DIR="$SCRIPT_DIR"
fi

PARENT_DIR="$(cd "$DEVKIT_DIR/.." && pwd)"
PARENT_FOLDER_NAME="$(basename "$PARENT_DIR")"

echo "=========================================="
echo "   dlr-webkit Parent Directory Installer  "
echo "=========================================="
echo "DevKit Location : $DEVKIT_DIR"
echo "Target Location : $PARENT_DIR"
echo "------------------------------------------"

# 2. Ask for App Name (Defaults to parent directory name)
read -p "Enter Project Name [$PARENT_FOLDER_NAME]: " APP_NAME
APP_NAME="${APP_NAME:-$PARENT_FOLDER_NAME}"

echo "🚀 Copying AI DevKit files to parent directory..."

# 3. Copy files and folders to parent directory
[ -d "$DEVKIT_DIR/docs" ] && cp -R "$DEVKIT_DIR/docs" "$PARENT_DIR/"
[ -d "$DEVKIT_DIR/prompts" ] && cp -R "$DEVKIT_DIR/prompts" "$PARENT_DIR/"
[ -f "$DEVKIT_DIR/CLAUDE.md" ] && cp "$DEVKIT_DIR/CLAUDE.md" "$PARENT_DIR/"
[ -f "$DEVKIT_DIR/.cursorrules" ] && cp "$DEVKIT_DIR/.cursorrules" "$PARENT_DIR/"

# Tooling / quality defaults
[ -f "$DEVKIT_DIR/eslint.config.js" ] && cp "$DEVKIT_DIR/eslint.config.js" "$PARENT_DIR/"
[ -f "$DEVKIT_DIR/.prettierrc" ] && cp "$DEVKIT_DIR/.prettierrc" "$PARENT_DIR/"
[ -f "$DEVKIT_DIR/.lintstagedrc.json" ] && cp "$DEVKIT_DIR/.lintstagedrc.json" "$PARENT_DIR/"
if [ -d "$DEVKIT_DIR/.husky" ]; then
  mkdir -p "$PARENT_DIR/.husky"
  cp -R "$DEVKIT_DIR/.husky/"* "$PARENT_DIR/.husky/" 2>/dev/null || true
fi

if [ -d "$DEVKIT_DIR/.github" ]; then
  mkdir -p "$PARENT_DIR/.github"
  cp -R "$DEVKIT_DIR/.github/"* "$PARENT_DIR/.github/" 2>/dev/null || true
fi

# 4. Personalize placeholders in parent directory
echo "🏷️ Personalizing documents for '$APP_NAME'..."
cd "$PARENT_DIR"

if [[ "$OSTYPE" == "darwin"* ]]; then
  find docs CLAUDE.md .cursorrules -type f -exec sed -i '' "s/\[APP_NAME\]/$APP_NAME/g" {} + 2>/dev/null || true
else
  find docs CLAUDE.md .cursorrules -type f -exec sed -i "s/\[APP_NAME\]/$APP_NAME/g" {} + 2>/dev/null || true
fi

echo "✨ DevKit files successfully placed in '$PARENT_FOLDER_NAME'!"

# 5. Optional self-destruct / cleanup of the nested devkit folder
DEVKIT_FOLDER_NAME="$(basename "$DEVKIT_DIR")"
echo "------------------------------------------"
read -p "Remove the nested '$DEVKIT_FOLDER_NAME' folder now? (Y/n): " REMOVE_DEVKIT
REMOVE_DEVKIT="${REMOVE_DEVKIT:-Y}"

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