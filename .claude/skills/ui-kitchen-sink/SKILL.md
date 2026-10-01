---
name: ui-kitchen-sink
description: >-
    Creates and maintains a UI kitchen sink page as the visual source of truth for
    app components, tokens, and states. Use when initializing a project, starting
    UI work, adding or changing shared components, or when the user mentions
    kitchen sink, design system, UI reference, or look-and-feel consistency.
---

# UI Kitchen Sink

> Keep in sync with `.cursor/skills/ui-kitchen-sink/SKILL.md` (Cursor). Claude Code discovers this copy under `.claude/skills/`.

Before shipping product UI, establish a **kitchen sink** page that showcases every shared UI primitive. Agents and humans use it as the single visual reference so the app keeps one look.

Do **not** auto-launch UI/UX designer agents. Follow these instructions only.

## When this applies

| Trigger                                        | Required action                                                  |
| :--------------------------------------------- | :--------------------------------------------------------------- |
| Project init (`/init` or first UI scaffolding) | Create the kitchen sink **before** product screens               |
| New UI feature and no kitchen sink exists      | Create it first, then build the feature from those primitives    |
| New shared component / variant / state         | Add (or update) it on the kitchen sink in the same change        |
| Styling a screen                               | Reuse kitchen-sink primitives; do not invent one-off look-alikes |

## Workflow

```
LOCATE → CREATE/UPDATE → REFERENCE → EXTEND → VERIFY
```

1. **LOCATE** — Find an existing kitchen sink (`**/kitchen-sink/**`, route `/kitchen-sink` or `/dev/kitchen-sink`, docs mentioning it).
2. **CREATE/UPDATE** — If missing, create it before product UI. If present, extend it when adding primitives.
3. **REFERENCE** — Match spacing, typography, color, radius, motion, and control states to the kitchen sink.
4. **EXTEND** — New shared UI lands on the kitchen sink first (or same PR), then in product views.
5. **VERIFY** — Page renders; sections cover required primitives; no divergent one-offs in the feature.

## Default location

Prefer one of (match the app’s router):

- `src/client/.../kitchen-sink/` with route `/kitchen-sink`
- Or `/dev/kitchen-sink` if the team wants it clearly non-product

Document the path/route in `docs/00-context/project.md` when created.

Gate behind auth or non-production only if the project already requires that—do not invent access control solely for this page.

## Required sections

Build mobile-first. Compose from the app’s real shared components (Tailwind + Shadcn/Radix when that is the stack)—do not duplicate with dead markup.

Minimum catalog:

- **Tokens** — color, typography, spacing, radius, elevation (CSS variables / theme classes)
- **Typography** — headings, body, labels, helper/error text
- **Buttons** — variants, sizes, disabled, loading
- **Forms** — text, select, checkbox/radio, textarea; default, focus, error, disabled (`noValidate` + accessible errors)
- **Feedback** — alert/banner, empty state, toast trigger if used
- **Loading** — spinner, skeleton, button pending
- **Navigation** — links, tabs, or menu patterns the app uses
- **Overlays** — modal/dialog, drawer/sheet if used
- **Data display** — table or list row patterns if used

Skip sections only when that primitive is out of scope for the product. When a primitive is added later, add its kitchen-sink section in the same change.

## Rules of use

- Kitchen sink is the **look SSOT**. Product screens compose the same components and tokens.
- Prefer granular, reusable components over page-local one-offs.
- Every interactive control needs keyboard access, focus rings, and loading/disabled states where async work exists.
- Forms: `noValidate`; Zod (+ react-hook-form in React); custom accessible errors—never native browser validation UI.
- Do not restyle a shared primitive ad hoc on a feature page; change the shared component and refresh the kitchen sink.

## Init checklist

When initializing or first scaffolding UI:

- [ ] Kitchen sink route + page exist
- [ ] Required sections present for in-scope primitives
- [ ] Shared components live outside the page and are imported in
- [ ] Path/route noted in `docs/00-context/project.md`
- [ ] Product UI work starts only after the kitchen sink exists

## Feature checklist

Before implementing or finishing UI feature work:

- [ ] Kitchen sink located or created
- [ ] New primitives/variants/states reflected on the kitchen sink
- [ ] Feature UI reuses those primitives (no divergent look-alikes)
- [ ] Loading and empty/error states match kitchen-sink patterns
