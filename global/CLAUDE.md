# Optimi Claude Code — Team Baseline

Distributed via occb. Don't edit your local symlinked copy — edit the source at `~/Projects/occb/global/CLAUDE.md`, commit, and run `./update.sh` to propagate.

Depth lives in `docs/` (conventions, secrets handling, preflight). This file is deliberately thin to keep every session cheap.

---

## Where does this config change go? (triage before editing)

If the user asks to change a setting, add a hook, change a model, add a permission, add a skill, or tweak CLAUDE.md behaviour — **stop and triage first**. Editing the wrong file either blows the change away on next `./install.sh`, or accidentally ships a personal preference to the whole team.

| Intent | File to edit | Propagation |
|--------|-------------|-------------|
| Team-wide rule, convention, shared hook | `~/Projects/occb/global/CLAUDE.md` or `global/settings.json` | **PR required** — another team member reviews for team-fit before merge; others get it on next `./install.sh` |
| Machine-global but mine only (permissions, personal preference, my-only hook, keys) | `~/Projects/occb-personal/CLAUDE.md` or `~/Projects/occb-personal/claude/settings.json` | Stays local; `./install.sh` merges it on top of team baseline |
| Scoped to a single repo | that repo's `.claude/settings.json` or `CLAUDE.md` | Per-project, committed with the repo |
| **NEVER edit directly** | `~/.claude/CLAUDE.md`, `~/.claude/settings.json`, or anything under `~/.claude/` that's a symlink or starts with `<!-- occb-generated -->` | Blown away on next `./install.sh` |

**Quick decision tree:** team affects Pete/Bryan → `occb/global/`. Personal (keys, machine paths) → `occb-personal/`. Single-repo → that repo's `.claude/`. If `~/Projects/occb-personal/` doesn't exist, create it with `CLAUDE.md`/`settings.json` inside, then re-run `./install.sh`.

**Team changes go via PR, always.** Any commit to `occb` needs another team member's eyes before merge — what feels right for you may not fit Pete or Bryan's setup. If you're not confident the change is genuinely team-shaped, put it in `occb-personal` first and promote later. Direct pushes to `occb main` are reserved for the maintainer fixing obvious breakage.

---

## Shared account discipline

The team currently shares two accounts — one Max plan and one Pro plan. Check your status line for 5-hour and weekly usage before spinning up orchestrated or long-running work. If either bucket is above 70%, coordinate in Slack first — and consider whether the Pro account is a better fit than Max for the job at hand. Avoid parallel orchestration runs without checking. Burning the shared quota without checking is the equivalent of using all the milk and not telling anyone.

---

## Sub-agent defaults

- **Sonnet by default.** Handles most work well.
- **Opus** only for architectural decisions, multi-step reasoning, nuanced code review. Not for search, file ops, or mechanical transforms.
- **Haiku** for mechanical work (repetitive tasks, formatting, lookups).
- **Advisor pattern:** run on Sonnet, consult Opus when stuck on a significant call. Cheaper than running the whole session on Opus.

---

## Cost discipline

- Don't use extended thinking unless the problem genuinely needs it.
- Prefer targeted searches (Grep/Glob) over broad agent exploration when the target is known.
- Parallel sub-agents must be truly independent — 10 agents for 10 sequential steps wastes quota.

---

## Env files — read local first

At runtime, the local `.env` (or `.env.<suffix>`) in the repo is **authoritative and always read directly**. Don't reach for 1Password or `op` just to read a secret for a task — read the `.env` file with the Read tool. 1Password is a sync/backup layer, not a runtime source. Use `op inject` / `op run` only when the user asks you to move bytes between disk and vault (rotation, onboarding a repo), never to satisfy a routine read. If the local `.env` exists, never probe 1Password.

---

## Sensitive data — park it in a `sensitive_data` folder

Any file containing sensitive data (keys, credentials, client PII, private correspondence, anything you'd not want Claude to read casually) should live in a folder whose name contains `sensitive_data`. The team baseline `settings.json` denies Read on `**/*sensitive_data*/**`, so anything under such a folder is off-limits across every project. Naming is the enforcement mechanism — if you want a file protected, put it in a `sensitive_data` folder; if you want Claude to read it, don't.

---

## Pointers (depth in `docs/`)

- **Planning** — plans before >30min work. See [`docs/08-conventions.md`](../docs/08-conventions.md).
- **Worktrees** — speculative work on a branch. See [`docs/08-conventions.md`](../docs/08-conventions.md).
- **Landscape context** — read repo + parent CLAUDE.md before editing; `landscape-context` skill automates. See [`docs/08-conventions.md`](../docs/08-conventions.md).
- **Dev workflow + zero-warning baseline** — See [`docs/08-conventions.md`](../docs/08-conventions.md).
- **Complexity signals + code style + dev env** — See [`docs/08-conventions.md`](../docs/08-conventions.md).
- **Session learnings** — `/wrap` at end, `/reflect` for learnings-only. See [`docs/08-conventions.md`](../docs/08-conventions.md).
- **Secrets with `op`** — cardinal rule: never reveal a secret into the transcript. See [`docs/06-secrets.md`](../docs/06-secrets.md).
- **Preflight** — skills/commands that write or run long need a `PREFLIGHT.md`. See [`docs/07-preflight.md`](../docs/07-preflight.md).
- **Patterns & antipatterns** — before non-trivial work, skim [`docs/03-patterns.md`](../docs/03-patterns.md) and [`docs/04-antipatterns.md`](../docs/04-antipatterns.md) for team-validated habits and known failure modes.

---

## Notion reference map

Key Notion database URLs, data source IDs, and field mappings live in `~/.claude/notion-map.md` (distributed via occb). **Always read this file before creating or updating any Notion entry** — correct data source IDs, field names, and option values (e.g. "Linked In" not "LinkedIn"). Personal/specialist databases may be in `~/.claude/notion-map-personal.md`.
