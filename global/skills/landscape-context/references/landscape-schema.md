# `## Landscape` Section — Schema

A convention for repo-level `CLAUDE.md` files. Gives the `landscape-context` skill (and humans) a predictable place to find orientation pointers: which Notion Area this repo belongs to, which strategic pages to fetch, sibling repos, deploy targets, external dashboards.

**Why a `CLAUDE.md` section and not a separate YAML file?**

- Humans skim `CLAUDE.md` anyway — one less file to open.
- Agents grep for the fixed heading `## Landscape`.
- Lives with the repo, versions with it, no new file type to maintain.

---

## Canonical format

Drop this block into the repo's root `CLAUDE.md`, typically near the top after the repo description:

```markdown
## Landscape

- **Notion Area:** {Area name} — page `{area_page_id}`
- **Strategic pages:**
  - {Label} — `{page_id}`
  - {Label} — `{page_id}`
- **Sibling repos:** `{repo-a/}`, `{repo-b/}` (relationship note if useful)
- **Parent meta-repo:** `{path}` (omit if none)
- **Deploys to:** {target} (omit if none)
- **External dashboards:** {url or description} (omit if none)
- **Skip Notion phase:** {no | yes — reason}
```

### Field reference

| Field | Required | Purpose |
|-------|----------|---------|
| **Notion Area** | yes (unless `Skip Notion phase: yes`) | Drives Phase 2 project lookup |
| **Strategic pages** | no | Page IDs the skill will fetch for human context |
| **Sibling repos** | no | Other repos in the same logical workspace (meta-repo pattern) |
| **Parent meta-repo** | no | Path to a governing meta-repo (e.g. `~/Projects/MillLawCenter/`) |
| **Deploys to** | no | Production target — flags blast radius for changes |
| **External dashboards** | no | Grafana, Vercel, Sentry, etc. — where to look for live signals |
| **Skip Notion phase** | no | Set `yes — {reason}` for one-off tools or personal experiments |

Page IDs are raw 32-char hex (dashes optional). Labels are freeform — write what's useful, not what's pretty.

---

## Example — client repo (MLC)

```markdown
## Landscape

- **Notion Area:** Mill Law Centre — page `3237841666cb81e1a021d836db9ca44b`
- **Strategic pages:**
  - Strategic Account — `3237841666cb81e1a021d836db9ca44b`
  - Operations Intelligence — `3247841666cb81159a63d00f8147b3ba`
- **Sibling repos:** `mlc-context/` (gitignored, business context), `time-reconciler/` (nightly batch)
- **Parent meta-repo:** `~/Projects/MillLawCenter/`
- **Deploys to:** Vultr (nightly Ruby batch — Clio → Airtable)
- **Skip Notion phase:** no
```

## Example — internal tool

```markdown
## Landscape

- **Notion Area:** Ops — page `{ops_area_id}`
- **Skip Notion phase:** no
```

## Example — personal experiment

```markdown
## Landscape

- **Skip Notion phase:** yes — personal experiment, no client or Area tie-in
```

---

## How the skill consumes this

1. `landscape-context` reads the repo's `CLAUDE.md` and greps for the `## Landscape` heading.
2. If present, the bullets are parsed directly — no fallback lookup needed.
3. If absent, the skill falls back to [repo-area-map.md](repo-area-map.md) using the repo name pattern.
4. If `Skip Notion phase: yes`, Phase 2 is skipped outright.

The fallback map stays useful for repos that haven't adopted the section yet, and for the skill to warn when a repo is missing its Landscape block.

---

## Migration

For existing repos, the first `/repo-health` run after this schema lands will WARN when `## Landscape` is missing and offer to generate it from the fallback map. Don't bulk-migrate — let repos adopt as they're touched.
