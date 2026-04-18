# Installation

> First time on a machine? See [02-prerequisites.md](02-prerequisites.md) first.

## What install.sh does

1. **Generates `~/.claude/CLAUDE.md`** by concatenating two sources:
   - Your personal config at `~/Projects/occb-personal/CLAUDE.md` (if the repo exists)
   - The team baseline at `~/Projects/occb/global/CLAUDE.md`

   Personal comes first, team baseline second, separated by a horizontal rule. The file starts with an `<!-- occb-generated -->` marker so the script knows it owns that file on re-run.

   If a pre-existing `~/.claude/CLAUDE.md` exists that is **not** occb-generated, it's backed up to `~/.claude-backup-<ISO8601>/` before being replaced.

2. **Symlinks `global/settings.json`** → `~/.claude/settings.json`. Same backup behaviour for pre-existing non-symlinked files.

3. **Symlinks each directory in `global/skills/`** → `~/.claude/skills/<name>`. Warns and skips if a non-symlink of the same name already exists (so your personal skills in `~/.claude/skills/` don't get clobbered).

4. **Symlinks each file in `global/commands/`** → `~/.claude/commands/<name>`. Same collision-safe behaviour as skills — your personal commands are left alone.

5. **Symlinks each script in `global/scripts/`** → `~/.claude/scripts/<name>`.

Safe to re-run. Existing occb symlinks and occb-generated files are detected and updated in place.

## Personal config (optional)

`occb-personal` is a separate, private repo you own. It's not required — if it doesn't exist, `install.sh` uses the team baseline alone.

To add personal config:

```bash
mkdir -p ~/Projects/occb-personal
cd ~/Projects/occb-personal
git init
touch CLAUDE.md
# add your personal Claude Code instructions to CLAUDE.md
# commit, and optionally push to a private remote
```

Then re-run `./install.sh` in occb to regenerate `~/.claude/CLAUDE.md` with your personal config layered in.

**Why personal-first:** your personal context (current projects, preferred patterns, personal conventions) sets the frame before team defaults fill in shared floor behaviour.

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

To update your personal config, edit `~/Projects/occb-personal/CLAUDE.md` and re-run `./install.sh`.

## Editing the generated CLAUDE.md

Don't. The file in `~/.claude/CLAUDE.md` is generated — edits will be overwritten on the next install.

- **Team-level change:** edit `~/Projects/occb/global/CLAUDE.md`, commit, and run `./update.sh` (or `./install.sh`).
- **Personal change:** edit `~/Projects/occb-personal/CLAUDE.md`, then run `./install.sh`.

## Opting out of specific pieces

Don't want occb managing your `settings.json`? Remove the symlink after install:

```bash
rm ~/.claude/settings.json
cp ~/Projects/occb/global/settings.json ~/.claude/settings.json
# Now it's a plain file — install.sh won't touch it.
```

For `CLAUDE.md`, opting out is trickier because it's generated, not symlinked. Options:

- Remove the `<!-- occb-generated -->` marker from the file — install.sh will then treat it as user-owned and back it up before overwriting on next run. Not sticky across updates.
- Or don't run `./install.sh` / `./update.sh` at all; manage `~/.claude/CLAUDE.md` by hand.

## Environment variables

| Variable | Default | Purpose |
|----------|---------|---------|
| `OCCB_PERSONAL_DIR` | `~/Projects/occb-personal` | Path to your personal config repo |
| `OCCB_QUIET` | `false` | Suppress output (used internally by update.sh) |

## Recovery from a broken install

1. Find your backup: `ls ~/.claude-backup-*/`
2. Restore manually: `cp ~/.claude-backup-<timestamp>/CLAUDE.md ~/.claude/CLAUDE.md`
3. Or run `./uninstall.sh` — it offers to restore the most recent backup automatically.

## Uninstalling

```bash
cd ~/Projects/occb
./uninstall.sh
```

Removes occb-managed symlinks and the generated CLAUDE.md. Doesn't delete the occb repo or your `occb-personal` repo.
