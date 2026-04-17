# occb Scaffold Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold the `occb` (Optimi Claude Code Baseline) repo at `~/Projects/occb/` with install/update/uninstall scripts, team-baseline Claude Code config, documentation, and project templates.

**Architecture:** File-creation scaffold. Scripts handle symlink management for `~/.claude/` distribution. Docs are Markdown. Validation is running `install.sh` against a clean and a pre-existing `~/.claude/` setup.

**Tech Stack:** Bash (scripts), Markdown (docs/templates), JSON (settings)

---

### Task 1: Initialize repo and create directory structure

**Files:**
- Create: `~/Projects/occb/` (git repo)
- Create: full directory tree

- [ ] **Step 1: Initialize git and create all directories**

```bash
cd ~/Projects/occb
git init
mkdir -p global/skills/landscape-context
mkdir -p project-templates/.claude
mkdir -p docs/decisions
mkdir -p personal
```

- [ ] **Step 2: Verify structure**

```bash
find ~/Projects/occb -not -path '*/.git/*' -type d | sort
```

Expected:
```
~/Projects/occb
~/Projects/occb/docs
~/Projects/occb/docs/decisions
~/Projects/occb/docs/superpowers
~/Projects/occb/docs/superpowers/plans
~/Projects/occb/global
~/Projects/occb/global/skills
~/Projects/occb/global/skills/landscape-context
~/Projects/occb/personal
~/Projects/occb/project-templates
~/Projects/occb/project-templates/.claude
```

- [ ] **Step 3: Commit**

```bash
cd ~/Projects/occb
git add -A
git commit -m "chore: initialize repo structure"
```

---

### Task 2: .gitignore

**Files:**
- Create: `~/Projects/occb/.gitignore`

- [ ] **Step 1: Write .gitignore**

```
# Personal per-developer space — gitignored
personal/*
!personal/README.md
!personal/.gitkeep

# Install state marker
.occb-last-update

# macOS
.DS_Store
.AppleDouble
.LSOverride

# Editors
.vscode/
.idea/
*.swp
*.swo
*~

# Misc
*.log
```

- [ ] **Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: add .gitignore"
```

---

### Task 3: install.sh

**Files:**
- Create: `~/Projects/occb/install.sh`

- [ ] **Step 1: Write install.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

OCCB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
BACKUP_DIR="$HOME/.claude-backup-${TIMESTAMP}"
QUIET="${OCCB_QUIET:-false}"
EXIT_CODE=0

log() { [[ "$QUIET" != "true" ]] && echo "$@" || true; }
warn() { echo "⚠️  $*" >&2; EXIT_CODE=1; }

# Ensure ~/.claude/skills exists
mkdir -p "$CLAUDE_DIR/skills"

# --- Helper: is this path an occb symlink? ---
is_occb_symlink() {
  local path="$1"
  [[ -L "$path" ]] && [[ "$(readlink "$path")" == "$OCCB_DIR/"* ]]
}

# --- Back up and symlink a single file ---
link_file() {
  local src="$1"   # absolute path under occb/global/
  local dst="$2"   # absolute path under ~/.claude/
  local label="$3"

  if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
    mkdir -p "$BACKUP_DIR"
    cp -a "$dst" "$BACKUP_DIR/$(basename "$dst")"
    log "  backed up $dst → $BACKUP_DIR/$(basename "$dst")"
    rm "$dst"
  elif is_occb_symlink "$dst"; then
    log "  $label already linked, skipping"
    return
  fi

  ln -sf "$src" "$dst"
  log "  linked $label"
}

# --- Symlink skills directories ---
link_skills() {
  local skills_src="$OCCB_DIR/global/skills"
  local skills_dst="$CLAUDE_DIR/skills"

  for skill_dir in "$skills_src"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local name
    name=$(basename "$skill_dir")
    local dst="$skills_dst/$name"

    if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
      warn "skill '$name' already exists in ~/.claude/skills/ and is not an occb symlink — skipping. Remove or rename it to install the occb version."
      continue
    fi

    if is_occb_symlink "$dst"; then
      log "  skill '$name' already linked, skipping"
      continue
    fi

    ln -sf "$skill_dir" "$dst"
    log "  linked skill: $name"
  done
}

log "occb install — $(date)"
log ""

link_file "$OCCB_DIR/global/CLAUDE.md"      "$CLAUDE_DIR/CLAUDE.md"      "CLAUDE.md"
link_file "$OCCB_DIR/global/settings.json"  "$CLAUDE_DIR/settings.json"  "settings.json"
link_skills

log ""
if [[ "$EXIT_CODE" -eq 0 ]]; then
  log "✓ install complete"
else
  log "install finished with warnings (see above)"
fi

exit "$EXIT_CODE"
```

