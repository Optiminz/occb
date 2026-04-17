#!/usr/bin/env bash
set -euo pipefail

OCCB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
TIMESTAMP=$(date -u +"%Y%m%dT%H%M%SZ")
BACKUP_DIR="$HOME/.claude-backup-${TIMESTAMP}"
PERSONAL_DIR="${OCCB_PERSONAL_DIR:-$HOME/Projects/occb-personal}"
QUIET="${OCCB_QUIET:-false}"
EXIT_CODE=0

log() { [[ "$QUIET" != "true" ]] && echo "$@" || true; }
warn() { echo "⚠️  $*" >&2; EXIT_CODE=1; }

# --- Prompt the user before replacing a non-occb file ---
# Returns 0 if user approves, 1 if they decline.
# In non-interactive mode (piped, cron, OCCB_QUIET), defaults to skip (safe).
confirm_replace() {
  local path="$1"
  local label="$2"

  if [[ "$QUIET" == "true" ]] || [[ ! -t 0 ]]; then
    warn "$label already exists at $path and is not occb-managed — skipping (run interactively to replace)"
    return 1
  fi

  echo ""
  echo "⚠️  Found existing $label at $path"
  echo "   This file is NOT managed by occb and will be replaced."
  echo "   A backup will be saved to ~/.claude-backup-${TIMESTAMP}/"
  echo ""
  read -rp "   Replace it? [y/N] " answer
  case "$answer" in
    [yY]*) return 0 ;;
    *)
      log "  skipped $label (kept existing)"
      return 1
      ;;
  esac
}

# --- Preflight: warn if ~/.claude is itself a git repo ---
# This creates a second sync channel that fights with occb over generated/
# symlinked files (CLAUDE.md, settings.json, commands/, skills/, etc.).
# Users can still proceed, but they must gitignore occb-managed paths to
# avoid merge-conflict markers getting written into CLAUDE.md.
if [[ -d "$CLAUDE_DIR/.git" ]]; then
  warn "$CLAUDE_DIR is itself a git repo."
  warn "  This will collide with occb-managed files (CLAUDE.md, settings.json,"
  warn "  commands/, skills/, scripts/, notion-map*.md). If you sync this"
  warn "  repo across machines, conflict markers can end up in CLAUDE.md."
  warn "  Gitignore all occb-managed paths in $CLAUDE_DIR/.gitignore"
  warn "  and \`git rm --cached\` them before continuing."
fi

# Ensure ~/.claude/skills, ~/.claude/scripts, and ~/.claude/commands exist
mkdir -p "$CLAUDE_DIR/skills"
mkdir -p "$CLAUDE_DIR/scripts"
mkdir -p "$CLAUDE_DIR/commands"

# --- Helper: is this path an occb symlink? ---
is_occb_symlink() {
  local path="$1"
  [[ -L "$path" ]] && [[ "$(readlink "$path")" == "$OCCB_DIR/"* ]]
}

# --- Helper: is this an occb-generated file? ---
is_occb_generated() {
  local path="$1"
  [[ -f "$path" ]] && head -1 "$path" 2>/dev/null | grep -q "^<!-- occb-generated"
}

# --- Generate ~/.claude/CLAUDE.md from personal + team sources ---
generate_claude_md() {
  local team_src="$OCCB_DIR/global/CLAUDE.md"
  local personal_src="$PERSONAL_DIR/CLAUDE.md"
  local dst="$CLAUDE_DIR/CLAUDE.md"

  if [[ ! -f "$team_src" ]]; then
    warn "team CLAUDE.md not found: $team_src — skipping"
    return
  fi

  # Build candidate output into a temp file
  local tmp
  tmp=$(mktemp)
  {
    echo "<!-- occb-generated: do not edit — regenerate with: cd ~/Projects/occb && ./install.sh -->"
    echo ""
    if [[ -f "$personal_src" ]]; then
      cat "$personal_src"
      echo ""
      echo "---"
      echo ""
      echo "<!-- occb team baseline — edit at ~/Projects/occb/global/CLAUDE.md -->"
      echo ""
    fi
    cat "$team_src"
  } > "$tmp"

  # If existing file matches, skip
  if [[ -f "$dst" ]] && diff -q "$tmp" "$dst" > /dev/null 2>&1; then
    log "  CLAUDE.md already up to date, skipping"
    rm "$tmp"
    return
  fi

  # Prompt before replacing a pre-existing non-occb file
  if [[ -f "$dst" ]] && ! head -1 "$dst" 2>/dev/null | grep -q "^<!-- occb-generated"; then
    if ! confirm_replace "$dst" "CLAUDE.md"; then
      rm "$tmp"
      return
    fi
    mkdir -p "$BACKUP_DIR"
    cp -a "$dst" "$BACKUP_DIR/CLAUDE.md"
    log "  backed up $dst → $BACKUP_DIR/CLAUDE.md"
  fi

  mv "$tmp" "$dst"

  # Guard against unresolved git merge-conflict markers in either source —
  # these sneak in when ~/.claude/ is cross-machine synced as its own git
  # repo and two machines disagree on CLAUDE.md content.
  if grep -qE '^(<<<<<<< |=======$|>>>>>>> )' "$dst"; then
    warn "generated CLAUDE.md contains merge-conflict markers."
    warn "  Check $OCCB_DIR/global/CLAUDE.md and $PERSONAL_DIR/CLAUDE.md"
    warn "  for unresolved <<<<<<< / ======= / >>>>>>> lines, resolve them,"
    warn "  commit, then re-run ./install.sh."
  fi

  if [[ -f "$personal_src" ]]; then
    log "  generated CLAUDE.md (personal + team baseline)"
  else
    log "  generated CLAUDE.md (team baseline only — no personal config at $PERSONAL_DIR)"
  fi
}

