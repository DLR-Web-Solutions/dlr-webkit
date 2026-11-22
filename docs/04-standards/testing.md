# Testing Standards

> Prefer the stack already present in the consumer project. For new JS/TS apps from this kit: **Bun test** or **Vitest** for unit/integration; **Playwright** for critical E2E. Do not install a second unit runner without reason.

## Test-driven development (mandatory)

All behavior changes follow **TDD: RED → GREEN → REFACTOR**.

1. **RED** — Write/update the smallest test for the next behavior. Run it and confirm it fails for the expected reason (not a typo or missing import).
2. **GREEN** — Write the minimal implementation that makes the test pass. Do not add unrequested behavior.
3. **REFACTOR** — Improve names/structure with the suite still green. Re-run narrow tests, then `bin/verify`.

- **Bug fixes:** the first commit-sized change is a failing regression test; then fix production code.
- **Refactors:** keep existing tests green; add characterization tests first where coverage is missing.
- **Exceptions:** throwaway spikes, pure docs/config, or genuinely untestable glue. State the exception explicitly; convert any kept spike into tested code before merging.
- Never write production behavior first and “add tests after.” If a test is hard to write, improve the seam instead of skipping TDD.

## Strategy

| Layer       | What to test                                                     | Tooling                                      |
| :---------- | :--------------------------------------------------------------- | :------------------------------------------- |
| Unit        | Pure functions, mappers/adapters, Zod schemas, domain helpers    | `bun test` or Vitest                         |
| Integration | Services + repositories against DB (or testcontainers / compose) | same runner + test DB                        |
| API         | HTTP handlers: authz, validation errors, happy paths             | supertest/fetch against app server or Vitest |
| E2E         | Critical user journeys only                                      | Playwright                                   |

## Rules for agents

1. Meaningful behavior changes require tests (bug fixes → regression test when non-trivial).
2. **Break down large features into phases** with clear deliverables per phase.
3. **ALWAYS update docs** for any changes (feature docs, project context, API conventions, etc.).
4. **Board workflow:** If a project board exists, create a ticket first, assign yourself (or the appropriate person), then move to "In Progress" before starting.
5. **QA verification:** Always ask a QA agent to verify the work before marking complete.
6. Do not claim completion until `bin/verify` passes.
7. Prefer fast unit tests near the changed module; reserve E2E for flows that break silently otherwise.
8. Never weaken auth, validation, or CSRF protections to make a test pass.
9. Tests must not require production secrets; use `.env.test` or inline test config.

## Layout

```
tests/                    # cross-cutting / kit tests
src/server/**/*.test.ts   # colocated unit tests (allowed)
src/client/**/*.test.tsx
```

Colocate when it keeps the tree scannable; use `tests/` for kit-wide or multi-surface suites.

## AI / LLM features

When the product calls models: assert **schema compliance** on structured outputs (Zod), and add a tiny fixture-based eval for instruction-following on critical prompts—not a large eval platform.
