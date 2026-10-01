# API Conventions

Apply when the project exposes HTTP APIs. Skip sections that do not fit the chosen framework—but stay consistent within a project.

## Naming & structure

- Prefer clear resource nouns: `/api/users`, `/api/billing/invoices`.
- Version only when you must support breaking clients: `/api/v1/...`.
- Controllers stay thin; validation + authz happen before service calls.

## Validation

- Validate all inputs with **Zod** (JS/TS) or Form Requests (Laravel).
- Reject unknown critical fields when abuse is a concern (`z.object({...}).strict()` where appropriate).

## Errors

Return a stable JSON shape, e.g.:

```json
{
    "error": {
        "code": "VALIDATION_ERROR",
        "message": "Human-readable summary",
        "details": []
    }
}
```

- Do not leak stack traces, SQL, or secrets to clients.
- Use proper HTTP status codes (400/401/403/404/409/422/429/500).

## Authn / authz

- Authenticate every protected route on the server.
- Authorize by role/permission/ownership inside services or dedicated policies—never UI-only.
- Prefer HttpOnly, Secure, SameSite cookies for browser sessions.

## Pagination

- Consistent list envelope (see `docs/02-architecture/data-mapping.md` collection pattern).
- Default conservative `per_page` limits; cap maximums server-side.

## Idempotency & rate limits

- Mutating webhooks and payment-like POSTs should accept an idempotency key when retries are expected.
- Rate-limit auth and public write endpoints at the edge or middleware.

## OpenAPI

Add OpenAPI/Swagger **only** if the project has external API consumers or needs contract testing. Do not add it “for completeness.”