- [ ] **Step 2: Make executable**

```bash
chmod +x ~/Projects/occb/install.sh
```

- [ ] **Step 3: Commit**

```bash
git add install.sh
git commit -m "feat: add install.sh"
```

---

### Task 4: update.sh

**Files:**
- Create: `~/Projects/occb/update.sh`

- [ ] **Step 1: Write update.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

OCCB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKER="$OCCB_DIR/.occb-last-update"

echo "occb update — $(date)"
echo ""

# Show CHANGELOG diff since last update
if [[ -f "$MARKER" ]]; then
  LAST_UPDATE=$(cat "$MARKER")
  echo "Changes since last update ($LAST_UPDATE):"
  git -C "$OCCB_DIR" log --oneline --since="$LAST_UPDATE" -- CHANGELOG.md 2>/dev/null || true
  echo ""
fi

# Pull latest
git -C "$OCCB_DIR" pull --ff-only

# Re-run install in quiet mode (only prints changes)
OCCB_QUIET=true bash "$OCCB_DIR/install.sh"

# Update marker
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$MARKER"

echo ""
echo "✓ update complete"
```

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x ~/Projects/occb/update.sh
git add update.sh
git commit -m "feat: add update.sh"
```

---

### Task 5: uninstall.sh

**Files:**
- Create: `~/Projects/occb/uninstall.sh`

- [ ] **Step 1: Write uninstall.sh**

```bash
#!/usr/bin/env bash
set -euo pipefail

OCCB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

is_occb_symlink() {
  local path="$1"
  [[ -L "$path" ]] && [[ "$(readlink "$path")" == "$OCCB_DIR/"* ]]
}

echo "occb uninstall — $(date)"
echo ""

for target in "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/settings.json"; do
  if is_occb_symlink "$target"; then
    rm "$target"
    echo "  removed symlink: $target"
  fi
done

for skill_link in "$CLAUDE_DIR/skills"/*/; do
  skill_link="${skill_link%/}"
  if is_occb_symlink "$skill_link"; then
    rm "$skill_link"
    echo "  removed skill symlink: $skill_link"
  fi
done

echo ""

# Offer to restore most recent backup
LATEST_BACKUP=$(ls -d "$HOME/.claude-backup-"* 2>/dev/null | sort | tail -1 || true)
if [[ -n "$LATEST_BACKUP" ]]; then
  echo "Most recent backup: $LATEST_BACKUP"
  read -rp "Restore backup? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    for f in "$LATEST_BACKUP"/*; do
      cp -a "$f" "$CLAUDE_DIR/$(basename "$f")"
      echo "  restored: $(basename "$f")"
    done
    echo "✓ backup restored"
  fi
fi

echo ""
echo "✓ uninstall complete (occb repo not deleted)"
```

- [ ] **Step 2: Make executable and commit**

```bash
chmod +x ~/Projects/occb/uninstall.sh
git add uninstall.sh
git commit -m "feat: add uninstall.sh"
```

---

### Task 6: Test install.sh

- [ ] **Step 1: Run install.sh**

```bash
cd ~/Projects/occb
./install.sh
```

Expected: prints what was linked/backed up. No errors.

- [ ] **Step 2: Verify symlinks**

```bash
ls -la ~/.claude/CLAUDE.md ~/.claude/settings.json
```

Expected: both show `-> /Users/malcolm/Projects/occb/global/...`

- [ ] **Step 3: Verify idempotency**

