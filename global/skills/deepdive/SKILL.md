---
name: deepdive
description: "NotebookLM deep-research orchestration — creates a new notebook, runs deep research (~5min, ~40 web sources), reviews the report and source list, picks follow-up queries for second-pass expansion, imports everything, and optionally generates a briefing doc. Trigger on 'deepdive', 'deep research', 'research notebook on X', '/deepdive', or when the user wants to go from a cold topic to a populated NotebookLM notebook with an evaluated source base."
---

# Deepdive — NotebookLM Research Orchestration

Turn a topic into a populated NotebookLM notebook with a curated, expanded source base. Replaces the manual loop of kicking off deep research, waiting, reading the report, deciding what to expand, and running follow-up searches.

## Dependencies

- **`notebooklm-mcp` MCP server** — required. All `mcp__notebooklm-mcp__*` tools used below come from this server. Must be registered in the user's MCP config.
- **`nlm` CLI** — required for first-time auth. User runs `nlm login` once per machine to authenticate against their Google/NotebookLM account; the MCP server reuses those tokens.
- **`yt-dlp`** — optional. Only needed if a follow-up pulls a YouTube transcript as an ingested source. Install with `brew install yt-dlp`.

## Team Setup

Deepdive orchestrates per-user infrastructure — every team member must set these up themselves before the skill will run:

- **NotebookLM account** — each person logs in with their own Google account via `nlm login`. There is no shared auth.
- **MCP server registration** — add `notebooklm-mcp` to your own Claude Code MCP config. It is not distributed via occb.
- **Usage metering** — NotebookLM meters deep research per account. Burning quota on one machine does not affect teammates, but also means there's no shared pool to draw from — plan your own runs.

If `nlm login` has never been run, the first `research_start` call will fail with an auth error. Run the CLI login, then retry.

## Trigger

**Primary:** `/deepdive <topic>`, `deepdive on <topic>`, `deep research on <topic>`
**Secondary:** `research notebook on <topic>`, `new NotebookLM on <topic>`

If the user gives a topic, proceed. If not, ask: "What's the topic, and do you want a fresh notebook or add to an existing one?"

---

## PHASE 0: MODE CHECK

**Skip deep mode if** the topic is narrow and well-bounded — a specific paper, a named product, a single factual question, a known entity. Deep mode's ~5min and ~40 sources are overkill; run `fast` mode directly (single `research_start` + `research_status` + `research_import`) and skip to Phase 7. Confirm with the user if unsure.

Use deep mode when the topic is broad, exploratory, or you need a source base to reason over (market landscapes, "state of X", positioning research, comparative analysis).

---

## PHASE 1: KICK OFF DEEP RESEARCH

**Tool:** `mcp__notebooklm-mcp__research_start`

Call with:
- `query`: the user's topic, sharpened if vague (confirm the sharpened query with the user before starting if you rewrote it substantively)
- `mode`: `"deep"` (default for this skill — ~5min, ~40 web sources)
- `source`: `"web"` (deep mode is web-only)
- `notebook_id`: omit to create a new notebook (default)
- `title`: a short, specific title derived from the query

**Capture** the returned `notebook_id` and `task_id` — you need both for every subsequent step.

Tell the user: "Deep research kicked off — polling for ~5 minutes." Then poll.

---

## PHASE 2: POLL UNTIL COMPLETE

**Tool:** `mcp__notebooklm-mcp__research_status`

Call with `notebook_id`, `task_id`, `max_wait: 300`, `poll_interval: 30`, `compact: true`.

If it returns before completion, re-poll. If it times out, call again — deep research can occasionally exceed 5 min.

Once `status: completed`, call it **once more with `compact: false`** to get the full report and source list for triage.

---

## PHASE 3: TRIAGE AND PLAN EXPANSION

Read the full report and source list. Identify:

1. **Gaps** — angles the deep research touched lightly or missed (common: recent news, NZ/AU-specific context, primary sources vs commentary, contrarian takes)
2. **Follow-up queries** — 1 to 3 targeted sharp queries that would fill those gaps. Fewer is better. Skip this phase entirely if the deep-research report already covers the topic comprehensively.

**Present the plan to the user** before running follow-ups:

```
Deep research complete — <N> sources found.

Gaps I noticed:
- <gap 1>
- <gap 2>

Proposed follow-ups (fast mode, ~30s each):
1. <query 1>
2. <query 2>

Proceed, edit, or skip?
```

Wait for confirmation. The user may skip, narrow, or add queries.

---

## PHASE 4: RUN FOLLOW-UP FAST RESEARCH (optional)

For each approved follow-up query:

1. `research_start(query=..., mode="fast", source="web", notebook_id=<same notebook>)` — reuse the notebook so everything lands in one place
2. `research_status(notebook_id=..., task_id=..., max_wait: 90)`
3. `research_import(notebook_id=..., task_id=..., source_indices=<selective>)` — review the found sources before importing. Drop obvious junk (SEO farms, paywalled re-reports of primary sources already in the notebook).

Run these sequentially, not in parallel — NotebookLM ingestion is the bottleneck and parallel writes to the same notebook can race.

---

## PHASE 5: IMPORT DEEP-RESEARCH SOURCES

**Tool:** `mcp__notebooklm-mcp__research_import`

Import the original deep-research sources. If the source list is long (>30), ask the user whether to import all or cherry-pick. If cherry-picking, show the source titles with indices and let them nominate which to drop.

---

## PHASE 6: OPTIONAL REPORT GENERATION

Ask: "Want a briefing doc generated from the notebook?"

If yes: `mcp__notebooklm-mcp__pipeline` with `action: "run"`, `pipeline_name: "research-and-report"`, `notebook_id: <same>`.

If the user wants audio instead, use `multi-format` or `ingest-and-podcast`.

---

## PHASE 7: HANDOFF

Return exactly this template so a parent skill or orchestrator can parse it:

```
**Notebook ready**
URL: https://notebooklm.google.com/notebook/<notebook_id>
Topic: <one-line sharpened query>
Sources: <N deep> + <M follow-up> = <total> imported
Summary: <one sentence on what the notebook now contains>
Next: [ask a question | generate audio/briefing | capture key finding]
```

Keep the field names and order identical across runs — that's the output contract.

---

## Notes

- **Blocking time:** ~5 min deep + ~30s per follow-up + ingestion. Tell the user upfront so they can context-switch.
- **Drive source:** deep mode doesn't support Drive. If the topic genuinely needs Drive search, run a separate `fast` research with `source: "drive"` as a follow-up.
- **Cost awareness:** deep research is expensive on the NotebookLM side and metered per account. Don't re-run for the same topic without good reason — prefer follow-up fast queries into the existing notebook.
- **Idea capture:** if the user surfaces an idea during triage ("oh that's interesting, we should…"), capture it per whatever inbox/idea-capture convention their repo uses.
