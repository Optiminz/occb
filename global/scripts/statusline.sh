#!/usr/bin/env bash
# Claude Code statusline — reads JSON from stdin, outputs a single line.
set -euo pipefail

data=$(cat)

eval "$(echo "$data" | python3 -c "
import sys, json, time, math

d = json.load(sys.stdin)

branch = d.get('git', {}).get('branch', '')
model = d.get('model', {}).get('display_name', '')
rl = d.get('rate_limits', {})

five = rl.get('five_hour', {})
seven = rl.get('seven_day', {})

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
    d = int(diff // 86400)
    h = int((diff % 86400) // 3600)
    if d > 0:
        return f'{d}d{h:02d}h'
    return f'{h}h'

reset_5h = fmt_reset_short(five.get('resets_at'))
reset_7d = fmt_reset_long(seven.get('resets_at'))

print(f'branch={repr(branch)}')
print(f'model={repr(model)}')
print(f'used_5h={repr(str(used_5h))}')
print(f'used_7d={repr(str(used_7d))}')
print(f'reset_5h={repr(reset_5h)}')
print(f'reset_7d={repr(reset_7d)}')
" 2>/dev/null)" 2>/dev/null

# Fallbacks if python fails
branch="${branch:-}"
model="${model:-}"
used_5h="${used_5h:-?}"
used_7d="${used_7d:-?}"
reset_5h="${reset_5h:-}"
reset_7d="${reset_7d:-}"

five_part="5h: ${used_5h}%"
[ -n "$reset_5h" ] && five_part="${five_part} (${reset_5h})"

seven_part="7d: ${used_7d}%"
[ -n "$reset_7d" ] && seven_part="${seven_part} (${reset_7d})"

echo "${branch} | ${five_part} | ${seven_part} | ${model}"
