# Coding Guidelines & Standards

**Scope:** These guidelines apply universally to the entire repository and all stack components (Laravel/PHP backend, JS/TS frontend, database schemas, scripts, and DevOps infrastructure) immediately upon overlaying or initializing the project via `install.sh`.

---

## 1. Universal Software Architecture Principles

These principles are strictly enforced across **all languages and frameworks**:

- **File Granularity over Monoliths:** **Prefer multiple small, modular files** over large monolithic files. Break down classes, controllers, utilities, components, and schemas into dedicated, well-scoped files to maximize readability and maintainability.
- **Controllers → Services → Repositories:** Prefer this folder/layer structure. Controllers stay thin; services own business logic; repositories own data access.
- **Centralized Middleware & Error Handling:** Handle uncaught exceptions and unexpected failures using **centralized middleware or global error boundaries** (e.g., Laravel's exception handler in `bootstrap/app.php` or Express/Next.js middleware). Avoid writing repetitive inline error checks or manual `try/catch` wrapping inside individual functions unless local recovery or custom domain handling is strictly required.
- **SOLID Design:**
    - **Single Responsibility (SRP):** Keep files, classes, and functions focused on a single responsibility.
    - **Open/Closed (OCP):** Open for extension, closed for modification using interfaces, traits, and composition.
    - **Liskov Substitution (LSP):** Subtypes must be completely substitutable for base types.
    - **Interface Segregation (ISP):** Prefer small, focused interfaces over large general-purpose ones.
    - **Dependency Inversion (DIP):** Depend on abstractions (interfaces/contracts), not concrete implementations.
- **DRY (Don't Repeat Yourself):** Consolidate repeated validation rules, utility functions, API calls, and business logic into shared services, actions, or helpers. Refactor duplicated logic upon its third occurrence.
- **KISS (Keep It Simple, Stupid):** Write explicit, readable code over clever or overly abstract implementations. Avoid speculative over-engineering.

---

## 2. Dependency & Package Management

- **Stable-First Policy:** Always select stable, production-ready, LTS releases when adding dependencies across all ecosystems (`npm`, `composer`, `pip`, Docker base images).
- **No Unstable Builds:** Pre-release packages (`alpha`, `beta`, `rc`, `canary`, `dev-main`) are strictly forbidden unless required by explicit user instruction.
- **Lockfile Enforcement:** Always commit updated lockfiles (`package-lock.json`, `composer.lock`, etc.) after adding or updating dependencies to guarantee deterministic builds across environments.

---

## 3. PHP & Laravel Standards

- **Strict Types:** Always declare strict types at the top of every PHP file: `declare(strict_types=1);`.
- **PSR-12 Compliance:** Strictly adhere to PSR-12 coding standard conventions.
- **Explicit Type Hints:** Define explicit parameter and return type hints on all class methods, controller actions, and helper functions.
- **Thin Controllers:** Keep controllers thin. Delegate business logic to **Services** and data access to **Repositories** (e.g., `app/Services/CreateUserService.php`, `app/Repositories/UserRepository.php`).
- **Exception Flow:** Throw typed domain exceptions and let framework exception handlers capture and format response payloads centrally.

---

## 4. JavaScript & TypeScript Standards

- **TypeScript First:** Strongly preferred over plain JavaScript. Use strict mode (`"strict": true`).
- **No `any` Types:** Use explicit interfaces, types, generics, or `unknown` with runtime type narrowing.
- **ES Modules Only:** Always use standard ES6 `import`/`export`. Never use CommonJS `require()` or `module.exports`.
    ```typescript
    // ✅ DO:
    import { useState } from 'react';
    import { User } from '@/models/User';
    ```
    ```javascript
    // ❌ DON'T:
    const express = require('express');
    module.exports = { ... };
    ```
- **Type-Only Imports:** Use explicit `import type` when importing types or interfaces in TypeScript to optimize bundle output:
    ```typescript
    import type { UserDTO } from '@/types/user';
    ```
- **Import Ordering:** Group imports consistently:
    1. External/Library dependencies (e.g., `react`, `express`)
    2. Internal alias imports (e.g., `@/components`, `@/services`)
    3. Relative imports (e.g., `./Button`, `../utils`)
    4. Type-only imports (`import type { ... }`)
- **Formatting Constraints:**
    - **Indentation:** 4 spaces per tab level.
    - **Quotes:** Single quotes (`'`) for string literals.
    - **Semicolons:** Always terminate statements with semicolons.
    - **Trailing Commas:** Multi-line structures must end with trailing commas (`trailingComma: 'all'`).

---

## 5. Validation (Zod)

- **Zod First:** Use Zod for all request, form, env, and API payload validation in JS/TS projects.
- **React Forms:** When the frontend is React, always use **react-hook-form** (typically with `@hookform/resolvers/zod`) for form state and submission. Do not manage form fields with ad-hoc `useState` for standard form flows.
- **No Native HTML Validation:** Do not rely on browser constraint validation. Disable it with `noValidate` on forms, and avoid HTML-only checks (`required`, `pattern`, `min`/`max`, `type="email"` as validation, etc.). Surface errors via Zod + accessible UI messaging (`aria-invalid`, `aria-describedby`).
- **Single Source of Truth:** Prefer shared Zod schemas that can derive TypeScript types via `z.infer<typeof schema>`.
- **Laravel:** When the backend is Laravel, still prefer Zod on the JS/TS frontend; use Form Requests on the PHP side when needed for server enforcement.

## 6. Data Access (ORM)

- **JS/TS projects:** Use **Prisma** as the ORM. No ad-hoc SQL string building; use the Prisma Client.
- **Laravel/PHP projects:** Use **Eloquent** (and Query Builder where appropriate). Prefer Eloquent models and relationships over raw queries.

## 7. Frontend HTTP Client

- **Axios Only:** All browser/frontend API calls must go through **Axios** (typically a shared configured instance, e.g. `api`). Do not use `fetch` for application API traffic unless Axios is unavailable for a platform-specific constraint explicitly approved by the user.

## 8. UI Layout

- **Mobile-First:** Write base styles for mobile, then progressive enhancement via Tailwind breakpoints (`sm:`, `md:`, `lg:`). Touch targets, spacing, and navigation must work on small screens first.
- **Granular UI:** Every UI surface must be composed of small, single-purpose components. Do not ship large monolithic page/view files—split layout, sections, forms, fields, and interactive pieces into dedicated components.
- **Loading Components:** Always include a loading state when async work can delay feedback (page/data load, form submit, button actions). Prefer dedicated reusable loading/skeleton components; wire `aria-busy` / polite status text where appropriate.

## 9. Code Quality & Formatting Enforcement

- **Functions & Components:** Keep functions under 50 lines and components/classes under 150 lines. Extract reusable hooks, sub-components, or helper functions into separate files when logic grows complex.
- **Early Returns:** Prefer early returns to eliminate deeply nested `if/else` blocks.
- **Defensive Defaults:** Use nullish coalescing (`??`) and optional chaining (`?.`) instead of logical OR (`||`) when evaluating potentially missing values.
- **Pre-Commit Rule:** Always run linting and code formatting tools (`npm run lint`, `./vendor/bin/pint`, or `./vendor/bin/phpcs`) prior to committing to ensure compliance.
