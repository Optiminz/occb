---
name: skill-audit
description: Assess existing skills against best-practice criteria for triggering, methodology, agent-readiness, and structural health. Produces scored report cards with actionable fixes. Trigger on "skill audit", "audit skill", "check skill quality", "review my skills", or "/skill-audit".
---

# skill-audit — Existing Skill Quality Checker

> **Purpose:** Assess existing skills against best-practice criteria for triggering, methodology quality, agent-readiness, and structural health. Answers: "Are my skills well-built and well-triggered?"

---

## Usage

```
/skill-audit [skill-path]         # Audit a single skill
/skill-audit --all                # Audit all skills in ~/.claude/skills/
/skill-audit --repo [repo-path]   # Audit all skills/commands in a specific repo
```

---

## Audit Dimensions

### 1. Description Quality (40% of score — this is where skills succeed or fail)

**Single-line check:** Is the description on exactly one line? Multi-line descriptions break Claude's triggering. This is a PASS/FAIL gate — if it fails, nothing else matters until it's fixed.

**Trigger specificity:**
- GOOD: Names artifact types, includes trigger phrases, states output format
- BAD: Vague ("helps with X"), too broad ("use for any writing task"), too narrow
- Score 1-10

**Pushiness check:** Following Anthropic's guidance that skills undertrigger by default:
- Does the description include specific user phrases that should trigger it?
- Does it cast a wide enough net without being vague?
- Would Claude confidently select this skill from a list of 20+?
- Score 1-10

**Routing signal quality (agent-readiness):**
- Could an orchestrator agent read this description and know exactly what it gets?
- Does it function as a contract declaration, not just a label?
- Score 1-10

### 2. Methodology Body (30% of score)

**Reasoning vs steps:**
- Does the skill explain WHY, not just WHAT?
- Does it include frameworks, quality criteria, or decision principles?
- Or is it just a linear procedure that will break on edge cases?
- Score 1-10

**Output format specificity:**
- Is the output format explicitly defined? (markdown, file type, exact sections)
- Or does it say "produce a summary" with no structure?
- Score 1-10

**Edge cases:**
- Are common-sense assumptions written down explicitly?
- Are failure modes addressed?
- Score 1-10

### 3. Testing & Validation (included in Structural Health)

**Tested with subagents?**
- Has the skill been pressure-tested per `superpowers:writing-skills` TDD methodology?
- Was a baseline captured (agent behavior WITHOUT the skill)?
- Were rationalizations documented and countered?
- UNTESTED = flag as critical structural gap, regardless of other scores

### 3b. Structural Health (20% of score)

**Length check:**
- SKILL.md under 150 lines? (ideal)
- Under 500 lines? (acceptable if using reference files)
- Over 500 lines? (flag for decomposition)

**Reference file usage:**
- Is large content properly split into `references/` files?
- Are reference files clearly pointed to from SKILL.md?
- Is there a clear "read this when you need it" pattern?

**Example quality:**
- Does the skill include at least one example of good output?
- Are examples in separate files or inline?

### 4. Composability & Agent-Readiness (10% of score)

**Output contract:**
- Is the output structured enough that another skill/agent could consume it?
- Or is it free-form text that requires human interpretation?

**Handoff clarity:**
- Does the skill know what happens before and after it in a workflow?
- Does it reference upstream inputs or downstream consumers?

---

## Output Format

### Per-Skill Report Card

```
╔══════════════════════════════════════════╗
║  SKILL: [skill-name]                     ║
╠══════════════════════════════════════════╣
║  OVERALL SCORE: [X]/100                  ║
║                                          ║
║  Description Quality:    [X]/40          ║
║    ├ Single-line:        PASS/FAIL       ║
║    ├ Trigger specificity: [X]/10         ║
║    ├ Pushiness:          [X]/10          ║
║    └ Routing signal:     [X]/10          ║
║                                          ║
║  Methodology Body:       [X]/30          ║
║    ├ Reasoning vs steps: [X]/10          ║
║    ├ Output format:      [X]/10          ║
║    └ Edge cases:         [X]/10          ║
║                                          ║
║  Structural Health:      [X]/20          ║
║    ├ Tested w/ subagents: [Y/N/UNKNOWN]  ║
║    ├ Length:              [status]        ║
║    ├ Reference files:    [status]        ║
║    └ Examples:           [status]        ║
║                                          ║
║  Agent-Readiness:        [X]/10          ║
║    ├ Output contract:    [status]        ║
║    └ Handoff clarity:    [status]        ║
╠══════════════════════════════════════════╣
║  TOP 3 FIXES:                            ║
║  1. [most impactful fix]                 ║
║  2. [second fix]                         ║
║  3. [third fix]                          ║
╚══════════════════════════════════════════╝
```

