# Preflight Check — gh-triage

## Blast Radius

**What does this touch?**
- GitHub via `gh` CLI (current repo only — scoped by `gh` context).
- Git working tree (read-only via `git log`, `git diff`).

**Read or write?**
- Triage mode: **read-only** (`gh issue list`).
- Update mode: **writes to GitHub** — `gh issue comment`, `gh issue close`, `gh issue edit --add-label`. All gated behind explicit "Push these updates? (y/n)" confirmation.

**Worst case if it runs wrong?**
- Closes an issue that was still active (reversible via `gh issue reopen`).
- Posts a public comment with incorrect summary (reversible via `gh issue comment --edit-last` or delete from web UI).
- Applies wrong label (reversible).
- All actions are scoped to the current repo only — cannot accidentally touch other repos.

## Failure Mode

**Crash halfway?** Triage mode is read-only — crash = re-run. Update mode commands run sequentially per issue; a crash mid-batch leaves earlier actions committed and later ones untouched. `gh` CLI exits non-zero on failure, so partial success is visible.

**State persistence?** None — stateless. Each run pulls fresh issue list from GitHub.

**Non-idempotent operations?**
- `gh issue comment` creates a new comment each run → re-running duplicates comments.
- `gh issue close` is idempotent (already-closed issue returns success).
- `gh issue edit --add-label` is idempotent (already-present label is a no-op).

**Mitigation:** Update mode's "confirm before push" step is the guardrail — Malcolm sees all proposed comments before any are posted.

## Token & Runaway Protection

**Natural stopping point?** Yes — fixed flow. Triage mode: 4 steps ending at recommendation. Update mode: 5 steps ending with "continue to triage" re-pull.

**Budget cap?** `--limit 50` on `gh issue list` caps the issue pull. No cap on comments/closes per run, but bounded by issues-touched-in-session (typically 1–5).

**Expected cost per run?** Light — one `gh issue list` call plus bounded per-issue analysis. Update mode adds conversational review of each touched issue.

---

*Filled by:* Claude (issue #21)
*Date:* 2026-04-14