```bash
./install.sh
```

Expected: all lines say "already linked, skipping". Exit code 0.

---

### Task 7: global/CLAUDE.md

**Files:**
- Create: `~/Projects/occb/global/CLAUDE.md`

- [ ] **Step 1: Write global/CLAUDE.md**

```markdown
# Optimi Claude Code — Team Baseline

Distributed via occb. Don't edit your local symlinked copy — edit the source at `~/Projects/occb/global/CLAUDE.md`, commit, and run `./update.sh` to propagate.

---

## Shared account discipline

The team shares a Max plan. Before spinning up orchestrated or long-running work:

- Check your status line for 5-hour and weekly usage buckets.
- If either bucket is above 70%, coordinate in Slack before starting.
- Avoid parallel orchestration runs without checking with the team first.

Burning the shared quota without checking is the equivalent of using all the milk and not telling anyone.

---

## Sub-agent defaults

When spawning sub-agents:

- **Default model: Sonnet.** It handles most work well.
- **Opus for complex reasoning only.** Architectural decisions, multi-step problem solving, nuanced code review. Not for search, file ops, or mechanical transforms.
- **Haiku for mechanical work.** Repetitive tasks, formatting, simple lookups.
- **Advisor pattern:** Run on Sonnet. When stuck or about to make a significant architectural call, consult Opus via the advisor tool. This costs roughly one Opus call instead of running the whole session on Opus.

When in doubt, start with Sonnet and escalate.

---

## Planning convention

For any work expected to take more than ~30 minutes of coding:

1. Write a plan doc first using `superpowers:writing-plans`.
2. Get alignment before implementing.
3. Track execution with `superpowers:executing-plans` or `superpowers:subagent-driven-development`.

Skipping planning is fine for one-off scripts. Not fine for features that touch multiple systems.

---

## Worktrees for speculative work

If you're not sure the direction is right, do it on a git worktree. Use `superpowers:using-git-worktrees`. Cheap to throw away, zero risk to main.

Don't start exploratory refactors on the main working tree.

---

## Landscape context before code

Before editing, read the relevant CLAUDE.md files in the current repo and any parent repo. If you're about to make architectural decisions without a mental topo map of the system, stop and build one first.

The `landscape-context` skill is designed for this — see `~/.claude/skills/landscape-context/`. It's WIP; contribute improvements.

---

## Cost discipline

- Don't use extended thinking unless the problem genuinely needs it.
- Prefer targeted searches (Grep, Glob) over broad agent exploration when the target is known.
- When parallelising sub-agents, check whether tasks are truly independent. Spawning 10 agents for 10 sequential steps wastes quota.
```

- [ ] **Step 2: Commit**

```bash
git add global/CLAUDE.md
git commit -m "feat: add global/CLAUDE.md team baseline"
```

---

### Task 8: global/settings.json

**Files:**
- Create: `~/Projects/occb/global/settings.json`

> **TODO:** Verify exact Claude Code settings.json schema for status line fields. Run `/statusline-setup` or check the statusline-setup skill for authoritative token names. The values below are best-effort.

- [ ] **Step 1: Write global/settings.json**

```json
{
  "model": "claude-sonnet-4-6",
  "theme": "dark",
  "statusLine": "{branch} | 5h: {usage_5h}% | 7d: {usage_7d}% | {model}"
}
```

- [ ] **Step 2: Commit**

```bash
git add global/settings.json
git commit -m "feat: add global/settings.json (TODO: verify status line syntax)"
```

---

### Task 9: global/skills/landscape-context/SKILL.md

**Files:**
- Create: `~/Projects/occb/global/skills/landscape-context/SKILL.md`

- [ ] **Step 1: Write SKILL.md**

```markdown
---
name: landscape-context
description: WIP — build a landscape-level mental model of a repo before starting non-trivial work
---

> This skill is WIP. The intent: before starting non-trivial work, build a landscape-level context — client direction, connected systems, load-bearing architectural decisions. See `docs/03-patterns.md` for current thinking. Contribute improvements.
```

- [ ] **Step 2: Commit**

