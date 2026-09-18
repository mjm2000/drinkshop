#!/usr/bin/env bash
# Commit and push site changes to GitHub (triggers Pages deploy).
#
# Usage:
#   ./push.sh                          # auto message with timestamp
#   ./push.sh "Update marketing slide" # custom commit message
#
# Live site (after ~1 min): https://mjm2000.github.io/drinkshop/

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "Error: not a git repository." >&2
  exit 1
fi

BRANCH="$(git branch --show-current)"
if [[ -z "$BRANCH" ]]; then
  echo "Error: could not detect current branch." >&2
  exit 1
fi

if [[ -n "${1:-}" ]]; then
  MSG="$*"
else
  MSG="Update site — $(date '+%Y-%m-%d %H:%M')"
fi

echo "Branch: $BRANCH"
echo "Remote: $(git remote get-url origin 2>/dev/null || echo none)"
echo ""
git status --short

if git diff --quiet && git diff --cached --quiet && [[ -z "$(git ls-files --others --exclude-standard)" ]]; then
  echo ""
  echo "Nothing to commit — working tree clean."
  exit 0
fi

echo ""
echo "Commit message: $MSG"
echo ""

git add -A
git commit -m "$MSG"
git push -u origin "$BRANCH"

echo ""
echo "Pushed to origin/$BRANCH"
echo "GitHub Pages deploy: https://github.com/mjm2000/drinkshop/actions"
echo "Live site:           https://mjm2000.github.io/drinkshop/"

if command -v gh >/dev/null 2>&1; then
  RUN_ID="$(gh run list --repo mjm2000/drinkshop --limit 1 --json databaseId -q '.[0].databaseId' 2>/dev/null || true)"
  if [[ -n "$RUN_ID" && "$RUN_ID" != "null" ]]; then
    echo ""
    echo "Watching deploy..."
    gh run watch "$RUN_ID" --repo mjm2000/drinkshop --exit-status
    echo "Deploy finished."
  fi
fi
