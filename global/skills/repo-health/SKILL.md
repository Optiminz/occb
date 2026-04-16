---
name: repo-health
description: "Cross-repo health check — audits the current repo against Optimi's standards for structure, documentation, and hygiene. Run from any repo with /repo-health. Checks CLAUDE.md quality, index files, learnings depth, duplication, stale TODOs, env docs, dependency freshness, GH issue inventory, secrets, and memory hygiene (collisions with CLAUDE.md, cross-project duplication, staleness, promotion candidates). Produces a pass/fail report with actionable fixes. Trigger on 'repo health', 'repo audit', 'repo check', 'health check', or '/repo-health'."
---

# Repo Health Check

Audits the current repo against Optimi's standards and produces a pass/fail report.

## Trigger

**Primary:** `/repo-health`
**Secondary:** `repo health`, `repo audit`, `repo check`, `health check`

---

## STEP 1: CLASSIFY THE REPO

**First:** Read the repo's `CLAUDE.md` — it usually states what the repo is. Use that as the primary signal.

**Fallback** if CLAUDE.md doesn't clarify:

| Type | Indicators | Example repos |
|------|-----------|---------------|
| **content** | No `package.json`, mostly `.md` files | oai |
| **code** | Has `package.json` or `pyproject.toml` | oi-app, OKM, ai-outreach |
| **config** | Skills, prompts, agent definitions | dash |
| **hybrid** | Mix of code and significant content | ai-sales-workflow |

If still unclear, default to **code**.

---

## KNOWN EXCEPTIONS

Check for `.repo-health-ignore` in the repo root. If it exists, read it. Each line is a check number and reason:

```
# Checks to skip with justification
5: No tests — this is a content-only repo with a stray package.json for markdownlint
9: No GH issues — tracked in Notion instead
```

Skipped checks show as **SKIP** in the report with the reason, not PASS or FAIL. This prevents known-acceptable states from generating noise on every run.

---

## STEP 2: RUN CHECKS

Run all applicable checks in parallel where possible. Each check produces one of:
- **PASS** — meets standard
- **WARN** — functional but could be better
- **FAIL** — missing or broken, needs action

### Check 1: CLAUDE.md exists, is current, and isn't bloated (all repos)

1. Read `CLAUDE.md` in repo root
2. Verify it contains:
   - Repo description (what this repo is)
   - Repo structure table or overview
   - Any repo-specific overrides to global defaults
3. Check `Last Updated` date — WARN if older than 60 days from today
4. **Bloat check** — estimate token count (rough: word count × 1.3):
   - Count instructions that restate default model behaviour (e.g. "use descriptive variable names", "handle errors gracefully") — the model already does these
   - Look for contradictory instructions (same topic, conflicting guidance)
   - Look for redundant/duplicate paragraphs within the file itself
   - Check for over-specific formatting rules or prompt-engineering scaffolding that newer models don't need

**FAIL** if: no CLAUDE.md, or it has no repo description.
**WARN** if: missing structure overview, stale date, estimated tokens >3000, or contradictory/redundant instructions found.
**FAIL** if: estimated tokens >5000 — CLAUDE.md is actively degrading output quality. Recommend a prune pass.

When bloat is flagged, suggest: *"Run: 'Update my CLAUDE.md to remove anything that's no longer needed, contradictory, duplicate, or unnecessary bloat impacting effectiveness.'"*

### Check 2: Index file exists (all repos)

Look for `_index.md`, `README.md`, or equivalent at repo root.

**FAIL** if: no index/readme at all.
**WARN** if: index exists but hasn't been updated in 90+ days (check git blame).

### Check 3: CLAUDE.md / constitution / subagent deduplication (repos with agents)

1. Check if repo has any of: `.claude/constitution.md`, `constitution.md`, agent/persona definitions (glob for `**/persona*.md`, `**/subagent*.md`, `**/agent*.md`)
2. If found, read CLAUDE.md and each agent/constitution file
3. Look for duplicated content blocks — same paragraph or instruction appearing in multiple files
4. Flag any instruction that appears in both CLAUDE.md and constitution/subagents

