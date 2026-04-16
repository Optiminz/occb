List open GitHub issues for the current repo with staleness classification.

## Steps

1. Detect the repo's GitHub remote: `git remote get-url origin`
2. Run `gh issue list --state open --limit 50 --json number,title,createdAt,updatedAt,labels,assignees`
3. For each issue, classify by age (from `updatedAt`):
   - **Active** — updated within last 30 days
   - **Stale** — no update in 30-89 days
   - **Abandoned** — no update in 90+ days
4. Present as a table:

```
## Open Issues: {repo-name}
Date: {today}

| # | Title | Age | Status | Labels |
|---|-------|-----|--------|--------|
| 6 | Setup Attio CRM | 1d | Active | — |

Summary: N open (N active, N stale, N abandoned)
```

5. If there are abandoned issues, ask: "Want me to close any of these, or add comments?"

This is **read-only by default** — don't modify issues unless asked.

$ARGUMENTS
