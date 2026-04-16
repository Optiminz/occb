# Notion Map — Team Reference

Key Notion databases, data source IDs, and field mappings shared across the Optimi team.
**Read this file before creating or updating any Notion entry.**

**Note:** Always use `data_source_id` (not `database_id`) when creating pages.
Use `notion-fetch` on the DB URL first if you need the full schema.

Personal/specialist databases (content pipeline, signal tracker, etc.) live in `~/.claude/notion-map-personal.md` if present.

---

## Notion Structure (PARA)

Optimi's Notion workspace follows the PARA method (Projects, Areas, Resources, Archive):

- **Areas** — Ongoing responsibilities (clients, internal functions like Strategy, Marketing, etc.)
- **Projects** — Time-bound work linked to an Area
- **Resources** — Reference material linked to Areas/Projects. Categorized by type.
- **Archive** — Not a separate location. Items have an `Archive` checkbox that hides them from views.

**Navigation pattern:** Area → Projects under it → Tasks/Resources/Meetings linked to those.

### Specs vs SOPs

Both live in the **Resources** database with different Category values:

| Type | Category value | Purpose |
|------|---------------|---------|
| **Spec** | `Spec` | Defines *what something is and why* — reference document for current state, decisions, constraints |
| **SOP** | `SOPs and guides` | Defines *how to do something* — procedures with steps |

Specs inform SOPs. SOPs operationalize specs. Both are linked to their relevant Area.

---

## Team Notion User IDs

Use these for `person` fields (Responsible, Team, Attendees, etc.)

| Name | Notion User ID | Notes |
|------|---------------|-------|
| Malcolm | `a6c529a1-e620-4567-93a1-e46c1030172e` | — |
| John Gieryn | `21fcf0d9-309d-4929-a81d-624edb0e0fb1` | — |
| Karen | `d6b0c59a-28cf-4d84-9e90-966bc37120db` | Guest |
| Pete | `2bcd872b-594c-81b6-b478-0002ff6b8570` | Guest |
| Bryan | `2e5d872b-594c-81a0-adb3-00024b95d776` | Guest |
| Cal | `bf8b8628-d214-4ae5-90ea-a3749f076da7` | Guest — leaving end of Feb 2026 |

---

## Key Pages

| Page | URL / ID |
|------|----------|
| Team Call (Ongoing) | https://www.notion.so/optimi/Team-Call-Ongoing-1506d7d5eb474a5280794ce45059b6ce |

---

## Relationship Map

These databases are interconnected — use relation fields to link records:

```
Areas ←→ Projects ←→ Tasks
  ↓           ↓
Resources  Meetings
```

- Tasks relate to Projects (`e866d5f6`)
- Projects relate to Areas (`691a70f5`) and Resources (`02b19e26`)
- Meetings relate to Projects (`e866d5f6`) and Areas (`691a70f5`)
- Resources relate to Areas (`691a70f5`)

---

## Tasks

**URL:** https://www.notion.so/optimi/b80558a20e8b44f3a30f6ba3488a9657
**Data source ID:** `196773cc-cbd0-4377-8837-df514b9e0aca`

| Field | Type | Values / Notes |
|-------|------|----------------|
| `Task` | title | — |
| `Status` | status | Backlog \| Nextup \| On hold \| Doing \| Review \| Done \| Cancelled |
| `Priority` | text | e.g. "High", "Medium", "Low" |
| `date:Due Date:start` | date | ISO date |
| `Completed` | checkbox | `__YES__` / `__NO__` |
| `Responsible` | person | **Always assign someone** — resolve by name from Team IDs table above |
| `Project` | relation | → Projects (`e866d5f6`) |
| `Area` | relation | → Areas (`691a70f5`) |

---

## Projects

**URL:** https://www.notion.so/06434890bbc0418cb11d4fa72076c7be
**Data source ID:** `e866d5f6-a661-450d-bce1-e5a5aabeb179`

| Field | Type | Values / Notes |
|-------|------|----------------|
| `Project` | title | — |
| `Status` | select | Backlog \| Planned \| In progress \| Complete \| Handing off \| Terminated |
| `Category` | select | Client \| Internal \| Lead |
| `Service` | select | Diagnose/Audit \| Optimise \| Support \| Discovery (archive) |
| `Area` | relation | → Areas (`691a70f5`) |
| `date:Timeframe:start` | date | ISO date |
| `Tasks` | relation | → Tasks (`196773cc`) |
| `Resources` | relation | → Resources (`02b19e26`) |

