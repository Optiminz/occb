# Changelog

All notable changes to occb are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [0.2.0] — 2026-04-17

### Added
- **Command distribution** — `install.sh` now symlinks `global/commands/` into `~/.claude/commands/`, including reference subdirectories
- **11 shared commands:** `wrap`, `orchestrate` (+ references), `solve-issues`, `code-review-cycle`, `issues`, `reflect`, `repo-health`, `skill-audit`, `skill-scan`, `persona-to-agent`, `branding`
- **5 shared skills:** `gh-triage`, `repo-health`, `skill-audit`, `skill-scan`, `session-learnings`
- **1 shared script:** `fix-chrome-native-host.sh`
- `global/notion-map.md` — team Notion database reference (Tasks, Projects, Areas, Meetings, Resources, user IDs, task template, comment convention, task routing)
- Team baseline sections in `global/CLAUDE.md`: development workflows, complexity signaling, code style, dev environment, session learnings, preflight discipline, notion reference map pointer
- `uninstall.sh` now removes command and notion-map symlinks

### Changed
- `README.md` — rewritten with "what you get" table, proper Notion link with description, contributing guide, project templates reference
- `docs/01-orientation.md` — expanded from 3-line stub to useful summary of what the Notion page covers
- `docs/02-installation.md` — updated to document command and script distribution
- `CLAUDE.md` — updated repo structure table, contributing guide, and how-it-works section
- Moved team-applicable sections (communication style, complexity signaling, code style, zero-warning baseline, dev workflows, preflight discipline, session learnings) from personal config into the shared team baseline

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
- `global/settings.json` — team-baseline settings with status line config
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
