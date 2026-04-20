#!/usr/bin/env bash
# bootstrap.sh — one-time onboarding for occb.
#
# Run this BEFORE install.sh the first time. It detects an existing
# ~/.claude/ setup, splits CLAUDE.md and settings.json into blocks, and
# asks the user to sort each block into: personal, promote-to-team,
# delete, or keep-as-is. Output is written into occb-personal/ and a
# PROMOTIONS.md staging file. install.sh then takes over.
#
# Idempotent-ish: refuses to re-run once occb has taken over ~/.claude/.

set -euo pipefail

OCCB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

# Resolve personal config dir (same precedence as install.sh):
#   1. $OCCB_PERSONAL_DIR env var
#   2. Sibling of the occb checkout
#   3. ~/Projects/occb-personal
#   4. ~/projects/occb-personal
# Falls back to the sibling path when none of 2–4 exist — that's the path
# bootstrap will create during scaffold.
resolve_personal_dir() {
  if [[ -n "${OCCB_PERSONAL_DIR:-}" ]]; then
    printf '%s\n' "$OCCB_PERSONAL_DIR"
    return
  fi
  local sibling
  sibling="$(dirname "$OCCB_DIR")/occb-personal"
  local candidate
  for candidate in "$sibling" "$HOME/Projects/occb-personal" "$HOME/projects/occb-personal"; do
    if [[ -d "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return
    fi
  done
  printf '%s\n' "$sibling"
}
PERSONAL_DIR="$(resolve_personal_dir)"
TIMESTAMP="$(date -u +"%Y%m%dT%H%M%SZ")"
SNAPSHOT_DIR="$HOME/.claude-pre-occb-${TIMESTAMP}"
TRIAGE_FILE="$SNAPSHOT_DIR/TRIAGE.md"
PROMOTIONS_FILE="$OCCB_DIR/PROMOTIONS.md"

EDITOR_CMD="${EDITOR:-${VISUAL:-vi}}"

log() { echo "$@"; }
err() { echo "error: $*" >&2; exit 1; }

# --- Guards ----------------------------------------------------------------

[[ -t 0 ]] || err "bootstrap.sh must be run interactively (TTY required)"
[[ "${OCCB_QUIET:-false}" != "true" ]] || err "bootstrap.sh cannot run with OCCB_QUIET=true"

command -v jq >/dev/null 2>&1 || err "jq is required for settings.json triage (brew install jq)"

# Detect state.
state="clean"
if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]] && head -1 "$CLAUDE_DIR/CLAUDE.md" 2>/dev/null | grep -q "^<!-- occb-generated"; then
  state="already-installed"
elif [[ -f "$CLAUDE_DIR/CLAUDE.md" ]] || [[ -f "$CLAUDE_DIR/settings.json" ]]; then
  state="existing"
fi

if [[ "$state" == "already-installed" ]]; then
  cat <<EOF
occb is already installed in $CLAUDE_DIR.

If you want to edit personal config, edit files in:
  $PERSONAL_DIR/claude/

Then re-run ./install.sh to regenerate.
EOF
  exit 0
fi

# --- Snapshot --------------------------------------------------------------

log "occb bootstrap — $(date)"
log ""
log "Snapshotting $CLAUDE_DIR → $SNAPSHOT_DIR"
mkdir -p "$SNAPSHOT_DIR"
if [[ -d "$CLAUDE_DIR" ]]; then
  # cp -a, but tolerate empty dir
  (cd "$CLAUDE_DIR" && find . -mindepth 1 -maxdepth 1 -exec cp -a {} "$SNAPSHOT_DIR/" \; 2>/dev/null) || true
fi

# --- Scaffold occb-personal ------------------------------------------------

if [[ ! -d "$PERSONAL_DIR" ]]; then
  log "Scaffolding $PERSONAL_DIR"
  mkdir -p "$PERSONAL_DIR/claude"
  cat > "$PERSONAL_DIR/claude/CLAUDE.md" <<'EOF'
# Personal Claude Config

This file is merged into ~/.claude/CLAUDE.md ABOVE the team baseline by
occb/install.sh. Put anything personal here: machine-specific paths,
private preferences, API key pointers, communication style quirks.