```bash
git add global/skills/
git commit -m "feat: add landscape-context skill stub"
```

---

### Task 10: README.md

**Files:**
- Create: `~/Projects/occb/README.md`

- [ ] **Step 1: Write README.md**

```markdown
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
```

- [ ] **Step 2: Commit**

```bash
git add README.md
git commit -m "docs: add README.md"
```

---

### Task 11: CHANGELOG.md

**Files:**
- Create: `~/Projects/occb/CHANGELOG.md`

- [ ] **Step 1: Write CHANGELOG.md**

```markdown
# Changelog

All notable changes to occb are documented here.

Format: [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

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
```

- [ ] **Step 2: Commit**

```bash
git add CHANGELOG.md
git commit -m "docs: add CHANGELOG.md"
```

---

### Task 12: docs/01-orientation.md

**Files:**
- Create: `~/Projects/occb/docs/01-orientation.md`

- [ ] **Step 1: Write placeholder**

```markdown
# Orientation

This doc lives in Notion — see [TODO: paste Notion URL].

Do not edit here. Edit in Notion and copy down only if we decide to keep a repo-local copy.
```

- [ ] **Step 2: Commit**

```bash
git add docs/01-orientation.md
git commit -m "docs: add orientation placeholder"
```

---

### Task 13: docs/02-installation.md

**Files:**
- Create: `~/Projects/occb/docs/02-installation.md`

- [ ] **Step 1: Write installation doc**

```markdown
# Installation

## What install.sh does

1. Detects whether `~/.claude/CLAUDE.md` and `~/.claude/settings.json` already exist.
2. If they exist and are **not** occb symlinks, backs them up to `~/.claude-backup-<ISO8601>/` before overwriting.
3. Symlinks `global/CLAUDE.md` → `~/.claude/CLAUDE.md`
4. Symlinks `global/settings.json` → `~/.claude/settings.json`
5. For each directory in `global/skills/`, symlinks it into `~/.claude/skills/<name>`. Warns if a non-symlink of the same name exists — does not clobber.

Safe to re-run. Existing occb symlinks are detected and skipped.

## Quick install

```bash
git clone git@github.com:Optiminz/occb.git ~/Projects/occb
cd ~/Projects/occb
./install.sh
```

## Updating

```bash
cd ~/Projects/occb
./update.sh
```

Pulls latest, re-runs install, shows what changed in CHANGELOG since your last update.

## Opting out of specific pieces

Don't want occb managing your `settings.json`? Remove the symlink after install:

```bash
rm ~/.claude/settings.json
cp ~/Projects/occb/global/settings.json ~/.claude/settings.json
# Now it's a plain file — install.sh won't touch it.
```

Same pattern works for `CLAUDE.md`.

## Recovery from a broken install

1. Find your backup: `ls ~/.claude-backup-*/`
2. Restore manually: `cp ~/.claude-backup-<timestamp>/CLAUDE.md ~/.claude/CLAUDE.md`
3. Or run `./uninstall.sh` — it offers to restore the most recent backup automatically.

## Uninstalling

```bash
cd ~/Projects/occb
./uninstall.sh
```

Removes occb-managed symlinks. Doesn't delete the occb repo.
```

- [ ] **Step 2: Commit**

```bash
git add docs/02-installation.md
git commit -m "docs: add installation guide"
```

---

### Task 14: docs/03-patterns.md

**Files:**
- Create: `~/Projects/occb/docs/03-patterns.md`

- [ ] **Step 1: Write patterns doc**

