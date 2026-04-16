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
