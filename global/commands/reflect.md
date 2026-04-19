# Session Reflection

Conduct a structured reflection on the current session to capture learnings. Standalone version of `/wrap` Step 1 — use when you want to capture learnings without committing/pushing.

## Process

### Step 1: Session Summary

Review what was accomplished:
- What was the main task/goal?
- What approaches were tried?
- What was the outcome?

### Step 2: Extract & Write Learnings

Identify anything genuinely novel. The bar is high — routine work produces no learnings, and that's fine.

**Delegate capture to the `session-learnings` skill** — it owns the templates, file paths, and duplicate-checking logic. Invoke it once per learning. Don't re-implement the format here; if the format needs to change, change it in the skill.

If nothing is genuinely novel, skip this step and say so in Step 3.

### Step 3: Present Summary

```
## Session Reflection Complete

**Learnings Captured:**
- [Type]: "[title]" → [file path]

**Recommendation for next session:**
[Any follow-up items or things to watch for]
```

If no learnings were captured, say so honestly — don't force it.

## Arguments

If invoked with arguments (e.g., `/reflect authentication flow`), focus reflection on that specific topic.

$ARGUMENTS

---

## Audit log

- **2026-04-20** — Malcolm, Opus 4.7 — 82/100. Refactored to delegate capture to `session-learnings` skill (was duplicating its templates and file paths); tightened summary; added audit log section. Not yet released.