```markdown
# Patterns

Living library of how the Optimi team uses Claude Code effectively. These aren't rules — they're patterns that have worked. Add yours when you find something that reliably makes things go better.

---

## Landscape context before code

*Status: WIP — not yet validated across the team.*

Before starting non-trivial work, build a mental topo map: what systems does this repo talk to, what's load-bearing, what decisions are already locked in. Read CLAUDE.md files up the directory tree. Check the project's Notion context if it exists.

The cost of skipping this is Claude confidently making changes that break assumptions nobody mentioned. The cost of doing it is 5–10 minutes. Worth it every time.

The `landscape-context` skill is intended to formalise this — it's a stub right now. Contribute.

---

## Plan → implement → review

For anything expected to take more than ~30 minutes of coding: write a plan first, get alignment, then implement. The superpowers plugin backs this up with `writing-plans`, `executing-plans`, and `subagent-driven-development` skills.

Skipping planning on small tasks is fine. Skipping it on multi-system changes is where sessions go wrong and quota gets burned.

---

## Sub-agent orchestration

Break work into sub-agents when tasks are genuinely independent and can be parallelised. Don't orchestrate just because you can — each sub-agent spawn has cost and overhead.

Good candidates: parallel file analysis, independent feature implementations, searching multiple repos simultaneously. Poor candidates: sequential steps where each depends on the last, or tasks where one agent's wrong assumption poisons another's input.

---

## Worktrees for experiments

When you're not sure the direction is right, do the work on a git worktree. `superpowers:using-git-worktrees` handles setup. If the experiment fails, delete the worktree — nothing is lost. If it succeeds, merge or cherry-pick.

The habit to build: before a speculative refactor or a "let me try this approach" session, reach for a worktree first.

---

## Advisor pattern

Run your session on Sonnet. When you hit a genuinely hard decision — architecture, non-obvious tradeoffs, multi-step reasoning — call the `advisor` tool. It routes to Opus and sends your full context. You get expert input on the hard part without paying Opus rates for the whole session.

Make your deliverable durable before calling advisor (write the file, save the result). The call takes time; if the session ends mid-call, a written result persists.

---

## Contributing

Open a PR or drop a note in Slack. If a pattern is team-agreed, it gets a doc. If it's still being tested, note that. If it's just yours, it goes in your `personal/` folder.
```

- [ ] **Step 2: Commit**

```bash
git add docs/03-patterns.md
git commit -m "docs: add seed patterns library"
```

---

### Task 15: docs/04-antipatterns.md

**Files:**
- Create: `~/Projects/occb/docs/04-antipatterns.md`

- [ ] **Step 1: Write antipatterns doc**

```markdown
# Anti-patterns

Concrete failure modes. Format: **signal → fix → meta-lesson**.

---

## The 1Password CLI rabbit hole

**Context:** Claude was configured to fetch secrets via the 1Password CLI. Without enough scaffolding, it started asking for interactive permission on every single secret read — dozens of times in quick succession.

**Signal:** Repeated permission prompts of the same type, feeling increasingly absurd. You find yourself approving the same operation over and over. Something that should be automatic is generating friction at every step.

**Fix:** Cancel early. Don't approve 15 times hoping it'll stop. Instead:
- Cache credentials at session start (`op signin` once, up front).
- Point Claude at a local `.env` file rather than live CLI calls.
- If the tool requires interactive confirmation by design, script around it or add the permission to settings permanently.

**Meta-lesson:** When Claude is asking the same kind of permission many times in a row, the design is wrong, not the prompting. Back up and fix the scaffolding.

---

## Contributing

Add anti-patterns in the same format: context, signal, fix, meta-lesson. Real stories from real sessions are more useful than hypotheticals.
```

- [ ] **Step 2: Commit**

```bash
git add docs/04-antipatterns.md
git commit -m "docs: add antipatterns doc with 1Password story"
```

---

### Task 16: docs/decisions/README.md

**Files:**
- Create: `~/Projects/occb/docs/decisions/README.md`

- [ ] **Step 1: Write decisions README**

```markdown
# Architecture Decision Records

Conventions that have an ADR are team standards. Conventions without an ADR aren't agreed yet — they might be someone's preference, a local pattern, or a WIP.

If you're unsure whether something is a team standard, check here first.

## Format

```markdown
# NNNN — Title

**Status:** Proposed | Accepted | Superseded by NNNN | Deprecated

## Context
What was the situation that required a decision?

## Decision
What did we decide?

