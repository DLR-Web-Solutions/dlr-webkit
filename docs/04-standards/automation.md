# Repository Scripts & Automation Registry

> **Rule for AI Agents:** Check this registry before executing multi-step terminal workflows. If a task is repeatable and has no script, create a script in `bin/`, document it here, and execute the script instead.

---

## Registered Utility Scripts

| Script Path        | Description                                                    | When to Run               |
| :----------------- | :------------------------------------------------------------- | :------------------------ |
| `bin/install.sh`   | Overlays `dlr-webkit` into parent directory and self-destructs | Initial project bootstrap |
| `bin/init.sh`      | Interactive CLI context gatherer for project docs              | First-time setup          |

---

## Required Repo Tooling (JS/TS)

When scaffolding or bootstrapping a JS/TS app from this kit, ensure:

| Piece | Purpose |
| :---- | :------ |
| `husky` | Git hooks |
| `lint-staged` | Run linters/formatters on staged files only |
| `.husky/pre-commit` | Runs `bunx lint-staged` |
| `.lintstagedrc.json` | Maps globs → `eslint` / `prettier` / `pint` (preferred over `package.json`) |

Install with: `bun add -d husky lint-staged` and `"prepare": "husky"` in `package.json`.

---

## Script Creation Rules

1. **Location:** All custom scripts must be stored in `bin/` or `scripts/`.
2. **Shebang & Fail-Fast:** Always start with `#!/usr/bin/env bash` and `set -e` so the script halts immediately on error.
3. **Portability:** Ensure paths use relative resolution based on `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`.
4. **Registry Update:** Every newly generated script MUST be added to the table above.
