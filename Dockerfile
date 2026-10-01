# DLR WebKit — Bun image template.
# Consumer projects should customize COPY paths / CMD for their real surfaces.
# Host ports stay in docker-compose + .env — never hardcode them here.

FROM oven/bun:1.2-alpine AS deps
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

FROM oven/bun:1.2-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
ENV PORT=8000
COPY --from=deps /app/node_modules ./node_modules
COPY package.json bun.lock ./
COPY . .

EXPOSE 8000
# Template process that serves GET /health and GET /ready.
# Replace with your real server entrypoint (e.g. src/server/index.ts) in product apps.
CMD ["bun", "src/server/health.ts"]
