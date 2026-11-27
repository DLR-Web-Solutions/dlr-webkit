# Changelog

All notable kit changes. This kit ships rules, scripts, and docs into consumer projects.

## [0.3.0] - 2026-11-27

### Added

- `bin/docs-check` — commit-time and CI gate that blocks business-code changes without a `docs/` update, with `[no-docs]` as the explicit escape.
- `.husky/commit-msg` — runs `bin/docs-check --staged --message-file "$1"`.
- `docs:check` package script.
- `docs/README.md` — doc map and the "Keeping docs true" contract.
- `AGENTS.md` — thin agent entry for tools that read `AGENTS.md`.
- `tests/scripts/docs-check.test.ts` — six script tests covering the gate decisions.

### Changed

- `.cursorrules`, `CLAUDE.md`, and `docs/04-standards/automation.md` document the gate, business paths, and `[no-docs]` rules.
- `bin/install.sh` copies and chmods `bin/docs-check` and `.husky/commit-msg`; fresh targets also get `package.json` and `bun.lock` so `bun install` can activate husky.
- CI checkout uses `fetch-depth: 0`; the verify job runs `bin/docs-check` on the pushed range.
- Refreshed `eslint`, `@eslint/js`, and `typescript-eslint` to stable releases using `minimatch` 11, clearing the audit advisory.
- Package version bumped to `0.3.0`.
