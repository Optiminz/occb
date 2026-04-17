#!/usr/bin/env bash
# Claude Code statusline — reads JSON from stdin, outputs a single line.
# Format: <branch>[*] | ctx <used>/<total> (<pct>%) | 5h <pct>% (<reset>) | 7d <pct>% (<reset>) | <model>
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
ctx_size = ctx.get('context_window_size')
cur = ctx.get('current_usage', {}) or {}
# input tokens are the closest proxy to 'context used' as shown in /context
ctx_used = cur.get('input_tokens')
if ctx_used is None:
    ctx_used = (cur.get('cache_read_input_tokens', 0) or 0) + (cur.get('cache_creation_input_tokens', 0) or 0) + (cur.get('input_tokens_uncached', 0) or 0)

def humank(n):
    if n is None:
        return '?'
    n = int(n)
    if n >= 1_000_000:
        v = n / 1_000_000
        return f'{v:.1f}m' if v < 10 else f'{int(round(v))}m'
    if n >= 1_000:
        return f'{int(round(n/1000))}k'
    return str(n)

ctx_used_s = humank(ctx_used) if ctx_used is not None else '?'
ctx_size_s = humank(ctx_size) if ctx_size else '?'
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
print(f'ctx_used={repr(ctx_used_s)}')
print(f'ctx_size={repr(ctx_size_s)}')
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
ctx_used="${ctx_used:-?}"
ctx_size="${ctx_size:-?}"
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

ctx_part="ctx ${ctx_used} (${ctx_pct}%)"

five_part="5h ${used_5h}%"
[ -n "$reset_5h" ] && five_part="${five_part} (${reset_5h})"

seven_part="7d ${used_7d}%"
[ -n "$reset_7d" ] && seven_part="${seven_part} (${reset_7d})"

echo "${branch_part} | ${ctx_part} | ${five_part} | ${seven_part} | ${model}"
