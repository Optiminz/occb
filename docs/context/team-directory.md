# Team Directory

Thin index of who's on the Optimi team — names, roles, timezones — so AI can route tasks and reference people correctly. For anything deeper (current capacity, working patterns, project involvement, background), search Notion for the person's profile page.

---

## Current team

| Name | Role | Timezone |
|------|------|----------|
| Malcolm Colman-Shearer | Founder, strategy, client advisory | NZ (UTC+12/+13) |
| John Gieryn | Business partner, operations | NZ (UTC+12/+13) |
| Pete | Developer, technical lead | NZ (UTC+12/+13) |
| Bryan Cabansay | Developer | Philippines (UTC+8) |
| Karen | Virtual assistant, admin & bookkeeping | Philippines (UTC+8) |

**Routing defaults** (for AI suggestions, not fixed rules):
- Technical work → Pete (primary), Bryan (support)
- Admin and structured SOPs → Karen
- Operations and internal systems → John
- Strategy, positioning, client relationships → Malcolm

---

## Finding someone's profile

Search Notion by name — each team member has a profile page with current role, capacity, working patterns, and active projects. That's the source of truth for anything beyond the table above.

```
# In Notion MCP
mcp__claude_ai_Notion__notion-search({ query: "<First Last>", query_type: "internal" })
```

Don't hard-code capacity hours, equity arrangements, or working-genius-style judgments into this or any other distributed file. That kind of detail is private to the individual's profile and changes over time.

---

## Timezones

Two poles: **NZ (UTC+12 winter / +13 summer)** and **Philippines (UTC+8)**. ~4–5 hour gap. Asynchronous communication is the default; never assume a real-time response.

---

## Notion user IDs

For assigning Notion tasks and relations, see the "Team IDs" table in `~/.claude/notion-map.md`.
