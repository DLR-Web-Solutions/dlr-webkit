# DLR WebKit — production-oriented Bun image template.
# Consumer projects should customize the final CMD / COPY paths for their surfaces
# (e.g. src/server). Keep host ports out of this file; use docker-compose + .env.

FROM oven/bun:1.2-alpine AS deps
WORKDIR /app
COPY package.json bun.lock ./
RUN bun install --frozen-lockfile

FROM oven/bun:1.2-alpine AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=deps /app/node_modules ./node_modules
COPY package.json bun.lock ./
COPY . .

# Default: kit smoke entry. Replace with your app start command in real projects.
EXPOSE 8000
CMD ["bun", "--version"]