**FAIL** if: significant duplicated instruction blocks (3+ lines repeated verbatim).
**WARN** if: overlapping intent (same idea phrased differently in multiple places).
**PASS** if: no agent files, or clean separation of concerns.

### Check 4: Learnings directory (all repos)

Check for `.claude/learnings/` with at least one file.

**WARN** if: directory missing or empty. Not a FAIL — repo may be new.

### Check 5: Stale TODOs/FIXMEs (code repos only)

1. Grep for `TODO`, `FIXME`, `HACK`, `XXX` across all source files
2. For each, check git blame date
3. Flag any older than 30 days

**WARN** if: stale TODOs found. List them with file, line, age.
**PASS** if: none found or all recent.

### Check 6: Environment documentation (code repos only)

1. Check if `.env`, `.env.local`, or `.env.example` exists
2. If `.env*` exists (other than `.env.example`), verify `.env.example` or env docs also exist
3. Check `.gitignore` includes `.env*.local`

**FAIL** if: `.env` files exist but no `.env.example` and no env docs in CLAUDE.md/README.
**WARN** if: `.gitignore` doesn't cover env files.

### Check 7: Dependency freshness (code repos only)

1. Read `package.json` (or equivalent)
2. Use your training knowledge to flag any packages you know to be deprecated, sunset, or replaced by a recommended successor
3. Don't run `npm outdated` — too slow and noisy for a health check

**WARN** if: known deprecated packages found. Include the recommended replacement.

### Check 8: Orphaned files (content repos only)

1. Find `.md` files not modified in 60+ days (use `git log`)
2. Cross-reference against index files and CLAUDE.md
3. Flag files that aren't referenced anywhere and haven't been touched

**WARN** if: orphaned files found. List them.
**PASS** if: all files referenced or recently active.

### Check 9: GitHub issue inventory (code and hybrid repos)

1. Run `gh issue list --state open --limit 50` to get all open issues
2. For each issue, note creation date and calculate age in days
3. Classify:
   - **Active** — created or updated within last 30 days
   - **Stale** — no update in 30+ days
   - **Abandoned** — no update in 90+ days

Report summary: total open, active, stale, abandoned. Don't list every issue — just the counts and any abandoned ones by title.

This is a **read-only inventory** — don't triage, close, or modify issues. The purpose is awareness.

**WARN** if: any abandoned issues (90+ days).
**PASS** if: all issues active or stale, or no issues exist.

### Check 10: Learnings depth review (all repos with learnings)

Go beyond existence — review the actual content of `.claude/learnings/` files:

1. Read all learnings files
2. For each learning entry, classify as:
   - **Informational** — context, decisions, gotchas — no action needed
   - **Actionable** — implies outstanding work (something to fix, add, change, enforce) that hasn't been tracked
   - **Stale** — references files, patterns, or tools that no longer exist or have changed
   - **Enforced** — already tracked via a GH issue or hookify rule (has `**Tracked:**` annotation)

3. For **actionable** learnings without a `**Tracked:**` annotation:
   - Determine routing: Is this an AI/dev task (GH issue) or a Malcolm task (Notion)?
   - Create the appropriate tracking item
   - Update the learning entry to include `**Tracked:** <link>`

4. For **stale** learnings:
   - Verify staleness (grep for referenced files/functions)
   - Flag for removal or update

**Report format:**
```
Learnings: N total entries
- Informational: N
- Actionable (untracked): N — [list briefly]
- Stale: N — [list briefly]
- Enforced: N
```

**FAIL** if: actionable learnings sitting untracked for 30+ days.
**WARN** if: stale learnings found.
**PASS** if: all learnings are informational or properly tracked.

### Check 11: Verification setup (code and hybrid repos)

Boris Cherney (Claude Code creator): "Give Claude a way to verify its work — it will 2-3x the quality of the final result."

1. Check if CLAUDE.md mentions any verification mechanism:
   - Test commands (`npm test`, `pytest`, `vitest`, etc.)
   - Linting/type-checking commands
   - Browser testing or preview URLs
   - Any explicit "how to verify" section
2. Check if `package.json` has `test`, `lint`, or `typecheck` scripts defined
3. Check for test directories (`__tests__/`, `tests/`, `test/`, `*.test.*`, `*.spec.*`)

