# Project Context (canonical)

> **For AI agents:** Read this file before planning or coding. Prefer it over scanning the whole repo. Keep it short and accurate—update it when the stack or architecture changes.

## What is this project?

- **Name:** [APP_NAME]
- **One-liner:** [Primary value proposition]
- **Kind:** [Product app | Internal tool | API service | AI application | Other]
- **Status:** [Greenfield / Active / Maintenance]

## Stack

| Layer                     | Choice                                                   |
| :------------------------ | :------------------------------------------------------- |
| Runtime / package manager | Bun (JS/TS) or PHP/Composer (Laravel)                    |
| Backend                   | [e.g. Hono / Express / Next.js route handlers / Laravel] |
| Frontend                  | [e.g. React + Vite / Next.js / Inertia + Vue]            |
| Database                  | [PostgreSQL recommended]                                 |
| ORM                       | Prisma (JS/TS) / Eloquent (Laravel)                      |
| Validation                | Zod (JS/TS) / Form Requests (Laravel)                    |
| Auth                      | [Session cookies / JWT / Sanctum / Auth.js — fill in]    |
| Styling                   | Tailwind + Shadcn/Radix (mobile-first)                   |

## Architecture

- App code lives under `src/<surface>/` (e.g. `src/client`, `src/server`).
- Backend layers: **controllers → services → repositories**.
- When a layer folder grows, nest by domain (e.g. `repositories/billing/`).
- Frontend never binds UI to raw API payloads—use adapters/mappers (`docs/02-architecture/data-mapping.md`).

## Major modules

| Module         | Path / notes |
| :------------- | :----------- |
| [e.g. Auth]    | [path]       |
| [e.g. Billing] | [path]       |

## Auth & authorization

- **Authentication:** [how users prove identity]
- **Authorization:** [roles/permissions model — see `docs/01-product/roles-permissions.md`]
- **Rule:** Enforce on the server; never rely on UI-only guards.

## APIs

- **Style:** [REST / RPC-ish / tRPC — fill in]
- **Versioning:** [e.g. `/api/v1` or none yet]
- **Errors:** Consistent JSON error shape; no stack traces to clients in production.
- **Conventions:** See `docs/04-standards/api-conventions.md` when present.

## Data

- Schema notes: `docs/05-database/schema.md`
- Migrations: [Prisma migrate / Laravel migrations]
- Soft deletes: [yes/no for which models]

## Testing

- Unit / integration: Vitest or Bun test (JS/TS); PHPUnit/Pest (Laravel)
- E2E: Playwright when UI flows matter
- Agents must run tests for meaningful changes and `bin/verify` before claiming done

## Deployment

- Docker Compose with dynamic `${APP_PORT}` / `${DB_PORT}`
- Health: `/health` (liveness), `/ready` (dependencies) when implemented

## AI (if this product uses LLMs)

- Provider abstraction: `docs/02-architecture/ai-providers.md`
- Env: `AI_PROVIDER`, `AI_MODEL`, `AI_BASE_URL`, API keys in `.env` only
- Treat model output as untrusted → structured output → Zod validate → app logic

## Agent conventions (non-negotiable)

1. Inspect existing code before inventing anything.
2. Follow `.cursorrules` and `docs/04-standards/`.
3. Do not add dependencies without need; prefer Bun for JS/TS.
4. Do not weaken security to pass a test.
5. Run `bin/verify` before completion.

## Related docs

- Product: `docs/01-product/`
- Architecture: `docs/02-architecture/`
- Features: `docs/03-features/`
- Standards: `docs/04-standards/`
- Database: `docs/05-database/`
