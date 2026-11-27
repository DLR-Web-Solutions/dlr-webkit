# Docs Map

Docs are the durable context for humans and agents. Start with `00-context/project.md`; update the closest document instead of creating a parallel tree.

| Path                    | Use for                                                  |
| :---------------------- | :------------------------------------------------------- |
| `00-context/project.md` | Canonical project facts, stack, and agent conventions    |
| `01-product/`           | Product overview, roles/permissions, business rules      |
| `02-architecture/`      | Stack, directory layout, data mapping, jobs, Docker, AI  |
| `03-features/`          | Feature notes and contracts                              |
| `04-standards/`         | Coding, testing, API, UI, security, automation standards |
| `05-database/`          | Schema and data notes                                    |

## Keeping docs true

A change that makes a document wrong must update that document in the same commit. This is enforced, not left to memory:

- **Local hook:** `.husky/commit-msg` runs `bin/docs-check --staged --message-file "$1"`.
- **CI:** the verify workflow runs `bin/docs-check --range "<base or before>"` on the pushed range.
- **Business paths:** `src/`, `deploy/`, `bin/`, `scripts/`, `.github/workflows/`.
- **Docs path:** `docs/`.

A business change passes when the same diff includes a `docs/` file. If no document can become untrue, use `[no-docs]` in the commit message and put the reason in the body. Legitimate cases are narrow:

- a pure refactor with no behavior or contract change;
- a test-only change;
- tooling that cannot affect documented behavior.

`[no-docs]` is a decision, not a shortcut. Do not use it for a behavior, API, schema, security, UI, or workflow change that belongs in a doc.

**One real bypass:** `git commit --no-verify` skips the local hook. CI still checks the pushed range, so a business change without docs cannot land on `dev` silently.
