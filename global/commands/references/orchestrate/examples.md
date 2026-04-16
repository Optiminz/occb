# Orchestrate — Example Runs

## Manual Mode (Codebase)

```
You: /orchestrate "Add a comments system to blog posts"

Claude (Setup):
  No existing session found.
  Run autonomously (Ralph mode) or with approval checkpoints (manual)?

You: manual

Claude (Phase 0 — Explore):
  Using superpowers:brainstorming...
  Explored requirements, proposed 3 approaches
  -> Does this capture what you want? [y/n]

You: y — go with threaded comments

Claude (Phase 1 — Plan):
  Using superpowers:writing-plans...
  Created plan at docs/plans/2026-04-01-comments-plan.md (12 tasks)
  -> Review the plan. Ready to build? [y/n]

You: y

Claude (Phase 1.5 — Branch):
  Detected codebase (package.json found)
  Using superpowers:using-git-worktrees...
  Created branch feat/threaded-comments in worktree

Claude (Phase 2 — Build):
  Using superpowers:subagent-driven-development...
  Task 1/12: Comment model + migration (tests passing) [committed]
  ...
  Task 12/12: Notification preferences (tests passing) [committed]
  -> Implementation complete. Ready for review? [y/n]

You: y

Claude (Phase 3 — Review):
  Pushed feat/threaded-comments to origin
  Using pr-review-toolkit:review-pr...
  6 specialized reviewers completed
  Found: 1 MEDIUM issue (missing rate limiting)
  -> Fix now? [y/n]

You: y
  Fixed + verified: all tests passing

Claude (Phase 4 — Document):
  Updated README, added API examples [committed]
  Session learnings captured via /wrap
  -> Ready to ship? [y/n]

You: y

Claude (Ship):
  Using superpowers:finishing-a-development-branch...
  -> Created PR #47: "feat: add threaded comments system"
```

## Ralph Mode (Codebase)

```
You: /orchestrate "Add a comments system to blog posts"

Claude (Setup):
  No existing session found.
  Run autonomously (Ralph mode) or with approval checkpoints (manual)?

You: ralph

Claude:
  Ralph Loop enabled. State file created. Running autonomously...

  [Phase 0 — Explore] Brainstorming... threaded comments is strongest fit
  [Phase 1 — Plan] Created plan: 12 tasks
  [Phase 1.5 — Branch] Created feat/threaded-comments
  [Phase 2 — Build] Task 1/12... 2/12... [context getting deep, saving state]

  --- context reset, Ralph re-feeds /orchestrate ---

Claude:
  Found in-progress session (Phase 2 — Build, task 7/12). Resuming...
  Task 7/12... 8/12... 12/12 done
  [Phase 3 — Review] 6 reviewers, 1 medium issue fixed
  [Phase 4 — Document] README updated, /wrap captured
  [Ship] Created PR #47: "feat: add threaded comments system"

  <promise>ORCHESTRATE_COMPLETE</promise>
```
