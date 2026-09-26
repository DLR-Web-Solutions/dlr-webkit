#!/usr/bin/env bash
# Initialize a new project from dlr-webkit

echo "🚀 Initializing dlr-webkit project..."
read -p "Enter Project Name: " APP_NAME

find docs CLAUDE.md .cursorrules -type f -exec sed -i '' "s/\[APP_NAME\]/$APP_NAME/g" {} +

echo "✅ Project $APP_NAME initialized!"
