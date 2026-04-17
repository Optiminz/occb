# Repo-to-Notion Area Mapping

Maps local repositories to their corresponding Notion Area and any strategic pages.

**Last updated:** 2026-04-17

---

## Repo → Area

| Repo pattern | Notion Area | Notes |
|-------------|-------------|-------|
| `mlc-*`, `Mill-Law-*`, `time-reconciler` | Mill Law Centre | Primary active client |
| `oi-app` | Strategy | Internal product — client-facing assessment app |
| `ai-writing-*` | Writing/Content | 9-agent writing pipeline |
| `ai-sales-*` | Sales | Baker/Enns sales workflow |
| `ai-outreach-*` | Marketing | LinkedIn outreach campaigns |
| `oai` | Strategy | Business intel, frameworks, client work |
| `smt-*` | *(no Notion area)* | Volunteer church work, not Optimi |
| `OKM` | Ops | Knowledge manager — ingestion pipeline |
| `ai-dev-orchestrator`, `occb`, `dash` | Ops | Dev tooling and workflows |
| `OCRM`, `optimi-lead-scoring` | Ops | Experimental — not daily drivers |

---

## Strategic Pages by Client

These Notion pages contain the human context — engagement status, relationship dynamics, recent decisions — that CLAUDE.md files don't capture.

| Client | Strategic Account Page | Operations Intelligence Page |
|--------|----------------------|----------------------------|
| MLC | `3237841666cb81e1a021d836db9ca44b` | `3247841666cb81159a63d00f8147b3ba` |
| A Rocha Canada | *(search Notion — no fixed page ID yet)* | — |
| Project Evident | *(search Notion — no fixed page ID yet)* | — |

---

## Key Notion Database IDs

| Database | Data Source ID | Use |
|----------|---------------|-----|
| Areas | `691a70f5-6a19-4b14-b781-d19a891c9f18` | Find the Area for a repo |
| Projects | `e866d5f6-a661-450d-bce1-e5a5aabeb179` | Find active work under an Area |
| Resources | `02b19e26-6762-4dfa-afb3-8e2fd19106a8` | Find specs/SOPs related to the Area |

For full Notion field mappings, see `~/.claude/notion-map.md`.
