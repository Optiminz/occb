#!/usr/bin/env bash
# bootstrap.sh — generic client repo folder structure
#
# Copy this to the new repo, adapt to the client's needs, then delete this comment block.
#
# Based on the meta-repo pattern (reference: ~/Projects/MillLawCenter/):
# - One meta repo (checked in)
# - Sibling directories (gitignored in meta repo, each their own repo)
#
# Usage: bash bootstrap.sh <project-name> [base-dir]

set -euo pipefail

PROJECT_NAME="${1:-my-project}"
BASE_DIR="${2:-$HOME/Projects}"
PROJECT_DIR="$BASE_DIR/$PROJECT_NAME"

echo "Bootstrapping $PROJECT_NAME at $PROJECT_DIR"

mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# Standard areas
mkdir -p areas/guides
mkdir -p areas/context
mkdir -p projects
mkdir -p resources
mkdir -p docs

# Claude Code config
mkdir -p .claude

# Placeholder files so directories are committed
touch areas/guides/.gitkeep
touch areas/context/.gitkeep
touch projects/.gitkeep
touch resources/.gitkeep
touch .claude/.gitkeep

echo ""
echo "Created:"
find "$PROJECT_DIR" -not -path '*/.git/*' | sort

echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_DIR && git init"
echo "  2. cp ~/Projects/occb/project-templates/CLAUDE.md.template ./CLAUDE.md"
echo "     Fill in the overview, integrations, and gotchas."
echo "  3. Add a .gitignore (sibling repos, .env, OS cruft)"
echo "  4. git add -A && git commit -m 'chore: initial scaffold'"
