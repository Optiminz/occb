# 2026-04-18 — occb Review & Refactor Plan

**Branch:** `review/2026-04-refactor`
**Status:** Proposed, awaiting execution

Synthesises findings from a 4-agent parallel audit (team baseline, personal layer, oai sweep, migration archaeology) plus token-footprint analysis.

---

## Execution order

### 1. 🔴 Rotate leaked Notion token *(critical)*
- `occb-personal/claude/mcp.json` line 7 contains a live `ntn_...` token committed to git.
- Rotate in Notion admin, replace with `${NOTION_API_TOKEN}` env ref, add `mcp.json` to `.gitignore`, keep a `mcp.json.template`.
- Private repo, but committed credentials are still an anti-pattern.

### 2. Slim team CLAUDE.md to ≤1,500 always-loaded tokens
Current: 199 lines, ~2,550 tokens. Target: ~80 lines.
- **Move to docs:** Preflight discipline → `docs/06-preflight.md`; detailed dev workflow prose + code style depth → `docs/07-conventions.md`.
- **Keep inline (rules + pointers):** config-change triage table, shared account discipline, sub-agent defaults, planning pointer, worktree pointer, landscape-context pointer, Notion reference map footer.
- Biggest lever for keeping Bryan's sessions cheap. Do this before adding new content.

### 3. Reconcile `settings.json` drift
- `~/.claude/settings.json` has `statusLine` + `permissions` not present in `occb-personal/claude/settings.json` (30 bytes).
- Decide source: is install.sh generating them, or has drift occurred? Commit authoritative version to the right layer (statusLine is team; permissions likely personal).

### 4. Promote 5 oai files → occb
- `oai/resources/claude-code-setup.md` → `occb/docs/onboarding/`
- `oai/areas/guides/env-sync-convention.md` → `occb/docs/onboarding/`
- `oai/areas/guides/google-workspace-mcp-setup.md` → `occb/docs/onboarding/`
- `oai/areas/guides/mcpl-quickstart.md` → `occb/docs/onboarding/`
- `oai/areas/guides/lint-enforcement-audit.md` → `occb/docs/guides/`
- Update `CLAUDE.md` references and oai `CLAUDE.md` back-pointers.
- Generic-ise any `"account": "malcolm"` references.

### 5. Move `notion-query-mcp` tool → `occb/global/tools/`
- Whole directory from `oai/tools/notion-query-mcp/`.
- Team-distributed custom MCP; belongs in shared baseline with version control.

### 6. Write `docs/02-prerequisites.md` for zero-state onboarding (Bryan)
- `jq`, `gh` CLI, git SSH, 1Password (optional), Notion access
- Plugin dependencies: `superpowers`, `pr-review-toolkit`, `commit-commands`
- MCP env vars: mandatory vs optional per integration
- Link from `README.md` and `docs/02-installation.md`

### 7. Extract learnings → fatten patterns/antipatterns
- Top entries from `occb-personal/claude/learnings/patterns.md` (369 lines) → `occb/docs/03-patterns.md`
- Top entries from `learnings/mistakes.md` (101 lines) → `occb/docs/04-antipatterns.md` (currently only 1 story)
- Candidates already tagged in `oai/occb-v0.3-upgrade-brief.md`.

### 8. Split personal CLAUDE.md
- Keep Malcolm-only: NZ timezone, port refs (5001/5002), personal project list, snippets index
- Abstract up to team: `pull-env`/`push-env` patterns, env-files-are-authoritative rule, Specs/SOPs convention if others adopt
- Depends on step 2 being done first.

---

## Out of scope / decisions deferred

- `knowledge-capture-systems-map.md` — contains Malcolm-only repo paths; keep in oai, link from occb with a note. Revisit if Pete/Bryan need a team-scoped version.
- `occb-v0.3-upgrade-brief.md` — keep in oai as historical artefact; don't promote.
- Shared hooks and shared MCP baseline config — intentionally not pursued (per-repo / per-user is working).
- Notion "Notion Optimise" + "Optimi Methods" — human-facing; no action.

---

## Confirmed during review (no action needed)

- `/orchestrate` is team-ready and belongs in `global/commands/`.
- Migration from legacy `~/.claude/` to occb + occb-personal was clean; no lost config.
- Skills and MCP tools are lazy-loaded; token-weight concern is isolated to `CLAUDE.md` only.
- No security leakage in team baseline (only client names + team member names, which are appropriate for org context).

---

## Tracking

Open one GitHub issue per step (1–8) so progress is visible and each step can be a self-contained PR. Step 1 is a hot-fix PR (can merge ahead of the rest). Steps 2–8 can bundle into a second PR or be serialised as preferred.
