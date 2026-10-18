# DLR WebKit — Python image template.
# Consumer projects should customize COPY paths / CMD for their real surfaces.
# Host ports stay in docker-compose + .env — never hardcode them here.

FROM python:3.12-slim AS deps
WORKDIR /app
COPY pyproject.toml uv.lock ./
RUN pip install uv

FROM python:3.12-slim AS runner
WORKDIR /app
COPY --from=deps /usr/local/bin/uv /usr/local/bin/uv
ENV PORT=8000
COPY pyproject.toml uv.lock ./
RUN uv sync --frozen --no-dev --no-install-project
COPY . .
EXPOSE 8000
CMD ["uv", "run", "--no-dev", "python", "src/server/health.py"]
