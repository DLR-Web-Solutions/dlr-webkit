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
| **Maintenance**   | `chore/`              | `chore/update-ruff-config`   | Build tools, dependencies, or config changes |

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

## 3. Pre-Commit Hooks (pre-commit)

Python projects **must** use **pre-commit** so only staged files are checked/fixed before each commit.

1. Install as devDependencies: `pre-commit`.
2. Enable pre-commit (`uv add --dev pre-commit && uv run pre-commit install`).
3. `.pre-commit-config.yaml` must include ruff hooks:

```yaml
repos:
  - repo: https://github.com/astral-sh/ruff-pre-commit
    rev: v0.1.6
    hooks:
      - id: ruff-format
      - id: ruff
```

Agents scaffolding a new app must set this up; never skip hooks with `--no-verify` unless the user explicitly requests it.

---

## 4. AI Agent Git Execution Rules

- Before creating a new branch or executing `git checkout -b`, verify the branch name against these guidelines.
- When generating commit messages or committing code autonomously, strictly use the Conventional Commits format above.
- **Author (this project):** Commits must be authored as `Joshua <dev.joshuadolor@gmail.com>`. Repo-local `user.name` / `user.email` are set for that. If committing in an environment that ignores local git config, pass explicit author flags:

```sh
git commit --author="Joshua <dev.joshuadolor@gmail.com>" -m "$(cat <<'EOF'
type(scope): summary

EOF
)"
```

- Push does not change authorship; ensure every commit on the branch already uses that author before `git push`.
- Never change global git config. Never use `--no-verify` unless the user explicitly requests it.
