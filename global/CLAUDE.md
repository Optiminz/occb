# Optimi Claude Code — Team Baseline

Distributed via occb. Don't edit your local symlinked copy — edit the source at `~/Projects/occb/global/CLAUDE.md`, commit, and run `./update.sh` to propagate.

---

## Shared account discipline

The team shares a Max plan. Before spinning up orchestrated or long-running work:

- Check your status line for 5-hour and weekly usage buckets.
- If either bucket is above 70%, coordinate in Slack before starting.
- Avoid parallel orchestration runs without checking with the team first.

Burning the shared quota without checking is the equivalent of using all the milk and not telling anyone.

---

## Sub-agent defaults

When spawning sub-agents:

- **Default model: Sonnet.** It handles most work well.
- **Opus for complex reasoning only.** Architectural decisions, multi-step problem solving, nuanced code review. Not for search, file ops, or mechanical transforms.
- **Haiku for mechanical work.** Repetitive tasks, formatting, simple lookups.
- **Advisor pattern:** Run on Sonnet. When stuck or about to make a significant architectural call, consult Opus via the advisor tool. This costs roughly one Opus call instead of running the whole session on Opus.

When in doubt, start with Sonnet and escalate.

---

## Planning convention

For any work expected to take more than ~30 minutes of coding:

1. Write a plan doc first using `superpowers:writing-plans`.
2. Get alignment before implementing.
3. Track execution with `superpowers:executing-plans` or `superpowers:subagent-driven-development`.

Skipping planning is fine for one-off scripts. Not fine for features that touch multiple systems.

---

## Worktrees for speculative work

If you're not sure the direction is right, do it on a git worktree. Use `superpowers:using-git-worktrees`. Cheap to throw away, zero risk to main.

Don't start exploratory refactors on the main working tree.

---

## Landscape context before code

Before editing, read the relevant CLAUDE.md files in the current repo and any parent repo. If you're about to make architectural decisions without a mental topo map of the system, stop and build one first.

The `landscape-context` skill is designed for this — see `~/.claude/skills/landscape-context/`. It's WIP; contribute improvements.

---

## Cost discipline

- Don't use extended thinking unless the problem genuinely needs it.
- Prefer targeted searches (Grep, Glob) over broad agent exploration when the target is known.
- When parallelising sub-agents, check whether tasks are truly independent. Spawning 10 agents for 10 sequential steps wastes quota.

---

## Development workflows

1. Understand → Plan → Execute → Test → Commit
2. Run tests before commits, no `console.log` in production code
3. **Zero-warning baseline** — if lint, typecheck, build, or tests produce warnings, do not report "all pass." Either fix the warnings in-place (config tweak, inline disable for false positives) or create a GitHub issue to track cleanup. A nonzero warning count that gets hand-waved trains everyone to ignore tool output.

---

## Complexity signaling

Never provide time estimates. Instead signal complexity:
- 🟢 Straightforward — standard patterns, minimal decisions
- 🟡 Moderate — some design choices, multiple components
- 🔴 Complex — architectural decisions, many dependencies, unknowns

---

## Code style

- **Verbose naming** — `getUserAuthenticationToken()` over `getToken()`, `MAX_RETRY_ATTEMPTS` over `MAX_RETRIES`
- Use TODO/FIXME comments to mark tech debt

---

## Development environment

**Local development ports:**
- Avoid port 5000 — occupied by macOS AirPlay Receiver
- Check each project's `.env` for its configured `PORT`

---

## Session learnings

Before starting work, check `~/.claude/learnings/` (global: `patterns.md`, `mistakes.md`) and project `.claude/learnings/learnings.md` for past insights. Use `/wrap` at session end to capture new learnings, or `/reflect` for learnings-only (no commit/push).

---

## Preflight discipline

Every skill or command that writes, mutates, or runs long MUST have a completed `PREFLIGHT.md` before deployment.

### When to require it
- Any skill/command that writes to Notion, GitHub, file system, email, or external APIs
- Any skill/command that runs for more than a single turn (long-running, looping, or multi-step)
- Any skill/command that could produce side effects if run twice (non-idempotent operations)

### When it's optional
- Read-only skills (eg. analysis, search, reporting with no writes)
- One-shot formatting or content generation that stays in conversation

### What to check
1. **Blast radius** — what systems does it touch, read vs write, worst-case failure
2. **Failure mode** — crash recovery, state persistence, idempotency
3. **Token/runaway protection** — stopping conditions, budget caps, expected cost

### Enforcement
Before packaging a new skill or command, check: does `PREFLIGHT.md` exist in the skill directory? If not, and the skill writes or runs long, flag it:

> ⚠️ This skill has no PREFLIGHT.md. It touches [X systems] and [runs long / writes data]. Fill in the preflight check before deploying.

Do not block deployment — but always surface the warning.

---

## Notion reference map

Key Notion database URLs, data source IDs, and field mappings live in `~/.claude/notion-map.md` (distributed via occb).

**Always read this file before creating or updating any Notion entry** — it has the correct data source IDs, field names, and option values (e.g. "Linked In" not "LinkedIn") for all key databases. Personal/specialist databases may be in `~/.claude/notion-map-personal.md`.
