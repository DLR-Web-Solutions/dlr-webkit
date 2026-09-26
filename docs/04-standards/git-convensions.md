# Git Conventions & Version Control Standards

## 1. Branch Naming Strategy

All branch names must be lowercase, kebab-case, and prefixed with an explicit category:

| Category          | Prefix                | Example                        | Description                                  |
| :---------------- | :-------------------- | :----------------------------- | :------------------------------------------- |
| **Feature**       | `feature/` or `feat/` | `feature/user-authentication`  | New product capability or feature            |
| **Bug Fix**       | `fix/` or `bugfix/`   | `fix/adapter-null-handling`    | Fixing a bug in existing code                |
| **Hotfix**        | `hotfix/`             | `hotfix/login-session-crash`   | Urgent production fix                        |
| **Refactor**      | `refactor/`           | `refactor/user-service-logic`  | Code restucturing without behavior change    |
| **Documentation** | `docs/`               | `docs/update-architecture-map` | Documentation or guide updates               |
| **Maintenance**   | `chore/`              | `chore/update-eslint-config`   | Build tools, dependencies, or config changes |

---

## 2. Commit Message Structure (Conventional Commits)

Commit messages must strictly follow the format:

```text
<type>(<scope>): <short summary in imperative mood>

[optional body]
```

### Commit Types

- `feat`: A new feature for the user or app.
- `fix`: A bug fix.
- `docs`: Documentation changes only.
- `style`: Formatting, semicolons, missing whitespace (no code change).
- `refactor`: Refactoring production code (e.g. renaming variables, extracting functions).
- `perf`: Code change that improves performance.
- `test`: Adding or updating tests.
- `chore`: Updating build tasks, package manager configs, Docker files, etc.

### Rules & Formatting Constraints

1. **Imperative Mood:** Use "add", "fix", "change", NOT "added", "fixed", "changed".
2. **Case & Punctuation:** Subject line must be lowercase, under 72 characters, and contain **no period** at the end.
3. **Scope:** Always specify the affected area in parentheses when applicable (e.g., `auth`, `docker`, `user-adapter`, `api`).

### Correct Examples

```text
feat(auth): add Sanctum token authentication service
fix(adapter): resolve null fallback in User entity constructor
docs(git): define branch naming and commit rules
chore(docker): map APP_PORT dynamic variable in docker-compose
refactor(users): extract full name formatting into User entity getter
```

---

## 3. AI Agent Git Execution Rules

- Before creating a new branch or executing `git checkout -b`, verify the branch name against these guidelines.
- When generating commit messages or committing code autonomously, strictly use the Conventional Commits format above.
