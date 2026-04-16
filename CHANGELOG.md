# Changelog

All notable changes to occb are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [0.1.1] — 2026-04-16

### Changed
- `install.sh` — CLAUDE.md is now generated (not symlinked) from personal + team sources
- `uninstall.sh` — detects and removes generated CLAUDE.md (not symlink)

### Added
- `docs/05-personal-config.md` — explains the two-repo setup for personal config
- Support for `~/Projects/occb-personal/` as the personal config source

---

## [0.1.0] — 2026-04-16

### Added
- `install.sh` — idempotent install with backup and symlink management
- `update.sh` — pulls latest, re-runs install, shows CHANGELOG diff since last run
- `uninstall.sh` — removes occb symlinks, offers to restore most recent backup
- `global/CLAUDE.md` — team-baseline instructions: shared account discipline, sub-agent defaults, planning convention, worktrees, landscape context, cost discipline
- `global/settings.json` — team-baseline settings with status line config (TODO: verify status line syntax)
- `global/skills/landscape-context/SKILL.md` — stub skill, WIP
- `docs/01-orientation.md` — placeholder pointing at Notion
- `docs/02-installation.md` — detailed install and recovery notes
- `docs/03-patterns.md` — seed patterns library (5 patterns)
- `docs/04-antipatterns.md` — seed with 1Password CLI rabbit hole story
- `docs/decisions/README.md` — ADR format + index
- `docs/decisions/0001-sub-agent-defaults.md`
- `docs/decisions/0002-superpowers-as-baseline.md`
- `docs/decisions/0003-worktrees-for-experiments.md`
- `project-templates/CLAUDE.md.template` — starter project-level CLAUDE.md
- `project-templates/bootstrap.sh` — generic folder-structure bootstrap
- `personal/README.md` — explains the gitignored personal space
