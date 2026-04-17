# Plugin Sync Between Machines

## How It Works

Claude Code plugins are **machine-specific** and don't sync through git:

- ✅ **Tracked in git:** `settings.json` (contains enabled plugin list)
- ❌ **Not tracked:** Plugin installations, marketplace config

## Setup New Machine

When you clone `~/.claude` to a new machine, run:

```bash
cd ~/.claude
./setup-plugins.sh
```

This script will:
1. Add the official plugin marketplace
2. Read `settings.json` to see which plugins you use
3. Install all plugins listed
4. Apply enabled/disabled states

## Manual Setup

If you prefer manual installation:

```bash
# 1. Add marketplace
claude plugin marketplace add anthropics/claude-plugins-official

# 2. Install plugins (from settings.json)
claude plugin install commit-commands agent-sdk-dev github Notion

# 3. Disable specific plugins (if needed)
claude plugin disable github
```

## Adding New Plugins

When you install a plugin on one machine:

```bash
# Install on machine 1
claude plugin install my-new-plugin

# The enabledPlugins in settings.json will update
# Commit and push settings.json
cd ~/.claude
git add settings.json
git commit -m "Add my-new-plugin"
git push

# On machine 2: pull and run setup script
git pull
./setup-plugins.sh
```

## Current Plugins

Based on `settings.json` (updated 2026-04-04):

**Enabled:**
- ✅ `commit-commands@claude-plugins-official`
- ✅ `agent-sdk-dev@claude-plugins-official`
- ✅ `superpowers@claude-plugins-official`
- ✅ `frontend-design@claude-plugins-official`
- ✅ `code-review@claude-plugins-official`
- ✅ `security-guidance@claude-plugins-official`
- ✅ `hookify@claude-plugins-official`
- ✅ `playground@claude-plugins-official`
- ✅ `supabase@claude-plugins-official`
- ✅ `postgres-best-practices@supabase-agent-skills`
- ✅ `feature-dev@claude-plugins-official`
- ✅ `pr-review-toolkit@claude-plugins-official`
- ✅ `playwright@claude-plugins-official`
- ✅ `mcp-server-dev@claude-plugins-official`

**Disabled:**
- ❌ `github@claude-plugins-official`
- ❌ `pinecone@claude-plugins-official`
- ❌ `ralph-loop@claude-plugins-official`
- ❌ `vercel@claude-plugins-official`
- ❌ `slack@claude-plugins-official`
- ❌ `firecrawl@claude-plugins-official`

## Why Machine-Specific?

Plugin installations include:
- Downloaded code from marketplace repos
- Installation metadata (install counts, cache)
- Platform-specific binaries (for LSP plugins)

These should regenerate per machine rather than sync through git.
