# 0001 — Sub-agent model defaults

**Status:** Accepted

## Context

The team shares a Max plan. Most Claude Code sessions spawn sub-agents for research, file ops, and mechanical transforms. Inconsistent model selection means inconsistent cost, and nobody was thinking about it explicitly.

Available models: Opus (highest capability, highest cost), Sonnet (strong general-purpose, mid cost), Haiku (fast, cheap, mechanical tasks). The `advisor` tool provides an escalation path to Opus without running the whole session on Opus.

## Decision

- **Default: Sonnet.** Unless there's a reason to go up or down.
- **Opus for complex reasoning.** Architectural decisions, nuanced code review, multi-step problem solving where quality matters more than cost.
- **Haiku for mechanical work.** Repetitive transforms, simple lookups, formatting tasks.
- **Advisor pattern.** Run on Sonnet; call the advisor tool when hitting a genuinely hard decision. Costs roughly one Opus call instead of running the whole session on Opus.

## Consequences

- Easier: cost predictability, shared vocabulary for model selection decisions.
- Harder: some judgment calls about what counts as "complex reasoning." When in doubt, try Sonnet and escalate.
- Neutral: individual sessions can override this default — the ADR sets expectations, not hard limits.