## Consequences
What becomes easier? What becomes harder?
```

Filename convention: `NNNN-lowercase-hyphenated-title.md`

## Index

| # | Title | Status |
|---|-------|--------|
| [0001](0001-sub-agent-defaults.md) | Sub-agent model defaults | Accepted |
| [0002](0002-superpowers-as-baseline.md) | Superpowers as baseline planning tool | Accepted |
| [0003](0003-worktrees-for-experiments.md) | Worktrees for speculative Claude Code work | Accepted |
```

- [ ] **Step 2: Commit**

```bash
git add docs/decisions/README.md
git commit -m "docs: add ADR index"
```

---

### Task 17: ADR 0001 — Sub-agent defaults

**Files:**
- Create: `~/Projects/occb/docs/decisions/0001-sub-agent-defaults.md`

- [ ] **Step 1: Write ADR**

```markdown
# 0001 — Sub-agent model defaults

**Status:** Accepted

## Context

The team shares a Max plan. Most Claude Code sessions spawn sub-agents for research, file ops, and mechanical transforms. Inconsistent model selection means inconsistent cost, and nobody was thinking about it explicitly.

Available models: Opus (highest capability, highest cost), Sonnet (strong general-purpose, mid cost), Haiku (fast, cheap, mechanical tasks). The `advisor` tool provides an escalation path to Opus without running the whole session on Opus.

## Decision

- **Default: Sonnet.** Unless there's a reason to go up or down.
- **Opus for complex reasoning.** Architectural decisions, nuanced code review, multi-step problem solving where quality matters more than cost.
- **Haiku for mechanical work.** Repetitive transforms, simple lookups, formatting tasks.
- **Advisor pattern.** Run on Sonnet; call the advisor tool when hitting a genuinely hard decision. Costs roughly one Opus call instead of running the whole session on Opus.

## Consequences

- Easier: cost predictability, shared vocabulary for model selection decisions.
- Harder: some judgment calls about what counts as "complex reasoning." When in doubt, try Sonnet and escalate.
- Neutral: individual sessions can override this default — the ADR sets expectations, not hard limits.
```

- [ ] **Step 2: Commit**

```bash
git add docs/decisions/0001-sub-agent-defaults.md
git commit -m "docs: add ADR 0001 sub-agent defaults"
```

---

### Task 18: ADR 0002 — Superpowers as baseline

**Files:**
- Create: `~/Projects/occb/docs/decisions/0002-superpowers-as-baseline.md`

- [ ] **Step 1: Write ADR**

```markdown
# 0002 — Superpowers as baseline planning tool

**Status:** Accepted

## Context

Before this decision, planning practices varied across sessions and team members. When sessions skipped planning, they went long, took wrong turns, and produced code that needed rework. There was no shared vocabulary for "write a plan", "execute against a plan", or "review what was done."

The Superpowers plugin provides skills for exactly this: `writing-plans`, `executing-plans`, `subagent-driven-development`, `requesting-code-review`, and others. It was already installed across the team.

## Decision

Superpowers is the team's default scaffolding for planning and executing non-trivial Claude Code work:

- Non-trivial tasks (>~30 min of coding) get a plan doc via `superpowers:writing-plans` before implementation starts.
- Implementation runs via `superpowers:executing-plans` or `superpowers:subagent-driven-development`.
- Significant changes get a review pass via `superpowers:requesting-code-review` before merging.

"Non-trivial" is a judgment call. When in doubt, write the plan.

## Consequences

- Easier: consistent planning vocabulary, better session outcomes, plans as durable artefacts in the repo.
- Harder: overhead per task for quick fixes that don't warrant a plan doc. Watch for over-planning.
- Watch for: treating the skill invocation as ceremony. The plan is the point, not the skill.
```

- [ ] **Step 2: Commit**

```bash
git add docs/decisions/0002-superpowers-as-baseline.md
git commit -m "docs: add ADR 0002 superpowers as baseline"
```

---

### Task 19: ADR 0003 — Worktrees for experiments

**Files:**
- Create: `~/Projects/occb/docs/decisions/0003-worktrees-for-experiments.md`

- [ ] **Step 1: Write ADR**

