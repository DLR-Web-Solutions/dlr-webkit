# DLR WebKit

**AI-native development overlay** for solo senior developers. It layers documentation, agent instructions, quality tooling, and conventions onto a new or existing project so humans and coding agents share one playbook.

## What it is

- A reusable **kit** (rules, docs, prompts, scripts, CI defaults)
- Optimized for **Bun**-based JS/TS apps (Laravel/PHP patterns documented where relevant)
- An agent operating system: inspect → implement → test → `verify`

## What it is not

- Not a finished product application
- Not a microservice / K8s / “enterprise platform” scaffold
- Not a substitute for filling `docs/00-context/project.md` for your app

Application code belongs under `src/<surface>/` (e.g. `src/client`, `src/server`) after you scaffold or overlay.

## Quick start

### Overlay into a parent project

Nest this kit inside a project folder, then:

```bash
bash bin/install.sh
# Non-interactive:
# DLR_APP_NAME=MyApp DLR_REMOVE_DEVKIT=0 bash bin/install.sh
```

Existing target files are **preserved** by default (`DLR_FORCE_OVERWRITE=1` to replace).

### Name placeholders

```bash
bash bin/init.sh "My App"
# or: DLR_APP_NAME="My App" bash bin/init.sh
```

### AI discovery (`/init`)

Ask an agent to run `/init` — it follows `prompts/00-init-project.md` and fills product/architecture context (including `docs/00-context/project.md`).

### Day-to-day

```bash
bun install
bun run doctor   # → bash bin/doctor.sh
bun run verify   # → bash bin/verify.sh (format, lint, typecheck, tests, audit)
```

A change is not done until `bun run verify` passes.

## Layout

```
src/                 # App surfaces (client, server, …)
docs/                # Product, architecture, standards (agent context)
docs/00-context/     # Canonical project facts for agents
prompts/             # /init, feature, bug-fix prompts
bin/                 # install, init, doctor, verify
.cursorrules         # Agent coding-rule SSOT
CLAUDE.md            # Short agent entry → .cursorrules + context
```

## Agent hierarchy

1. `docs/00-context/project.md` — what this app is
2. `.cursorrules` — how to work
3. `docs/04-standards/` — detailed standards
4. `prompts/` — task playbooks

Workflow: `UNDERSTAND → INSPECT → PLAN → IMPLEMENT → TEST → VERIFY → REVIEW → DOCUMENT`

## Versions

Prefer lockfile / declared versions. Upgrade deliberately with compatibility checks; never instruct `@latest`.