## Machine

## Personal Preferences

## Personal Keys & Paths

EOF
  echo '{}' > "$PERSONAL_DIR/claude/settings.json"
  cat > "$PERSONAL_DIR/README.md" <<'EOF'
# occb-personal

Private layer for the team occb baseline. Not shared.

- `claude/CLAUDE.md` → merged above team baseline into ~/.claude/CLAUDE.md
- `claude/settings.json` → merged over team settings.json via `jq -s '.[0] * .[1]'`
- Any other file/dir under `claude/` → symlinked into ~/.claude/<same path>
EOF
  cat > "$PERSONAL_DIR/.gitignore" <<'EOF'
.env
.env.*
!.env.template
*.key
*.pem
EOF
  (cd "$PERSONAL_DIR" && git init -q && git add -A && git commit -q -m "initial scaffold from occb bootstrap") || true
else
  log "Personal dir already exists at $PERSONAL_DIR — will append, not overwrite"
fi

PERSONAL_CLAUDE_MD="$PERSONAL_DIR/claude/CLAUDE.md"
PERSONAL_SETTINGS="$PERSONAL_DIR/claude/settings.json"

# --- Clean-state shortcut --------------------------------------------------

if [[ "$state" == "clean" ]]; then
  log ""
  log "No existing ~/.claude/CLAUDE.md or settings.json found — clean install."
  log "Scaffold ready. Run ./install.sh now."
  exit 0
fi

# --- Block-split existing CLAUDE.md ---------------------------------------

SRC_CLAUDE="$CLAUDE_DIR/CLAUDE.md"
TEAM_CLAUDE="$OCCB_DIR/global/CLAUDE.md"

