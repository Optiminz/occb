# occb Learnings

## Conventions

### Tool docs: `global/tools/` vs `docs/external-tools/`

Two distinct homes for tool documentation — don't conflate them:

- **`global/tools/<name>/README.md`** — for tools this repo **vendors** (ships code for). Example: `notion-query-mcp` — Python server lives here, gets symlinked into `~/.claude/` on install.
- **`docs/external-tools/<name>.md`** — for **external upstream** CLIs/MCP servers the team depends on but doesn't own. Example: `notebooklm-mcp.md` (the `nlm` CLI). Covers install, first-run auth, account switching, Claude Code registration, troubleshooting.

Skills that depend on an external tool should link to `docs/external-tools/<name>.md` rather than repeat setup inline. Add a one-liner pointer under the relevant section of `docs/02-prerequisites.md` so it's discoverable from the onboarding path.

**Captured:** 2026-04-18
