I want to build [FEATURE_NAME].

Follow the agent workflow: UNDERSTAND → INSPECT → PLAN → TEST (red) → IMPLEMENT (green) → REFACTOR → VERIFY → REVIEW → DOCUMENT.

1. Read `docs/00-context/project.md`, `docs/03-features/[FEATURE_NAME].md` (create if missing), and `docs/05-database/schema.md`.
2. Inspect existing code under `src/` for reusable controllers/services/repositories/components.
3. Follow `docs/04-standards/` and `.cursorrules`.
4. **UI features:** Follow `docs/04-standards/ui-architecture.md`. If no kitchen sink exists, create it first (`.cursor/skills/ui-kitchen-sink/SKILL.md` or `.claude/skills/ui-kitchen-sink/SKILL.md`) so it imports real primitives. If it exists, extend the primitive and its sink section together. Apply a new design to tokens and primitives first; a sink-only restyle is incomplete. On the PR: did you change a primitive instead of restyling in the page?
5. **Break down large features into phases** with clear deliverables per phase.
6. Output a brief implementation plan (files to touch + tests) before coding.
7. **TDD (mandatory):** write the failing test first, run it, and confirm RED.
8. Implement the minimal code to pass (GREEN), then refactor with tests green.
9. Use small, focused diffs—no unrelated refactors.
10. Run `bin/verify` (or `bun run verify`) before claiming done.
11. **ALWAYS update docs** for any changes (feature docs, project context, API conventions, etc.).
12. **Board workflow:** If a project board exists, create a ticket first, assign yourself (or the appropriate person), then move to "In Progress" before starting.
13. **QA verification:** Always ask a QA agent to verify the work before marking complete.