if [[ -f "$SRC_CLAUDE" ]]; then
  log ""
  log "Splitting $SRC_CLAUDE into blocks for triage..."

  # Collect team H2 headings (normalized) for overlap detection.
  team_headings="$(grep -E '^## ' "$TEAM_CLAUDE" 2>/dev/null | sed 's/^## //' | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]//g')"

  {
    cat <<EOF
# CLAUDE.md triage

One block per H2 section in your existing ~/.claude/CLAUDE.md.
For each block, TICK ONE box:

  [x] personal        → goes into occb-personal/claude/CLAUDE.md
  [x] promote         → staged in occb/PROMOTIONS.md for team PR review
  [x] delete          → dropped
  [x] keep-as-is      → (default) goes into personal with a TODO marker

Then save and quit the editor. Unticked blocks default to "keep-as-is".

---

EOF
  } > "$TRIAGE_FILE"

  # awk splits on ^## and emits each block with a decision stub.
  awk -v team="$team_headings" -v out="$TRIAGE_FILE" '
    function normh(s) {
      gsub(/[^a-zA-Z0-9]/, "", s)
      return tolower(s)
    }
    function flush(   h, nh, overlap) {
      if (buf == "") return
      h = heading
      nh = normh(h)
      overlap = 0
      if (nh != "" && index(team, nh) > 0) overlap = 1
      n++
      print "## Block " n ": " (h == "" ? "(preamble)" : h) >> out
      print "" >> out
      if (overlap) {
        print "⚠️  Heading matches a team baseline section — probably already covered." >> out
        print "" >> out
      }
      print "```" >> out
      printf "%s", buf >> out
      print "```" >> out
      print "" >> out
      print "Decision: [ ] personal  [ ] promote  [ ] delete  [ ] keep-as-is" >> out
      print "" >> out
      print "---" >> out
      print "" >> out
      buf = ""
    }
    /^## / {
      flush()
      heading = $0
      sub(/^## /, "", heading)
      buf = $0 "\n"
      next
    }
    { buf = buf $0 "\n" }
    END { flush() }
  ' "$SRC_CLAUDE"

  log "Opening $TRIAGE_FILE in $EDITOR_CMD — make your decisions, save, and quit."
  read -rp "Press ENTER to open editor..."
  "$EDITOR_CMD" "$TRIAGE_FILE"

  # --- Parse decisions -----------------------------------------------------

  log "Applying decisions..."
  touch "$PROMOTIONS_FILE"

  awk -v personal="$PERSONAL_CLAUDE_MD" -v promotions="$PROMOTIONS_FILE" '
    /^## Block [0-9]+: / {
      if (have) emit()
      have = 1; block = ""; heading = $0; sub(/^## Block [0-9]+: /, "", heading)
      decision = ""; in_code = 0; code = ""
      next
    }
    /^```/ { in_code = !in_code; next }
    in_code { code = code $0 "\n"; next }
    /^Decision:/ {
      if (match($0, /\[[xX]\] personal/))   decision = "personal"
      else if (match($0, /\[[xX]\] promote/)) decision = "promote"
      else if (match($0, /\[[xX]\] delete/))  decision = "delete"
      else if (match($0, /\[[xX]\] keep-as-is/)) decision = "keep"
      else decision = ""
      next
    }
    END { if (have) emit() }

    function emit() {
      if (decision == "delete") return
      if (decision == "promote") {
        print "\n<!-- staged by bootstrap.sh " strftime("%F %T") " -->" >> promotions
        print "## " heading >> promotions
        printf "%s", code >> promotions
        return
      }
      # personal or keep (default)
      print "" >> personal
      if (decision == "" || decision == "keep") {
        print "<!-- TODO triage: bootstrap left this block unclassified -->" >> personal
      }
      printf "%s", code >> personal
    }
  ' "$TRIAGE_FILE"

  log "  personal blocks appended to $PERSONAL_CLAUDE_MD"
  log "  promoted blocks staged in $PROMOTIONS_FILE"
fi

# --- settings.json triage --------------------------------------------------

SRC_SETTINGS="$CLAUDE_DIR/settings.json"
TEAM_SETTINGS="$OCCB_DIR/global/settings.json"

if [[ -f "$SRC_SETTINGS" ]]; then
  log ""
  log "Diffing $SRC_SETTINGS against team settings..."

  SETTINGS_TRIAGE="$SNAPSHOT_DIR/settings-triage.md"
  {
    cat <<'EOF'
# settings.json triage

Top-level keys in your existing ~/.claude/settings.json. For each key:

  [x] personal   → merged into occb-personal/claude/settings.json
  [x] promote    → staged in occb/PROMOTIONS.md for team PR review
  [x] delete     → dropped
  [x] keep-as-is → (default) goes into personal

Save and quit when done.

---

EOF
  } > "$SETTINGS_TRIAGE"

  # Build per-key diff.
  keys="$(jq -r 'keys[]' "$SRC_SETTINGS")"
  while IFS= read -r key; do
    [[ -n "$key" ]] || continue
    team_val="$(jq --arg k "$key" '.[$k]' "$TEAM_SETTINGS" 2>/dev/null || echo 'null')"
    your_val="$(jq --arg k "$key" '.[$k]' "$SRC_SETTINGS")"
    status="new"
    if [[ "$team_val" != "null" ]]; then
      if [[ "$team_val" == "$your_val" ]]; then
        status="matches-team"
      else
        status="conflicts-with-team"
      fi
    fi

    {
      echo "## Key: \`$key\`  (status: $status)"
      echo ""
      if [[ "$status" == "matches-team" ]]; then
        echo "✓ Identical to team baseline — safe to delete."
      elif [[ "$status" == "conflicts-with-team" ]]; then
        echo "⚠️  Team has a different value for this key."
        echo ""
        echo "Team value:"
        echo '```json'
        echo "$team_val"
        echo '```'
      fi
      echo ""
      echo "Your value:"
      echo '```json'
      echo "$your_val"
      echo '```'
      echo ""
      echo "Decision: [ ] personal  [ ] promote  [ ] delete  [ ] keep-as-is"
      echo ""
      echo "---"
      echo ""
    } >> "$SETTINGS_TRIAGE"
  done <<< "$keys"

  log "Opening $SETTINGS_TRIAGE in $EDITOR_CMD..."
  read -rp "Press ENTER to open editor..."
  "$EDITOR_CMD" "$SETTINGS_TRIAGE"

  # Parse decisions and rebuild personal settings.
  personal_tmp="$(mktemp)"
  cp "$PERSONAL_SETTINGS" "$personal_tmp"

  current_key=""
  while IFS= read -r line; do
    if [[ "$line" =~ ^##\ Key:\ \`([^\`]+)\` ]]; then
      current_key="${BASH_REMATCH[1]}"
    elif [[ "$line" =~ ^Decision: ]] && [[ -n "$current_key" ]]; then
      decision=""
      if [[ "$line" =~ \[[xX]\]\ personal ]]; then decision="personal"
      elif [[ "$line" =~ \[[xX]\]\ promote ]]; then decision="promote"
      elif [[ "$line" =~ \[[xX]\]\ delete ]]; then decision="delete"
      elif [[ "$line" =~ \[[xX]\]\ keep-as-is ]]; then decision="keep"
      else decision="keep"
      fi

      val="$(jq --arg k "$current_key" '.[$k]' "$SRC_SETTINGS")"

      case "$decision" in
        personal|keep)
          jq --arg k "$current_key" --argjson v "$val" '. + {($k): $v}' "$personal_tmp" > "${personal_tmp}.new"
          mv "${personal_tmp}.new" "$personal_tmp"
          ;;
        promote)
          {
            echo ""
            echo "<!-- settings.json key staged by bootstrap.sh $(date -u +%FT%TZ) -->"
            echo "\`\`\`json"
            echo "{ \"$current_key\": $val }"
            echo "\`\`\`"
          } >> "$PROMOTIONS_FILE"
          ;;
        delete) ;;
      esac
      current_key=""
    fi
  done < "$SETTINGS_TRIAGE"

  mv "$personal_tmp" "$PERSONAL_SETTINGS"
  log "  personal settings written to $PERSONAL_SETTINGS"
