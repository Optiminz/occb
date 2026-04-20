# notebooklm-mcp (`nlm`)

Unofficial CLI + MCP server for Google NotebookLM. Used by skills that create or query notebooks, add sources, and generate audio/video/report artifacts (e.g. `deepdive`, `nate-signal-capture` follow-ups).

Upstream: https://github.com/lloydzhou/nlm (Python, distributed as the `nlm` CLI — the MCP server ships inside it, there is no separate package).

---

## Install

```bash
# Preferred — pipx keeps it isolated from system Python
brew install pipx
pipx install nlm-cli

# Or via uv / pip in a venv — pick one, don't mix
uv tool install nlm-cli
```

Binary lands at `~/.local/bin/nlm`. Confirm with `nlm --version`.

### Optional: `yt-dlp`

Needed only if you plan to add YouTube sources to notebooks via `source_add` (NotebookLM's own ingestion is unreliable for some videos, so `nlm` falls back to `yt-dlp` transcripts).

```bash
brew install yt-dlp
```

Skip if you only use web / Drive / text sources.

---

## First-run auth

```bash
nlm login
```

Opens a localized Chrome profile, you sign into Google normally, cookies persist in `~/.config/nlm/`. This is the one authoritative path — do **not** try to hand-feed cookies unless `nlm login` is broken (`--manual` flag exists as an escape hatch only).

Verify:

```bash
nlm login --check
nlm doctor
```

---

## Account switching

Multiple Google accounts (e.g. personal + Optimi Workspace) live as named profiles:

```bash
# Add a second profile
nlm login --profile optimi --clear   # --clear wipes old Chrome state so you can pick a different Google account

# Switch default
nlm login switch optimi
nlm login switch default

# List / manage
nlm login profile
```

The MCP server uses whatever the active default is. Switch before starting a Claude Code session if you need a specific workspace — the server reads the default at call time, but keeping it stable per-session avoids surprises.

---

## Register MCP server with Claude Code

```bash
nlm setup add "Claude Code"
```

This writes the server block into `claude mcp list`. Restart Claude Code after.

To remove:

```bash
nlm setup remove "Claude Code"
```

Skills that depend on the MCP server should point at this doc rather than repeat the install/auth story.

---

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `Authentication required` in MCP calls | `nlm login` (not `save_auth_tokens` — that's a fallback only) |
| Wrong Google account's notebooks appear | `nlm login switch <profile>`, restart Claude Code |
| YouTube source fails | install `yt-dlp`, retry |
| Stale Chrome profile after Google password change | `nlm login --profile <name> --clear` |
| Anything weirder | `nlm doctor` |
