#!/usr/bin/env bash
set -euo pipefail

OCCB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MARKER="$OCCB_DIR/.occb-last-update"

echo "occb update — $(date)"
echo ""

# Pull latest first (so CHANGELOG diff is accurate)
git -C "$OCCB_DIR" pull --ff-only

# Show CHANGELOG diff since last update
if [[ -f "$MARKER" ]]; then
  LAST_UPDATE=$(cat "$MARKER")
  echo "Changes since last update ($LAST_UPDATE):"
  git -C "$OCCB_DIR" log --oneline --since="$LAST_UPDATE" -- CHANGELOG.md 2>/dev/null || true
  echo ""
fi

# Re-run install in quiet mode (only prints changes)
# Capture exit code — install may return 1 on skill conflicts (non-fatal)
install_exit=0
OCCB_QUIET=true bash "$OCCB_DIR/install.sh" || install_exit=$?

# Always write the marker, even if install had warnings
date -u +"%Y-%m-%dT%H:%M:%SZ" > "$MARKER"

echo ""
if [[ "$install_exit" -eq 0 ]]; then
  echo "✓ update complete"
else
  echo "update complete with install warnings — check output above"
fi
