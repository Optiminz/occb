# Personal Config

occb distributes the team baseline. Personal config — org context, personal workflows, individual preferences — layers on top via a separate private repo.

## How it works

`install.sh` generates `~/.claude/CLAUDE.md` by combining:

1. `~/Projects/occb-personal/CLAUDE.md` (your personal config, if present)
2. `~/Projects/occb/global/CLAUDE.md` (team baseline)

Personal content comes first, so Claude reads it as the primary context. The team baseline follows, adding shared conventions.

### `settings.json` merge behaviour

Team `global/settings.json` and personal `claude/settings.json` are merged with `jq -s '.[0] * .[1]'` — personal keys override team keys. **Arrays are replaced, not concatenated.** If team has `permissions.allow: [A, B, C]` and personal has `permissions.allow: [D]`, the result is `[D]` — the team entries are lost.

**Implication:** Shared read-only command allowlists live in team settings only. If you need to extend personally, copy the team list into your personal file and add your entries to it. Don't split an array across layers.

## Setup (new machine)

`occb-personal` is **your own private repo** — each team member has their own. Malcolm's lives at `mdshearer/occb-personal`; Pete and Bryan should create their own, named however they like.

If you don't have one yet, see "Bootstrapping your personal repo" below.

```bash
# Clone occb (shared team baseline) — pick any location you like
git clone git@github.com:Optiminz/occb.git ~/projects/Optimi/occb

# Clone YOUR personal repo alongside it (replace with your own URL)
git clone git@github.com:<your-username>/occb-personal.git ~/projects/Optimi/occb-personal

# Install — auto-detects personal dir (sibling of occb, then ~/Projects/occb-personal)
cd ~/projects/Optimi/occb
./install.sh

# If your personal repo is somewhere unusual, override:
OCCB_PERSONAL_DIR=~/custom/path/occb-personal ./install.sh
```

### Where install.sh looks for `occb-personal`

No special config needed — `install.sh` tries these in order:

1. `$OCCB_PERSONAL_DIR` env var if set (explicit override)
2. **Sibling of your occb checkout** (e.g. `~/projects/Optimi/occb-personal`)
3. `~/Projects/occb-personal` (legacy default)
4. `~/projects/occb-personal` (lowercase variant)

The resolved path is printed at the top of every install run. If `occb-personal` isn't present, install uses the team baseline only.

## Bootstrapping your personal repo

```bash
mkdir -p ~/Projects/occb-personal
cd ~/Projects/occb-personal
git init
touch CLAUDE.md
# add your personal Claude Code instructions to CLAUDE.md
git add CLAUDE.md
git commit -m "initial personal config"
# create a private repo on GitHub and push when ready
```

## Keeping personal config current

```bash
cd ~/Projects/occb-personal
# edit CLAUDE.md
git add CLAUDE.md
git commit -m "update personal config"
git push

# On the other machine:
cd ~/Projects/occb-personal && git pull
cd ~/Projects/occb && ./install.sh   # regenerates ~/.claude/CLAUDE.md
```

## What goes where

| Content | Where |
|---------|-------|
| Machine identity, NZ timezone, preferred tone | `occb-personal/CLAUDE.md` |
| Org context, project registry, Notion conventions | `occb-personal/CLAUDE.md` |
| Sub-agent defaults, planning conventions, cost discipline | `occb/global/CLAUDE.md` |
| Worktree policy, landscape context, anti-patterns | `occb/global/CLAUDE.md` |

The line isn't always sharp. When in doubt: "would Pete need this?" → team baseline. "Is this about my setup?" → personal.
