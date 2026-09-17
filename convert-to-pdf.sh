#!/usr/bin/env bash
# Convert idea-checklist.md to a styled PDF.
#
# Usage:
#   ./convert-to-pdf.sh [input.md] [output.pdf]
#
# Requires: pandoc, xelatex (TeX Live)

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INPUT="${1:-$SCRIPT_DIR/idea-checklist.md}"
OUTPUT="${2:-${INPUT%.md}.pdf}"
STYLES="$SCRIPT_DIR/pdf-styles.tex"

if [[ ! -f "$INPUT" ]]; then
  echo "Error: input file not found: $INPUT" >&2
  exit 1
fi

if [[ ! -f "$STYLES" ]]; then
  echo "Error: styles file not found: $STYLES" >&2
  exit 1
fi

for cmd in pandoc xelatex; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "Error: required command not found: $cmd" >&2
    echo "Install pandoc and a TeX distribution with xelatex." >&2
    exit 1
  fi
done

echo "Converting: $INPUT"
echo "Output:     $OUTPUT"

pandoc "$INPUT" \
  -o "$OUTPUT" \
  --pdf-engine=xelatex \
  --from=markdown+task_lists \
  --standalone \
  --toc \
  --toc-depth=2 \
  --number-sections=false \
  -H "$STYLES" \
  -V geometry:"margin=0.85in" \
  -V fontsize=11pt \
  -V documentclass=article \
  -V papersize=letter \
  -V colorlinks=true \
  -V linkcolor=CoffeeMid \
  -V urlcolor=Caramel

echo "Done."
