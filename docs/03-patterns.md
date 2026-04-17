# Patterns

Living library of how the Optimi team uses Claude Code effectively. These aren't rules — they're patterns that have worked. Add yours when you find something that reliably makes things go better.

---

## Landscape context before code

Before starting non-trivial work, build a mental topo map: what systems does this repo talk to, what's load-bearing, what decisions are already locked in. Read CLAUDE.md files up the directory tree. Check the project's Notion context if it exists.

The cost of skipping this is Claude confidently making changes that break assumptions nobody mentioned. The cost of doing it is 5–10 minutes. Worth it every time.

The `landscape-context` skill formalises this — it reads CLAUDE.md files, index files, learnings, and Notion context to build a topo map before non-trivial work.

---

## Plan → implement → review

For anything expected to take more than ~30 minutes of coding: write a plan first, get alignment, then implement. The superpowers plugin backs this up with `writing-plans`, `executing-plans`, and `subagent-driven-development` skills.

Skipping planning on small tasks is fine. Skipping it on multi-system changes is where sessions go wrong and quota gets burned.

---

## Sub-agent orchestration

Break work into sub-agents when tasks are genuinely independent and can be parallelised. Don't orchestrate just because you can — each sub-agent spawn has cost and overhead.

Good candidates: parallel file analysis, independent feature implementations, searching multiple repos simultaneously. Poor candidates: sequential steps where each depends on the last, or tasks where one agent's wrong assumption poisons another's input.

---

## Worktrees for experiments

When you're not sure the direction is right, do the work on a git worktree. `superpowers:using-git-worktrees` handles setup. If the experiment fails, delete the worktree — nothing is lost. If it succeeds, merge or cherry-pick.

The habit to build: before a speculative refactor or a "let me try this approach" session, reach for a worktree first.

---

## Advisor pattern

Run your session on Sonnet. When you hit a genuinely hard decision — architecture, non-obvious tradeoffs, multi-step reasoning — call the `advisor` tool. It routes to Opus and sends your full context. You get expert input on the hard part without paying Opus rates for the whole session.

Make your deliverable durable before calling advisor (write the file, save the result). The call takes time; if the session ends mid-call, a written result persists.

---

## Contributing

Open a PR or drop a note in Slack. If a pattern is team-agreed, it gets a doc. If it's still being tested, note that. If it's just yours, it goes in your `personal/` folder.
