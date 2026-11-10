# Claude Code / Agent Entry

> **SSOT for coding rules:** `.cursorrules`  
> **SSOT for project facts:** `docs/00-context/project.md`  
> **Standards detail:** `docs/04-standards/`

## Before any work

1. Read `docs/00-context/project.md`.
2. Read `.cursorrules`.
3. Inspect existing code under `src/`—reuse before inventing.

## UI / kitchen sink

Follow `docs/04-standards/ui-architecture.md`.

Before product UI (init **or** UI work when none exists), create the kitchen sink and keep it as the render of the real primitives (`src/client/components/ui/`), not a hand-rolled catalog.

- Applying a design: change tokens, then primitives, confirm the sink imports and renders them (variants, states, ~390px preview), then migrate pages. A sink-only restyle is incomplete.
- On every UI change: did you change a primitive instead of restyling in the page?
- Skill (Claude Code): `.claude/skills/ui-kitchen-sink/SKILL.md` — also `/ui-kitchen-sink`
- Same content for Cursor: `.cursor/skills/ui-kitchen-sink/SKILL.md` (keep both in sync)
- Accessibility: `docs/04-standards/ui-accessibility.md`
- Instructions only—do not auto-launch UI/UX designer agents

## Git author

Commits in this repo must use **Joshua \<dev.joshuadolor@gmail.com\>**. See `docs/04-standards/git-conventions.md`. Do not change global git config.

## Workflow

`UNDERSTAND → INSPECT → PLAN → TEST (red) → IMPLEMENT (green) → REFACTOR → VERIFY → REVIEW → DOCUMENT`

- **TDD is mandatory:** write a failing test first, then the minimal implementation, then refactor. No production behavior without a failing test. Bug fixes start with a failing regression test. Only throwaway spikes, pure docs/config, or genuinely untestable glue are exempt—state why.
- Completion requires `bin/verify` (or `bun run verify`) passing.
- Do not claim success without verification.

## Shortcuts

- `/init` or “initialize project” → `prompts/00-init-project.md` (discovery + docs)
- `bash bin/init.sh "Name"` → placeholder rename only
- New feature → `prompts/01-new-feature.md`
- Bug fix → `prompts/02-bug-fix.md`
- UI architecture → `docs/04-standards/ui-architecture.md`
- UI kitchen sink → `.claude/skills/ui-kitchen-sink/SKILL.md` (`/ui-kitchen-sink`)

## Diagnostics

```bash
bun run doctor   # bash bin/doctor.sh
bun run verify   # bash bin/verify.sh
```
