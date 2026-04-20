# Prerequisites

Before running `install.sh`, make sure your machine has the tools occb relies on. This page is for someone installing occb from zero — a new machine, or a new team member with no prior Claude Code setup.

`install.sh` itself will still run without most of these, but several baseline skills and commands expect them to be present.

---

## Required

### Claude Code

The CLI itself. If you don't have it: https://claude.com/claude-code

After install, run `claude` once to sign in with your Anthropic account.

### Git with SSH access to GitHub

occb is cloned from GitHub via SSH. You'll also clone your own `occb-personal` (private repo you create). Verify with:

```bash
ssh -T git@github.com
# should say: Hi <you>! You've successfully authenticated.
```

If not: [GitHub SSH setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh).

### `jq`

Used by `install.sh` to merge team + personal `settings.json`. Without it, only the team baseline gets applied.

```bash
brew install jq
```

### `gh` CLI (for GitHub operations)

Several skills (`gh-triage`, `solve-issues`, `code-review-cycle`) and commands expect `gh` to be authenticated.

```bash
brew install gh
gh auth login
```

---

## Strongly recommended

### 1Password CLI (`op`)

The team uses 1Password for all shared and personal secrets. `occb-personal/claude/mcp.json` is rendered from a template via `op inject`, so you need `op` to get your MCP servers wired up.

```bash
brew install 1password-cli
op signin
```

Ask an existing team member to add you to the `Agency Shared` vault.

Full secrets-handling conventions: `docs/06-secrets.md`.

### Python 3 (for notion-query MCP)

The custom `notion-query-mcp` server under `global/tools/` needs Python 3 + dependencies in a virtualenv:

```bash
cd ~/Projects/occb/global/tools/notion-query-mcp
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
```

Then point your `occb-personal/claude/mcp.json.template` at `.venv/bin/python` (see that tool's `README.md`).

macOS system Python is PEP-668 externally-managed — you **must** use a venv; plain `pip install` will refuse.

### Claude Code plugins

A few commands depend on plugin packages that aren't bundled with Claude Code:

- **superpowers** — planning, worktrees, sub-agent patterns
- **pr-review-toolkit** — used by `/code-review-cycle`
- **commit-commands** — used by `/orchestrate`

Install them with `claude plugin marketplace add anthropics/claude-plugins-official` followed by `claude plugin install <name>`. The full enabled list lives in `global/settings.json` under `enabledPlugins`.

---

## Optional — unlock more

### Notion workspace access

Many skills (`landscape-context`, `gh-triage`, project/task lookups) query Optimi's Notion workspace. You need to be invited to `optimi.notion.site` and have a personal API token in 1Password (`op://misc/notion_api _<you>/credential`).

Without Notion access: those skills will skip the Notion portion; everything else still works.

### MCP Launchpad (`mcpl`)

On-demand MCP server launcher for Google Workspace, GitHub, Fathom, Pinecone, Brave Search, GA4. See `docs/onboarding/mcpl-quickstart.md`.

### Google Workspace MCP

Gmail, Drive, Docs, Sheets, Calendar. Requires membership in Optimi's Google Cloud project. See `docs/onboarding/google-workspace-mcp-setup.md`.

### NotebookLM (`nlm`) + MCP server

Used by skills that create notebooks, add sources, or generate audio/report artifacts. Install + auth covered in `docs/tools/notebooklm-mcp.md`.

### `.env` file for MCP Launchpad

If you use `mcpl`, copy `global/.env.template` → `~/.claude/.env` and fill in the API keys you actually need. Nothing breaks if keys are missing — the affected MCP servers just won't connect.

---

## Verify you're ready

After installing the required tools, from a new terminal:

```bash
command -v claude git jq gh op python3 && echo "✅ required tools present"
ssh -T git@github.com 2>&1 | grep "successfully authenticated" && echo "✅ GitHub SSH"
gh auth status 2>&1 | grep "Logged in" && echo "✅ gh authenticated"
op account list 2>&1 | head -1 && echo "✅ 1Password signed in"
```

Once those pass, you're ready to `./install.sh`. See `docs/02-installation.md`.
