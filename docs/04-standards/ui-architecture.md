# UI Architecture

Product UI has one implementation of each visual decision. Tokens define the theme. Primitives consume the tokens. Pages compose the primitives. The kitchen sink renders those same primitives, so a change to a primitive shows up on the sink and on every page.

A project built from this kit shipped the opposite: a public kitchen sink of hand-rolled markup (hundreds of lines, hard-coded hex, no shared imports) while `components/ui` sat unused and pages styled themselves with raw Tailwind. Restyling the sink changed nothing else. Follow this document so that split cannot happen.

Accessibility, focus, and forms stay in `docs/04-standards/ui-accessibility.md`. This file is the structure.

## 1. Tokens — one file

Colors, type, radii, shadows, and motion are defined once, as CSS variables and the Tailwind theme:

- Tailwind v4: `@theme` in one CSS file, e.g. `src/client/styles/theme.css`
- Tailwind v3: `theme.extend` in `tailwind.config.ts`, still backed by those CSS variables

Pages and feature components use the semantic utilities that read the theme (`bg-surface`, `text-muted`, `text-destructive`, `rounded-md`, `shadow-sm`).

Raw hex, `rgb()` / `hsl()`, and default-palette utilities (`bg-[#…]`, `text-slate-500`, `bg-emerald-100`, `bg-white`, `text-black`) stay out of pages, feature components, and the kitchen sink. Literals live in the token file. Shadcn or Radix variables, when you use them, **are** that file — extend them; do not start a second palette.

## 2. Primitives — one folder

Shared controls live in `src/client/components/ui/` (one primitive per file; adjust the surface name if the client is not `client`):

| Primitive        | Role                                                    |
| :--------------- | :------------------------------------------------------ |
| Button           | Actions, including disabled and loading                 |
| Chip / Badge     | Status and tags; takes a `tone` from the closed palette |
| Card             | Surface container                                       |
| Input / Select   | Text and choice fields                                  |
| Tabs / Segmented | In-page switches                                        |
| PageHeader       | Page title block (display face)                         |
| SectionHeader    | Section title and micro-label                           |
| EmptyState       | Empty and zero-data                                     |
| Table            | Tabular data                                            |
| Avatar           | Person or entity mark                                   |
| Stat             | Single metric                                           |
| Sheet / Drawer   | Side panel                                              |
| Menu             | Actions menu                                            |

Pages pass props (`variant`, `tone`, `size`, `loading`). They do not restyle a primitive with a new `className` string, and they do not rebuild it with raw utilities. Layout that is specific to one screen can live next to that screen; the controls inside it still come from this folder.

If a screen needs a look the primitive cannot express, change the primitive, update its sink section, then use it.

Micro-labels (`uppercase`, wide tracking, very small type) belong on `SectionHeader` or `Chip`, once. Pages do not repeat that treatment.

## 3. Kitchen sink renders the primitives

Route: `/kitchen-sink` (or `/dev/kitchen-sink`). Skill: `.cursor/skills/ui-kitchen-sink/SKILL.md` (Claude Code: `.claude/skills/ui-kitchen-sink/SKILL.md`).

- The page **imports** the primitives and renders them. A local copy of Button, Card, Table, or Badge does not count, however close the markup looks.
- One section per primitive: the variants and the states the product uses (default, focus, disabled, loading, error, empty).
- Each section includes a narrow column about **390px** wide that renders the same primitive, so the mobile layout is visible next to the full-width sample.
- The tokens section swatches the theme variables. It is not a second, hard-coded palette.
- Changing a primitive’s styles changes the sink and every page that imports it, with no further edits to those pages.

Record the path and route in `docs/00-context/project.md`.

## 4. Fonts

Load every weight the UI uses, or load a variable font whose `font-weight` range covers them (`100 900`, or a Google Fonts axis such as `wght@100..900`). Requesting `font-medium` or `font-semibold` from a face that only shipped 400 makes the browser faux-bold.

Register families as theme tokens and use the utilities those tokens generate:

```css
/* Tailwind v4 — src/client/styles/theme.css */
@theme {
    --font-display: 'Source Serif 4', Georgia, serif;
    --font-body: 'Source Sans 3', ui-sans-serif, system-ui, sans-serif;
}
```

```html
<h1 class="font-display">…</h1>
<p class="font-body">…</p>
```

`font-[var(--font-display)]` is the wrong tool. Tailwind’s arbitrary `font-[…]` sets **font-weight**, so that class compiles to `font-weight: var(--font-display)` and the family never changes. Use `font-display` / `font-body`. An arbitrary family, only until a token exists, needs an explicit hint: `font-[family-name:var(--font-display)]` (v3) or `font-(family-name:--font-display)` (v4). Then add the token and delete the arbitrary class.

Display face: page titles and section titles (`PageHeader`, `SectionHeader`). Body face: everything else — copy, tables, buttons, inputs, badges, meta. Pages do not pick a family of their own.

## 5. Domain color lives on the entity

Status, stage, and similar tones come from a **closed palette** defined next to the tokens (`neutral`, `info`, `success`, `warning`, `danger` — names mapped to theme colors).

