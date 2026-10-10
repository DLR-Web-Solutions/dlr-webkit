# Tech Stack Summary

Decided during `/init` on branch `web-based-games`. Kit defaults apply unless noted. This is a **game-agnostic base**; per-game choices are recorded in that game's project, not here.

## Surfaces

| Surface     | Path              | Runtime / framework                               | Purpose                                                             |
| :---------- | :---------------- | :------------------------------------------------ | :------------------------------------------------------------------ |
| Web client  | `src/client`      | React + Vite, TypeScript, Tailwind + shadcn/Radix | Portal pages, admin UI, `/play/:game` game shell, `/kitchen-sink`   |
| HTTP API    | `src/server`      | Hono on Bun                                       | Auth, accounts, characters (read), catalog, tickets, admin          |
| Game server | `src/game-server` | Bun `Bun.serve` WebSocket, TypeScript             | `core/` game-agnostic realtime foundation; `<game>/` added per game |
| Shared      | `src/shared`      | TypeScript + Zod only                             | Core protocol schemas, DTOs, enums, constants                       |
| Database    | `prisma/`         | Prisma schema + migrations                        | Single schema, single PostgreSQL database                           |

## Choices

- Runtime: **Bun** (required). Lockfile = source of truth.
- Language: TypeScript, ES modules only.
- Database: **PostgreSQL** (single shared DB; write-ownership rules in `docs/01-product/business-rules.md`).
- ORM: **Prisma**. One `schema.prisma`; both server surfaces import the generated client.
- Validation: **Zod** everywhere—env, HTTP input, and every inbound WebSocket message.
- Frontend HTTP: Axios shared instance (`src/client/src/lib/api.ts`), adapters/mappers before UI.
- Forms: react-hook-form + Zod, `noValidate`.
- Styling: Tailwind + shadcn/Radix; mobile-first for portal; kitchen sink is the look SSOT.
- Testing: Bun test (unit, protocol), Playwright (critical flows).
- Tooling: Husky + lint-staged, `bun run doctor`, `bun run verify`.
- Containers: Docker Compose **used** (PostgreSQL + app; game servers as extra services when they exist).
- AI: not used.

## Realtime game protocol (core)

Browsers cannot open TCP sockets, so there is no "existing emulator behind a proxy" path. Game servers speak **WebSocket natively**.

- Transport: one WebSocket per game session, `wss://` in production.
- Framing: JSON messages `{ "t": "<type>", "d": { … } }` validated with Zod. Core messages live in `src/shared/protocol/core/`; game messages in `src/shared/protocol/<game>/`. Binary framing only after a measured need.
- Core handshake: `hello { protocolVersion, ticket }` → server redeems the ticket (single-use, TTL 60 s) → `welcome { accountId, role, characters[] }` or `error` + close.
- Core messages owned by the base: `hello`, `welcome`, `ping`/`pong`, `error`, `char.create|select|delete` (shared character row; game validates its own detail payload). Everything else is game-defined.
- Heartbeat: server pings every 15 s; drop after 2 missed pongs.
- Server-authoritative: clients send intents; the server validates, applies, broadcasts. Never trust client-reported state.
- Rate limits per message type enforced server-side; unknown/invalid messages → `error { code: "bad_message" }`, 3 strikes → close.

## Game-server core contract

A game module registers with `core` and gets lifecycle hooks; `core` never imports from a game folder.

```ts
// src/game-server/core/game-module.ts (shape; implement when scaffolding)
interface GameModule {
    slug: string; // matches games.slug
    protocol: { version: number; messages: ZodDiscriminatedUnion };
    onSessionReady(session: Session): Promise<void>; // after welcome
    onMessage(session: Session, msg: GameMessage): Promise<void>;
    onTick(dtMs: number): void; // optional time-based systems
    onSessionEnd(session: Session, reason: EndReason): Promise<void>; // persist here
}
```

- One OS process per game (per realm when scale requires). No cross-process state sync in the base.
- Persistence: autosave interval + on disconnect, via repositories; game logic never imports Prisma directly.

## Client game-shell contract

`/play/:game` loads `src/client/src/games/<game>/index.ts` exporting a module with `mount(container, socket, store)` / `unmount()`. The shell owns ticket fetch, socket, reconnect UI, and character select; the game owns rendering and input.

- Rendering engine is per game (2D: PixiJS default candidate; 3D: Three.js/WebGL). Pin versions in the game project.
- Assets load from a configurable base URL (`VITE_ASSET_BASE_URL`); never bundled into the repo.

## Adding a game (checklist)

1. Insert a `games` row (slug) and at least one `game_realms` row.
2. `src/shared/protocol/<game>/` — Zod message schemas + protocol version.
3. `src/game-server/<game>/` — implement `GameModule`; services for rules, repositories for `<game>_*` tables.
4. Prisma: `<game>_characters` (PK = `characters.id`) + related tables; decide static-data strategy (seeded tables vs versioned JSON).
5. `src/client/src/games/<game>/` — renderer, input, state store; register in the game shell.
6. Tests: pure unit tests for rules; in-process protocol tests; one Playwright path to `welcome`.
7. Docs: `docs/03-features/<game>.md` with scope, protocol tables, and rules. Update `docs/00-context/project.md` "Games".

## Open decisions (record answers here when made)

1. Notification channel for ban/realm-status changes to running game servers (PostgreSQL `LISTEN/NOTIFY` vs polling).
2. Whether game tickets are hashed at rest (optional given 60 s TTL).
3. Static game data strategy default for games (seeded tables vs versioned JSON loaded at start).
