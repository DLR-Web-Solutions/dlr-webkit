I encountered this error:

[PASTE ERROR / STACK TRACE]

Follow: UNDERSTAND → INSPECT → PLAN → TEST (red) → IMPLEMENT (green) → REFACTOR → VERIFY → REVIEW.

1. Analyze likely root causes (do not guess wildly—inspect evidence).
2. Search relevant files under `src/` and related tests.
3. **TDD (mandatory):** write a failing regression test that reproduces the bug; confirm RED.
4. Fix with the smallest safe change (GREEN); do not break existing types or weaken security.
5. Refactor only with tests green.
6. Run `bin/verify` before claiming the fix is complete.
