# 0002 — Superpowers as baseline planning tool

**Status:** Accepted

## Context

Before this decision, planning practices varied across sessions and team members. When sessions skipped planning, they went long, took wrong turns, and produced code that needed rework. There was no shared vocabulary for "write a plan", "execute against a plan", or "review what was done."

The Superpowers plugin provides skills for exactly this: `writing-plans`, `executing-plans`, `subagent-driven-development`, `requesting-code-review`, and others. It was already installed across the team.

## Decision

Superpowers is the team's default scaffolding for planning and executing non-trivial Claude Code work:

- Non-trivial tasks (>~30 min of coding) get a plan doc via `superpowers:writing-plans` before implementation starts.
- Implementation runs via `superpowers:executing-plans` or `superpowers:subagent-driven-development`.
- Significant changes get a review pass via `superpowers:requesting-code-review` before merging.

"Non-trivial" is a judgment call. When in doubt, write the plan.

## Consequences

- Easier: consistent planning vocabulary, better session outcomes, plans as durable artefacts in the repo.
- Harder: overhead per task for quick fixes that don't warrant a plan doc. Watch for over-planning.
- Watch for: treating the skill invocation as ceremony. The plan is the point, not the skill.
