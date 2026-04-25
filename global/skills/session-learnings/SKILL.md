---
name: session-learnings
description: Capture notable learnings, patterns, or mistakes during a session. Used by /wrap for end-of-session review, or invoke directly with "capture this learning", "remember this for next time", "add to learnings", or "session notes". Appends structured entries to global or project learnings files.
last_audited: 2026-04-25
---

# Session Learnings Capture

## Prerequisites

Ensure these files exist. If missing, create them:

```bash
# Global
mkdir -p ~/.claude/learnings
touch ~/.claude/learnings/{patterns,mistakes}.md

# Project (run from project root)
mkdir -p .claude/learnings
touch .claude/learnings/learnings.md
```

## When to Use This Skill

- **Primary:** Called by `/wrap` during end-of-session review
- **Secondary:** Malcolm explicitly asks to capture something ("remember this", "add to learnings")

Capture when you encounter:
- A **mistake** that cost time and should be avoided
- A **pattern** that elegantly solved a problem
- A **gotcha** or **decision** specific to the current project

**User preferences** (style, tool choices, communication) go in **auto-memory** instead — not learnings files.

## Learnings Structure

| Type | Scope | File |
|------|-------|------|
| Pattern | Global — applies everywhere | `~/.claude/learnings/patterns.md` |
| Mistake | Global — applies everywhere | `~/.claude/learnings/mistakes.md` |
| Project learning | This repo only | `.claude/learnings/learnings.md` |

**Rule of thumb:** If it applies to more than this repo, it's global.

## Format

**For Patterns:**
```markdown
## YYYY-MM-DD: [Pattern Name]
- [What the pattern is]
- **When to use:** [Conditions]
- **Example:** [Brief code or workflow example]
```

**For Mistakes:**
```markdown
## YYYY-MM-DD: [Mistake Name]
- **What happened:** [Description]
- **Root cause:** [Why it happened]
- **Prevention:** [How to avoid in future]
```

**For Project Learnings:**
```markdown
## YYYY-MM-DD: [Title]
- [Description — what was learned, decided, or discovered]
- [Context, workaround, or rationale as needed]
```

## Concrete example

A good captured mistake — specific enough to actually prevent recurrence:

```markdown
## 2026-04-22: Edited symlinked ~/.claude/CLAUDE.md directly
- **What happened:** Made changes to ~/.claude/CLAUDE.md, lost them on next `./install.sh`
- **Root cause:** That path is a symlink into occb/global/; install.sh regenerates it
- **Prevention:** Edit `~/Projects/occb/global/CLAUDE.md` source, commit, run install.sh
```

A bad version — too vague to be useful: *"Be careful editing config files — they can get overwritten."* No path, no trigger condition, no fix.

## Edge cases

- **Fits multiple categories** (e.g. a pattern that emerged from a mistake): pick the dominant frame. If the value is "avoid this in future" → mistake. If the value is "do this in future" → pattern. Don't double-file.
- **Project root isn't a git repo:** `.claude/learnings/learnings.md` still works as a plain folder. If the directory is ephemeral (scratch, tmp), promote to global instead.
- **Learning is really a user preference** (style, tool choice, communication): route to auto-memory, not learnings — see the rule above.
- **Similar entry already exists:** update the existing entry with new context/date rather than appending a near-duplicate.

## Process

1. Determine if it's global (pattern/mistake) or project-specific
2. Check existing entries to avoid duplicates — update if similar exists
3. Append to the appropriate file
4. Briefly confirm: `Captured [type]: "[title]" → [file path]`

Keep confirmation minimal — don't interrupt flow.

## Important Guidelines

- **Be specific** — vague learnings aren't useful
- **Don't over-capture** — only notable learnings, not everything
- **Update, don't duplicate** — if a similar learning exists, update it

## Integration with /wrap

This skill captures learnings in-the-moment. `/wrap` Step 1 does end-of-session review. They complement each other:
- Use this skill when you notice something immediately worth capturing
- `/wrap` handles systematic end-of-session review


---

## Audit log

- **2026-04-25** — Malcolm, Opus 4.7 — 80/100, then fixes applied. Added concrete good/bad example and edge-cases section (multi-category, non-git root, user-preference routing, duplicate handling). Subagent pressure-test still outstanding.
