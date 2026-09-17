#!/usr/bin/env bash
# Serve The Lone Volt presentation locally.
#
# Usage:
#   ./serve.sh [port]
#
# Then open http://localhost:8080 (or your chosen port).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE_DIR="$SCRIPT_DIR/site"
PORT="${1:-8080}"

if [[ ! -d "$SITE_DIR" ]]; then
  echo "Error: site directory not found: $SITE_DIR" >&2
  exit 1
fi

echo "Serving The Lone Volt presentation at http://localhost:$PORT"
echo "Press Ctrl+C to stop."
echo ""

cd "$SITE_DIR"

if command -v python3 >/dev/null 2>&1; then
  exec python3 -m http.server "$PORT"
elif command -v python >/dev/null 2>&1; then
  exec python -m SimpleHTTPServer "$PORT"
else
  echo "Error: Python is required to serve the site." >&2
  exit 1
fi
