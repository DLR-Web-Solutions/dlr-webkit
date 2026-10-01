# Observability Conventions

Keep the base kit vendor-neutral. Provide hooks; do not require Datadog/Sentry/etc. unless the consumer project chooses them.

## Structured logging

- Log JSON (or structured key/value) from servers: `level`, `msg`, `requestId`, `route`, `durationMs`.
- **Never** log passwords, session tokens, API keys, raw card data, or full LLM prompts that contain PII unless explicitly required and redacted.

## Request IDs

- Accept incoming `x-request-id` or generate one per request; propagate to logs and downstream calls.

## Health endpoints

When implementing a server surface, expose:

| Path          | Purpose                                      |
| :------------ | :------------------------------------------- |
| `GET /health` | Liveness — process is up                     |
| `GET /ready`  | Readiness — DB (and critical deps) reachable |

Docker/K8s (if used later) should probe these—not arbitrary HTML pages.

## Errors

- Centralize exception handling; map domain errors to safe client responses.
- Record unexpected errors with stack traces **only** in server logs.

## AI request metadata

If the app calls LLMs, log safely: provider, model, latency, token usage (if available), success/failure—not full secrets or unnecessary user content.
