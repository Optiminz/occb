---
name: session-learnings
description: Capture notable learnings, patterns, or mistakes during a session. Used by /wrap for end-of-session review, or invoke directly with "capture this learning", "remember this for next time", "add to learnings", or "session notes". Appends structured entries to global or project learnings files.
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
