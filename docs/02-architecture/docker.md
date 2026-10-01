# Docker & Environment Port Guidelines

## When to use

Docker Compose is **conditional** — use it when the project benefits from containers (database, workers, parity with production, or containerized deploy).

Do **not** add `docker-compose.yml` / `Dockerfile` solely to satisfy a checklist. Simple host-run apps can omit them.

If you **do** use Compose and it **builds** an app image, ship a matching `Dockerfile` and an HTTP health endpoint the healthcheck can probe.

## Core Rule

All Docker container **host** bindings MUST be driven dynamically by `.env` variables. Hardcoding host ports in `docker-compose.yml` or `Dockerfile` is strictly prohibited.

## Objectives

1. **Zero-Collision Deployments:** Allow multiple apps on the same VPS by changing `APP_PORT` and `DB_PORT` in `.env`.
2. **Environment Consistency:** Keep internal `CONTAINER_PORT` stable while varying the exposed host port.

## Standard Configuration Pattern

- **Host Web Port:** `${APP_PORT:-8000}`
- **Internal App Port:** `${CONTAINER_PORT:-8000}`
- **Host Database Port:** `${DB_PORT:-5432}`

## Healthchecks

| Service  | Probe                                                                                                                 |
| :------- | :-------------------------------------------------------------------------------------------------------------------- |
| App      | HTTP `GET /health` on the container port (liveness). Do **not** use `bun --version` or similar as an app healthcheck. |
| Database | `pg_isready` (or engine equivalent) — separate from app liveness.                                                     |

Kit template: `src/server/health.ts` serves `/health` and `/ready`. Product apps should replace the process with the real server and keep (or extend) those routes.

## Secrets

- Compose must **not** default `POSTGRES_PASSWORD` to a literal like `secret`.
- Require `DB_PASSWORD` from `.env` (see `.env.example` for a local-dev-only placeholder).
- Production: use a strong unique password; never commit real `.env` files.

## Production Deployment Checklist

1. Copy `.env.example` to `.env` and set a real `DB_PASSWORD`.
2. Assign unique `APP_PORT` / `DB_PORT` for this stack.
3. Confirm app healthcheck hits `/health`, not a runtime version flag.
4. Run `docker compose up -d --build` only if this project uses Compose.
