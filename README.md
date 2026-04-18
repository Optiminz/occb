# occb — Optimi Claude Code Baseline

Shared baseline for how the Optimi team uses Claude Code. Distributes team-aligned global config, commands, skills, and scripts via `install.sh` into `~/.claude/`.

> v0.1.1 — the team hasn't fully converged on all conventions yet. Where things are open, the docs say so.

## Install

```bash
git clone git@github.com:Optiminz/occb.git ~/Projects/occb
cd ~/Projects/occb
# First-time only, if you already have a populated ~/.claude/ setup:
./bootstrap.sh
./install.sh
```

**If `~/.claude/` is empty** (new machine, new user), skip straight to `./install.sh`.

**If you've been using Claude Code already** and have your own `~/.claude/CLAUDE.md` or `~/.claude/settings.json`, run `./bootstrap.sh` first. It snapshots your existing setup, splits it into blocks, and asks you to sort each block into: personal (goes to `occb-personal`), promote (staged for a team PR), delete, or keep-as-is. Then `./install.sh` takes over.

`install.sh` generates `~/.claude/CLAUDE.md` from your personal config (if present) plus the team baseline, and symlinks settings, commands, skills, and scripts into `~/.claude/`. Backs up any pre-existing config first.

> Note: `project-templates/bootstrap.sh` is a different script — it scaffolds a new client repo, not occb onboarding. Don't confuse the two.

See [docs/02-installation.md](docs/02-installation.md) for full details and recovery instructions.

## What you get after install

| Component | What it does |
|-----------|-------------|
| `~/.claude/CLAUDE.md` | Generated from your personal config + team baseline |
| `~/.claude/settings.json` | Status line (usage buckets, branch, model) + theme |
| `~/.claude/notion-map.md` | Team Notion databases — schemas, user IDs, task template, comment convention |
| **11 commands** | `/wrap`, `/orchestrate`, `/solve-issues`, `/code-review-cycle`, `/issues`, `/reflect`, `/repo-health`, `/skill-audit`, `/skill-scan`, `/persona-to-agent`, `/branding` |
| **6 skills** | `landscape-context`, `gh-triage`, `repo-health`, `skill-audit`, `skill-scan`, `session-learnings` |
| **2 scripts** | `statusline.sh`, `fix-chrome-native-host.sh` |

Your personal commands, skills, and scripts in `~/.claude/` are left untouched — occb only manages what it installed.

## Orientation

**[occb — Optimi Claude Code Baseline (Layer 1: Orientation)](https://www.notion.so/3447841666cb813cb2e0d67f57ec952e)** — Notion doc for experienced devs joining Optimi. Covers how config gets assembled, the Pete/Malcolm working-style spectrum, three setup tiers (baseline → recommended → optional), MLC and Knack client context, and landscape-context philosophy.

Start there if you're new.

## Who it's for

Malcolm, Pete, Bryan — and anyone else onboarding to the Optimi Claude Code setup.

## What it is (and isn't)

**In:** team-alignment conventions, shared commands and skills, sub-agent defaults, cost discipline, planning conventions, shared anti-patterns.

**Out:** project-specific config (MLC, Knack clients), personal skills, Malcolm's ADO, Pete's personal setup. Those go in your `occb-personal` repo — see [docs/05-personal-config.md](docs/05-personal-config.md).

## Project templates

`project-templates/` contains a starter `CLAUDE.md` template and `bootstrap.sh` for scaffolding new client repos. See the files there for usage.

## Shell templates (opt-in)

`shell-templates/` contains optional zsh snippets — currently `terminal-launcher.zsh`, a fresh-shell menu (claude / npm run dev / pullall / shell) plus a `pullall` bulk-git-pull function. Not auto-installed; copy or source it from your own `~/.zshrc` and customise the repo list. See [shell-templates/README.md](shell-templates/README.md).

## Contributing

- **Team conventions:** edit `global/CLAUDE.md`, commit, PR
- **New commands:** add to `global/commands/`, re-run `install.sh`
- **New skills:** add a directory under `global/skills/` with a `SKILL.md`
- **New patterns/anti-patterns:** add to `docs/03-patterns.md` or `docs/04-antipatterns.md`
- **New ADRs:** add to `docs/decisions/` following the existing numbering

## Docs

| Doc | What it covers |
|-----|---------------|
| [01-orientation.md](docs/01-orientation.md) | Pointer to the Notion orientation page |
| [02-installation.md](docs/02-installation.md) | Full install details, env vars, recovery |
| [03-patterns.md](docs/03-patterns.md) | Team-validated patterns |
| [04-antipatterns.md](docs/04-antipatterns.md) | Things we've learned not to do |
| [05-personal-config.md](docs/05-personal-config.md) | The two-repo personal + team setup |
| [onboarding/](docs/onboarding/) | Setup guides: Claude Code, env sync, MCPs |
| [context/](docs/context/) | Team and client reference for new sessions |
| [decisions/](docs/decisions/) | Architecture Decision Records |