### Summary Table (for --all audits)

| Skill | Score | Description | Methodology | Structure | Agent-Ready | Top Fix |
|-------|-------|-------------|-------------|-----------|-------------|---------|
| [name] | [X]/100 | [X]/40 | [X]/30 | [X]/20 | [X]/10 | [fix] |

Sort by score ascending — worst skills first, because those need attention.

---

## Fix Recommendations

For each skill scoring below 70/100, provide:

1. **Rewritten description** — a concrete replacement, not just advice
2. **Missing edge cases** — specific scenarios the skill doesn't handle
3. **Structural changes** — what to extract, what to inline, what to cut

For skills scoring 70-85, provide:
1. **Description tweaks** — specific wording improvements for better triggering

For skills scoring 85+:
1. **Leave it alone** — just note what makes it good as a reference for other skills

---

## After Auditing

1. **Record the audit in the skill itself** (see "Audit log convention" below) — the per-skill log is the source of truth for team skills
2. **Update `~/.claude/skill-registry.md`** — personal registry only; skip entries for team skills (their history lives in the skill's audit log)
3. **For team skills (anything under `occb/global/skills/`):** remember that `~/.claude/skills/X/` is a symlink into the `occb` repo. Your edit is real locally but invisible to Pete/Bryan until you `cd ~/Projects/occb && git commit && gh pr create`. Don't leave audit work stranded on your machine.
4. **Build/fix skills:** Use `superpowers:writing-skills` — it applies TDD to skill creation (baseline test → write skill → pressure-test → close loopholes)
5. **Find new candidates:** Use `/skill-scan` to surface workflows that should be skills but aren't

---

## Audit log convention

Every audit leaves two traces in the `SKILL.md` it audits:

**1. Frontmatter field** (add on first audit, update on each subsequent audit):

```yaml
---
name: example-skill
description: ...
last_audited: 2026-04-18
---
```

**2. `## Audit log` section at the bottom** — append-only, newest first, one line per audit:

```markdown
## Audit log

- **2026-04-18** — Malcolm, Opus 4.7 — 82/100. Tightened trigger phrases; added agent-readiness section. [#42](https://github.com/Optiminz/occb/pull/42)
- **2026-02-03** — Pete, Sonnet 4.6 — 61/100. Multi-line description (gate fail); rewritten. [#19](https://github.com/Optiminz/occb/pull/19)
```

**Entry format:** `- **YYYY-MM-DD** — Auditor, Model — score/100. One-line outcome. PR link (optional).`

**Before running an audit:** read the existing log. If the last audit was recent and the skill hasn't changed since (check `git log -- <SKILL.md>`), either skip or call out what's new since the last pass. Don't re-audit unchanged skills just because time passed.

**Why in-skill instead of a central registry:** the log travels with the file through renames, moves, and copies; it's visible in the same file the auditor is editing; and there's no separate index to keep in sync. For team skills this matters — Pete auditing a skill Malcolm wrote should see Malcolm's prior notes without opening a second file.

## What This Is NOT

- This does NOT find new skill candidates. That's `/skill-scan`.
- This does NOT rewrite skills for you. It diagnoses and prescribes. Use `superpowers:writing-skills` to execute fixes with proper TDD methodology.
- This does NOT run triggering evals. The `skill-creator` skill has `run_loop.py` for quantitative trigger testing. This audit is qualitative and structural.

---

## Edge Cases

- **Skill has no description at all:** Score 0/40 on description, flag as critical.
- **Skill is a `.claude/commands/` file, not a `skills/` skill:** Still audit it, but note that commands have different triggering mechanics (explicit invocation vs auto-trigger). Adjust description scoring accordingly — commands don't need pushy descriptions.
- **Skill references external tools (Notion, Gmail, etc):** Check that the skill handles tool unavailability gracefully.
- **Skill is very new (< 1 week old):** Note it but don't penalise for lack of iteration — flag for re-audit after use.


---

## Audit log (this skill)

_Never audited. First entry will be added by `/skill-audit`._
