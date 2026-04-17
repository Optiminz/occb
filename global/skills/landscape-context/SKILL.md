---
name: landscape-context
description: Orientation before non-trivial work — reads CLAUDE.md tree, index files, learnings, and Notion client context to build a mental model of the repo and its surrounding systems. Activates when entering a new codebase, context-switching between clients, or before architectural decisions.
user-invocable: false
---

# Landscape Context — Orientation Before Action

Before starting non-trivial work in any repo, build a mental topological map of the system. The cost of skipping this is Claude confidently making changes that break assumptions nobody mentioned. The cost of doing it is 2–5 minutes.

**When this skill activates:** You are about to start work that touches architecture, crosses system boundaries, or involves a repo you haven't oriented to in this session. Do NOT activate for simple file edits, formatting, or tasks where the scope is obvious and contained.

---

## Phase 1: Local Context (always do this)

Read these files in order. Skip any that don't exist — not every repo has all of them.

### 1.1 CLAUDE.md tree

Walk up from the current working directory, reading each CLAUDE.md you find:

1. `.claude/CLAUDE.md` or `CLAUDE.md` in the current repo root
2. `../CLAUDE.md` — parent directory (catches meta-repo patterns like `~/Projects/MillLawCenter/CLAUDE.md` governing sibling repos)
3. `~/.claude/CLAUDE.md` — global personal + team baseline (already loaded by Claude Code, but confirm you've absorbed the team conventions relevant to this repo)

**Extract from each:** repo purpose, structure, connected systems, overrides, critical rules, verification commands.

**Monorepo note:** If you're working inside a subdirectory (e.g., `packages/frontend/`), also check for `.claude/CLAUDE.md` and `.claude/skills/` within that subdirectory — Claude Code discovers these automatically, but you should read them as part of orientation.

### 1.2 Index and architecture files

Look for these in the repo root and one level down:

- `_index.md`, `*/_index.md` — project or folder indexes
- `ARCHITECTURE.md`, `CONSTITUTION.md`, `*-CONSTITUTION.md` — architectural decisions
- `client-directory.md` — if this is the oai repo
- `.claude/learnings/learnings.md` — what past sessions discovered about this repo

**Extract from each:** what's load-bearing, what decisions are locked in, what past sessions flagged as tricky.

### 1.3 Git state

Run a quick orientation:

```
git log --oneline -10
git branch --list
```

**Extract:** what's been happening recently, whether there are active branches that signal in-progress work.

---

## Phase 2: Notion Context (do this when the repo relates to a client or internal area)

**Skip this phase if:** the repo is a one-off tool, a personal experiment, or the CLAUDE.md already contains all the context you need. Use judgment — not every task needs Notion.

### 2.1 Identify the Area

From the repo's CLAUDE.md, identify which Notion Area this repo belongs to. See [references/repo-area-map.md](references/repo-area-map.md) for the repo-to-Area mapping table, strategic page IDs, and database IDs.

If the mapping isn't obvious from the reference file, search Notion:

```tool
mcp__claude_ai_Notion__notion-search
  query: "{repo name or client name}"
  query_type: "internal"
  filters: {}
  page_size: 5
  max_highlight_length: 100
```

### 2.2 Fetch active projects

Use the Area page ID from the search result to query the Projects database. The database ID and query pattern are in [references/repo-area-map.md](references/repo-area-map.md).

```tool
mcp__notion-query__query_database
  database_id: "e866d5f6-a661-450d-bce1-e5a5aabeb179"
  filter: {
    "and": [
      {"property": "Area", "relation": {"contains": "<area_page_id>"}},
      {"property": "Status", "select": {"does_not_equal": "Complete"}},
      {"property": "Status", "select": {"does_not_equal": "Terminated"}}
    ]
  }
  limit: 10
```

**Extract:** project names, statuses, service types, timeframes. This tells you what's actively in flight.

### 2.3 Fetch strategic context (client repos only)

For client-facing repos, check [references/repo-area-map.md](references/repo-area-map.md) for known strategic account and operations intelligence page IDs. For clients without fixed page IDs, search Notion for "{Client name} Strategic Account" or check the Area page for linked sub-pages.

Fetch the strategic page if it exists:

```tool
mcp__claude_ai_Notion__notion-fetch
  id: "<page_id>"
```

**Extract:** current engagement status, recent decisions, relationship dynamics, active concerns. This is the human context that CLAUDE.md files don't capture.

---

## Phase 3: Output the Topo Map

Synthesise everything into a structured mental model. Present it to the user (or hold it as working context) in the format below. For a concrete example of a completed topo map, see [references/example-topo-map.md](references/example-topo-map.md).

```
## Landscape Context: {repo name}

**What this is:** {one sentence — repo purpose and who it serves}

**Connected systems:** {list of systems this repo talks to — databases, APIs, other repos, external services}

**Load-bearing decisions:**
- {locked-in architectural or process decisions from CLAUDE.md, ADRs, or constitutions}

**Active work:**
- {active Notion projects and their status, if retrieved}

**Client/strategic context:**
- {current engagement status, key relationships, recent decisions — from Notion strategic pages}
- {if no Notion context: "No Notion context retrieved — working from repo files only"}

**Watch out for:**
- {things past sessions flagged in learnings}
- {things CLAUDE.md explicitly warns about}
- {active branches that signal in-progress work}

**Overrides from global baseline:**
- {any ways this repo's CLAUDE.md overrides team defaults — e.g., "no PRs, commit direct to main"}
```

---

## Rules

- **Don't over-fetch.** If Phase 1 gives you a complete picture, skip Phase 2. The goal is orientation, not exhaustive research.
- **Don't block on Notion failures.** If a Notion query fails or times out, proceed with local context only. Note the gap in the topo map.
- **Don't output this map unless the user would benefit from seeing it.** If you're activating this as background context for yourself, hold it internally. If the user seems to be orienting too (e.g., "what's going on in this repo?"), show it.
- **Update as you learn.** If you discover something during the session that contradicts the topo map, revise your mental model. Don't cling to stale orientation.
- **Respect the 5-minute budget.** This skill should take 2–5 minutes. If you're spending longer, you're over-investigating. Stop and start the actual work.
