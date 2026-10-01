# Claude Code / Agent Entry

> **SSOT for coding rules:** `.cursorrules`  
> **SSOT for project facts:** `docs/00-context/project.md`  
> **Standards detail:** `docs/04-standards/`

## Before any work

1. Read `docs/00-context/project.md`.
2. Read `.cursorrules`.
3. Inspect existing code under `src/`—reuse before inventing.

## Workflow

`UNDERSTAND → INSPECT → PLAN → IMPLEMENT → TEST → VERIFY → REVIEW → DOCUMENT`

- Meaningful changes need tests.
- Completion requires `bin/verify` (or `bun run verify`) passing.
- Do not claim success without verification.

## Shortcuts

- `/init` or “initialize project” → follow `prompts/00-init-project.md`
- New feature → `prompts/01-new-feature.md`
- Bug fix → `prompts/02-bug-fix.md`

## Diagnostics

```bash
bun run doctor
bun run verify
```
