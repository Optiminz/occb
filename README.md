# occb — Optimi Claude Code Baseline

Shared baseline for how the Optimi team uses Claude Code. Distributes team-aligned global config, patterns docs, and light tooling via symlinks into `~/.claude/`.

> v0.1 — the team hasn't fully converged on all conventions yet. Where things are open, the docs say so.

## Install

```bash
git clone git@github.com:Optiminz/occb.git ~/Projects/occb
cd ~/Projects/occb
./install.sh
```

Symlinks `global/CLAUDE.md` and `global/settings.json` into `~/.claude/`. Backs up any pre-existing config first.

See [docs/02-installation.md](docs/02-installation.md) for full details and recovery instructions.

## Orientation

TODO: add Notion URL

## Who it's for

Malcolm, Pete, Bryan — and anyone else onboarding to the Optimi Claude Code setup.

## What it is (and isn't)

**In:** team-alignment conventions, sub-agent defaults, cost discipline, planning conventions, shared anti-patterns.

**Out:** project-specific config (MLC, Knack clients), personal skills, Malcolm's ADO, Pete's personal setup.
