# Claude Code Budget Kit

Skill do Claude Code, który obniża zużycie tokenów bez wyraźnej utraty jakości. Dzieli pracę między Haiku, Sonneta i Opusa, planuje na mocnym modelu a wykonuje na tańszym, pilnuje liczby agentów i podpowiada próg automatycznego compactu.

## Instalacja

```bash
git clone https://github.com/FennecOS-PL/claude-code-budget-kit.git
cd claude-code-budget-kit
./install.sh
```

Z ustawieniem progu compactu (domyślnie 60%, zmienisz przez `PCT=50`):

```bash
./install.sh --settings
```

Skrypt kopiuje skill do `~/.claude/skills/budget-routing` i niczego nie nadpisuje. Opcja `--settings` dopisuje do `~/.claude/settings.json` tylko `env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` i `autoCompactEnabled`, reszta pliku zostaje. Zmiany działają od nowej sesji.

Ręcznie: skopiuj folder `skills/budget-routing` do `~/.claude/skills/`.

## Użycie

Skill włącza się, gdy napiszesz na przykład: oszczędzaj tokeny, jaki model do czego, mały budżet, albo gdy Claude planuje wielu agentów. Możesz też wywołać go wprost: `/budget-routing`.

## Co zawiera

- Tabelę: który model do czego.
- Wzorzec plan na Opusie, wykonanie na Sonnecie, masówka na Haiku.
- Zasady budżetu agentów: limit, krótkie wyniki, wspólny skrót faktów, weryfikacja tylko zarzutów o najwyższej wadze.
- Dwie zmienne progu compactu:
  - `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` - procent okna, przy którym startuje compact.
  - `CLAUDE_CODE_AUTO_COMPACT_WINDOW` - ogranicza efektywne okno do liczby tokenów (100 000 do 1 000 000).

## Zastrzeżenia

- Nazwy i zachowanie zmiennych compactu sprawdzono w wersji Claude Code 2.1.215. W innych wersjach mogą się różnić, więc po aktualizacji zwróć uwagę, czy compact startuje tam, gdzie oczekujesz.
- Progi (60-70% okna) to punkt wyjścia, nie pomiar. Dobierz je do własnej pracy.
- Repozytorium nie podaje cen modeli. Aktualny cennik sprawdź u dostawcy.

## English summary

A Claude Code skill that cuts token spend while keeping most of the quality: route work across Haiku / Sonnet / Opus, plan on the strong model and execute on a cheaper one, cap agent count and result length, and tune the auto-compact threshold via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (percent of window) and `CLAUDE_CODE_AUTO_COMPACT_WINDOW` (token cap, 100k-1M). Install with `./install.sh` (add `--settings` to write the compact threshold into `~/.claude/settings.json` without touching other keys). Verified against Claude Code 2.1.215; thresholds are starting points, not measurements. No pricing is claimed.

## Licencja

MIT
