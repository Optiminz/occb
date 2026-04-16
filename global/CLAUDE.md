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
