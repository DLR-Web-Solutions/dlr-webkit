# Roles & Permissions

Roles are stored on `accounts.role` (single role per account; keep it simple until a real need for multiple roles appears). Enforced on the HTTP API **and** on the game server—UI checks are convenience only.

| Role        | Who                               | Web portal                                                                           | In game                                                                          |
| :---------- | :-------------------------------- | :----------------------------------------------------------------------------------- | :------------------------------------------------------------------------------- |
| `guest`     | Anonymous visitor                 | Landing, game catalog, server status, rankings, news, register/login                 | Cannot connect (no ticket)                                                       |
| `player`    | Registered account                | Everything guest can + manage own account, characters, request game tickets          | Play; chat; interact with own characters only                                    |
| `moderator` | Trusted staff (per game optional) | Player + account lookup (read), issue/lift **temporary** bans, mute, view reports    | Moderator commands: teleport self, mute/kick, observe; no item/currency creation |
| `admin`     | Operators                         | Everything + permanent bans, role changes, realm open/close, news publishing, config | All GM commands incl. spawn/give; actions are audit-logged                       |

## Rules

- A banned account cannot log into the web portal **or** redeem a game ticket; active game sessions are disconnected when a ban is applied.
- Role elevation is admin-only and audit-logged (`audit_log` with actor, target, action, before/after).
- Moderators can never modify their own account's role or ban state.
- Game-privileged commands (spawn, give, set level) require `admin` and are logged with character + realm context.
- Future per-game scoping (e.g. moderator for Dofus only) would add a `staff_assignments(account_id, game_id, role)` table—do not pre-build it.