```markdown
# 0003 — Worktrees for speculative Claude Code work

**Status:** Accepted

## Context

Claude Code sessions can run a long time down an exploratory path before it becomes clear the direction is wrong. On the main working tree, this creates messy history, uncommitted changes, and sometimes partial edits that are hard to unpick.

Git worktrees let you check out a branch in a separate directory without disrupting the main tree. The `superpowers:using-git-worktrees` skill handles setup. The overhead is low; the safety gain is real.

## Decision

For speculative or exploratory Claude Code work — "let me try this approach", "I'm not sure if this refactor is right", "exploring the impact of this change" — do it on a git worktree.

The signal that a worktree is appropriate: you're about to start something you might want to throw away without it affecting your main working tree.

## Consequences

- Easier: abandon exploratory sessions cleanly, no main-tree pollution, safe to let Claude go further down a path.
- Harder: small overhead to set up; team needs to know the pattern exists.
- Cleanup: delete the worktree directory and branch when the experiment is done or merged.
```

- [ ] **Step 2: Commit**

```bash
git add docs/decisions/0003-worktrees-for-experiments.md
git commit -m "docs: add ADR 0003 worktrees for experiments"
```

---

### Task 20: project-templates/CLAUDE.md.template

**Files:**
- Create: `~/Projects/occb/project-templates/CLAUDE.md.template`

- [ ] **Step 1: Write template**

```markdown
# [Project Name]

## Overview

[One paragraph: what this project is, who it's for, what it does.]

## Key systems and integrations

[List the external systems this project touches — APIs, databases, services. Include credentials location (e.g. `.env`) and any gotchas about auth.]

## Gotchas

[Things that would surprise a new developer: non-obvious conventions, known quirks, things not to change without understanding why.]

## Where to find more context

- Project README: `./README.md`
- Client Notion: [URL]
- Related repos: [list]
- Relevant specs/SOPs: [Notion search or direct link]
```

- [ ] **Step 2: Commit**

```bash
git add project-templates/CLAUDE.md.template
git commit -m "feat: add CLAUDE.md.template"
```

---

### Task 21: project-templates/bootstrap.sh

**Files:**
- Create: `~/Projects/occb/project-templates/bootstrap.sh`
- Create: `~/Projects/occb/project-templates/.claude/.gitkeep`

- [ ] **Step 1: Write bootstrap.sh**

```bash
#!/usr/bin/env bash
# bootstrap.sh — generic client repo folder structure
#
# Copy this to the new repo, adapt to the client's needs, then delete this comment block.
#
# Based on the meta-repo pattern (reference: ~/Projects/MillLawCenter/):
# - One meta repo (checked in)
# - Sibling directories (gitignored in meta repo, each their own repo)
#
# Usage: bash bootstrap.sh <project-name> [base-dir]

set -euo pipefail

PROJECT_NAME="${1:-my-project}"
BASE_DIR="${2:-$HOME/Projects}"
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"

echo "Bootstrapping $PROJECT_NAME at $PROJECT_DIR"

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Standard areas
mkdir -p areas/guides
mkdir -p areas/context
mkdir -p projects
mkdir -p resources
mkdir -p docs

# Claude Code config
mkdir -p .claude

# Placeholder files so directories are committed
touch areas/guides/.gitkeep
touch areas/context/.gitkeep
touch projects/.gitkeep
touch resources/.gitkeep
touch .claude/.gitkeep

echo ""
echo "Created:"
find "$PROJECT_DIR" -not -path '*/.git/*' | sort

echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_DIR && git init"
echo "  2. cp ~/Projects/occb/project-templates/CLAUDE.md.template ./CLAUDE.md"
echo "     Fill in the overview, integrations, and gotchas."
echo "  3. Add a .gitignore (sibling repos, .env, OS cruft)"
echo "  4. git add -A && git commit -m 'chore: initial scaffold'"
```

- [ ] **Step 2: Make executable, add .gitkeep, commit**

```bash
chmod +x project-templates/bootstrap.sh
touch project-templates/.claude/.gitkeep
git add project-templates/
git commit -m "feat: add project-templates (bootstrap.sh, CLAUDE.md.template, .claude/)"
```

