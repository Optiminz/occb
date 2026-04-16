---
name: skill-scan
description: Scan a repo for workflows, patterns, and repeated processes that should be skills but aren't. Produces a prioritised candidate list with draft descriptions. Trigger on "skill scan", "scan for skills", "what should be a skill", "find skill candidates", or "/skill-scan".
---

# skill-scan — Repo Scanner for Skill Candidates

> **Purpose:** Walk a repo and surface workflows, patterns, and repeated processes that should be skills but aren't. This is Malcolm's "recognition reflex" — the thing he doesn't do naturally yet.

---

## Usage

```
/skill-scan [repo-path]
```

If no path given, scan the current repo.

---

## What It Scans

### 1. Commands directory (`.claude/commands/`)
Commands that exist but aren't skills are the lowest-hanging fruit. A command is a skill candidate if:
- It has reusable methodology (not just a one-off task runner)
- It could benefit other repos or other people
- It has enough structure to trigger predictably

**Output:** List each command with a SKILL CANDIDATE / ALREADY COVERED / NOT SKILL-SHAPED verdict.

### 2. CLAUDE.md and CONSTITUTION.md
Look for:
- Repeated instruction blocks that encode methodology (eg "always do X before Y")
- Formatting/output conventions that get copy-pasted across projects
- Quality gates or scoring rubrics
- Voice/tone definitions that could be reusable

**Output:** Extract methodology blocks and flag as potential Tier 1 (standard) or Tier 2 (methodology) skill candidates.

### 3. Agents directory (`.claude/agents/`)
Agents are often skills waiting to be extracted. Flag agents that:
- Encode a repeatable workflow (not just a persona definition)
- Could work outside this specific repo
- Have clear input → output contracts

**Output:** List agents with EXTRACTABLE / REPO-SPECIFIC verdict.

### 4. Workflow files (`workflows/`, `docs/`, `guides/`)
Look for documented processes that:
- Describe step-by-step methodology
- Include decision trees or quality criteria
- Reference specific output formats
- Are referenced from multiple places in the repo

### 5. Git history patterns (last 50 commits)
Run `git log --oneline -50` and look for:
- Repeated commit message patterns suggesting recurring work types
- Files that get edited together frequently (suggesting a workflow)
- Common prefixes in commit messages (eg "lidev:", "callprep:")

### 6. Scripts directory (`scripts/`)
Scripts that wrap a multi-step process are often skill candidates — the script handles the deterministic parts, a skill could handle the reasoning parts.

---

## Output Format

### Summary Table

| # | Candidate | Source | Type | Priority | Notes |
|---|-----------|--------|------|----------|-------|
| 1 | [name] | [where found] | Tier 1/2/3 | HIGH/MED/LOW | [why] |

### Priority Criteria

- **HIGH:** Repeated weekly+, involves reasoning not just execution, currently done via copy-paste prompting
- **MED:** Done regularly, has clear methodology, but current approach works OK
- **LOW:** Occasional use, nice-to-have, or borderline between skill and simple prompt

### For Each HIGH Priority Candidate

Provide:
1. **What it would do** (2-3 sentences)
2. **Draft trigger description** (single line, pushy, following Anthropic guidance)
3. **Estimated complexity** (lines of SKILL.md, need for reference files, edge cases)
4. **Where it should live** — this repo's `.claude/commands/`, or extracted to `~/.claude/skills/` for cross-repo use. Check `~/.claude/skill-registry.md` to avoid duplicating existing skills.

---

## Next Steps After Scanning

This skill surfaces candidates. To actually build them well:

- **Build:** Use `superpowers:writing-skills` — it applies TDD to skill creation (baseline test → write skill → pressure-test → close loopholes)
- **Audit existing:** Use `/skill-audit` to grade skills you already have
- **Don't skip testing:** Anthropic's guidance is that untested skills = untested code. Every candidate surfaced here should go through RED-GREEN-REFACTOR before deployment.

---

## What This Is NOT

- This does NOT build the skills. That's `skill-creator`'s job.
- This does NOT audit existing skills. That's `/skill-audit`.
- This does NOT make architectural decisions about skill infrastructure. It surfaces candidates for Malcolm to prioritise.

---

## Nate B Jones Criteria Applied

When evaluating candidates, consider:
- **Composability:** Would this skill's output feed naturally into another skill or agent?
- **Agent-callability:** Could an orchestrator agent invoke this, or is it human-only?
- **Compounding potential:** Will this skill get better with iteration, or is it static?

---

## Edge Cases

- **Repo has no .claude/ directory:** Still scan for workflow docs, scripts, and git patterns. Note that the repo isn't set up for Claude Code yet.
- **Repo is tiny (< 10 files):** Skip git history analysis, focus on CLAUDE.md and any workflow docs.
- **Candidate overlaps with existing skill:** Flag the overlap explicitly — "This looks like it might be covered by [existing-skill], but [difference]."
- **Candidate is too broad:** Flag it as needing decomposition — "This is actually 2-3 skills: [a], [b], [c]."
