# occb — Optimi Claude Code Baseline

Shared baseline for how the Optimi team uses Claude Code. Distributes team-aligned global config, commands, skills, and scripts via `install.sh` into `~/.claude/`.

**This is a config repo** — no application code. Shell scripts (`install.sh`, `update.sh`, `uninstall.sh`) are the only executable components.

---

## Repo Structure

| Path | Purpose |
|------|---------|
| `global/CLAUDE.md` | Team baseline — concatenated into `~/.claude/CLAUDE.md` on install |
| `global/settings.json` | Symlinked to `~/.claude/settings.json` |
| `global/commands/` | Commands distributed to `~/.claude/commands/` |
| `global/skills/` | Skills distributed to `~/.claude/skills/` |
| `global/scripts/` | Scripts distributed to `~/.claude/scripts/` |
| `docs/` | Patterns, anti-patterns, installation guide, ADRs |
| `project-templates/` | Starter CLAUDE.md template and bootstrap script for new repos |
| `install.sh` / `update.sh` / `uninstall.sh` | Install/update/remove lifecycle |

## How it works

1. `install.sh` generates `~/.claude/CLAUDE.md` from `occb-personal/CLAUDE.md` (personal, first) + `global/CLAUDE.md` (team baseline, second)
2. Symlinks `global/settings.json`, `global/commands/*`, `global/skills/*`, and `global/scripts/*` into `~/.claude/`
3. `update.sh` pulls latest, re-runs install, shows CHANGELOG delta

See `docs/02-installation.md` for full details.

## Contributing

- **Team conventions:** edit `global/CLAUDE.md`, commit, PR
- **New commands:** add to `global/commands/`, re-run `install.sh`
- **New skills:** add a directory under `global/skills/` with a `SKILL.md`
- **New patterns/anti-patterns:** add to `docs/03-patterns.md` or `docs/04-antipatterns.md`
- **New ADRs:** add to `docs/decisions/` following the existing numbering

## Key context

- Orientation lives in Notion — see [docs/01-orientation.md](docs/01-orientation.md) for the link
- `occb-personal` is a separate private repo layered in at install time — see [docs/05-personal-config.md](docs/05-personal-config.md)
- The `/.claude/` directory is gitignored (Claude Code project harness, not part of the scaffold)

---

**Last Updated:** 2026-04-17
