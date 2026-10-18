# Tech Stack Summary

> **Status: TEMPLATE** — replace bracketed choices during `/init`.

- Surfaces: `src/client`, `src/server` (+ more only if needed)
- Runtime (Python): uv (**required** for Python)
- Framework: [e.g., FastAPI / Django / Flask]
- Language: Python 3.12+ / PHP 8.3+
- Database: PostgreSQL (recommended)
- ORM: SQLAlchemy 2.x + Alembic (Python) / Eloquent (Laravel) — **defaults**; document exceptions
- Architecture: Controllers → Services → Repositories (**default** backend split); domain-nest when crowded
- Validation: Pydantic v2 (**required** for Python); React → react-hook-form + Zod
- Frontend HTTP: Axios (**default** shared client)
- Styling: Tailwind CSS + Radix UI / Shadcn (mobile-first, granular UI)
- UI/UX: Loading states required for async waits
- Testing: pytest; Playwright for critical E2E
- Tooling: pre-commit; `bash bin/doctor.sh` + `bash bin/verify.sh`
- Containers: Docker Compose **conditional** (only when DB/workers/container deploy help)
- AI (optional): Provider interface + Pydantic-validated structured output
