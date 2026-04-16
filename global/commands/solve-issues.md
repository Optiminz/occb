# Solve Issues: GitHub Issue Orchestrator

Triage open GitHub issues, classify them by complexity, and progressively solve each one. Ralph Loop-compatible for autonomous multi-session execution.

---

## What This Does

`/solve-issues` pulls open issues from the current repo, classifies each by complexity, and solves them one by one — batching trivials, implementing standards directly, and running full plan cycles for complex ones. Issues that need human judgment are skipped and summarised at the end.

Works for the **current repo only**. Chains existing skills — this command is glue, not reimplementation.

---

## Prerequisites

- These plugins installed:
  - superpowers (plans, execution, verification, code review)
  - pr-review-toolkit (code review agents)
  - commit-commands (git workflow)
- `gh` CLI authenticated
- Git repository with remote configured

---

## Phase 0: Setup & Discovery

### Step 1: Check for existing state

Look for `.claude/solve-issues.local.md` in the repo root.

If found:
> "Found in-progress `/solve-issues` session ({N}/{total} issues done). Resume where you left off? (y/n)"

- **Yes:** Load state, skip completed issues, continue from first pending.
- **No:** Delete the state file, start fresh.

### Step 2: Choose execution mode

> "Run autonomously (Ralph mode) or with approval checkpoints (manual)?"

- **Ralph:** Check that `ralph-loop@claude-plugins-official` is enabled in `~/.claude/settings.json`. If not, offer to enable it. Set mode to `ralph`.
- **Manual:** Set mode to `manual`. Single-session with checkpoints.

### Step 3: Discover issues

Invoke the `gh-triage` skill in **triage mode**. This pulls open issues, prioritises them, and presents the landscape.

After triage completes, capture the prioritised issue list.

### Step 4: Write state file

Create `.claude/solve-issues.local.md`:

```markdown
---
mode: ralph | manual
completion_promise: ALL_ISSUES_RESOLVED
started: {ISO timestamp}
trivial_branch: fix/trivial-batch-{YYYY-MM-DD}
---

## Issues

| # | Title | Class | Status | Branch |
|---|-------|-------|--------|--------|
```

Populate with all open issues from triage. Status starts as `pending` for all. Class and Branch filled in during Phase 1.

Add `.claude/solve-issues.local.md` to `.gitignore` if not already there — this is local session state, not committed.

---

## Phase 1: Classification

For each issue in the state file, read the full issue (body, labels, comments) and classify:

### Classification rules

| Class | Criteria | Git Strategy |
|-------|----------|-------------|
| **trivial** | Label/typo fix, config change, one-file edit, documentation fix | Batched on `fix/trivial-batch-{date}` |
| **standard** | Bug fix, small feature, clear acceptance criteria, 2-5 files | Own branch: `fix/{issue-num}-{slug}` or `feat/{issue-num}-{slug}` |
| **complex** | Multi-file feature, architectural change, unclear scope, needs design | Own branch: `feat/{issue-num}-{slug}` |
| **needs-human** | Fails any needs-human signal (see below) | Skipped entirely |

### Needs-human detection signals

Classify as `needs-human` if **any** of these apply:

- **Labels:** `question`, `discussion`, `needs-decision`, `needs-human-input`
- **No clear acceptance criteria** — issue body is vague, has no concrete "done when..." or testable outcome
- **Touches sensitive areas** — auth, billing, payments, external API keys, destructive operations, data deletion
- **Asks for human opinion** — body contains phrases like "should we", "what do you think", "which approach", "thoughts?"
- **Architectural fork** — multiple valid approaches exist with no clear winner, and the issue doesn't specify a preference
- **External dependency** — requires information not available in the codebase (e.g., "check with the client", "waiting on API access")

Update the state file with classifications.

Present the classification summary:

```
📋 CLASSIFICATION

🟢 Trivial (batched): #12, #15, #18
🔵 Standard: #14 Input validation, #17 Fix rate limiter
🟣 Complex: #20 Refactor scoring pipeline
🚫 Needs human: #16 Auth redesign (ambiguous requirements)

Proceed? (y/n)
```

Wait for confirmation before solving.

---

## Phase 2: Solve Loop

Process issues in this order: **trivial batch → standard (by priority) → complex (by priority)**.

### Trivial Batch

1. Create branch `fix/trivial-batch-{YYYY-MM-DD}` from main
2. For each trivial issue:
   - Read the issue fully
   - Implement the fix directly
   - Run tests/lint if applicable
   - Commit with message: `fix: {description} (#{issue-num})`
   - Update state file: status → `done`
3. After all trivials are committed, checkpoint (see below)

### Standard Issues

For each standard issue:

1. Create branch `fix/{issue-num}-{slug}` or `feat/{issue-num}-{slug}` from main
2. Read the issue fully, understand acceptance criteria
3. Implement the fix/feature directly
4. Run tests — if tests exist for the area, ensure they pass. Add tests if the change is testable.
5. Invoke `superpowers:requesting-code-review` on the changes
6. Fix any critical/high issues from review
7. Commit with conventional commit message referencing the issue: `fix: {description} (#N)` or `feat: {description} (#N)`
8. Update state file: status → `done`
9. Checkpoint

### Complex Issues

For each complex issue:

1. Create branch `feat/{issue-num}-{slug}` from main
2. Read the issue fully
3. Invoke `superpowers:writing-plans` — create a lightweight implementation plan (no separate spec, just a plan)
4. Invoke `superpowers:executing-plans` — implement the plan task by task
5. Invoke `superpowers:requesting-code-review` on the changes
6. Fix any critical/high issues from review
7. Commit with conventional commit message referencing the issue
8. Update state file: status → `done`
9. Checkpoint

### Checkpoint (after each issue or batch)

```
✅ PROGRESS: {done}/{total} issues resolved

Solved:
  ✅ #{num} {title}
  ✅ #{num} {title}

Next up:
  → #{num} {title} ({class})

Skipped (needs human):
  🚫 #{num} {title} — {reason}

Remaining: {count}
```

**Context pressure check:** If the conversation is deep into context (many tool calls, large diffs reviewed), suggest wrapping:
> "We're deep into context. Recommend wrapping this session and resuming fresh. The state file will pick up where we left off."

**Manual mode:** Ask "Continue to next issue? (y/n)"

**Ralph mode:** Continue automatically unless all issues are done or skipped.

### Error handling

