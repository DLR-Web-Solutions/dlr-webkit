# DLR WebKit

Personal **AI-native development kit** for solo senior development. Overlay docs, AI instructions, quality tooling, and conventions onto a new or existing project—then let coding agents work inside a known framework.

This repository is a **kit**, not a finished product app. Application code belongs under `src/<surface>/` after you scaffold or overlay.

## What you get

- AI agent rules (`.cursorrules`, `CLAUDE.md`) and task prompts (`prompts/`)
- Product / architecture / standards docs (`docs/`)
- Bun-first JS/TS tooling (ESLint, Prettier, Husky, lint-staged)
- Docker Compose with dynamic host ports
- `bin/doctor` and `bin/verify` for diagnostics and quality gates
- MCP server configs for Cursor / Claude Code

## Quick start

### Overlay into a parent project

```bash
# From inside a nested clone of this kit:
bash bin/install.sh
```

### Initialize docs for a named app

```bash
bash bin/init.sh
# or ask an agent: /init
```

### Day-to-day (in a JS/TS project using this kit)

```bash
bun install
bun run doctor    # environment / tooling health
bun run verify    # format, lint, typecheck, tests, audit
```

## Layout

```
src/                 # Application surfaces (client, server, …)
docs/                # Product, architecture, standards (AI context)
prompts/             # Reusable agent task prompts
bin/                 # Install, init, doctor, verify
.cursorrules         # Agent SSOT for coding rules
```

Read `docs/00-context/project.md` first when working on a consumer project.

## Principles

1. Security before speed
2. Small files, domain-nested folders, code under `src/`
3. Controllers → Services → Repositories
4. Zod validation; Bun for JS/TS; no invented APIs or schemas
5. A change is not done until `bin/verify` passes
