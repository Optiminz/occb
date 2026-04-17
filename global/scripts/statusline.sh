#!/usr/bin/env bash
# Claude Code statusline — reads JSON from stdin, outputs a single line.
# Format: <branch>[*] | ctx <pct>% | 5h <pct>% (<reset>) | 7d <pct>% (<reset>) | <model>
set -euo pipefail

data=$(cat)

eval "$(echo "$data" | python3 -c "
import sys, json, time, math

d = json.load(sys.stdin)

branch = d.get('git', {}).get('branch', '')
model = d.get('model', {}).get('display_name', '')
cwd = d.get('cwd', '') or d.get('workspace', {}).get('current_dir', '')

ctx = d.get('context_window', {}) or {}
ctx_pct = ctx.get('used_percentage')
ctx_pct_s = f'{int(round(ctx_pct))}' if isinstance(ctx_pct, (int, float)) else '?'

rl = d.get('rate_limits', {}) or {}
five = rl.get('five_hour') or {}
seven = rl.get('seven_day') or {}

used_5h = int(five.get('used_percentage', 0)) if five else '?'
used_7d = int(seven.get('used_percentage', 0)) if seven else '?'

def fmt_reset_short(epoch):
    if not epoch:
        return ''
    diff = epoch - time.time()
    if diff <= 0:
        return 'now'
    h = int(diff // 3600)
    m = int(math.ceil((diff % 3600) / 60))
    if h > 0:
        return f'{h}h{m:02d}m'
    return f'{m}m'

def fmt_reset_long(epoch):
    if not epoch:
        return ''
    diff = epoch - time.time()
    if diff <= 0:
        return 'now'
    dd = int(diff // 86400)
    h = int((diff % 86400) // 3600)
    if dd > 0:
        return f'{dd}d{h:02d}h'
    return f'{h}h'

reset_5h = fmt_reset_short(five.get('resets_at'))
reset_7d = fmt_reset_long(seven.get('resets_at'))

print(f'branch={repr(branch)}')
print(f'model={repr(model)}')
print(f'cwd={repr(cwd)}')
print(f'ctx_pct={repr(ctx_pct_s)}')
print(f'used_5h={repr(str(used_5h))}')
print(f'used_7d={repr(str(used_7d))}')
print(f'reset_5h={repr(reset_5h)}')
print(f'reset_7d={repr(reset_7d)}')
" 2>/dev/null)" 2>/dev/null

# Fallbacks if python fails
branch="${branch:-}"
model="${model:-}"
cwd="${cwd:-}"
ctx_pct="${ctx_pct:-?}"
used_5h="${used_5h:-?}"
used_7d="${used_7d:-?}"
reset_5h="${reset_5h:-}"
reset_7d="${reset_7d:-}"

# Branch fallback + dirty flag — check against the session's cwd
dirty=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  if [ -z "$branch" ]; then
    branch="$(git -C "$cwd" rev-parse --abbrev-ref HEAD 2>/dev/null || echo '')"
  fi
  if [ -n "$(git -C "$cwd" status --porcelain 2>/dev/null | head -1)" ]; then
    dirty="*"
  fi
fi

branch_part="${branch}${dirty}"

# Bold a segment when its percentage crosses the warning threshold (>70%).
BOLD=$'\033[1m'
RESET=$'\033[0m'
bold_if_hot() {
  local pct="$1" segment="$2"
  if [[ "$pct" =~ ^[0-9]+$ ]] && [ "$pct" -gt 70 ]; then
    printf '%s%s%s' "$BOLD" "$segment" "$RESET"
  else
    printf '%s' "$segment"
  fi
}

ctx_part=$(bold_if_hot "$ctx_pct" "ctx ${ctx_pct}%")

five_seg="5h ${used_5h}%"
[ -n "$reset_5h" ] && five_seg="${five_seg} (${reset_5h})"
five_part=$(bold_if_hot "$used_5h" "$five_seg")

seven_seg="7d ${used_7d}%"
[ -n "$reset_7d" ] && seven_seg="${seven_seg} (${reset_7d})"
seven_part=$(bold_if_hot "$used_7d" "$seven_seg")

echo "${branch_part} | ${ctx_part} | ${five_part} | ${seven_part} | ${model}"
