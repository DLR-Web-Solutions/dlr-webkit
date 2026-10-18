# Coding Guidelines & Standards

**Scope:** These guidelines apply universally to the entire repository and all stack components (Laravel/PHP backend, Python backend, database schemas, scripts, and DevOps infrastructure) immediately upon overlaying or initializing the project via `install.sh`.

---

## 1. Universal Software Architecture Principles

These principles are strictly enforced across **all languages and frameworks**:

- **`src/` Root for App Code:** All application code lives under `src/`. Split deployable/runtime surfaces into sibling packages there—e.g. `src/client`, `src/server`, `src/another-server`—not as top-level `client/` / `server/` folders or scattered outside `src/`. Config, docs, scripts (`bin/`), and infrastructure stay at the repo root.
- **File Granularity over Monoliths:** **Prefer multiple small, modular files** over large monolithic files. Break down classes, controllers, utilities, components, and schemas into dedicated, well-scoped files to maximize readability and maintainability.
- **Domain Nesting:** Keep small files, but when a folder fills with related peers (e.g. `repositories/`), nest them by domain—`repositories/billing/…`—so the tree stays scannable. Prefer many readable files in clear groups over a flat dump.
- **Controllers → Services → Repositories:** **Default** backend layering. Controllers stay thin; services own business logic; repositories own data access. Adapt folder names to the framework when required.
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

- **uv for Python:** Full-stack Python projects must use **uv** as the runtime and package manager (`uv add`, `uv run`). Do not use pip, poetry or conda unless explicitly requested.
- **Lockfile is truth:** Prefer versions already declared in `pyproject.toml` / `uv.lock`. Upgrade deliberately, check compatibility, and run `bash bin/verify.sh`.
- **When adding a dependency:** Pick an explicit **stable** version (no alpha/beta/rc/canary/`@latest` unless the user asks), update the lockfile, and verify. Do not chase “newest” for its own sake.
- **Lockfile Enforcement:** Always commit updated lockfiles after adding or updating dependencies.

---

## 3. PHP & Laravel Standards

- **Strict Types:** Always declare strict types at the top of every PHP file: `declare(strict_types=1);`.
- **PSR-12 Compliance:** Strictly adhere to PSR-12 coding standard conventions.
- **Explicit Type Hints:** Define explicit parameter and return type hints on all class methods, controller actions, and helper functions.
- **Thin Controllers:** Keep controllers thin. Delegate business logic to **Services** and data access to **Repositories** (e.g., `app/Services/CreateUserService.php`, `app/Repositories/UserRepository.php`).
- **Exception Flow:** Throw typed domain exceptions and let framework exception handlers capture and format response payloads centrally.

---

## 4. Python Standards

- **Python >=3.12:** All Python code must use at least Python version 3.12.
- **src layout:** Application code lives under `src/<package>/`.
- **Type hints everywhere:** All functions and classes must include type hints.
- **mypy:** Run type checking using mypy.
- **Dataclasses or Pydantic models for structured data:** Use dataclasses or Pydantic v2 models for structured data.
- **pathlib over os.path:** Use pathlib for file system operations.
- **f-strings:** Use f-strings for string formatting.
- **logging module not print:** Use the logging module in library code instead of print statements.
- **no bare except:** Always specify exceptions to catch.
- **argparse/typer for CLIs:** Use argparse or typer for command-line interfaces.
- **small pure functions:** Keep functions focused and small.
    ```python
    # ✅ DO:
    def calculate_total(price: float, tax_rate: float) -> float:
        return price * (1 + tax_rate)


    from __future__ import annotations


    def process_user_data(user_info: dict[str, str]) -> User: ...
    ```

---

## 5. Validation (Pydantic)

- **Pydantic v2 First:** Use Pydantic v2 for all request, form, env, and API payload validation in Python projects.
- **Pydantic-settings for env:** Use pydantic-settings for environment variable parsing.
- **React Forms:** When a JS/TS frontend exists, always use **react-hook-form** (typically with `@hookform/resolvers/zod`) for form state and submission. Do not manage form fields with ad-hoc `useState` for standard form flows.
- **No Native HTML Validation:** Do not rely on browser constraint validation. Disable it with `noValidate` on forms, and avoid HTML-only checks (`required`, `pattern`, `min`/`max`, `type="email"` as validation, etc.). Surface errors via Pydantic + accessible UI messaging (`aria-invalid`, `aria-describedby`).
- **Single Source of Truth:** Prefer shared Pydantic schemas that can derive Python types via `BaseModel`.
- **Laravel:** When the backend is Laravel, still prefer Zod on the JS/TS frontend; use Form Requests on the PHP side when needed for server enforcement.

## 6. Data Access (ORM)

- **Python projects (default):** Use **SQLAlchemy 2.x + Alembic**. No ad-hoc SQL string building; use SQLAlchemy ORM. Document any alternate ORM choice in `docs/00-context/project.md`.
- **Laravel/PHP projects:** Use **Eloquent** (and Query Builder where appropriate). Prefer Eloquent models and relationships over raw queries.

## 7. Frontend HTTP Client

- **Default:** Browser/frontend API calls go through **Axios** (shared configured instance). Do not use raw `fetch` for application API traffic unless a platform constraint requires it—and document that exception.

## 8. UI Layout

- **Mobile-First:** Write base styles for mobile, then progressive enhancement via Tailwind breakpoints (`sm:`, `md:`, `lg:`). Touch targets, spacing, and navigation must work on small screens first.
- **Granular UI:** Every UI surface must be composed of small, single-purpose components. Do not ship large monolithic page/view files—split layout, sections, forms, fields, and interactive pieces into dedicated components.
- **Loading Components:** Always include a loading state when async work can delay feedback (page/data load, form submit, button actions). Prefer dedicated reusable loading/skeleton components; wire `aria-busy` / polite status text where appropriate.

## 9. Code Quality & Formatting Enforcement

- **Functions & Components:** Keep functions under 50 lines and components/classes under 150 lines. Extract reusable hooks, sub-components, or helper functions into separate files when logic grows complex.
- **Early Returns:** Prefer early returns to eliminate deeply nested `if/else` blocks.
- **Defensive Defaults:** Use nullish coalescing (`??`) and optional chaining (`?.`) instead of logical OR (`||`) when evaluating potentially missing values.
- **pre-commit with ruff format + ruff check (required for Python):** Every Python project must install `pre-commit`, wire `.pre-commit-config.yaml` to `ruff format` and `ruff check`, and run `uv add --dev pre-commit && uv run pre-commit install`. Staged files are linted/formatted on commit—do not rely on manual `ruff check` alone.
- **Pre-Commit Rule:** Always run linting and code formatting tools via pre-commit on commit (`ruff` for Python; `./vendor/bin/pint` for PHP when present).
