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
