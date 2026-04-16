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

# Remove generated CLAUDE.md
if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]] && head -1 "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null | grep -q "^<!-- occb-generated"; then
  rm "$CLAUDE_DIR/CLAUDE.md"
  echo "  removed generated CLAUDE.md"
fi

# Remove settings.json symlink
if is_occb_symlink "$CLAUDE_DIR/settings.json"; then
  rm "$CLAUDE_DIR/settings.json"
  echo "  removed symlink: $CLAUDE_DIR/settings.json"
fi

shopt -s nullglob
for skill_link in "$CLAUDE_DIR/skills"/*/; do
  skill_link="${skill_link%/}"
  if is_occb_symlink "$skill_link"; then
    rm "$skill_link"
    echo "  removed skill symlink: $skill_link"
  fi
done
shopt -u nullglob

echo ""

# Offer to restore most recent backup
LATEST_BACKUP=$(ls -d "$HOME/.claude-backup-"* 2>/dev/null | sort | tail -1 || true)
if [[ -n "$LATEST_BACKUP" ]]; then
  echo "Most recent backup: $LATEST_BACKUP"
  read -rp "Restore backup? [y/N] " answer
  if [[ "$answer" =~ ^[Yy]$ ]]; then
    shopt -s nullglob
    for f in "$LATEST_BACKUP"/*; do
      cp -a "$f" "$CLAUDE_DIR/$(basename "$f")"
      echo "  restored: $(basename "$f")"
    done
    shopt -u nullglob
    echo "✓ backup restored"
  fi
fi

echo ""
echo "✓ uninstall complete (occb repo not deleted)"