**FAIL** if: code repo with no tests, no test scripts, and no verification guidance in CLAUDE.md.
**WARN** if: test infrastructure exists but CLAUDE.md doesn't mention how to verify work.
**PASS** if: CLAUDE.md documents verification steps, or test/lint scripts are present and discoverable.

### Check 12: Skills coverage (config and hybrid repos)

Check whether repetitive workflows have been captured as reusable skills.

1. Look for `.claude/skills/` or `skills/` directories
2. If skills exist:
   - Check for orphaned skills — skill files that aren't referenced in any CLAUDE.md, slash command list, or skill index
   - Check for skills with no `description` in frontmatter (undiscoverable)
3. If no skills directory exists and repo type is config or hybrid:
   - WARN — suggest running `/skill-scan` to identify candidates

**WARN** if: orphaned or undescribed skills found, or config repo has no skills directory.
**PASS** if: skills are present, described, and referenced — or repo type doesn't warrant skills.

### Check 13: Memory hygiene (all repos) — deep, cross-scope audit

Memory files live at `~/.claude/projects/<repo-hash>/memory/` (per-repo) and `~/.claude/memory/` (global). They auto-load via the `MEMORY.md` index and drift into duplication with CLAUDE.md over time, because Claude writes them without the user's explicit approval.

**This check intentionally steps outside the current repo's scope** — memory duplication is inherently cross-project (e.g. the same fact saved in oai, dash, and OKM memories), so Check 13 scans sibling memory dirs and global memory too. This is the one check in `/repo-health` that looks beyond cwd; it's justified because memory lives at `~/.claude/` regardless of which repo you're auditing from.

**Skip prompt:** Before running, ask the user:
> "Memory audit is the heavy step in this run — include it? (default: yes)"

If the user defers, mark Check 13 as **SKIP** with reason "user deferred" and continue. Don't persist this skip to `.repo-health-ignore` — it's a per-run choice.

**Steps:**

1. **Locate memory dirs**
   - Current repo memory: derive the project hash by matching cwd against `~/.claude/projects/*/memory/MEMORY.md` paths (the hash is a sanitised cwd, e.g. `-Users-malcolm-Projects-oai`)
   - Global memory: `~/.claude/memory/`
   - Sibling project memories: glob `~/.claude/projects/*/memory/MEMORY.md`

2. **Index hygiene** (for each memory dir with a `MEMORY.md`)
   - Line count — WARN if >180 (the 200-line truncation looms)
   - Orphaned files — files in `memory/` that aren't listed in `MEMORY.md`
   - Dead links — files listed in `MEMORY.md` but missing from disk

3. **Collision scan — memory vs CLAUDE.md**
   Compare each memory file in the current repo's memory dir AND global memory dir against:
   - The current repo's `CLAUDE.md` (project-level)
   - `~/.claude/CLAUDE.md` (global)
   
   Flag any memory whose content substantively overlaps (≥40% semantic overlap, or restates a structured block like a table/list). These are **promote-and-delete candidates** — merge anything unique back into CLAUDE.md, then delete the memory file.

4. **Contradiction scan**
   For each memory line, check whether it directly contradicts a statement in the relevant CLAUDE.md (same topic, conflicting rule). Contradictions silently break Claude's behaviour because both load into context — flag hard.

5. **Cross-project duplication**
   Compare the current repo's memory files against all sibling project memories. If the same fact (by frontmatter `description` similarity + body overlap) appears in 2+ project memories, flag for promotion to either global memory (`~/.claude/memory/`) or `~/.claude/CLAUDE.md`, depending on whether it's volatile or stable.

6. **Staleness** (by memory type)
   - **reference** — verify referenced file/path/URL/ID still exists (read file, grep for identifier). WARN if stale.
   - **project** — check file mtime; WARN if >45 days old (project memory decays fast per its own guidance in the auto-memory system prompt).
   - **feedback** — check if the rule already appears in CLAUDE.md or a hookify rule. If yes, it's been codified — recommend deletion from memory (the canonical version has graduated).
   - **user** — check file mtime; INFO only if >180 days (user facts are long-lived; only flag for sanity check, not action).

