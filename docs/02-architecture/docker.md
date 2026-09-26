# Docker & Environment Port Guidelines

## Core Rule

All Docker container host bindings MUST be driven dynamically by `.env` variables. Hardcoding host ports in `docker-compose.yml` or `Dockerfile` is strictly prohibited.

## Objectives

1. **Zero-Collision Deployments:** Allow multiple apps to run on the same VPS by changing `APP_PORT` and `DB_PORT` in `.env`.
2. **Environment Consistency:** Keep the internal `CONTAINER_PORT` consistent across environments while varying the exposed host port.

## Standard Configuration Pattern

- **Host Web Port:** `${APP_PORT:-8000}`
- **Internal App Port:** `${CONTAINER_PORT:-8000}`
- **Host Database Port:** `${DB_PORT:-5432}`

## Production Deployment Checklist

1. Copy `.env.example` to `.env`.
2. Assign a unique `APP_PORT` (e.g., `8001`, `8002`) and `DB_PORT` (e.g., `5433`, `5434`) for this specific container stack.
3. Run `docker compose up -d --build`.
