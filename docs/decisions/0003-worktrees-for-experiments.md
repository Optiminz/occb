# 0003 — Worktrees for speculative Claude Code work

**Status:** Accepted

## Context

Claude Code sessions can run a long time down an exploratory path before it becomes clear the direction is wrong. On the main working tree, this creates messy history, uncommitted changes, and sometimes partial edits that are hard to unpick.

Git worktrees let you check out a branch in a separate directory without disrupting the main tree. The `superpowers:using-git-worktrees` skill handles setup. The overhead is low; the safety gain is real.

## Decision

For speculative or exploratory Claude Code work — "let me try this approach", "I'm not sure if this refactor is right", "exploring the impact of this change" — do it on a git worktree.

The signal that a worktree is appropriate: you're about to start something you might want to throw away without it affecting your main working tree.

## Consequences

- Easier: abandon exploratory sessions cleanly, no main-tree pollution, safe to let Claude go further down a path.
- Harder: small overhead to set up; team needs to know the pattern exists.
- Cleanup: delete the worktree directory and branch when the experiment is done or merged.
