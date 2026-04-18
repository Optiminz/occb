# MCP Launchpad (mcpl) Quickstart

mcpl lets Claude Code access external services (GitHub, Google Workspace, Pinecone, etc.) via bash commands instead of loading MCP tools into the system prompt. This saves ~21,000+ tokens per session.

---

## How It Works

Instead of enabling MCP plugins (which inject tool definitions into every conversation), mcpl runs MCP servers on-demand via bash:

```bash
# Plugin approach (always loaded, costs tokens):
# Claude sees 100+ Google Workspace tools in system prompt

# mcpl approach (on-demand, zero token cost):
mcpl call google-workspace searchGmail '{"account": "<your-account>", "query": "is:unread"}'
```

---

## Setup

### 1. Install mcpl

```bash
# Check current install method at the mcpl repo
npm install -g @anthropic-ai/mcpl
```

### 2. Configure Servers

Edit `~/.claude/mcpl.json` to add MCP servers. Each server entry specifies:
- Server name (used in `mcpl call <server> ...`)
- Transport type (stdio, HTTP)
- Command/URL to start the server
- Environment variables (API keys, etc.)

### 3. Environment Variables

Store API keys in `~/.claude/.env`:

```bash
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
PINECONE_API_KEY=pc_...
```

---

## Common Commands

```bash
# List all tools for a server
mcpl list github
mcpl list google-workspace
mcpl list pinecone

# Search across all servers
mcpl search "gmail"

# Inspect a specific tool (see parameters)
mcpl inspect github list_issues
mcpl inspect github list_issues --example

# Call a tool
mcpl call <server> <tool> '{"param": "value"}'

# Check daemon status
mcpl session status

# Restart daemon (fixes most issues)
mcpl session stop

# Verify all servers
mcpl verify

# Bypass daemon for debugging
mcpl call github get_me '{}' --no-daemon
```

---

## Configured Servers (Optimi)

| Server | What It Covers | Auth |
|--------|---------------|------|
| `github` | Repos, issues, PRs, actions | `GITHUB_PERSONAL_ACCESS_TOKEN` in `~/.claude/.env` |
| `google-workspace` | Gmail, Drive, Docs, Sheets, Calendar, Slides, Forms | OAuth tokens in `~/.google-mcp/tokens/` |
| `pinecone` | Vector database operations | `PINECONE_API_KEY` in `~/.claude/.env` |
| `fathom` | Meeting recordings, transcripts, summaries, action items | `FATHOM_API_KEY` in `~/.claude/.env` |
| `ga4-analytics` | Google Analytics 4 — website traffic, events, user behaviour | Service account JSON (hardcoded path in mcpl.json) |
| `brave-search` | Web search | `BRAVE_API_KEY` in `~/.claude/.env` |

See individual setup guides for each server:
- [Google Workspace MCP Setup](google-workspace-mcp-setup.md)

---

## When to Use mcpl vs Claude Code Plugins

| Use mcpl | Use plugins |
|----------|-------------|
| Occasional tool usage | Tools needed every session |
| Want to save tokens | OAuth requires plugin flow (e.g., Notion) |
| Server supports stdio/HTTP | mcpl has compatibility issues |

---

## Troubleshooting

| Problem | Fix |
|---------|-----|
| "Tool not found" | `mcpl list <server>` — check server name and tool name |
| Connection refused | `mcpl session stop` then retry |
| Auth errors | Check `~/.claude/.env` has the right keys |
| Slow responses | First call starts the daemon — subsequent calls are faster |
