---
name: notion-tidy
description: Audit and tidy Notion databases — Areas, Projects, or Resources. 4-pass pipeline producing JSON reports and interactive HTML playground. Trigger on "tidy", "notion tidy", "notion cleanup", "clean up Notion", "tidy area/project/resource", or "audit [element name]".
---

# Notion Tidy — 4-Pass Audit Pipeline

Repeatable process for auditing and tidying any top-level Notion element (Area, Project, or Resource).

**Output:** JSON report + interactive HTML playground per element
**Scope:** First-order elements only. Tasks and Meetings are indexed for context but not individually triaged.

---

## STEP 0: Load Context

Before doing anything:

1. Read the full SOP: `~/Projects/oai/projects/notion-optimise/sop-notion-tidy.md`
2. Read the Notion map: `~/.claude/notion-map.md`
3. Read the element inventory: `~/Projects/oai/projects/notion-optimise/element-inventory.md`
4. Read the index for completed audits: `~/Projects/oai/projects/notion-optimise/_index.md`

---

## STEP 1: Parse the Request

Extract from Malcolm's message:
- **Element name(s)** — one or more elements to tidy
- **Element type(s)** — Area, Project, or Resource (infer from context or ask if ambiguous)

If multiple elements are requested, dispatch each as a parallel sub-agent (Phase 1 of the SOP). Sub-agents work independently.

---

## STEP 2: Execute Passes 1-3

Follow the SOP exactly for each element:

### Pass 1: Index
- Query the element's DB record via Notion MCP
- Follow relations to linked items
- Fetch child pages (one level deep)
- Keyword search with name variants
- Deduplicate and build the asset table

### Pass 2: Structure Audit
- Check structural issues (floating pages, missing relations, naming, duplicates, wrong DB)
- Check content quality (messy, merge candidates, stubs, mixed-purpose)
- Flag resource clusters

### Pass 3: Staleness Scan
- Age bucket every first-order item
- Flag status mismatches
- Identify archive candidates
- Note systemic Task/Meeting patterns

---

## STEP 3: Generate Report (Pass 4)

1. Consolidate Passes 1-3 into JSON at `~/Projects/oai/projects/notion-optimise/reports/{element-name}.json`
2. Generate the interactive HTML playground at `~/Projects/oai/projects/notion-optimise/reports/{element-name}-review.html` using the template at `~/Projects/oai/projects/notion-optimise/notion-tidy-review.html`
3. Open the playground in the browser for Malcolm to review

---

## STEP 4: Post-Audit Updates

After Malcolm has reviewed and the audit is complete:

1. Update `_index.md` — add the element to the Completed Audits table
2. Add any resource clusters to the Resource Observations section
3. If the element inventory needs updating, refresh `element-inventory.md`

---

## Key References

- **SOP (source of truth):** `~/Projects/oai/projects/notion-optimise/sop-notion-tidy.md`
- **Notion Map (DB schemas):** `~/.claude/notion-map.md`
- **Element Inventory:** `~/Projects/oai/projects/notion-optimise/element-inventory.md`
- **Playground Template:** `~/Projects/oai/projects/notion-optimise/notion-tidy-review.html`
- **Reports folder:** `~/Projects/oai/projects/notion-optimise/reports/`

## Triage Levels

- **safe-fix**: missing-relation, naming — batch approve
- **malcolm-review**: duplicate, wrong-db, merge-candidate, resource-cluster, archive candidates
- **team-input**: needs someone else's context — include person and question
- **content-quality**: messy, stub, mixed-purpose
