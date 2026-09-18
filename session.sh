#!/usr/bin/env bash
# Saved project context — run this to restore session memory for future work.
#
# Usage:
#   ./session.sh              Print full project context (brand, decisions, URLs)
#   ./session.sh summary      One-screen cheat sheet
#   ./session.sh note "text"  Append a timestamped note to .session-log.md
#   ./session.sh log          Show appended session notes
#   ./session.sh scripts      List helper scripts in this repo

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SESSION_LOG="$SCRIPT_DIR/.session-log.md"

cmd="${1:-show}"
shift || true

print_full_context() {
  cat <<'EOF'
# The Lone Volt — saved session context
# Last consolidated: 2026-09-17 (Cursor build session)

## Brand
- Name: The Lone Volt (display: THE LONE VOLT)
- No motto / tagline (removed "Built in DFW. Fueled for Texas.")
- Texas visual theme: burnt orange (#e8943a) + Texas blue (#5a8fc4), warm cream text, navy-charcoal backgrounds

## Concept
- DFW energy drink shop presentation site (not a live business yet — planning stage)
- On-tap energy drinks (house + partner draft lines) + custom builds at the bar
- Bottled/import retail wall (40–60 SKUs, Made in Texas + Around the World)
- Caffeine mg transparency on every cup
- NOT positioned as late-night — peak hours: 11 AM–2 PM, 3–7 PM
- No kitchen required (beverage-only food permit); optional prepackaged snacks + protein bars; creatine scoop add-in at bar

## Target clientele (primary)
1. Students — campus-adjacent (UTA, UTD, SMU, UNT), study sessions, student ID discount
2. Work from home — remote/hybrid, laptop-friendly seating, Wi-Fi/outlets, WFH weekday rate
3. Gamers & gym-goers — energy-native demo, customization, import wall

## Site structure
- site/index.html       18-slide presentation deck
- site/styles.css       Main deck styling (Texas palette)
- site/app.js           Slide nav, present mode, checklist localStorage (key: lonewolt-checklist)
- site/ordinances/      Per-city ordinance pages + use-comparison.html
- idea-checklist.md     Source workbook (PDF via convert-to-pdf.sh)

## Slides (deck nav titles)
Intro · Brand · Concept · Competitors · Vision · Audience · Locations · Compare ·
Risks · Profit · Growth · Community · Marketing · Capital · Launch · Suppliers ·
Research · Operations · Decision

## Key decisions from session
- Renamed from VOLT BAR → The Lone Volt
- Removed Texas brand-options table from Brand slide (name only now)
- Removed boba-bar / esports lounge analogy from concept copy
- Added food-requirements section on ordinances/use-comparison.html#food-required
- Added Marketing slide (find gyms, gaming cafés, students, WFH partners)
- GitHub Pages live deploy on push to main

## Hosting
- Live:  https://mjm2000.github.io/drinkshop/
- Repo:  https://github.com/mjm2000/drinkshop
- CI:    .github/workflows/deploy-pages.yml (deploys site/ folder)

## Helper scripts
- ./serve.sh [port]   Local preview (default http://localhost:8080)
- ./push.sh [msg]     git add, commit, push, watch Pages deploy
- ./session.sh        This file — print saved context

## Typical workflow
  ./serve.sh                    # preview locally
  # edit site/
  ./push.sh "Describe change"   # publish to GitHub Pages

## Ordinance research notes
- Operate as restaurant without drive-in (like coffee shop, not bar)
- Bar path requires TABC food service; energy shop does not
- Dallas Deep Ellum: restaurant by right in PD 269; midnight SUP only if hours past 12a
- Compare page: energy vs coffee vs bar (zoning, food, cost, setup)

## Files to bump after CSS/JS changes (cache bust)
- site/index.html → styles.css?v=N and app.js?v=N

EOF
  if [[ -f "$SESSION_LOG" ]]; then
    echo ""
    echo "--- Appended session notes (.session-log.md) ---"
    cat "$SESSION_LOG"
  fi
}

print_summary() {
  cat <<'EOF'
The Lone Volt | DFW energy drink bar concept | THE LONE VOLT
Live: https://mjm2000.github.io/drinkshop/  |  ./serve.sh  |  ./push.sh "msg"
Core: on-tap energy + custom builds + import retail | students + WFH + gamers/gym
Theme: burnt orange + Texas blue | no motto | no late-night positioning
Peak: 11 AM–2 PM, 3–7 PM | mid startup ~$242K | run ./session.sh for full context
EOF
}

append_note() {
  local note="$*"
  if [[ -z "$note" ]]; then
    echo "Usage: ./session.sh note \"Your note here\"" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$SESSION_LOG")"
  if [[ ! -f "$SESSION_LOG" ]]; then
    printf '# Session log\n\n' > "$SESSION_LOG"
  fi
  printf '\n## %s\n\n%s\n' "$(date '+%Y-%m-%d %H:%M %Z')" "$note" >> "$SESSION_LOG"
  echo "Note saved to .session-log.md"
}

print_scripts() {
  echo "Helper scripts in $SCRIPT_DIR:"
  for f in serve.sh push.sh session.sh convert-to-pdf.sh; do
    if [[ -x "$SCRIPT_DIR/$f" ]]; then
      echo "  ./$f"
    elif [[ -f "$SCRIPT_DIR/$f" ]]; then
      echo "  ./$f  (not executable — run: chmod +x $f)"
    fi
  done
}

case "$cmd" in
  show|context|"") print_full_context ;;
  summary|short)   print_summary ;;
  note)            append_note "$@" ;;
  log)             [[ -f "$SESSION_LOG" ]] && cat "$SESSION_LOG" || echo "No notes yet. Use: ./session.sh note \"...\"" ;;
  scripts)         print_scripts ;;
  help|-h|--help)
    sed -n '2,10p' "$0" | sed 's/^# \?//'
    ;;
  *)
    echo "Unknown command: $cmd (try: show, summary, note, log, scripts)" >&2
    exit 1
    ;;
esac
