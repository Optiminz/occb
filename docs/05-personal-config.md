# Personal Config

occb distributes the team baseline. Personal config — org context, personal workflows, individual preferences — layers on top via a separate private repo.

## How it works

`install.sh` generates `~/.claude/CLAUDE.md` by combining:

1. `~/Projects/occb-personal/CLAUDE.md` (your personal config, if present)
2. `~/Projects/occb/global/CLAUDE.md` (team baseline)

Personal content comes first, so Claude reads it as the primary context. The team baseline follows, adding shared conventions.

## Setup (new machine)

```bash
# Clone both repos
git clone git@github.com:Optiminz/occb.git ~/Projects/occb
git clone git@github.com:mdshearer/occb-personal.git ~/Projects/occb-personal

# Install — generates ~/.claude/CLAUDE.md from both sources
cd ~/Projects/occb
./install.sh

# If your personal repo is at a different path:
OCCB_PERSONAL_DIR=~/path/to/occb-personal ./install.sh
```

If `occb-personal` isn't present, install uses the team baseline only.

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
