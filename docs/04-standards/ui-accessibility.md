# UI & Accessibility (WCAG 2.1 AA)

- **Kitchen Sink (required):** Before product UI—at project init **or** when starting UI work with no kitchen sink yet—create a kitchen sink page (`/kitchen-sink` or `/dev/kitchen-sink`) that catalogs shared tokens and components (typography, buttons, forms, loading, feedback, navigation, overlays as used). Treat it as the visual SSOT: extend it when adding primitives; compose product screens from those same pieces. Skill: `.cursor/skills/ui-kitchen-sink/SKILL.md` (Cursor) / `.claude/skills/ui-kitchen-sink/SKILL.md` (Claude Code).
- **Mobile-First:** Design and implement layouts for the smallest viewport first, then layer enhancements with `sm:`, `md:`, `lg:` (and up). Never start from desktop and scale down.
- **Granular UI:** All UIs must be granular—small, reusable, single-responsibility components. Avoid monolithic pages; compose views from focused pieces.
- **Loading States:** Whenever async work can leave the user waiting (data fetch, submit, navigation, mutation), provide an explicit loading UI (skeleton, spinner, or button pending state). Never leave interactive flows without feedback.
- **No Native HTML Validation:** Forms use `noValidate`. Validate with Zod and show custom, accessible error messages—never browser tooltips or constraint validation. React apps must use **react-hook-form** for form state.
- Use semantic HTML (`<main>`, `<nav>`, `<button>`).
- Interactive elements must support full keyboard navigation and focus rings.
- Utility-first CSS using Tailwind. No raw inline styles.
