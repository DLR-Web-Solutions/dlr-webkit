I want to build [FEATURE_NAME].

Follow the agent workflow: UNDERSTAND → INSPECT → PLAN → IMPLEMENT → TEST → VERIFY → REVIEW → DOCUMENT.

1. Read `docs/00-context/project.md`, `docs/03-features/[FEATURE_NAME].md` (create if missing), and `docs/05-database/schema.md`.
2. Inspect existing code under `src/` for reusable controllers/services/repositories/components.
3. Follow `docs/04-standards/` and `.cursorrules`.
4. **UI features:** If no kitchen sink exists, create it first (`.cursor/skills/ui-kitchen-sink/SKILL.md` or `.claude/skills/ui-kitchen-sink/SKILL.md`). If it exists, extend it when adding shared primitives/variants/states; compose the feature from those pieces.
5. Output a brief implementation plan (files to touch + tests) before coding.
6. Implement with small, focused diffs—no unrelated refactors.
7. Add/update tests for meaningful behavior.
8. Run `bin/verify` (or `bun run verify`) before claiming done.
9. Update feature docs / project context only if architecture or contracts changed.
