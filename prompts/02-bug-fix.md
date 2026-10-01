I encountered this error:

[PASTE ERROR / STACK TRACE]

Follow: UNDERSTAND → INSPECT → PLAN → IMPLEMENT → TEST → VERIFY → REVIEW.

1. Analyze likely root causes (do not guess wildly—inspect evidence).
2. Search relevant files under `src/` and related tests.
3. Fix with the smallest safe change; do not break existing types or weaken security.
4. Add/adjust a regression test when the bug is non-trivial.
5. Run `bin/verify` before claiming the fix is complete.
