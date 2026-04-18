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

Good candidates: parallel file analysis, independent feature implementations, searching multiple repos simultaneously, audit tasks with multiple independent scopes (security + dead code + consistency running in parallel). Poor candidates: sequential steps where each depends on the last, or tasks where one agent's wrong assumption poisons another's input.

---

## Worktrees for experiments

When you're not sure the direction is right, do the work on a git worktree. `superpowers:using-git-worktrees` handles setup. If the experiment fails, delete the worktree — nothing is lost. If it succeeds, merge or cherry-pick.

The habit to build: before a speculative refactor or a "let me try this approach" session, reach for a worktree first.

---

## Advisor pattern

Run your session on Sonnet. When you hit a genuinely hard decision — architecture, non-obvious tradeoffs, multi-step reasoning — call the `advisor` tool. It routes to Opus and sends your full context. You get expert input on the hard part without paying Opus rates for the whole session.

Make your deliverable durable before calling advisor (write the file, save the result). The call takes time; if the session ends mid-call, a written result persists.

---

## Create GitHub issues before starting fixes

Before starting a multi-stream fix or refactor, create a GitHub issue per work stream. Reference the issue number in each commit (`Refs: Org/repo#123`, `Resolves #123`).

Creates a paper trail: issue → commit → close. Especially useful when work spans multiple sessions or multiple people need to see what's done vs. remaining. Sessions come and go; the issue tracker doesn't.

---

## Iterate manually before automating

When a manual process works well once, do it two or three more times before building automation. The edge cases and real shape only reveal themselves through repetition. Build the tool after you know exactly what it needs to do.

The opposite failure mode — "this worked once, let me skill-ify it" — bakes in assumptions from a single data point and wastes time refactoring the skill as real usage reveals what was actually needed.

---

## Two process shapes → two skills, not one parameterised skill

When a new process looks similar on the surface to an existing skill ("both are 'call prep'") but has **opposing success criteria**, resist the urge to parameterise with a `--type=X` switch. Build a separate skill.

The "portable" pieces are often the exact sections that would turn one process into the wrong shape of the other. Keep skills distinct; cross-link them in each skill's "when NOT to use" section.

**Signal:** you're adding a mode flag because the `--type=A` path and `--type=B` path share vocabulary but need opposite defaults. That's a second skill, not a flag.

---

## Agent files reference governance docs, not duplicate them

When converting personas/prompts to Claude subagent or skill files, the first instinct is to copy rules inline for "self-containedness." Resist it — inline copies drift independently, and within a few iterations you have N contradictory versions of the same rule.

**Pattern:** the agent says "Read [Doc] Section X.Y for [criteria/rules]" and trusts the subagent to actually read it. Reserve inline content for operational checklists unique to that agent's function.

---

## Lint rules as executable law for AI-generated code

Documented rules an agent must "read and choose to comply with" are insufficient. Linting rules that block non-compliant code at commit are the actual enforcement layer. **If a convention can be expressed as an ESLint rule or tsconfig flag, it should be.**

Phase-in strategy: start inherited strictness rules as `warn` (surfaces in editors, doesn't block commits), graduate to `error` once existing violations are cleared. Ships enforcement immediately without a giant cleanup blocker.

High-value TypeScript flag: `noUncheckedIndexedAccess: true` — AI agents assume `array[0]` is always defined. Forces a null check AI has zero intuition about.

---

## Generated files with markers > symlinks when combining sources

When a config tool combines two sources (personal + team baseline) into one target file, generate the output with a marker comment on line 1 (`<!-- occb-generated: do not edit -->`), don't symlink.

Markers enable idempotent detection (diff candidate output against existing, skip if identical), safe uninstall (`head -1 | grep marker` reliably identifies tool-managed files), and clean backup logic (only back up files that aren't already tool-generated).

Symlinks only work for one-to-one relationships. Generated files handle N-to-one naturally. occb's `install.sh` uses this exact pattern for `~/.claude/CLAUDE.md`.

---

## Installer preflight checks for rival sync channels

When a tool generates or symlinks files into a shared directory (`~/.claude/`, `~/.config/*`), a second sync mechanism (git repo, iCloud, Dropbox, rsync cron) tracking the same tree will silently corrupt the tool's output. The collision is invisible until a machine-boundary diff produces unresolved merge-conflict markers inside generated files.

Detect and warn at install time about: a `.git` directory inside the target (another repo claims ownership), unresolved conflict markers in generated files (`<<<<<<<`, `=======`, `>>>>>>>`), untracked shadow files at installer-owned paths.

occb's `install.sh` runs both checks as preflights. Low-effort, high-payoff guard.

---

## Contributing

Open a PR or drop a note in Slack. If a pattern is team-agreed, it gets a doc. If it's still being tested, note that. If it's just yours, it goes in your `occb-personal/claude/learnings/` folder.