7. **Promotion candidates**
   Surface any memory file that is:
   - Stable (mtime >60 days, no edits)
   - Not stale
   - Describes a domain/project fact (not a behavioural preference or transient state)
   
   These are eligible to graduate from memory into CLAUDE.md — presented as a review list, not auto-moved.

**Report format:**
```
Memory audit: N files across [current repo / global / N sibling projects]

| Category | Count | Notes |
|----------|-------|-------|
| Collisions (promote-and-delete) | N | [one-line list] |
| Contradictions | N | [list with CLAUDE.md line refs] |
| Cross-project duplicates | N | [list of shared facts across repos] |
| Stale references | N | [list with broken target] |
| Stale project memories | N | [list with age] |
| Codified feedback (delete candidates) | N | [list] |
| Promotion candidates | N | [list] |
| Index hygiene issues | N | [orphans, dead links, over-limit] |
```

**FAIL** if: contradictions found (these are silently breaking behaviour).
**WARN** if: any collisions, duplicates, staleness, or promotion candidates found.
**PASS** if: all memory files are unique, current, correctly scoped, and index is clean.

**Fix workflow — never auto-edit memory.** This is the control mechanism the user has been missing: present each finding as a proposal and get explicit approval per-item or per-category.

After the report, offer:
> "Found [N collisions, N stale, N promotion candidates]. How do you want to handle these?
> (a) Walk through one by one — I'll show each, you approve/reject/edit
> (b) Category sweep — approve an entire category at once (e.g. 'delete all codified feedback')
> (c) Show full diffs first, decide after"

Never silently merge, delete, or promote memory entries. Every write is user-approved.

---

## STEP 3: PRODUCE REPORT

Format the report as a table:

```
## Repo Health Report: {repo-name}
Type: {content|code|config|hybrid}
Date: {today}

| # | Check | Status | Detail |
|---|-------|--------|--------|
| 1 | CLAUDE.md | PASS/WARN/FAIL | ... |
| 2 | Index file | PASS/WARN/FAIL | ... |
| ... | ... | ... | ... |

### Summary
- X passed, Y warnings, Z failures

### Recommended Actions
1. [Most important fix first]
2. ...
```

Order recommended actions by:
1. FAILs first (blocking issues)
2. WARNs that are quick to fix
3. WARNs that need more thought

---

## STEP 4: OFFER TO FIX

After presenting the report, ask:

> "Want me to fix any of these? I can handle [list quick fixes] right now."

Quick fixes (do without asking further):
- Create empty `.claude/learnings/` directory
- Add `.env*.local` to `.gitignore`
- Create skeleton `.env.example` from existing `.env`

Larger fixes (confirm approach first):
- Rewriting CLAUDE.md
- Deduplicating constitution/subagent content
- Removing orphaned files

---

## STEP 5: LOG THE RESULT

After the report is presented, append a summary to the global health log at `~/.claude/repo-health-log/`.

**This directory is NOT auto-loaded into context.** It exists only as a historical record, read on demand.

### Log structure

One file per repo: `~/.claude/repo-health-log/{repo-name}.md`

Each run appends an entry (do not overwrite previous entries):

```markdown
## {date}

| # | Check | Status |
|---|-------|--------|
| 1 | CLAUDE.md | PASS/WARN/FAIL |
| 2 | Index file | PASS/WARN/FAIL |
| ... | ... | ... |

**Summary:** X pass, Y warn, Z fail
**Actions taken:** [list any fixes applied, or "none"]
**Delta from last run:** [improved/regressed/unchanged — compare to previous entry if one exists]
```

### Using the log

- When running `/repo-health`, check if a previous log entry exists for this repo. If it does, include a **Delta** line in the report comparing current vs last run (e.g. "Check 1 improved WARN→PASS, Check 5 regressed PASS→WARN").
- The log enables tracking health trends across runs without polluting context on every conversation start.
- To review all repo health history: read `~/.claude/repo-health-log/` directly.

---

## NOTES

- This skill runs against the **current working directory** only. To audit multiple repos, run it from each.
- Don't fetch from remote or run install commands. Work with what's on disk.
- The check list is defined here as the canonical source. If standards evolve, update this file.