fi

# --- Custom commands / skills / agents triage -----------------------------
#
# Anything in ~/.claude/{commands,skills,agents}/ that is a real file or
# real dir (not already an occb symlink) is custom. Offer to move it into
# occb-personal so install.sh can re-link it from there.

migrate_custom_subdir() {
  local subdir="$1"   # commands | skills | agents
  local src_dir="$CLAUDE_DIR/$subdir"
  local dst_dir="$PERSONAL_DIR/claude/$subdir"

  [[ -d "$src_dir" ]] || return 0

  local candidates=()
  for entry in "$src_dir"/*; do
    [[ -e "$entry" ]] || continue
    # Skip anything that's already a symlink (occb-managed or otherwise).
    [[ -L "$entry" ]] && continue
    candidates+=("$entry")
  done

  [[ ${#candidates[@]} -gt 0 ]] || return 0

  log ""
  log "Found ${#candidates[@]} custom item(s) in $src_dir:"
  for c in "${candidates[@]}"; do
    log "  - $(basename "$c")"
  done
  read -rp "Move these into $dst_dir/ for occb-personal to manage? [Y/n] " answer
  case "$answer" in
    [nN]*)
      log "  skipped — originals remain in snapshot: $SNAPSHOT_DIR/$subdir/"
      return
      ;;
  esac

  mkdir -p "$dst_dir"
  for c in "${candidates[@]}"; do
    local name; name=$(basename "$c")
    if [[ -e "$dst_dir/$name" ]]; then
      log "  skip $name — already exists in $dst_dir"
      continue
    fi
    mv "$c" "$dst_dir/$name"
    log "  moved $subdir/$name → occb-personal"
  done
}

migrate_custom_subdir commands
migrate_custom_subdir skills
migrate_custom_subdir agents

# --- Clear the way for install.sh -----------------------------------------

log ""
log "Removing pre-occb CLAUDE.md and settings.json from $CLAUDE_DIR"
log "(full snapshot preserved at $SNAPSHOT_DIR)"
rm -f "$CLAUDE_DIR/CLAUDE.md" "$CLAUDE_DIR/settings.json"

log ""
log "✓ bootstrap complete"
log ""
log "Next steps:"
step=1
log "  $step. Review $PERSONAL_CLAUDE_MD"; step=$((step+1))
log "  $step. Review $PERSONAL_SETTINGS"; step=$((step+1))
if [[ -s "$PROMOTIONS_FILE" ]]; then
  log "  $step. Review $PROMOTIONS_FILE and open a PR for blocks worth promoting to team"
  step=$((step+1))
fi
log "  $step. Run ./install.sh"
