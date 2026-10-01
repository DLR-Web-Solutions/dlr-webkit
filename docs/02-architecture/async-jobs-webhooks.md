# Async Jobs & Webhooks

Patterns only—add infrastructure when the product needs it.

## Background jobs

When work must leave the request path (email, billing reconciliation, embeddings):

1. Enqueue from a service after the DB transaction commits (or use outbox if dual-write risk matters).
2. Handlers must be **idempotent** (safe retries).
3. Cap retries with backoff; dead-letter or alert after exhaustion.
4. Keep job payloads small (IDs, not huge blobs).

Place handlers under something like `src/server/jobs/` (domain-nest when crowded). Prefer the framework’s queue (BullMQ, Laravel queues, etc.) already in the stack—do not add a second queue system.

## Webhooks (incoming)

For Stripe/GitHub/etc. callbacks:

1. Verify signatures with the provider secret from `.env`.
2. Enforce idempotency (event id unique constraint / processed-events table).
3. Respond quickly; heavy work goes to a job.
4. Log event id + type, not full sensitive payloads.

## Webhooks (outgoing)

If you emit webhooks: sign payloads, retry with backoff, and document the event schema. Skip until a real consumer exists.
