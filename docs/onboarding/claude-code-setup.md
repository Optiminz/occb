# Claude Code Setup — Optimi Team

Everything you need to get Claude Code working with the full Optimi toolkit.

---

## 1. Install Claude Code

```bash
npm install -g @anthropic-ai/claude-code
```

Set your API key when prompted on first run, or export `ANTHROPIC_API_KEY` in your shell profile.

---

## 2. Install occb

Before anything else, install the team baseline:

```bash
cd ~/Projects
git clone git@github.com:optimi-ai/occb.git
cd occb && ./install.sh
```

This symlinks team skills, commands, scripts, and the notion-map into `~/.claude/`. See `docs/02-installation.md` for detail.

Personal config layers on top — see `docs/05-personal-config.md` for how to set up `occb-personal`.

---

## 3. Essential Plugins

Enable these via `/plugins` in Claude Code. All are from the official marketplace unless noted.

### Must-Have

| Plugin | What it does |
|--------|-------------|
| **commit-commands** | `/commit`, `/commit-push-pr` — standardised git workflows |
| **superpowers** | Planning, code review, brainstorming, debugging workflows |
| **Notion** | Direct Notion read/write (tasks, databases, pages) |
| **playwright** | Browser automation — testing, screenshots, form filling |
| **hookify** | Create hooks to prevent unwanted Claude behaviours |

### Development

| Plugin | What it does |
|--------|-------------|
| **vercel** | Full Vercel ecosystem guidance — Next.js, AI SDK, deployment |
| **frontend-design** | Distinctive UI generation (avoids generic AI aesthetics) |
| **feature-dev** | Guided feature development with architecture focus |
| **agent-sdk-dev** | Claude Agent SDK app scaffolding |
| **supabase** | Supabase integration |
| **postgres-best-practices** | Postgres query and schema optimisation (Supabase) |

### Code Quality

| Plugin | What it does |
|--------|-------------|
| **code-review** | PR code review |
| **pr-review-toolkit** | Comprehensive PR review with specialised agents |
| **security-guidance** | Security best practices |

### Utility

| Plugin | What it does |
|--------|-------------|
| **playground** | Interactive HTML playgrounds for exploring ideas |
| **ralph-loop** | Recurring task runner |

### Currently Disabled (team default)

| Plugin | Why |
|--------|-----|
| **github** | Using mcpl for GitHub instead (saves tokens) |
| **pinecone** | Using mcpl for Pinecone instead |
| **slack** | Not yet configured |
| **firecrawl** | Not yet needed |

---

## 4. Cloud-Hosted MCP Servers

These run on Anthropic/third-party infrastructure — authenticated via OAuth in Claude Code settings. They load into every session automatically (no local setup beyond connecting your account).

| Server | Purpose | How to connect |
|--------|---------|----------------|
| **Zapier MCP** | Google Sheets, Slack, MailerLite, Zapier management | Claude Code MCP settings → Add Zapier |
| **Gmail** | Email drafting, search, reading | Claude Code MCP settings → Add Gmail |
| **Google Calendar** | Events, scheduling, free time | Claude Code MCP settings → Add Google Calendar |
| **Notion** | Pages, databases, search | Claude Code plugin (OAuth) |

---

## 5. MCP Launchpad (mcpl) — On-Demand Servers

mcpl runs MCP servers on-demand via bash instead of loading them into every session. Saves ~21k tokens.

**Config:** `~/.claude/mcpl.json`

| Server | Purpose | Auth |
|--------|---------|------|
| **github** | Repos, issues, PRs, actions | `GITHUB_PERSONAL_ACCESS_TOKEN` in `~/.claude/.env` |
| **google-workspace** | Gmail, Drive, Docs, Sheets, Calendar | OAuth tokens in `~/.google-mcp/tokens/` |
| **pinecone** | Vector database operations | `PINECONE_API_KEY` in `~/.claude/.env` |
| **fathom** | Meeting recordings, transcripts, summaries, action items | `FATHOM_API_KEY` in `~/.claude/.env` |
| **ga4-analytics** | Google Analytics 4 — website traffic, events, user behaviour | Service account JSON + `GA4_PROPERTY_ID` (hardcoded in mcpl.json) |
| **brave-search** | Web search | `BRAVE_API_KEY` in `~/.claude/.env` |