---

### Task 22: personal/ scaffold

**Files:**
- Create: `~/Projects/occb/personal/README.md`
- Create: `~/Projects/occb/personal/.gitkeep`

- [ ] **Step 1: Write personal/README.md**

```markdown
# personal/

Per-developer space. Gitignored by default.

Malcolm and Pete (and anyone else on the team) can keep personal Claude Code config layered on top of the team baseline here — personal skills, local overrides, experimental tooling.

occb doesn't manage what goes in your personal folder. That's yours. The only files tracked in git are this README and `.gitkeep`.
```

- [ ] **Step 2: Create .gitkeep and commit**

```bash
touch personal/.gitkeep
git add personal/README.md personal/.gitkeep
git commit -m "chore: add personal/ scaffold"
```

---

### Task 23: Final verify and tag

- [ ] **Step 1: Verify the full tree**

```bash
find ~/Projects/occb -not -path '*/.git/*' -not -name '.DS_Store' | sort
```

Expected output includes all files from the target structure in the spec.

- [ ] **Step 2: Verify symlinks are live**

```bash
ls -la ~/.claude/CLAUDE.md ~/.claude/settings.json
readlink ~/.claude/CLAUDE.md    # should be ~/Projects/occb/global/CLAUDE.md
readlink ~/.claude/settings.json  # should be ~/Projects/occb/global/settings.json
```

- [ ] **Step 3: Check git log**

```bash
git -C ~/Projects/occb log --oneline
```

Expected: ~20 atomic commits from chore: through feat: and docs:.

- [ ] **Step 4: Tag v0.1.0**

```bash
git -C ~/Projects/occb tag v0.1.0
```

---

## Self-review

### Spec coverage

| Spec item | Task | Notes |
|-----------|------|-------|
| `install.sh` — idempotent, backup, symlinks, skills | 3 | ✓ |
| `update.sh` | 4 | ✓ |
| `uninstall.sh` — remove symlinks, offer restore | 5 | ✓ |
| `global/CLAUDE.md` — all 5+ sections | 7 | ✓ |
| `global/settings.json` — status line, model | 8 | ✓ — status line syntax flagged TODO |
| `global/skills/landscape-context/SKILL.md` | 9 | ✓ stub only |
| `README.md` | 10 | ✓ |
| `CHANGELOG.md` | 11 | ✓ |
| `docs/01-orientation.md` | 12 | ✓ placeholder only |
| `docs/02-installation.md` | 13 | ✓ |
| `docs/03-patterns.md` — 5 patterns + contributing | 14 | ✓ |
| `docs/04-antipatterns.md` — 1Password story | 15 | ✓ |
| `docs/decisions/README.md` | 16 | ✓ |
| ADR 0001 sub-agent defaults | 17 | ✓ |
| ADR 0002 superpowers as baseline | 18 | ✓ |
| ADR 0003 worktrees | 19 | ✓ |
| `project-templates/CLAUDE.md.template` | 20 | ✓ |
| `project-templates/bootstrap.sh` | 21 | ✓ |
| `project-templates/.claude/` | 21 | ✓ |
| `personal/README.md` + `.gitkeep` | 22 | ✓ |
| `.gitignore` | 2 | ✓ |

### Things I made up vs. specified

- **`install.sh` quiet mode via `OCCB_QUIET` env var** — spec said update.sh should call install.sh quietly; I chose env var over flag to avoid bash flag-parsing boilerplate. Flag if you prefer a `-q` flag.
- **`settings.json` status line syntax** — genuinely unknown. Flagged with TODO in Task 8. Verify via `/statusline-setup`.
- **`bootstrap.sh` directory structure** — spec said "minimal, based on MLC pattern". I used `areas/`, `projects/`, `resources/`, `docs/`. Adjust to taste.
- **Commit message style** — conventional commits. Flag if you want a different convention.

### Open items

1. `settings.json` status line syntax — verify before distributing to Pete/Bryan.
2. Notion orientation URL — add before sharing the repo.
3. GitHub remote — `git@github.com:Optiminz/occb.git` confirmed correct.
