# Auth Feature Specification

Two authentication surfaces share one `accounts` table: the **web session** (portal) and the **game ticket** (WebSocket). Passwords are only ever handled by the HTTP API.

## Web authentication

- Credentials: username or email + password. Hash with Argon2id (`Bun.password.hash` / `Bun.password.verify`).
- Session: server-side row in `sessions`; cookie holds an opaque id. Cookie flags: `HttpOnly`, `SameSite=Lax`, `Secure` in production, `Path=/`. Sliding expiry 14 days, absolute max 30 days.
- Login rate limit per IP + per username; generic error message on failure (no "wrong password" vs "unknown user").
- Logout destroys the session row. "Log out everywhere" deletes all sessions for the account.
- Password reset: email token, single-use, expires in 60 minutes; resetting invalidates all sessions.
- Registration: username (3–20 chars, `[a-zA-Z0-9_]`), email, password (min 10 chars, checked against a breached-password list when feasible). New accounts get role `player`.
- OAuth: **not** in v1.

## Game ticket flow

```
Browser (logged in)                 HTTP API                           Game server
  │  POST /api/v1/games/:game/ticket  │                                   │
  │  { realmId }                      │  check: session valid, not banned,│
  │ ────────────────────────────────▶ │  realm online, game enabled       │
  │  { ticket, wsUrl, expiresAt }     │  insert game_tickets (TTL 60 s)   │
  │ ◀──────────────────────────────── │                                   │
  │  WS connect wsUrl                 │                                   │
  │  hello { protocolVersion, ticket }│                                   │
  │ ─────────────────────────────────────────────────────────────────────▶│ redeem: not expired, not redeemed,
  │                                   │                                   │ realm matches, account not banned
  │  welcome { accountId, characters[] }  or  error + close               │ mark redeemed_at; bind session
  │ ◀─────────────────────────────────────────────────────────────────────│
```

- Tickets are random 32-byte opaque values; store only the value needed to look them up (hash at rest is optional for v1 given the 60 s TTL—decide when implementing).
- One active game session per account per game; redeeming a new ticket disconnects the previous socket with reason `replaced`.
- Game server re-checks ban status on a schedule and disconnects banned accounts (see business rules).

## Endpoints (HTTP API, `/api/v1`)

| Method | Path                    | Auth    | Purpose                       |
| :----- | :---------------------- | :------ | :---------------------------- |
| POST   | `/auth/register`        | guest   | Create account, start session |
| POST   | `/auth/login`           | guest   | Start session                 |
| POST   | `/auth/logout`          | player+ | End current session           |
| POST   | `/auth/logout-all`      | player+ | End all sessions              |
| POST   | `/auth/password/forgot` | guest   | Send reset email (always 200) |
| POST   | `/auth/password/reset`  | guest   | Consume token, set password   |
| GET    | `/me`                   | player+ | Current account summary       |
| POST   | `/games/:game/ticket`   | player+ | Issue game ticket for a realm |

All bodies validated with Zod; errors use the shared JSON error shape from `docs/04-standards/api-conventions.md`.

## Tests

- Unit: password policy, ticket TTL/single-use, ban check ordering.
- Integration: register → login → ticket → redeem on an in-process game server; second redeem fails; banned account gets `error` and close.
- E2E (Playwright): register, login, open `/play/:game` (a stub game module in tests), reach `welcome`.