If implementation fails for an issue (tests won't pass, unclear how to proceed):

1. Update state file: status → `failed`
2. Add a comment to the GitHub issue: "Attempted automated fix but blocked: {reason}. Needs manual investigation."
3. Move to the next issue

---

## Phase 3: Cleanup

### Step 1: Summary

```
🏁 SOLVE SESSION COMPLETE

✅ Solved: {count}
  • #{num} {title} → {branch}
  • #{num} {title} → {branch}

🚫 Skipped (needs human): {count}
  • #{num} {title} — {reason}

❌ Failed: {count}
  • #{num} {title} — {reason}

📌 Trivial batch: {branch} ({count} fixes)
```

### Step 2: Create PRs

- **Trivial batch branch:** One PR titled `fix: resolve trivial issues #{nums}`
- **Each standard/complex branch:** One PR per branch, titled with conventional commit style, body references the issue with `Closes #{num}`

Use `gh pr create` for each. Link issues in PR body.

### Step 3: Wrap

Invoke `/wrap` to:
- Capture session learnings
- Push any remaining changes
- Rename the session

### Step 4: Completion

If in Ralph mode, output the completion promise:

```
<promise>ALL_ISSUES_RESOLVED</promise>
```

Delete the state file (session is complete).

---

## State File Format

`.claude/solve-issues.local.md` — local file, not committed.

```markdown
---
mode: ralph
completion_promise: ALL_ISSUES_RESOLVED
started: 2026-04-05T10:00:00Z
trivial_branch: fix/trivial-batch-2026-04-05
---

## Issues

| # | Title | Class | Status | Branch |
|---|-------|-------|--------|--------|
| 12 | Fix typo in README | trivial | done | fix/trivial-batch-2026-04-05 |
| 14 | Add input validation | standard | done | fix/14-input-validation |
| 16 | Auth redesign | needs-human | skipped | — |
| 17 | Fix rate limiter | standard | in-progress | fix/17-rate-limiter |
| 20 | Refactor scoring | complex | pending | — |
```

**Status values:** `pending` | `in-progress` | `done` | `skipped` | `failed`

---

## Ralph Loop Integration

### How it works

When Ralph mode is active:
- The state file persists across context resets
- Each new iteration reads the state file first
- Completed/skipped/failed issues are skipped
- The loop continues from the first `pending` or `in-progress` issue
- `<promise>ALL_ISSUES_RESOLVED</promise>` is output only when every issue is `done`, `skipped`, or `failed`

### Prompt fed by Ralph

The `/solve-issues` command itself is re-fed on each iteration. The state file provides continuity — Claude reads it, sees what's done, and picks up the next issue.

### Safety

- `--max-iterations` on the Ralph loop prevents infinite cycling
- Failed issues are marked and skipped, not retried infinitely
- The checkpoint after each issue ensures progress is saved before any context reset

---

## Usage

```
/solve-issues
```

No arguments needed — discovers issues from the current repo automatically.

---

## Example Run

```
You: /solve-issues

Claude (Phase 0 — Setup):
  No existing session found.
  Ralph Loop is disabled. Enable for autonomous multi-session? (y/n)

You: y

Claude:
  Ralph enabled. Running /gh-triage...

  🎫 ISSUES — mdshearer/sl-app (6 open)
  🔴 HIGH: #42 Fix crash on empty input
  🟡 MEDIUM: #43 Add word count display, #44 Improve error messages
  ⚪ LOW: #45 Update README, #46 Fix typo in footer

  State file created.

Claude (Phase 1 — Classify):
  📋 CLASSIFICATION
  🟢 Trivial (batched): #45, #46
  🔵 Standard: #42 Fix crash, #44 Error messages
  🟣 Complex: #43 Word count display
  🚫 Needs human: (none)

  Proceed? (y/n)

You: y

Claude (Phase 2 — Solve):
  → Trivial batch: #45, #46
    ✅ #45 Updated README [committed]
    ✅ #46 Fixed typo [committed]

  ✅ PROGRESS: 2/5 resolved
  → Next: #42 Fix crash on empty input (standard)
  [continues automatically in Ralph mode...]

  → Standard: #42
    Implemented input validation, tests passing
    Code review: no issues
    ✅ #42 [committed to fix/42-crash-empty-input]

  → Standard: #44
    Improved error messages, tests passing
    Code review: 1 medium issue (fixed)
    ✅ #44 [committed to fix/44-error-messages]

  → Complex: #43
    Writing plan... 4 tasks
    Executing plan... task 1/4... 2/4... 3/4... 4/4
    Code review: clean
    ✅ #43 [committed to feat/43-word-count]

Claude (Phase 3 — Cleanup):
  🏁 SOLVE SESSION COMPLETE
  ✅ Solved: 5
  Created 4 PRs
  Running /wrap...

  <promise>ALL_ISSUES_RESOLVED</promise>
```

---

## Key Principles

1. **Thin orchestrator** — chains existing skills, doesn't reimplement them
2. **State-driven resumability** — state file enables multi-session work with or without Ralph
3. **Progressive complexity** — trivials batched, standards direct, complex get full plan cycle
4. **Human-aware** — auto-detects issues needing judgment, skips gracefully
5. **Autonomous between checkpoints** — doesn't ask permission for micro-decisions
