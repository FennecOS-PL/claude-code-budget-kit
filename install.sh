#!/usr/bin/env bash
# Instaluje skill budget-routing do ~/.claude/skills.
# Opcjonalnie (--settings) dopisuje próg compactu do ~/.claude/settings.json bez nadpisywania reszty.
set -euo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
PCT="${PCT:-60}"

mkdir -p "$DEST/skills"
if [ -e "$DEST/skills/budget-routing" ]; then
  echo "Już istnieje: $DEST/skills/budget-routing (pomijam, usuń ręcznie, jeśli chcesz zaktualizować)"
else
  cp -R "$HERE/skills/budget-routing" "$DEST/skills/budget-routing"
  echo "Zainstalowano skill: $DEST/skills/budget-routing"
fi

if [ "${1:-}" = "--settings" ]; then
  python3 - "$DEST/settings.json" "$PCT" <<'PY'
import json, os, sys
path, pct = sys.argv[1], sys.argv[2]
data = {}
if os.path.exists(path):
    with open(path, encoding="utf-8") as f:
        data = json.load(f)
data.setdefault("env", {})["CLAUDE_AUTOCOMPACT_PCT_OVERRIDE"] = pct
data["autoCompactEnabled"] = True
with open(path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
    f.write("\n")
print(f"Ustawiono próg compactu {pct}% w {path} (działa od nowej sesji)")
PY
fi
echo "Gotowe. Uruchom nową sesję Claude Code."
