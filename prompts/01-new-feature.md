I want to build [FEATURE_NAME].

Follow the agent workflow: UNDERSTAND → INSPECT → PLAN → TEST (red) → IMPLEMENT (green) → REFACTOR → VERIFY → REVIEW → DOCUMENT.

1. Read `docs/00-context/project.md`, `docs/03-features/[FEATURE_NAME].md` (create if missing), and `docs/05-database/schema.md`.
2. Inspect existing code under `src/` for reusable controllers/services/repositories/components.
3. Follow `docs/04-standards/` and `.cursorrules`.
4. **UI features:** Follow `docs/04-standards/ui-architecture.md`. If no kitchen sink exists, create it first (`.cursor/skills/ui-kitchen-sink/SKILL.md` or `.claude/skills/ui-kitchen-sink/SKILL.md`) so it imports real primitives. If it exists, extend the primitive and its sink section together. Apply a new design to tokens and primitives first; a sink-only restyle is incomplete. On the PR: did you change a primitive instead of restyling in the page?
5. Output a brief implementation plan (files to touch + tests) before coding.
6. **TDD (mandatory):** write the failing test first, run it, and confirm RED.
7. Implement the minimal code to pass (GREEN), then refactor with tests green.
8. Use small, focused diffs—no unrelated refactors.
9. Run `bin/verify` (or `bun run verify`) before claiming done.
10. Update feature docs / project context only if architecture or contracts changed.
