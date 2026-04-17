# Preflight — repo-health

## Blast radius

**Reads:**
- The current repo: `CLAUDE.md`, `.repo-health-ignore`, `README.md`, `package.json`/`pyproject.toml`, `.claude/learnings/`, git metadata
- `~/.claude/projects/<repo-hash>/memory/` and `~/.claude/memory/` (memory hygiene check)
- GitHub (via `gh`): open issues, stale TODOs
- Previous log entries at `~/.claude/repo-health-log/{repo-name}.md`

**Writes:**
- `~/.claude/repo-health-log/{repo-name}.md` — appends one entry per run (never overwrites, never deletes)

**Does NOT write to:**
- The repo itself — no edits to CLAUDE.md, no file creation, no commits
- Memory files — reports on them only; never merges, deletes, or promotes
- Any external system (GitHub issues, Notion, etc.) — read-only

Worst-case failure: stale log entry in `~/.claude/repo-health-log/`. Easy to delete by hand.

## Failure mode

- **Crash mid-run:** no partial writes to user files. The log append is a single operation at the end.
- **Idempotency:** running twice produces two log entries, which is intentional (audit trail). No file corruption risk.
- **Missing dirs:** if `~/.claude/repo-health-log/` doesn't exist, the skill creates it. No other dirs are assumed to exist.

## Token / runaway protection

- Fixed checklist — 14 numbered checks, no unbounded exploration
- Memory scan is bounded by the contents of two known directories
- No loops, no self-triggered reruns
- No network calls beyond `gh` and `git` (which the user already pays for)

Expected cost: single-digit tool calls plus one `gh` call for issues. Safe for routine use.
