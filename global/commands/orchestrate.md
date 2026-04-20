# Orchestrate: Full AI-Dev Workflow Automation

Run a feature through 5 phases — Explore, Plan, Build, Review, Ship — with TDD, code review, and PR creation. Input: a feature request string. Output: merged PR (codebase) or committed changes (text repo). Supports manual checkpoints or autonomous Ralph mode with state-file resumability. Trigger on "orchestrate", "run the full workflow", "build this feature end to end", or any feature request that needs structured multi-phase delivery.

---

## What This Does

The `/orchestrate` command takes a feature request and runs it through structured phases — brainstorming, planning, building, reviewing, and shipping. In manual mode it pauses for your approval between each phase. In Ralph mode it runs end-to-end autonomously, resuming from where it left off after context resets.

It works for both **codebases** (apps with tests, builds, branches) and **text repos** (markdown, config, documentation).

---

## Prerequisites

- These plugins installed:
  - superpowers (brainstorming, TDD, plans, verification)
  - pr-review-toolkit (code review)
  - commit-commands (git workflow)
- These agents available (via `~/.claude/agents/` or the repo's `.claude/agents/`):
  - `security-review` — invoked in Phase 3 for sensitive-scope diffs. Missing agent → warn and skip, never silently proceed.
  - `technical-writer` — invoked in Phase 4.
- `gh` CLI authenticated (needed for the CI gate in Ship)
- Git repository initialized
- **For Ralph mode:** `ralph-loop@claude-plugins-official` enabled in `~/.claude/settings.json`

---

## Repo Type Detection

Before starting, determine the repo type. This affects branching and git workflow throughout.

```dot
digraph repo_type {
    "Has package.json, Cargo.toml, go.mod, pyproject.toml, or Makefile with build/test targets?" [shape=diamond];
    "Codebase" [shape=box];
    "Text repo" [shape=box];

    "Has package.json, Cargo.toml, go.mod, pyproject.toml, or Makefile with build/test targets?" -> "Codebase" [label="yes"];
    "Has package.json, Cargo.toml, go.mod, pyproject.toml, or Makefile with build/test targets?" -> "Text repo" [label="no"];
}
```

**Codebase:** Has build tools, test runners, compiled output. Needs feature branches, PRs, test gates.

**Text repo:** Markdown, config, prompts, docs. Commits to main, no PR needed unless requested.

Store the result — every later phase checks it.

---

## Session Setup

### Step 1: Check for existing state

Look for `.claude/orchestrate.local.md` in the repo root.

If found:
> "Found in-progress `/orchestrate` session (Phase {N} — {phase name}). Resume where you left off? (y/n)"

- **Yes:** Load state, jump to the in-progress phase.
- **No:** Delete the state file, start fresh.

If not found, continue to Step 2.

### Step 2: Choose execution mode

> "Run autonomously (Ralph mode) or with approval checkpoints (manual)?"

- **Ralph:** Check that `ralph-loop@claude-plugins-official` is enabled in `~/.claude/settings.json`. If not, offer to enable it. Set mode to `ralph`.
- **Manual:** Set mode to `manual`. All checkpoints active — identical to the original workflow.

**Sensitive-scope escalation.** Phase 0 runs a sensitive-scope detection on the brainstormed feature (see `references/orchestrate/phases.md` — Sensitive-Scope Criteria). When `sensitive_scope: true`, Ralph elevates to manual checkpoints for Plan, Build, and Review even if Ralph mode was chosen. Ship's CI gate behaviour is unchanged. The user can override with the `--trust-ralph-on-sensitive` flag (see Usage); the override is recorded in the PR trailer so reviewers can see it was a deliberate call.

### Step 3: Write state file

Create `.claude/orchestrate.local.md`:

```markdown
---
mode: ralph | manual
feature: "{feature description}"
repo_type: pending
branch: pending
plan_path: pending
phase: setup
sensitive_scope: pending  # set to true | false | overridden in Phase 0
started: {ISO timestamp}
completion_promise: ORCHESTRATE_COMPLETE
---

## Progress

| Phase | Status | Actor |
|-------|--------|-------|
| Explore | pending | — |
| Plan | pending | — |
| Branch | pending | — |
| Build | pending | — |
| Review | pending | — |
| Document | pending | — |
| Ship | pending | — |
```

**Actor values** — record per phase as it completes:
- `ralph` — phase ran autonomously without a human at a gate
- `manual` — phase paused at a manual gate and the user gave explicit approval
- `human-approved` — user intervened during the phase (e.g. rewrote plan, overrode a review finding)

Add `.claude/orchestrate.local.md` to `.gitignore` if not already there — this is local session state, not committed.

---

## Standards Discovery

Look for project standards in this order (use the first found):

1. `CONSTITUTION.md` in repo root
2. `CLAUDE.md` in repo root
3. `AGENTS.md` in repo root
4. Infer from existing code patterns and tooling

Reference whichever is found as "project standards" throughout.

---

## Phase Execution

Read `references/orchestrate/phases.md` for detailed phase instructions. Summary:

| Phase | Skill Used | Gate (Manual) | Gate (Ralph) |
|-------|-----------|---------------|--------------|
| **0: Explore** | `superpowers:brainstorming` | "Does this capture what you want?" | Auto-pick strongest approach |
| **1: Plan** | `superpowers:writing-plans` | "Review the plan. Ready to build?" | Auto-continue |
| **1.5: Branch** | `superpowers:using-git-worktrees` | *(none — auto)* | *(none — auto)* |
| **2: Build** | `superpowers:subagent-driven-development` | "Implementation complete. Ready for review?" | Auto-continue |
| **3: Review** | `pr-review-toolkit:review-pr` / `superpowers:requesting-code-review` + `security-review` agent (scope-gated) | "Review complete. Approve documentation?" | Auto-fix critical/high + all security Blockers |
| **4: Document** | `technical-writer` agent + `/wrap` | "Ready to ship?" | Auto-continue |
| **Ship** | `superpowers:finishing-a-development-branch` + CI gate (`gh pr checks`) | Present all options; CI must be green | Auto-create PR; wait for CI green before `ORCHESTRATE_COMPLETE` |

Each phase updates the state file on entry (`in-progress`) and exit (`done`).

---

## User Interaction Points

**Manual mode** — you pause for approval at these checkpoints:

1. After brainstorming: "Does this capture what you want?"
2. After planning: "Review the plan. Ready to build?"
3. After building: "Implementation complete. Ready for review?"
4. After review: "Review complete. Approve documentation?"
5. After documentation: "Ready to ship?"

Between checkpoints, work autonomously. Only pause for approval, not micro-decisions.

**Ralph mode** — no checkpoints. Work autonomously from start to finish. The state file provides continuity across context resets.

---

## Ralph Loop Integration

### How it works

When Ralph mode is active:
- The state file persists across context resets
- Each new iteration reads the state file first
- Completed phases are skipped — jump to the first `in-progress` or `pending` phase
- The plan file, branch name, and repo type are all in the state file, so no context is lost
- `<promise>ORCHESTRATE_COMPLETE</promise>` is output only when Ship is done

### Safety

- Failed phases are not retried infinitely — if a phase fails twice, stop and report
- The state file is written to `.gitignore` — it's local session state, not committed
- Context pressure checks during Build phase prevent working with degraded context

---

## Usage

```
/orchestrate "Build user authentication with email and OAuth"
```

### Flags

- `--trust-ralph-on-sensitive` — skip the auto-escalation from Ralph to manual checkpoints when sensitive-scope is detected. Use only when you've read the feature and agree Ralph is appropriate. The override is recorded in the PR trailer for reviewer visibility.

For full example runs (manual + Ralph mode), see `references/orchestrate/examples.md`.

---

## Key Principles

1. **Mode is a per-invocation choice** — Ralph or manual, chosen at the start, not auto-detected
2. **State-driven resumability** — State file enables multi-session work with or without Ralph
3. **Repo-type aware** — Codebases get branches + PRs; text repos commit to main
4. **Plugin-powered** — Each phase delegates to the best available plugin/skill
5. **Quality gates** — Review phase runs specialized checks, verification proves claims
6. **Learning capture** — Every session improves future orchestration via /wrap
7. **Security is scope-gated, not optional** — Diffs touching auth, APIs, RLS, env vars, MCP/skills/agents trigger the `security-review` agent. Missing agent → warn and skip, never silently proceed.
8. **Shipping waits for CI** — Ralph cannot declare completion while PR checks are pending or red.
