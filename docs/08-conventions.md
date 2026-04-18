# Team conventions — depth

Short-form pointers to these live in `global/CLAUDE.md`. This file holds the detail.

## Planning

For any work expected to take more than ~30 minutes of coding:

1. Write a plan doc first using `superpowers:writing-plans`.
2. Get alignment before implementing.
3. Track execution with `superpowers:executing-plans` or `superpowers:subagent-driven-development`.

Skipping planning is fine for one-off scripts. Not fine for features that touch multiple systems.

## Worktrees for speculative work

If you're not sure the direction is right, do it on a git worktree. Use `superpowers:using-git-worktrees`. Cheap to throw away, zero risk to main.

Don't start exploratory refactors on the main working tree.

## Landscape context before code

Before editing, read the relevant CLAUDE.md files in the current repo and any parent repo. If you're about to make architectural decisions without a mental topo map of the system, stop and build one first.

The `landscape-context` skill handles this automatically — it reads CLAUDE.md files up the directory tree, checks learnings, and queries Notion for client context.

## Development workflow

1. Understand → Plan → Execute → Test → Commit
2. Run tests before commits, no `console.log` in production code
3. **Zero-warning baseline** — if lint, typecheck, build, or tests produce warnings, do not report "all pass." Either fix the warnings in-place (config tweak, inline disable for false positives) or create a GitHub issue to track cleanup. A nonzero warning count that gets hand-waved trains everyone to ignore tool output.

## Complexity signaling

Never provide time estimates. Instead signal complexity:

- 🟢 Straightforward — standard patterns, minimal decisions
- 🟡 Moderate — some design choices, multiple components
- 🔴 Complex — architectural decisions, many dependencies, unknowns

## Code style

- **Verbose naming** — `getUserAuthenticationToken()` over `getToken()`, `MAX_RETRY_ATTEMPTS` over `MAX_RETRIES`
- Use TODO/FIXME comments to mark tech debt

## Development environment

**Local development ports:**

- Avoid port 5000 — occupied by macOS AirPlay Receiver
- Check each project's `.env` for its configured `PORT`

## Session learnings

Before starting work, check `~/.claude/learnings/` (global: `patterns.md`, `mistakes.md`) and project `.claude/learnings/learnings.md` for past insights. Use `/wrap` at session end to capture new learnings, or `/reflect` for learnings-only (no commit/push).
