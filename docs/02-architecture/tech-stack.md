# Tech Stack Summary

> **Status: TEMPLATE** — replace bracketed choices during `/init`.

- Surfaces: `src/client`, `src/server` (+ more only if needed)
- Runtime (JS/TS): Bun (**required** for JS/TS)
- Framework: [e.g., Hono / Express / Next.js / Laravel]
- Language: TypeScript / PHP 8.3+
- Database: PostgreSQL (recommended)
- ORM: Prisma (JS/TS) / Eloquent (Laravel) — **defaults**; document exceptions
- Architecture: Controllers → Services → Repositories (**default** backend split); domain-nest when crowded
- Validation: Zod (**required** for JS/TS); React → react-hook-form + Zod
- Frontend HTTP: Axios (**default** shared client)
- Styling: Tailwind CSS + Radix UI / Shadcn (mobile-first, granular UI)
- UI/UX: Loading states required for async waits
- Testing: Bun test or Vitest; Playwright for critical E2E
- Tooling: Husky + lint-staged; `bun run doctor` + `bun run verify`
- Containers: Docker Compose **recommended** for deployable apps (dynamic `${APP_PORT}` / `${DB_PORT}`)
- AI (optional): Provider interface + Zod-validated structured output
