# Project Context (canonical)

> **For AI agents:** Read this file before planning or coding. Prefer it over scanning the whole repo. Keep it short and accurate—update it when the stack or architecture changes.

## What is this project?

- **Name:** DLR Games (working title)
- **One-liner:** A reusable **starting point for browser-based private game servers**: shared accounts, auth, game tickets, a realtime WebSocket game-server core, and a React game shell—so each new game (e.g. Dofus, GunZ, Rakion) starts from the same foundation.
- **Kind:** Base project / foundation (web portal + browser game client shell + realtime game-server core)
- **Status:** Greenfield (branch `web-based-games`)
- **Games:** None built in yet. Game projects created from this base add their own module under `src/game-server/<game>/` and `src/client/src/games/<game>/`. Dofus, GunZ, Rakion are the intended first targets; nothing game-specific belongs in this base.

## Stack

| Layer                     | Choice                                                                                                                   |
| :------------------------ | :----------------------------------------------------------------------------------------------------------------------- |
| Runtime / package manager | Bun                                                                                                                      |
| Backend (HTTP)            | Hono on Bun — portal/admin REST API                                                                                      |
| Game server (realtime)    | Bun native WebSocket server (`Bun.serve` + `websocket`); game-agnostic `core/`, one process per game                     |
| Frontend                  | React + Vite SPA (portal pages **and** the in-browser game shell)                                                        |
| Game rendering            | Per game. Default candidate for 2D: PixiJS; 3D: Three.js/WebGL. Decide per game, not in the base                         |
| Database                  | PostgreSQL — **one shared database** for the HTTP API and the game servers                                               |
| ORM                       | Prisma — single schema at `prisma/schema.prisma`, imported by every server surface                                       |
| Validation                | Zod (env, API input, WebSocket message payloads)                                                                         |
| Auth                      | Session cookies for the web (HttpOnly, SameSite); short-lived single-use **game tickets** for WebSocket game connections |
| Styling                   | Tailwind + shadcn/Radix (mobile-first for portal pages; game canvas requirements are per game)                           |

## Architecture

- App code lives under `src/<surface>/`:
    - `src/client` — React + Vite: portal (auth, account, characters, realm list), admin UI, `/play/:game` game shell that fetches a ticket, opens the socket, and mounts the game module.
    - `src/server` — Hono HTTP API. Layers: **controllers → services → repositories**.
    - `src/game-server` — realtime WebSocket servers. `core/`: connection lifecycle, ticket redemption, session registry, heartbeat, rate limiting, tick loop, persistence hooks. `<game>/`: added per game. Same discipline: message handlers thin, game logic in services, persistence in repositories.
    - `src/shared` — types and Zod schemas shared across surfaces (core protocol messages, DTOs, enums). No runtime side effects.
- `prisma/` (repo root) — schema + migrations (infrastructure/config stays at root per `docs/02-architecture/directory-layout.md`).
- Frontend never binds UI to raw API payloads—use adapters/mappers (`docs/02-architecture/data-mapping.md`).
- Browsers cannot open raw TCP sockets, so **the game protocol is WebSocket-native**; the base does not proxy to existing TCP emulators. See `docs/02-architecture/tech-stack.md` → "Realtime game protocol".

## Major modules

| Module             | Path / notes                                                                               |
| :----------------- | :----------------------------------------------------------------------------------------- |
| Auth & accounts    | `src/server/{controllers,services,repositories}/auth`, `docs/03-features/auth.md`          |
| Game tickets       | `src/server/services/game-tickets` (issue) + `src/game-server/core/auth` (redeem)          |
| Game catalog       | `games` + `game_realms` tables; drives the "choose a game" page and realm status           |
| Characters         | Game-agnostic `characters` row + per-game detail tables added by each game                 |
| Game-server core   | `src/game-server/core/` — everything a game module plugs into; no game rules here          |
| Game shell         | `src/client/src/pages/play/` — ticket → socket → mount `src/client/src/games/<game>/`      |
| Admin / moderation | Bans, account lookup, realm toggles (`src/server/.../admin`); server-side role checks      |
| UI kitchen sink    | `src/client/src/pages/kitchen-sink` → route `/kitchen-sink` (create **before** product UI) |

## Auth & authorization

- **Authentication (web):** Username/email + password, Argon2id hashes (`Bun.password`), server-side sessions in PostgreSQL, HttpOnly cookie.
- **Authentication (game):** Logged-in web session → `POST /api/v1/games/:game/ticket` → opaque single-use ticket (TTL 60 s) → first WebSocket message redeems it. The game server never sees passwords.
- **Authorization:** Roles `guest`, `player`, `moderator`, `admin` — see `docs/01-product/roles-permissions.md`.
- **Rule:** Enforce on the server (HTTP **and** game server); never rely on UI-only guards.

## APIs

- **Style:** REST (JSON) for the portal under `/api/v1`; WebSocket JSON messages for gameplay (binary framing only with a measured need).
- **Versioning:** `/api/v1`; WebSocket `hello` carries a protocol version.
- **Errors:** Consistent JSON error shape; no stack traces to clients in production.
- **Conventions:** `docs/04-standards/api-conventions.md`.

## Data

- Schema notes: `docs/05-database/schema.md`
- Migrations: Prisma migrate (single schema, single database)
- Soft deletes: **yes** for `accounts` and `characters`; hard delete elsewhere
- Write ownership (single shared DB): the HTTP API owns account/portal rows; the **game server owns live gameplay rows** while a character is online. Cross-boundary effects go through the `pending_deliveries` queue table, never direct writes into the other side's hot rows. See `docs/01-product/business-rules.md`.

## Testing

- Unit / integration: Bun test. Game logic must be pure and unit-testable without sockets.
- Protocol tests: spin up the game server in-process, connect with Bun's WebSocket client, assert message sequences.
- E2E: Playwright for register → login → choose game → socket `welcome`.
- Agents must run tests for meaningful changes and `bin/verify` before claiming done

## Deployment

- Docker Compose for local dev: `db` (PostgreSQL) + `app`. Game servers run as separate services (same image, different `CMD`) once they exist.
- Health: `/health` (liveness), `/ready` (DB reachable) on the HTTP API; game servers expose the same on their HTTP port.
- Ports: dynamic via `.env` (`APP_PORT`, `DB_PORT`; add `GAME_PORT_<GAME>` per game server).

## AI (if this product uses LLMs)

- Not in scope. `docs/02-architecture/ai-providers.md` is reference only.

## Agent conventions (non-negotiable)

1. Inspect existing code before inventing anything.
2. Follow `.cursorrules` and `docs/04-standards/`.
3. Do not add dependencies without need; prefer Bun for JS/TS.
4. Do not weaken security to pass a test.
5. Run `bin/verify` before completion.
6. **Keep the base game-agnostic.** Game-specific code lives only under `src/game-server/<game>/`, `src/client/src/games/<game>/`, `src/shared/protocol/<game>/`, and `<game>_*` tables. Never leak a game's assumptions into `core/`, shared account code, or the `characters` table.

## Related docs

- Product: `docs/01-product/`
- Architecture: `docs/02-architecture/`
- Features: `docs/03-features/` (`auth.md`)
- Standards: `docs/04-standards/`
- Database: `docs/05-database/`
- Adding a game: `docs/02-architecture/tech-stack.md` → "Adding a game"
