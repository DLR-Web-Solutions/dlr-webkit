# Tech Stack Summary

- Surfaces: `src/client`, `src/server` (+ more only if needed)
- Runtime (JS/TS): Bun
- Framework: [e.g., Hono / Express / Next.js / Laravel]
- Language: TypeScript / PHP 8.3+
- Database: PostgreSQL (recommended)
- ORM: Prisma (JS/TS) / Eloquent (Laravel)
- Architecture: Controllers → Services → Repositories; domain-nested folders when crowded
- Validation: Zod (no native HTML validation); React → react-hook-form + Zod
- Frontend HTTP: Axios
- Styling: Tailwind CSS + Radix UI / Shadcn (mobile-first, granular UI)
- UI/UX: Loading states required for async waits
- Testing: Bun test or Vitest; Playwright for critical E2E
- Tooling: Husky + lint-staged; `bin/doctor` + `bin/verify`
- AI (optional): Provider interface + Zod-validated structured output
