# Database Schema

High-level entities for the single shared PostgreSQL database (Prisma schema at `prisma/schema.prisma`). Columns listed are the contract; add detail in migrations, not here. Soft deletes only where marked. Everything here is **game-agnostic**; games add their own tables.

## Platform (owned by the HTTP API)

| Table             | Key columns                                                                                                                     | Notes                                                            |
| :---------------- | :------------------------------------------------------------------------------------------------------------------------------ | :--------------------------------------------------------------- |
| `accounts`        | id, username (citext unique), email (citext unique), password_hash, role, last_login_ip, created_at, updated_at, **deleted_at** | Argon2id via `Bun.password`; role ∈ guest/player/moderator/admin |
| `sessions`        | id, account_id, expires_at, created_at, user_agent, ip                                                                          | Web sessions; cookie stores opaque id                            |
| `password_resets` | id, account_id, token_hash, expires_at, used_at                                                                                 | Single-use, 60 min                                               |
| `games`           | id, slug, name, enabled                                                                                                         | Catalog; one row per game module                                 |
| `game_realms`     | id, game_id, slug, name, status (online/maintenance/offline), ws_url, max_players                                               |                                                                  |
| `game_tickets`    | id (opaque random), account_id, game_id, realm_id, expires_at, redeemed_at                                                      | Single-use; TTL 60 s; purge job                                  |
| `bans`            | id, account_id, issued_by, reason, starts_at, ends_at (null = permanent), lifted_at                                             | Effective ban = latest active row                                |
| `audit_log`       | id, actor_id, action, target_type, target_id, before, after (jsonb), created_at                                                 | Every privileged action                                          |

## Characters (shared row; detail per game)

| Table               | Key columns                                                                                            | Notes                                                      |
| :------------------ | :----------------------------------------------------------------------------------------------------- | :--------------------------------------------------------- |
| `characters`        | id, account_id, game_id, realm_id, name (unique per realm), created_at, last_played_at, **deleted_at** | Game-agnostic; what the portal lists                       |
| `<game>_characters` | character_id (PK/FK → characters.id), …game-specific columns                                           | Added by each game; owned by that game server while online |
| `<game>_*`          | —                                                                                                      | Inventory, spells, etc. — defined in the game's own docs   |

Never widen `characters` with game-specific columns.

## Cross-boundary queue

| Table                | Key columns                                                                         | Notes                                                       |
| :------------------- | :---------------------------------------------------------------------------------- | :---------------------------------------------------------- |
| `pending_deliveries` | id, character_id, kind, payload (jsonb), created_by, created_at, consumed_at, error | HTTP side inserts; game server consumes; idempotent on `id` |

## Game static data

Maps, item templates, monsters, etc. are large and game-specific. Each game decides (seeded `<game>_*_templates` tables vs versioned JSON loaded at server start) and records it in its feature doc. Do not model static data in the base schema.

## Conventions

- `id` = UUID v7 (or `cuid2`) for platform tables; integer ids acceptable for high-volume game rows if measured.
- Timestamps `timestamptz`; `created_at`/`updated_at` on every table.
- Indexes: `game_tickets(expires_at)`, `bans(account_id, ends_at)`, `characters(account_id, game_id)`.
- Tenancy: none. Soft deletes: `accounts`, `characters` only.
