# UI & Accessibility (WCAG 2.1 AA)

- **Mobile-First:** Design and implement layouts for the smallest viewport first, then layer enhancements with `sm:`, `md:`, `lg:` (and up). Never start from desktop and scale down.
- **Granular UI:** All UIs must be granular—small, reusable, single-responsibility components. Avoid monolithic pages; compose views from focused pieces.
- **Loading States:** Whenever async work can leave the user waiting (data fetch, submit, navigation, mutation), provide an explicit loading UI (skeleton, spinner, or button pending state). Never leave interactive flows without feedback.
- **No Native HTML Validation:** Forms use `noValidate`. Validate with Zod and show custom, accessible error messages—never browser tooltips or constraint validation. React apps must use **react-hook-form** for form state.
- Use semantic HTML (`<main>`, `<nav>`, `<button>`).
- Interactive elements must support full keyboard navigation and focus rings.
- Utility-first CSS using Tailwind. No raw inline styles.
