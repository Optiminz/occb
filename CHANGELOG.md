# Changelog

All notable changes to occb are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

---

## [Unreleased]

### Removed
- **Plugin sync tooling** — `global/PLUGIN_SYNC.md` and `global/setup-plugins.sh` moved to `occb-personal/claude/` (plugin preferences are per-person, not team-shared). Existing `~/.claude/` symlinks re-point to the personal copy on next `./install.sh`.

---

## [0.3.0] — 2026-04-17

### Added
- **Onboarding docs** — `docs/onboarding/claude-code-setup.md`, `docs/onboarding/env-sync-convention.md`
- **Team context** — `docs/context/team-directory.md`, `docs/context/client-context-technical.md` (trimmed technical-team version, revenue/strategic notes stay in oai)
- **Shared agents:** `frontend-design-orchestrator`, `technical-writer` in `global/agents/`
- **Shared skills:** `marp-slides` (Optimi-themed deck generator), `notion-tidy`
- **Brand assets:** `global/assets/optimi/*.png` (logo set — color, white, icon, landscape, portrait, favicon, email signature)
- **Plugin sync tooling:** `global/PLUGIN_SYNC.md` + `global/setup-plugins.sh` — reproducible Claude Code plugin setup
- **Env template:** `global/.env.template` — MCP env var reference
- **Org context:** `global/org-context.md` — shared org-level context (process stays personal in `refresh-org-context`)
- **Landscape schema:** `global/skills/landscape-context/references/landscape-schema.md` — per-repo `## Landscape` CLAUDE.md block; repo-health Check 14 flags missing blocks
- **Preflight** — `global/skills/repo-health/PREFLIGHT.md` (blast radius, failure mode, runaway protection)
- **Bootstrap** — `bootstrap.sh` at repo root for first-time onboarding against a populated `~/.claude/`
- Wrap Config section in `project-templates/CLAUDE.md.template` so new repos are wrap-compatible
- `docs/archive/` — old build plans out of the way

### Changed
- **`install.sh` personal layering** — `settings.json` is now a merged file (team ∪ personal via `jq`) instead of a symlink. Claude Code's auto-writes no longer land in team-shared files. Personal preferences (e.g. `effortLevel`) live in `occb-personal/settings.json`.
- **Full occb-personal tree support** — personal files now mirror `~/.claude/` structure under `occb-personal/claude/`. `install.sh` walks the tree and descends one level into shared dirs (`commands/`, `skills/`) when they already exist as real dirs.
- **Preflight guards** — `install.sh` now warns if `~/.claude/` is itself a git repo (collides with occb) and checks for unresolved merge-conflict markers in generated `CLAUDE.md`.
- **landscape-context skill** fully implemented (previously a stub) — reads CLAUDE.md tree, learnings, and Notion context for orientation before non-trivial work.
- **Statusline** — context usage now a percent with bolding over 70%; 5-hour and weekly quota reset times displayed; dirty-branch indicator.
- **CLAUDE.md triage table** — new "Where does this config change go?" section prevents the #1 new-user mistake of editing the wrong file.
- **Secrets handling** — added `op` CLI secrets-handling rules to `global/CLAUDE.md`.
- **Cal** — marked as former team member in `notion-map.md`.

### Removed (demoted to `occb-personal`)
- `commands/skill-scan.md` + `skills/skill-scan/` — unproven, not ready for Pete/Bryan yet
- `commands/persona-to-agent.md` — unproven

### Fixed
- Stale "WIP/stub" language for landscape-context skill in `global/CLAUDE.md` and `docs/03-patterns.md`
- Archived `2026-04-16-occb-scaffold` build plan (all boxes unchecked, noise for new contributors)

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
