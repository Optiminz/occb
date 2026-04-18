# ===== Terminal Launcher (optional) =====
#
# Drop-in template for ~/.zshrc. Shows a small menu on fresh interactive
# shells so opening a terminal leads somewhere useful instead of a blank
# prompt. Also defines `pullall` for bulk git pull across your working
# repos.
#
# To use: copy the sections below into your own ~/.zshrc (or source this
# file from it), then customise the REPOS list in `pullall` to match the
# repos YOU actually work in. This is intentionally not auto-installed by
# occb — everyone's repo list is different.
#
# Assumes:
#   - repos live under ~/Projects/<name>
#   - you have `claude` on PATH (aliased to `cc` below)
#   - zsh (uses `read -rk`)

# ----- aliases the launcher relies on -----
alias cc='claude'

# ----- pullall: bulk git pull -----
# CUSTOMISE: replace this list with the repos you want pullall to touch.
# Anything not present on disk is silently skipped.
pullall() {
  local repos=(
    # repo-name-1
    # repo-name-2
    # repo-name-3
  )
  local total=0 updated=0 failed=0

  _pullall_repo() {
    local name=$1 dir=$2
    ((total++))
    local output
    output=$(git -C "$dir" pull --ff-only 2>&1)
    local rc=$?
    if [[ $rc -ne 0 ]]; then
      echo "  ✗ $name — $(echo "$output" | tail -1)"
      ((failed++))
    elif [[ "$output" == *"Already up to date"* ]]; then
      echo "  ✓ $name"
    else
      local summary=$(echo "$output" | grep -E '^\s*[0-9]+ file' | head -1)
      echo "  ↑ $name — ${summary:-updated}"
      ((updated++))
    fi
  }

  echo "Pulling repos..."
  for name in "${repos[@]}"; do
    [ -d ~/Projects/$name/.git ] || continue
    _pullall_repo "$name" ~/Projects/$name
  done

  # Add any nested/sibling repos here, e.g. meta-repo layouts:
  # [ -d ~/Projects/MetaRepo/sibling/.git ] && _pullall_repo "sibling" ~/Projects/MetaRepo/sibling

  echo ""
  echo "Done: $updated updated, $failed failed, $((total - updated - failed)) clean"
}

# ----- silent background auto-sync on shell open -----
# Keep dotfiles / ~/.claude current across machines without blocking the prompt.
# Comment out any you don't want.
(git -C ~/Projects/dotfiles pull --ff-only &>/dev/null &) 2>/dev/null
(git -C ~/.claude pull --ff-only &>/dev/null &) 2>/dev/null

# ----- launcher menu -----
_terminal_launcher() {
    echo ""
    echo "  1  claude code"
    echo "  2  npm run dev"
    echo "  3  pullall"
    echo "  4  shell"
    echo ""
    printf "  → "
    read -rk 1 _tl_choice 2>/dev/null
    echo ""
    case $_tl_choice in
        1) cc ;;
        2) npm run dev ;;
        3) pullall; sleep 3; cc ;;
    esac
    unset _tl_choice
}

# Show only in fresh interactive shells — not sub-shells spawned by Claude, npm, etc.
[[ -o interactive ]] && [[ -z "$LAUNCHER_SHOWN" ]] && export LAUNCHER_SHOWN=1 && _terminal_launcher
