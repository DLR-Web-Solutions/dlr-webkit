# Coding Guidelines & Standards

> **Scope:** These guidelines apply to all JavaScript and TypeScript projects within the repository (Frontend, Node.js API services, and build tooling).

---

## 1. Language Preference & Typing

- **TypeScript First:** **TypeScript is strongly preferred** over plain JavaScript for all new features, components, services, and utilities.
- **Strict Mode:** Strict mode must be enabled (`"strict": true` in `tsconfig.json`).
- **No `any` Types:** Avoid using `any`. Use explicit interfaces, types, generics, or `unknown` with runtime type narrowing.
- **Plain JavaScript Exception:** Plain `.js` or `.jsx` files should only be used if required by legacy constraints or third-party tool configurations.

---

## 2. Module Syntax & Imports (JS / TS)

- **ES Modules Only:** Always use standard ES6 `import` and `export` syntax.
    ```typescript
    // ✅ DO:
    import { useState } from "react";
    import { User } from "@/models/User";
    ```
- **No CommonJS:** Never use CommonJS `require()` or `module.exports` in JS/TS source code.
    ```javascript
    // ❌ DON'T:
    const express = require('express');
    module.exports = { ... };
    ```
- **Type-Only Imports:** Use explicit `import type` when importing types or interfaces in TypeScript to optimize bundle output:
    ```typescript
    import type { UserDTO } from "@/types/user";
    ```
- **Import Ordering:** Group imports consistently:
    1. External/Library dependencies (e.g., `react`, `express`)
    2. Internal alias imports (e.g., `@/components`, `@/services`)
    3. Relative imports (e.g., `./Button`, `../utils`)
    4. Type-only imports (`import type { ... }`)

---

## 3. Code Quality & Structure

- **Functions & Components:** Keep functions under 50 lines and components under 150 lines. Extract reusable hooks or helper functions when logic grows complex.
- **Early Returns:** Prefer early returns to eliminate deeply nested `if/else` blocks.
- **Defensive Defaults:** Use nullish coalescing (`??`) and optional chaining (`?.`) instead of logical OR (`||`) when evaluating potentially missing values.

---

## 4. Linting & Formatting Enforcement

- **ESLint Integration:** All JS/TS projects must use ESLint configured with `@typescript-eslint/no-require-imports` set to `error`.
- **Pre-Commit Rule:** Run `npm run lint` or `npx eslint .` prior to committing to ensure compliance.
