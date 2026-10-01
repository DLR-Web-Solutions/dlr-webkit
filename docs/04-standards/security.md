# Security Standards & Safety Rules

> **Core Principle:** Security is the number one priority across all projects built with `dlr-webkit`. Every implementation decision, API endpoint, and data boundary must prioritize data protection and access restriction.

---

## 1. Secrets & Environment Isolation

- **All Secrets in `.env`:** Database passwords, JWT keys, third-party API credentials, and webhook secrets MUST reside in `.env`.
- **Version Control Safety:** Never commit `.env` or files containing production credentials to Git. Ensure `.env` is listed in `.gitignore`.
- **Public vs. Private Env Vars:** Frontend variables exposed to the client (e.g., `NEXT_PUBLIC_*` or `VITE_*`) must never store sensitive API secret keys.
- **Env validation:** Parse env with Zod (or equivalent) at startup; fail fast on missing required production secrets.
- **Example file:** `.env.example` documents keys without real values; mark optional vs required in comments.

---

## 2. Input Validation & Data Handling

- **Server-Side Validation:** Always validate incoming request payloads with **Zod** schemas (shared or mirrored on the server).
- **No Native HTML Validation:** Client forms must not depend on browser constraint validation. Use `noValidate` and Zod-driven errors instead.
- **SQL Injection Prevention:** Use the project ORM (**Prisma** for JS/TS, **Eloquent** for Laravel) or parameterized queries. Raw string concatenation in queries is strictly forbidden.
- **XSS Prevention:** Escape user-generated content before rendering. Sanitize HTML payloads if raw rich text must be displayed.
- **SSRF:** Do not fetch arbitrary user-supplied URLs from the server without allowlists / network controls.
- **Uploads:** Validate content type and size server-side; store outside the web root or via signed object storage; never trust client MIME alone.
- **LLM output:** Treat as untrusted—structured output + Zod before use (`docs/02-architecture/ai-providers.md`).

---

## 3. Authentication & Access Control

- **Server-Side Enforced:** Never rely on UI visibility or frontend routing for security.
- **Principle of Least Privilege:** Minimum permissions necessary.
- **Session Security:** Secure, `HttpOnly`, `SameSite=Lax/Strict` cookies; `Secure` in production.
- **CSRF:** For cookie-based session mutations, use framework CSRF protection or same-site + origin checks as appropriate.
- **Webhooks:** Verify signatures; enforce idempotency (`docs/02-architecture/async-jobs-webhooks.md`).

---

## 4. Error Disclosure & Logging

- Clients get safe error messages; stacks stay in server logs.
- Never log secrets, tokens, passwords, or full payment payloads.

---

## 5. Dependencies & Automation

- **Audit:** `bun audit` (wired into `bin/verify`).
- **Minimize Dependencies:** Avoid single-function packages when a few lines or an existing dep suffice.
- **CI:** Quality gates must run on every push/PR (see `.github/workflows/ci.yml`).