# --- Back up and symlink a single file ---
link_file() {
  local src="$1"   # absolute path under occb/global/
  local dst="$2"   # absolute path under ~/.claude/
  local label="$3"

  if [[ ! -e "$src" ]]; then
    warn "source not found: $src — skipping $label"
    return
  fi

  if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
    if ! confirm_replace "$dst" "$label"; then
      return
    fi
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

# --- Symlink scripts ---
link_scripts() {
  local scripts_src="$OCCB_DIR/global/scripts"
  local scripts_dst="$CLAUDE_DIR/scripts"

  for script_file in "$scripts_src"/*; do
    [[ -f "$script_file" ]] || continue
    local name
    name=$(basename "$script_file")
    local dst="$scripts_dst/$name"

    if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
      warn "script '$name' already exists in ~/.claude/scripts/ and is not an occb symlink — skipping. Remove or rename it to install the occb version."
      continue
    fi

    if is_occb_symlink "$dst"; then
      log "  script '$name' already linked, skipping"
      continue
    fi

    ln -sf "$script_file" "$dst"
    log "  linked script: $name"
  done
}

# --- Symlink agents (individual files in ~/.claude/agents/) ---
link_agents() {
  local agents_src="$OCCB_DIR/global/agents"
  local agents_dst="$CLAUDE_DIR/agents"

  [[ -d "$agents_src" ]] || return 0
  mkdir -p "$agents_dst"

  for agent_file in "$agents_src"/*.md; do
    [[ -f "$agent_file" ]] || continue
    local name
    name=$(basename "$agent_file")
    local dst="$agents_dst/$name"

    if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
      warn "agent '$name' already exists in ~/.claude/agents/ and is not an occb symlink — skipping."
      continue
    fi
    if is_occb_symlink "$dst"; then
      log "  agent '$name' already linked, skipping"
      continue
    fi
    ln -sf "$agent_file" "$dst"
    log "  linked agent: $name"
  done
}

# --- Symlink assets directory (whole subdir e.g. assets/optimi/) ---
link_assets() {
  local assets_src="$OCCB_DIR/global/assets"
  local assets_dst="$CLAUDE_DIR/assets"

  [[ -d "$assets_src" ]] || return 0
  mkdir -p "$assets_dst"

  for asset_sub in "$assets_src"/*/; do
    asset_sub="${asset_sub%/}"
    [[ -d "$asset_sub" ]] || continue
    local name
    name=$(basename "$asset_sub")
    local dst="$assets_dst/$name"

    if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
      warn "assets/$name already exists and is not an occb symlink — skipping."
      continue
    fi
    if is_occb_symlink "$dst"; then
      log "  assets/$name already linked, skipping"
      continue
    fi
    ln -sf "$asset_sub" "$dst"
    log "  linked assets: $name"
  done
}

# --- Symlink skills directories ---
link_skills() {
  local skills_src="$OCCB_DIR/global/skills"
  local skills_dst="$CLAUDE_DIR/skills"

  for skill_dir in "$skills_src"/*/; do
    skill_dir="${skill_dir%/}"
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

# --- Symlink commands (files and subdirectories) ---
link_commands() {
  local cmds_src="$OCCB_DIR/global/commands"
  local cmds_dst="$CLAUDE_DIR/commands"

  # Symlink top-level command files
  for cmd_file in "$cmds_src"/*.md; do
    [[ -f "$cmd_file" ]] || continue
    local name
    name=$(basename "$cmd_file")
    local dst="$cmds_dst/$name"

    if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
      warn "command '$name' already exists in ~/.claude/commands/ and is not an occb symlink — skipping. Remove or rename it to install the occb version."
      continue
    fi

    if is_occb_symlink "$dst"; then
      log "  command '$name' already linked, skipping"
      continue
    fi

    ln -sf "$cmd_file" "$dst"
    log "  linked command: $name"
  done

  # Symlink reference subdirectories (e.g., references/orchestrate/)
  if [[ -d "$cmds_src/references" ]]; then
    mkdir -p "$cmds_dst/references"
    for ref_dir in "$cmds_src/references"/*/; do
      ref_dir="${ref_dir%/}"
      [[ -d "$ref_dir" ]] || continue
      local name
      name=$(basename "$ref_dir")
      local dst="$cmds_dst/references/$name"

      if [[ -e "$dst" ]] && ! is_occb_symlink "$dst"; then
        warn "command reference '$name' already exists in ~/.claude/commands/references/ and is not an occb symlink — skipping."
        continue
      fi

      if is_occb_symlink "$dst"; then
        log "  command reference '$name' already linked, skipping"
        continue
      fi

      ln -sf "$ref_dir" "$dst"
      log "  linked command reference: $name"
    done
  fi
}

merge_settings_json() {
  local team_src="$OCCB_DIR/global/settings.json"
  local personal_src="$PERSONAL_DIR/settings.json"
  local dst="$CLAUDE_DIR/settings.json"

  if [[ ! -f "$team_src" ]]; then
    warn "source not found: $team_src — skipping settings.json"
    return
  fi

  if [[ -e "$dst" ]] && [[ ! -L "$dst" ]] && ! is_occb_symlink "$dst"; then
    # Real file that's not an occb-managed symlink — back up before overwriting.
    if ! confirm_replace "$dst" "settings.json"; then
      return
    fi
    mkdir -p "$BACKUP_DIR"
    cp -a "$dst" "$BACKUP_DIR/settings.json"
    log "  backed up $dst → $BACKUP_DIR/settings.json"
  fi

  # Remove any prior symlink or file so we can write fresh.
  [[ -e "$dst" || -L "$dst" ]] && rm -f "$dst"

  if [[ -f "$personal_src" ]]; then
    if ! command -v jq >/dev/null 2>&1; then
      warn "jq not found — cannot merge personal settings.json; falling back to team-only"
      cp "$team_src" "$dst"
    else
      jq -s '.[0] * .[1]' "$team_src" "$personal_src" > "$dst"
      log "  merged settings.json (team + personal)"
      return
    fi
  else
    cp "$team_src" "$dst"
  fi
  log "  wrote settings.json (team baseline only)"
}

log "occb install — $(date)"
log ""

generate_claude_md
merge_settings_json
link_file "$OCCB_DIR/global/notion-map.md"    "$CLAUDE_DIR/notion-map.md"    "notion-map.md"
link_file "$OCCB_DIR/global/PLUGIN_SYNC.md"   "$CLAUDE_DIR/PLUGIN_SYNC.md"   "PLUGIN_SYNC.md"
link_file "$OCCB_DIR/global/setup-plugins.sh" "$CLAUDE_DIR/setup-plugins.sh" "setup-plugins.sh"
link_file "$OCCB_DIR/global/.env.template"    "$CLAUDE_DIR/.env.template"    ".env.template"
link_scripts
link_skills
link_agents
link_assets
link_commands

# --- Link personal files from occb-personal (if present) ---
if [[ -f "$PERSONAL_DIR/notion-map-personal.md" ]]; then
  local_dst="$CLAUDE_DIR/notion-map-personal.md"
  if [[ -L "$local_dst" ]] && [[ "$(readlink "$local_dst")" == "$PERSONAL_DIR/"* ]]; then
    log "  notion-map-personal.md already linked, skipping"
  elif [[ -e "$local_dst" ]]; then
    warn "notion-map-personal.md already exists in ~/.claude/ and is not a personal symlink — skipping"
  else
    ln -sf "$PERSONAL_DIR/notion-map-personal.md" "$local_dst"
    log "  linked personal: notion-map-personal.md"
  fi
fi

log ""
if [[ "$EXIT_CODE" -eq 0 ]]; then
  log "✓ install complete"
else
  log "install finished with warnings (see above)"
fi

exit "$EXIT_CODE"
