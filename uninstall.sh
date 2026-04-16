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
