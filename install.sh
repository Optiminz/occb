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