```bash
# Quick reference
mcpl list <server>                    # See available tools
mcpl call <server> <tool> '{json}'    # Call a tool
mcpl session stop                     # Restart daemon (fixes most issues)
```

For mcpl Google Workspace tools, pass your own account name (configured during setup) — not someone else's.

See [mcpl quickstart](./mcpl-quickstart.md) and [Google Workspace setup](./google-workspace-mcp-setup.md) for detailed guides.

> **GA4 note:** The GA4 MCP uses a Google Cloud service account (not personal OAuth). The credentials JSON and property ID are hardcoded in `mcpl.json`. Team members need the service account file at the same path, or update their `mcpl.json` to point to their own copy. Ask Malcolm for the service account file — it's not in any repo.

---

## 6. Environment Variables

Store API keys in `~/.claude/.env` (never committed to git):

```bash
GITHUB_PERSONAL_ACCESS_TOKEN=ghp_...
PINECONE_API_KEY=pc_...
FATHOM_API_KEY=...
BRAVE_API_KEY=...
```

Cloud-hosted MCPs (Zapier, Gmail, Calendar) authenticate via OAuth in Claude Code settings — no local keys needed.

See [env-sync-convention](./env-sync-convention.md) for how the team syncs `.env` files between machines via 1Password.

---

## 7. CLI Tools (Non-MCP)

Tools Claude Code can use via bash that aren't MCP servers but are part of the toolkit.

| Tool | Purpose | Install |
|------|---------|---------|
| **1Password CLI (`op`)** | Retrieve secrets, credentials, API keys from 1Password vaults | [developer.1password.com/docs/cli/get-started](https://developer.1password.com/docs/cli/get-started/) |
| **pull-env / push-env** | Sync `.env` files between 1Password and disk | See [env-sync-convention](./env-sync-convention.md) |

### 1Password CLI

Claude Code can use `op` to look up credentials without storing them in plaintext:

```bash
op item get "Service Name" --fields label=password
op item list --vault "Optimi"
op item get "Service Name" --otp
```

> **Setup:** Install the CLI, then run `op signin` to authenticate. Requires the 1Password desktop app with CLI integration enabled (Settings → Developer → Integrate with 1Password CLI).

---

## 8. Custom Skills (Optimi-Specific)

Team-shared skills are distributed via occb and appear as `/command` shortcuts. Key ones:

| Skill | What it does |
|-------|-------------|
| `/wrap` | End-of-session cleanup — commit, push, capture learnings |
| `/reflect` | Session reflection — capture learnings only |
| `/repo-health` | Cross-repo health audit against Optimi standards |
| `/gh-triage` | Review and triage GitHub issues on current repo |
| `/skill-scan` | Scan a repo for skill candidates |
| `/skill-audit` | Audit existing skills against quality criteria |
| `/branding` | Optimi brand guidelines reference |
| `/refresh-org-context` | Refresh cached org strategy from Notion |
| `landscape-context` | Orientation before non-trivial work (auto-triggers) |

Personal skills (callprep, notion-tidy, etc.) live in your own `~/.claude/skills/` — not distributed via occb.

---

## 9. Key Configuration

### Settings (`~/.claude/settings.json`)

- Team baseline symlinked from `occb/global/settings.json`
- Personal overrides layered via `occb-personal/settings.json`
- Safety denials: force push, hard reset, clean, drop, truncate, rm -rf all blocked

### Project Config

Each repo has its own `CLAUDE.md` with project-specific instructions. Read it before working in any repo. The `landscape-context` skill handles this automatically.

---

## 10. Getting Started Checklist

- [ ] Install Claude Code
- [ ] Clone and install occb (`~/Projects/occb && ./install.sh`)
- [ ] (Optional) Create `occb-personal` for personal overrides
- [ ] Run `/plugins` and enable the must-have plugins listed above
- [ ] Set up `~/.claude/.env` with your API keys
- [ ] Install mcpl: `npm install -g @anthropic-ai/mcpl`
- [ ] Copy `mcpl.json` config (ask Malcolm for the current version)
- [ ] Set up Google Workspace MCP (see [setup guide](./google-workspace-mcp-setup.md))
- [ ] Ask Malcolm to add you as a test user on the Google Cloud OAuth project
- [ ] Install `pull-env` / `push-env` and fetch `.env` files for the repos you need
- [ ] Run `claude` in a project repo and check everything connects
