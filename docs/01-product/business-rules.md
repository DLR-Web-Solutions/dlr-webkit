# Global Business Rules

Only rules that are real for this product. Extend as features land.

## Accounts

- One account plays every game on the platform; characters are per game and per realm.
- Soft deletes for `accounts` and `characters` (`deleted_at`); hard delete only via an explicit admin purge job after a retention window (default 90 days).
- Usernames are unique case-insensitively; emails are unique and required for recovery.
- No multi-tenancy. One operator, one platform.

## Game access

- Entering a game requires a **game ticket**: issued by the HTTP API to a logged-in, non-banned account; single-use; expires in 60 seconds; bound to `account_id + game_id + realm_id`.
- One active game session per account per game. A new successful ticket redemption disconnects the previous session.
- Realms have a status (`online`, `maintenance`, `offline`). Tickets are only issued for `online` realms; staff may bypass `maintenance`.

## Single shared database: write ownership

The HTTP API and the game servers share one PostgreSQL database. To avoid lost updates:

| Data                                                          | Owner while character is online  | Other side may…                                        |
| :------------------------------------------------------------ | :------------------------------- | :----------------------------------------------------- |
| Account, session, role, ban, ticket, news, realm status       | HTTP API                         | Game server reads (bans/realm status polled or pushed) |
| Character state, position, inventory, stats, in-game currency | Game server                      | HTTP API reads only (rankings, profile)                |
| Cross-boundary effects (future shop, rewards, GM grants)      | Queue table `pending_deliveries` | Producer inserts; game server consumes and marks done  |

- Game servers persist character state on logout/disconnect and on a periodic autosave; never rely on a single end-of-session write.
- Bans and realm closures must take effect in a running game server without restart (poll interval or notification channel—document when implemented).

## Moderation & safety

- Every privileged action (ban, role change, item grant, realm toggle) writes an `audit_log` row.
- Chat is rate-limited server-side; chat logs are retained 30 days for moderation then purged.
- Never log passwords, session ids, or raw tickets.

## Data retention / privacy

- Store only what the product needs: email, username, password hash, IP of last login (for abuse handling), gameplay data.
- Account deletion request → soft delete immediately, purge after the retention window.

## Game content & intellectual property

- Game assets (maps, sprites, sounds, data files) are **not** committed to this repository and are not distributed from it. Asset sourcing/hosting is the operator's responsibility and is configured via environment/asset URLs, not code.
- Protocol and game logic are original implementations targeting the browser; no decompiled client code is vendored.

## Billing

- N/A for v1. If a shop or donations are added later, payments go through a provider interface and deliver via `pending_deliveries`—never by writing directly into inventory tables.
