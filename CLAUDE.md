# Claude Code / Agent Entry

> **SSOT for coding rules:** `.cursorrules`  
> **SSOT for project facts:** `docs/00-context/project.md`  
> **Standards detail:** `docs/04-standards/`

## Before any work

1. Read `docs/00-context/project.md`.
2. Read `.cursorrules` — it is the single source of truth for all coding rules, workflow, and standards.
3. Inspect existing code under `src/`—reuse before inventing.

## Docs gate

`bin/docs-check` runs from `.husky/commit-msg` and CI. Business paths (`src/`, `deploy/`, `bin/`, `scripts/`, `.github/workflows/`) require a `docs/` update; `[no-docs]` in the commit message (with the reason in the body) is the only escape. See `.cursorrules` DOCUMENT step and `docs/README.md`.

## UI / kitchen sink

Follow `.cursorrules` and `docs/04-standards/ui-architecture.md`.  
Skill: `.claude/skills/ui-kitchen-sink/SKILL.md` (also `/ui-kitchen-sink`)

## Git author

Commits in this repo must use **Joshua \<dev.joshuadolor@gmail.com\>**. See `docs/04-standards/git-conventions.md`. Do not change global git config.

## Shortcuts

- `/init` or "initialize project" → `prompts/00-init-project.md` (discovery + docs)
- `bash bin/init.sh "Name"` → placeholder rename only
- New feature → `prompts/01-new-feature.md`
- Bug fix → `prompts/02-bug-fix.md`

## Diagnostics

```bash
bun run doctor   # bash bin/doctor.sh
bun run verify   # bash bin/verify.sh
```
