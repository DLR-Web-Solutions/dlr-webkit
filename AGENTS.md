# Agent Entry (AGENTS.md)

> **SSOT for coding rules:** `.cursorrules`  
> **SSOT for project facts:** `docs/00-context/project.md`  
> **Standards detail:** `docs/04-standards/`

## Before any work

1. Read `docs/00-context/project.md`.
2. Read `.cursorrules` — it is the single source of truth for all coding rules, workflow, and standards.
3. Inspect existing code under `src/`—reuse before inventing.

## Docs gate

`bin/docs-check` runs from `.husky/commit-msg` and CI. Business paths (`src/`, `deploy/`, `bin/`, `scripts/`, `.github/workflows/`) require a `docs/` update; `[no-docs]` in the commit message (with the reason in the body) is the only escape. See `.cursorrules` DOCUMENT step and `docs/README.md`.

## Shortcuts

- `/init` or "initialize project" → `prompts/00-init-project.md` (discovery + docs)
- New feature → `prompts/01-new-feature.md`
- Bug fix → `prompts/02-bug-fix.md`
