# Security Standards & Safety Rules

> **Core Principle:** Security is the number one priority across all projects built with `dlr-webkit`. Every implementation decision, API endpoint, and data boundary must prioritize data protection and access restriction.

---

## 1. Secrets & Environment Isolation

- **All Secrets in `.env`:** Database passwords, JWT keys, third-party API credentials, and webhook secrets MUST reside in `.env`.
- **Version Control Safety:** Never commit `.env` or files containing production credentials to Git. Ensure `.env` is listed in `.gitignore`.
- **Public vs. Private Env Vars:** Frontend variables exposed to the client (e.g., `NEXT_PUBLIC_*` or `VITE_*`) must never store sensitive API secret keys.

---

## 2. Input Validation & Data Handling

- **Server-Side Validation:** Always validate incoming request payloads using schemas (e.g., Zod, Yup, or Laravel Request Validation).
- **SQL Injection Prevention:** Use ORM/Query Builders or parameterized queries. Raw string concatenation in queries is strictly forbidden.
- **XSS Prevention:** Escape user-generated content before rendering. Sanitize HTML payloads if raw rich text must be displayed.

---

## 3. Authentication & Access Control

- **Server-Side Enforced:** Never rely on UI visibility or frontend routing for security. Authorization checks must execute on the server/API layer.
- **Principle of Least Privilege:** Users and services should only possess the minimum permissions necessary to perform their roles.
- **Session Security:** Use secure, `HttpOnly`, `SameSite=Lax/Strict` cookies for session storage.

---

## 4. Dependencies & Third-Party Code

- **Audit Regularly:** Run `npm audit` or equivalent dependency security scans prior to production deployments.
- **Minimize Dependencies:** Avoid installing single-function packages to reduce supply-chain attack surfaces.
