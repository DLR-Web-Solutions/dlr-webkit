# Testing Standards

> Prefer the stack already present in the consumer project. For new JS/TS apps from this kit: **Bun test** or **Vitest** for unit/integration; **Playwright** for critical E2E. Do not install a second unit runner without reason.

## Strategy

| Layer       | What to test                                                     | Tooling                                      |
| :---------- | :--------------------------------------------------------------- | :------------------------------------------- |
| Unit        | Pure functions, mappers/adapters, Zod schemas, domain helpers    | `bun test` or Vitest                         |
| Integration | Services + repositories against DB (or testcontainers / compose) | same runner + test DB                        |
| API         | HTTP handlers: authz, validation errors, happy paths             | supertest/fetch against app server or Vitest |
| E2E         | Critical user journeys only                                      | Playwright                                   |

## Rules for agents

1. Meaningful behavior changes require tests (bug fixes → regression test when non-trivial).
2. Do not claim completion until `bin/verify` passes.
3. Prefer fast unit tests near the changed module; reserve E2E for flows that break silently otherwise.
4. Never weaken auth, validation, or CSRF protections to make a test pass.
5. Tests must not require production secrets; use `.env.test` or inline test config.

## Layout

```
tests/                    # cross-cutting / kit tests
src/server/**/*.test.ts   # colocated unit tests (allowed)
src/client/**/*.test.tsx
```

Colocate when it keeps the tree scannable; use `tests/` for kit-wide or multi-surface suites.

## AI / LLM features

When the product calls models: assert **schema compliance** on structured outputs (Zod), and add a tiny fixture-based eval for instruction-following on critical prompts—not a large eval platform.
