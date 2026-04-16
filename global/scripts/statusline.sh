#!/usr/bin/env bash
# Claude Code statusline — reads JSON from stdin, outputs a single line.
set -euo pipefail

data=$(cat)

branch=$(echo "$data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('git',{}).get('branch',''))" 2>/dev/null || echo "")
used_5h=$(echo "$data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(int(d.get('rate_limits',{}).get('five_hour',{}).get('used_percentage',0)))" 2>/dev/null || echo "?")
used_7d=$(echo "$data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(int(d.get('rate_limits',{}).get('seven_day',{}).get('used_percentage',0)))" 2>/dev/null || echo "?")
model=$(echo "$data" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('model',{}).get('display_name',''))" 2>/dev/null || echo "")

echo "${branch} | 5h: ${used_5h}% | 7d: ${used_7d}% | ${model}"
