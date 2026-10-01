# Project Directory Layout

All application code lives under `src/`. Split each deployable/runtime surface into a sibling package:

```
src/
  client/           # Frontend (web UI)
  server/           # Primary backend API
  another-server/   # Additional services (workers, admin API, etc.)
docs/               # AI context documentation
prompts/            # Standardized AI task prompts
bin/                # Automation scripts
```

Do not place app packages at the repo root (`client/`, `server/`, etc.). Config, docs, scripts, and infrastructure stay at the root; source code stays in `src/<surface>/`.

## Preferred Backend Layering

Inside each backend surface, organize as **Controllers → Services → Repositories** (do not dump business or data-access logic in controllers):

```
src/server/
  controllers/     # HTTP / route handlers only (thin)
  services/        # Business logic & orchestration
  repositories/    # Data access (Prisma / Eloquent / DB)
```

- **Controllers:** Parse input, call a service, return the response. No business rules or queries.
- **Services:** Domain logic, validation orchestration, multi-repo workflows.
- **Repositories:** Persist and fetch data via the ORM. No HTTP concerns.

When a layer folder fills with related peers, nest by domain (e.g. `repositories/billing/…`). Adapt names to the framework if needed, but keep the three-layer split under `src/<surface>/`.
