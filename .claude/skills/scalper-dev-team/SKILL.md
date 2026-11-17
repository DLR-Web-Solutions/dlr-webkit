---
name: scalper-dev-team
description: Coordinate a multi-agent development and review workflow for the read-only JEV futures scalper scaffold in DLR WebKit.
---

# Scalper development team workflow

Use this skill when planning or implementing substantial work in `services/jev-futures-scalper/`.

## Team shape

The lead/orchestrator remains responsible for task decomposition, integration, conflict resolution, and final reporting. When Claude Code Agent Teams is enabled, launch independent teammates for these workstreams:

1. **Quant research** — hypotheses, evaluation metrics, historical replay/backtest design, cost assumptions.
2. **Exchange/data engineering** — public or demo/testnet feed correctness, reconnects, timestamps, data freshness.
3. **Risk/security review** — independent review of risk limits, failure handling, secrets, and deployment exposure.
4. **QA/release** — tests, config validation, diff review, and reproducible verification.

Use the custom agents in `.claude/agents/` as role guidance. Assign separate files/workstreams to avoid concurrent edits to the same file. Prefer parallel read-only reviews first; consolidate findings before implementation.

## Mandatory workflow

1. Read `.cursorrules`, `docs/00-context/project.md`, and the scalper README.
2. Inspect current code and open PR state; write a small plan with file ownership and tests.
3. Ask quant and exchange/data teammates for independent research/review; ask risk/security to challenge assumptions; ask QA to identify missing tests.
4. The lead reconciles disagreements explicitly and chooses a minimal implementation plan.
5. Implement only after the plan is clear. Keep changes scoped to the scalper unless the user approves wider changes.
6. Run focused Python tests, Docker Compose validation/smoke checks if available, then `bun run verify` for repository-level verification.
7. Inspect the final diff and report exactly which checks ran. Do not claim success for checks not run.
8. Leave merge, deployment, and any live-trading capability to explicit human approval.

## Trading-system safety rules

- Paper/read-only mode remains mandatory.
- No exchange order placement, modification, or cancellation in this project phase.
- Never request or commit credentials; no withdrawal permissions.
- Public Spot data is not a Futures feed. Verify product and Spain/EEA account eligibility against official exchange sources.
- No strategy is considered promising without out-of-sample evaluation after fees, spread, slippage, funding, latency, and minimum order constraints.
- AI research is advisory only. Deterministic code owns validation and risk gates.
- For account capital under €250, treat trading costs and venue minimums as first-order constraints; make no profitability claims.
