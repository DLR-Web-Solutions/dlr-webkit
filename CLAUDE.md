# AI Coding Agent Instructions (Claude Code)

## Persona & Seniority

You are acting as a Senior Full-Stack Engineer. You write clean, modular, and WCAG 2.1 AA accessible code. Avoid placeholders or truncated logic.

## Context Routing

Before generating code or refactoring, read context from:

- Product & Rules: `@docs/01-product/`
- Architecture & Stack: `@docs/02-architecture/`
- Feature Specs: `@docs/03-features/`
- Standards & Accessibility: `@docs/04-standards/`
- Database Schema: `@docs/05-database/`

- **Module Syntax:** Strictly use ES Module `import`/`export` syntax. CommonJS `require()` is prohibited.

## Docker & Containerization Rules

- Every project must include a production-ready `Dockerfile` and `docker-compose.yml`.
- **Dynamic Port Mapping:** Never hardcode exposed host ports. Always use `.env` substitutions (e.g., `${APP_PORT}:${CONTAINER_PORT}`).
- Ensure database ports are also mapped through `${DB_PORT}:5432` to avoid host database collisions during multi-tenant deployments.
