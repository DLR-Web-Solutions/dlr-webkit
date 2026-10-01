# Repository Scripts & Automation Registry

> **Rule for AI Agents:** Check this registry before executing multi-step terminal workflows. If a task is repeatable and has no script, create a script in `bin/`, document it here, and execute the script instead.

---

## Registered Utility Scripts

| Script Path      | Description                                      | When to Run                                          |
| :--------------- | :----------------------------------------------- | :--------------------------------------------------- |
| `bin/install.sh` | Overlays kit files into the parent directory     | Bootstrap a new project from a nested kit clone      |
| `bin/init.sh`    | Replaces `[APP_NAME]` placeholders in docs/rules | First-time naming                                    |
| `bin/doctor.sh`  | Diagnoses runtime, env, docker, hooks, kit files | Setup issues; before debugging “works on my machine” |
| `bin/verify.sh`  | Format, lint, typecheck, tests, audit (+ doctor) | Before claiming a feature/fix complete; CI           |

Package shortcuts (when `package.json` is present):

```bash
bun run doctor
bun run verify
```

---

## Required Repo Tooling (JS/TS)

When scaffolding or bootstrapping a JS/TS app from this kit, ensure:

| Piece                | Purpose                                     |
| :------------------- | :------------------------------------------ |
| `husky`              | Git hooks                                   |
| `lint-staged`        | Run linters/formatters on staged files only |
| `.husky/pre-commit`  | Runs `bunx lint-staged`                     |
| `.lintstagedrc.json` | Maps globs → `eslint` / `prettier` / `pint` |

Install with: `bun add -d husky lint-staged` and `"prepare": "husky"` in `package.json`.

---

## Script Creation Rules

1. **Location:** All custom scripts must be stored in `bin/` or `scripts/`.
2. **Shebang & Fail-Fast:** Always start with `#!/usr/bin/env bash` and `set -euo pipefail` so the script halts immediately on error.
3. **Portability:** Ensure paths use relative resolution based on `SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"`.
4. **Registry Update:** Every newly generated script MUST be added to the table above.
5. **No duplicates:** Improve an existing script before adding a parallel one.
