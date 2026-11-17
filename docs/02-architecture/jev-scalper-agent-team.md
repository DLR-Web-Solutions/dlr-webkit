# JEV scalper development team

This document defines a reviewable AI-assisted workflow for the isolated `services/jev-futures-scalper/` service.

## Roles

- **Lead / human owner:** decomposes tasks, integrates changes, resolves conflicting findings, and approves releases.
- **Quant research:** evaluates hypotheses and backtest methodology, with all trading costs represented.
- **Exchange/data engineer:** owns public/demo market-data correctness, timestamps, freshness, reconnects, and schema validation.
- **Risk/security reviewer:** independently challenges risk controls, failure handling, secret handling, and network exposure.
- **QA/release engineer:** owns test coverage, repeatable verification, and final diff review.

Role prompts are stored in `.claude/agents/`; the reusable workflow is `.claude/skills/scalper-dev-team/SKILL.md`.

## Claude Code Agent Teams

Claude Code Agent Teams is an experimental feature and may require enabling in the installed Claude Code version. Consult the official documentation for current setup and limitations:
https://code.claude.com/docs/en/agent-teams

If the feature is available, start Claude Code from the repository root with the feature flag enabled in that terminal session:

```bash
CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 claude
```

Then ask the lead to use the `scalper-dev-team` workflow and delegate independent workstreams. Check current official docs before using configuration flags or controls; do not assume this setting is supported by every version.

Agent Teams uses additional model sessions and can increase token use and cost. Begin with a small team (2–4 teammates), particularly for review or parallel research. Do not let agents deploy, merge, access secrets, or enable live trading.

## Non-negotiable release boundary

The service remains read-only and paper-only. A passing test suite is not evidence of profitability or exchange eligibility. Human review is required before merge, deployment, or any change to the execution boundary.
