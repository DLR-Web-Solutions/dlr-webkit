---
name: ui-kitchen-sink
description: >-
    Creates and maintains a UI kitchen sink page as the visual source of truth for
    app components, tokens, and states. Use when initializing a project, starting
    UI work, adding or changing shared components, or when the user mentions
    kitchen sink, design system, UI reference, or look-and-feel consistency.
---

# UI Kitchen Sink

> Keep in sync with `.claude/skills/ui-kitchen-sink/SKILL.md` (Claude Code). Cursor discovers this copy under `.cursor/skills/`.

Before shipping product UI, establish a **kitchen sink** page that renders every shared UI primitive. Agents and humans use it as the single visual reference so the app keeps one look.

Structural rules (tokens, the primitive folder, fonts, domain color, `lint:ui`): `docs/04-standards/ui-architecture.md`. This skill keeps the sink honest.

Do **not** auto-launch UI/UX designer agents. Follow these instructions only.

## When this applies

| Trigger                                        | Required action                                                                   |
| :--------------------------------------------- | :-------------------------------------------------------------------------------- |
| Project init (`/init` or first UI scaffolding) | Create the kitchen sink **before** product screens                                |
| New UI feature and no kitchen sink exists      | Create it first, then build the feature from those primitives                     |
| New shared component / variant / state         | Add (or update) it on the kitchen sink in the same change                         |
| Styling a screen or applying a design          | Change tokens and primitives first, then pages. A sink-only restyle is incomplete |

## Workflow

```
LOCATE → CREATE/UPDATE → COMPOSE → EXTEND → VERIFY
```

1. **LOCATE** — Find an existing kitchen sink (`**/kitchen-sink/**`, route `/kitchen-sink` or `/dev/kitchen-sink`, docs mentioning it).
2. **CREATE/UPDATE** — If missing, create it before product UI. If present, extend it when adding primitives.
3. **COMPOSE** — Import `src/client/components/ui` primitives into the sink and into product screens. Copying their class strings, or rebuilding a control as local markup, does not count.
4. **EXTEND** — A new shared control is a primitive first. Add its sink section in the same change, then use it in product views.
5. **VERIFY** — Each section imports the real primitive and shows variants, states, and a ~390px preview. Editing the primitive changes the sink and the pages that use it.

## Default location

Prefer one of (match the app’s router):

- `src/client/.../kitchen-sink/` with route `/kitchen-sink`
- Or `/dev/kitchen-sink` if the team wants it clearly non-product

Document the path/route in `docs/00-context/project.md` when created.

Gate behind auth or non-production only if the project already requires that—do not invent access control solely for this page.

## Required sections

Build mobile-first. Import primitives from `src/client/components/ui/` (Tailwind + Shadcn/Radix when that is the stack). One section per primitive, with its variants, its states, and a column about 390px wide rendering the same component. Hand-rolled markup that reimplements a primitive does not count.

Minimum catalog (the named primitives in `docs/04-standards/ui-architecture.md`: Button, Chip/Badge, Card, Input/Select, Tabs/Segmented, PageHeader, SectionHeader, EmptyState, Table, Avatar, Stat, Sheet/Drawer, Menu):

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

- Kitchen sink is the **look SSOT** because it renders the primitives. Product screens import those same components and tokens.
- Prefer granular, reusable components over page-local one-offs.
- Every interactive control needs keyboard access, focus rings, and loading/disabled states where async work exists.
- Forms: `noValidate`; Zod (+ react-hook-form in React); custom accessible errors—never native browser validation UI.
- Change the shared primitive, then let the sink and the pages pick it up. A page-level restyle of a control that already exists is a miss.
- Applying a design: edit the theme file, then the primitives, confirm the sink renders those primitives, then migrate pages. Restyling only the sink leaves every product screen on the old styles.

## Init checklist

When initializing or first scaffolding UI:

- [ ] Kitchen sink route + page exist
- [ ] Theme file exists; primitives live in `components/ui/` and the sink imports them
- [ ] Required sections present: one per in-scope primitive, with variants, states, and a ~390px preview
- [ ] Path/route noted in `docs/00-context/project.md`
- [ ] Product UI work starts only after the kitchen sink exists

## Feature checklist

Before implementing or finishing UI feature work:

- [ ] Kitchen sink located or created
- [ ] Did you change a primitive instead of restyling in the page?
- [ ] New primitives/variants/states reflected on the kitchen sink, which still imports the real component
- [ ] Feature UI imports those primitives (no divergent look-alikes, no raw hex or off-palette utilities)
- [ ] Loading and empty/error states match kitchen-sink patterns