---

## Areas

**URL:** https://www.notion.so/3dda230ae7594868a5c7ba489ebb47b0
**Data source ID:** `691a70f5-6a19-4b14-b781-d19a891c9f18`

| Field | Type | Values / Notes |
|-------|------|----------------|
| `Area` | title | — |
| `Status` | select | Planned \| Ongoing \| Complete \| Handing off \| Terminated \| Backlog |
| `Category` | select | Client \| Internal \| Hosted client \| Solution |
| `Responsible` | person | single user |
| `Team` | person | multiple users |

---

## Meetings & Comms

**URL:** https://www.notion.so/600d9ef959a048f99ff19f2c1be9ea43
**Data source ID:** `6a2c326e-963c-42ed-8e88-c9ba7bbb6d53`

| Field | Type | Values / Notes |
|-------|------|----------------|
| `Event` | title | — |
| `Type of meeting` | select | Diagnostic \| Sales - 2 calls \| App building \| Sales - 3 calls / Customised services \| Requirements \| Optimising \| Closing \| Comms \| Lead \| Client checkin \| Recurring \| Collaboration |
| `date:When:start` | date | ISO date |
| `date:When:is_datetime` | int | 1 for datetime, 0 for date |
| `Area` | relation | → Areas (`691a70f5`) |
| `Projects` | relation | → Projects (`e866d5f6`) |
| `Attendees` | person | multiple users |
| `Done?` | checkbox | `__YES__` / `__NO__` |
| `Finalised` | person | multiple users — removes from WIP view when set |
| `Recording URL` | url | — |
| `userDefined:URL` | url | — |

---

## Resources

**URL:** https://www.notion.so/d3ed0cea85084b43a3b099965d2aa735
**Data source ID:** `02b19e26-6762-4dfa-afb3-8e2fd19106a8`

| Field | Type | Values / Notes |
|-------|------|----------------|
| `Resource` | title | — |
| `Category` | select | Public \| References \| SOPs and guides \| Tools \| Training / Onboarding / Recruiting \| Research \| Learning \| Influencers \| Spec |
| `Description` | text | — |
| `Area` | relation | → Areas (`691a70f5`) |
| `Projects` | relation | → Projects (`e866d5f6`) |
| `userDefined:URL` | url | — |
| `Archive` | checkbox | `__YES__` / `__NO__` |

---

## Task Page Template

When creating a task page, use this 3-callout content structure:

```
<callout icon="/icons/target_gray.svg">
	**GOALS**
	*<goal description in italic gray>*
</callout>
<callout icon="/icons/info-alternate_gray.svg">
	**CONTEXT**
	<Write what's known: background, requirements, constraints, related links. Skip sections that have nothing to say — don't leave placeholder text.>
</callout>
<callout icon="/icons/checkmark_gray.svg">
	**ACTIONS**
	- [ ] <action item>
	- [ ] <action item>
</callout>
```

**Defaults:**
- **Responsible:** Always assign someone (resolve name → user ID from Team IDs table)
- **Status:** `Nextup` unless explicitly discussed as `Backlog`
- **Due Date:** Today + 5 days unless otherwise specified

---

## Task Routing

| Who does it? | Where to create | How |
|-------------|----------------|-----|
| **Human** (business, strategy, manual tasks) | **Notion** Tasks DB | Use Notion MCP tools |
| **AI/Dev** (code changes, audits, automation) | **GitHub Issues** | Use `gh issue create` |

---

## Notion Comment Convention

The Notion MCP posts as the current user — there is no separate bot avatar. Every comment Claude creates in Notion (page-level, block-level, or reply inside an existing discussion) MUST end with a signoff so readers can tell AI from human:

> — Claude on behalf of {user}

**Rules:**
- Signoff goes at the END of the comment (not prefix). Use an em dash before "Claude".
- Applies to all comments created via Notion MCP tools.
- Does **not** apply to Notion page content or properties — only comments/discussions.
- Does **not** apply to other systems. GitHub uses the `Co-Authored-By: Claude ...` git trailer instead.

---

*Distributed via occb. Edit at `~/Projects/occb/global/notion-map.md`.*
