# Project Directory Layout

`src/` - Core source code
`docs/` - AI context documentation
`prompts/` - Standardized AI task prompts

## Preferred Backend Layering

Organize application code as **Controllers → Services → Repositories** (do not dump business or data-access logic in controllers):

```
controllers/     # HTTP / route handlers only (thin)
services/        # Business logic & orchestration
repositories/    # Data access (Prisma / Eloquent / DB)
```

- **Controllers:** Parse input, call a service, return the response. No business rules or queries.
- **Services:** Domain logic, validation orchestration, multi-repo workflows.
- **Repositories:** Persist and fetch data via the ORM. No HTTP concerns.

Adapt paths to the framework (`app/Http/Controllers`, `app/Services`, `app/Repositories`, or `src/controllers`, etc.) but keep the three-layer split.