Store the key on the record. Look up the tone from that key. Taking the color from the row’s index (`tones[index % tones.length]`) repaints the entity when the list is sorted or filtered.

```ts
export const stageTone = {
    new: 'info',
    screen: 'warning',
    offer: 'success',
    declined: 'danger',
} as const;

export type Stage = keyof typeof stageTone;

// candidate.stage is a Stage. Unknown keys render `neutral`.
// <Badge tone={stageTone[candidate.stage] ?? 'neutral'} />
```

The API does not send a raw hex for the badge to paint. An unknown key renders `neutral`.

## 6. Guardrails

Add a `lint:ui` check (grep or ESLint) that fails on:

- raw hex (`#rgb`, `#rrggbb`, `#rrggbbaa`) in pages and components outside the token file and `components/ui/` — keep literals in the token file; the primitive folder is the only other exempt path
- tiny arbitrary text sizes anywhere in the client, including primitives and the sink (`text-[10px]`, `text-[11px]`, `text-[12px]`, `text-[0.7rem]`, and anything under the type scale)
- off-palette color utilities anywhere in the client (`text-slate-*`, `bg-emerald-*`, `border-zinc-*`, `bg-white`, `text-black`, and the rest of the default palette)
- `font-[var(` anywhere in the client (font-weight mistaken for a family)

Run it in CI next to the app’s lint step. The script below is an example to copy into an application as `bin/lint-ui.sh`. It is not a kit script; register it in that app’s `docs/04-standards/automation.md` and `package.json` (`"lint:ui": "bash bin/lint-ui.sh"`) when you copy it. If the theme file is not under `src/client/styles/`, set `UI_LINT_TOKENS` to that directory. Set `UI_LINT_SRC` when the client surface has another name.

```bash
#!/usr/bin/env bash
# Example lint:ui. Copy to bin/lint-ui.sh in the app. Not wired in the kit.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="${UI_LINT_SRC:-$ROOT/src/client}"
TOKEN_DIR="${UI_LINT_TOKENS:-$SRC/styles}"
UI_DIR="${UI_LINT_UI:-$SRC/components/ui}"

if [[ ! -d "$SRC" ]]; then
    echo "lint:ui: $SRC does not exist; skip"
    exit 0
fi

fail=0

list_files() {
    # $1 = 1 → also skip components/ui (hex is allowed there and in tokens)
    local skip_ui="$1"
    find "$SRC" -type f \
        \( -name '*.tsx' -o -name '*.ts' -o -name '*.jsx' -o -name '*.js' -o -name '*.vue' -o -name '*.css' \) \
        ! -path '*/node_modules/*' \
        ! -path "$TOKEN_DIR/*" |
        while IFS= read -r file; do
            if [[ "$skip_ui" == 1 && "$file" == "$UI_DIR"/* ]]; then
                continue
            fi
            printf '%s\n' "$file"
        done
}

report() {
    local label="$1"
    local hits="$2"
    if [[ -n "$hits" ]]; then
        printf 'lint:ui: %s\n%s\n' "$label" "$hits"
        fail=1
    fi
}

hex_files=()
while IFS= read -r file; do
    hex_files+=("$file")
done < <(list_files 1)

all_files=()
while IFS= read -r file; do
    all_files+=("$file")
done < <(list_files 0)

if ((${#hex_files[@]})); then
    report "raw hex outside styles/ and components/ui/" \
        "$(grep -nE '#[0-9A-Fa-f]{3,8}\b' "${hex_files[@]}" || true)"
fi

if ((${#all_files[@]})); then
    report "arbitrary text size below the type scale" \
        "$(grep -nE 'text-\[([0-9]|1[0-2])(\.[0-9]+)?px\]|text-\[0\.([0-6][0-9]*|7([0-5][0-9]*)?)rem\]' "${all_files[@]}" || true)"
    report "off-palette color utility" \
        "$(grep -nE '\b(text|bg|border|ring|fill|stroke|from|to|via|outline|decoration|divide|placeholder)-(slate|gray|zinc|neutral|stone|red|orange|amber|yellow|lime|green|emerald|teal|cyan|sky|blue|indigo|violet|purple|fuchsia|pink|rose)-(50|100|200|300|400|500|600|700|800|900|950)\b|\b(text|bg|border|ring|fill|stroke)-(white|black)\b' "${all_files[@]}" || true)"
    report "font-[var( sets font-weight, not font-family" \
        "$(grep -nE 'font-\[var\(' "${all_files[@]}" || true)"
fi

exit "$fail"
```

On every UI pull request, answer this before merge:

- [ ] Did you change a primitive instead of restyling in the page?

And confirm the sink still imports that primitive, including its variants, states, and the ~390px preview.

## 7. Agents applying a design

When asked to apply, restyle, or “match” a design:

1. Change tokens first (the one theme file).
2. Change primitives second (`src/client/components/ui/`).
3. Open the kitchen sink and confirm each section imports and renders the real primitive — variants, states, and the ~390px preview. A sink that only contains local markup is not done.
4. Migrate pages that still use raw utilities onto those primitives.
5. Stop. Restyling the kitchen sink alone leaves the product on the old styles.

Order of work: tokens → primitives → sink (as a render of the primitives) → pages.
