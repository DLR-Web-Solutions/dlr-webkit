# Product Overview

- **App Name:** DLR Games (working title)
- **What it is:** A **starting point** for browser-based private game servers. It is not a game itself; it is the foundation every game project (Dofus, GunZ, Rakion, …) is created from.
- **Target Audience:** Primarily the developer (me) starting new web-based game projects; ultimately players of those games, who sign up once and play in the browser with no downloads, plus a small admin/moderator team.
- **Core Goal:** Make "new game, same foundation" cheap: accounts, auth, game tickets, realm catalog, moderation, a realtime WebSocket game-server core, and a React game shell are solved once here. A game project only adds its rules, protocol, renderer, and data.

## What the base provides

1. **Accounts & auth** — register, login, sessions, password reset, roles.
2. **Game catalog & realms** — list games/realms with status; issue game tickets for a realm.
3. **Game-server core** — WebSocket lifecycle, ticket redemption, session registry, heartbeat, rate limiting, tick loop, persistence hooks. No game rules.
4. **Game shell (client)** — `/play/:game` page: fetch ticket, connect, mount the game module, connection/loading/disconnect UI. No renderer.
5. **Characters (shared row)** — game-agnostic character identity; per-game detail tables are added by each game.
6. **Admin & moderation** — account lookup, bans (web + in-game enforced), realm open/close, audit log.
7. **Tooling** — kitchen sink, Compose with PostgreSQL, Prisma schema, Bun test + Playwright setup, CI.

## What a game project adds

- `src/game-server/<game>/` — game logic, message handlers, repositories for `<game>_*` tables.
- `src/shared/protocol/<game>/` — Zod schemas for the game's messages.
- `src/client/src/games/<game>/` — renderer, asset loading, input → intents, state store.
- Prisma models for `<game>_characters` and related tables; static game data strategy.
- Its own feature docs under `docs/03-features/`.

## Out of scope for the base

- Any specific game's rules, protocol, assets, or renderer.
- Payments, donations, cash shop (the `pending_deliveries` queue is the hook for them later).
- Native/desktop clients and TCP compatibility with existing emulators.
- Multi-tenancy / hosting for other operators.
