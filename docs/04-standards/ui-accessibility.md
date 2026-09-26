# UI & Accessibility (WCAG 2.1 AA)

- **Mobile-First:** Design and implement layouts for the smallest viewport first, then layer enhancements with `sm:`, `md:`, `lg:` (and up). Never start from desktop and scale down.
- **No Native HTML Validation:** Forms use `noValidate`. Validate with Zod and show custom, accessible error messages—never browser tooltips or constraint validation.
- Use semantic HTML (`<main>`, `<nav>`, `<button>`).
- Interactive elements must support full keyboard navigation and focus rings.
- Utility-first CSS using Tailwind. No raw inline styles.
