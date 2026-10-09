# Claude Code Budget Kit

Skill do Claude Code, który obniża zużycie tokenów bez wyraźnej utraty jakości. Uczy Claude'a, który model wybrać do jakiego zadania, jak planować drogim modelem a wykonywać tanim, ile agentów uruchamiać i jak ustawić próg automatycznego compactu.

Spis treści: [Po co to jest](#po-co-to-jest) · [Jak to działa](#jak-to-działa) · [Instalacja](#instalacja) · [Konfiguracja](#konfiguracja-krok-po-kroku) · [Który model do czego](#który-model-do-czego) · [Plan na mocnym, wykonanie na tanim](#plan-na-mocnym-wykonanie-na-tanim) · [Budżet agentów](#budżet-agentów) · [Próg compactu](#próg-compactu) · [Przykładowa sesja](#przykładowa-sesja) · [Aktualizacja i odinstalowanie](#aktualizacja-i-odinstalowanie) · [FAQ i problemy](#faq-i-problemy) · [Zastrzeżenia](#zastrzeżenia) · [English](#english)

## Po co to jest

Koszt pracy z Claude Code rośnie z trzech powodów, a sam wybór modelu jest tylko jednym z nich:

1. **Za mocny model do prostej roboty.** Szukanie w plikach, wyciąganie pól czy formatowanie nie wymagają najmocniejszego modelu.
2. **Za dużo agentów i za długie wyniki.** Każdy agent czyta swoje pliki od zera i odpowiada elaboratem. Przy audycie wielu plików to szybko liczy się w milionach tokenów.
3. **Za długi kontekst.** Im dłuższa sesja, tym drożej kosztuje każde kolejne zapytanie, a jakość odpowiedzi z przeładowanego kontekstu spada.

Ten skill adresuje wszystkie trzy naraz i robi to bez dodatkowych narzędzi: to zestaw instrukcji, które Claude czyta i stosuje, plus opcjonalny próg compactu w ustawieniach.

## Jak to działa

**Skill to plik z instrukcjami.** W `skills/budget-routing/SKILL.md` leży opis (kiedy skill się włącza) i treść (co Claude ma robić). Claude Code czyta opisy wszystkich zainstalowanych skilli, a pełną treść ładuje dopiero wtedy, gdy zadanie pasuje do opisu albo wywołasz skill wprost przez `/budget-routing`. Dzięki temu skill nic nie kosztuje, dopóki nie jest potrzebny.

**Co skill robi po załadowaniu:**

- Claude dobiera model do zadania według tabeli z tego repozytorium, zamiast używać jednego modelu do wszystkiego.
- Przy zadaniach wieloetapowych proponuje wzorzec plan na mocnym modelu, wykonanie na tańszym.
- Przed uruchomieniem wielu agentów liczy ich, ogranicza długość wyników i podaje Ci szacunek kosztu.
- Podpowiada próg compactu i wyjaśnia, jak go ustawić.

**Czego skill nie robi.** Nie zmienia sam ustawień, nie przełącza modelu Twojej sesji i nie blokuje żadnych narzędzi. To zestaw reguł, które Claude stosuje, a nie wymuszenie na poziomie systemu. Jedyna rzecz zmieniająca konfigurację to opcjonalny przełącznik `--settings` w instalatorze, który uruchamiasz świadomie.

**Dwie warstwy.** Skill (instrukcje) działa na zachowanie Claude'a. Zmienne środowiskowe compactu działają na samo narzędzie Claude Code. Możesz używać obu albo tylko jednej.

## Instalacja

Wymagania: zainstalowany Claude Code, `bash` i `python3` (tylko dla opcji `--settings`).

```bash
git clone https://github.com/FennecOS-PL/claude-code-budget-kit.git
cd claude-code-budget-kit
./install.sh
```

Z ustawieniem progu compactu (domyślnie 60%, zmienisz przez `PCT=50`):

```bash
./install.sh --settings
```

```bash
PCT=50 ./install.sh --settings
```

Co robi instalator:

- Kopiuje skill do `~/.claude/skills/budget-routing`. Jeśli taki folder już istnieje, pomija kopiowanie i niczego nie nadpisuje.
- Z opcją `--settings` dopisuje do `~/.claude/settings.json` dwa klucze: `env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` oraz `autoCompactEnabled`. Pozostała zawartość pliku zostaje. Jeśli plik nie istnieje, powstaje nowy.
- Własny folder konfiguracji ustawisz zmienną `CLAUDE_HOME`.

Instalacja ręczna: skopiuj folder `skills/budget-routing` do `~/.claude/skills/`, a próg compactu wpisz sam według wzoru z pliku `settings.example.json`.

**Zmiany działają od nowej sesji.** Zmienne środowiskowe Claude Code czyta przy starcie, więc w trwającej sesji nic się nie zmieni.

## Konfiguracja krok po kroku

1. **Zainstaluj** skill i próg compactu jedną komendą: `./install.sh --settings`.
2. **Zamknij Claude Code i otwórz nową sesję.** Bez tego zmienne środowiskowe nie zadziałają.
3. **Sprawdź, czy skill widać.** Wpisz `/budget-routing`. Jeśli skill się załaduje, instalacja się udała.
4. **Sprawdź, czy automat compactu jest włączony.** W terminalu wpisz `/config autoCompact=true`. W aplikacji desktopowej to samo ustawisz w ustawieniach lub poleceniem w terminalowej sesji `claude`.
5. **Ustaw domyślny model.** Skill zakłada, że sesja stoi na Sonnecie. Ustawisz to poleceniem `/config model=sonnet` albo kluczem `"model": "sonnet"` w `~/.claude/settings.json`. Jeśli wolisz zostać przy Opusie, skill nadal działa, ale oszczędność będzie mniejsza.
6. **Dopasuj próg do swojego okna.** Dla okna 200 tys. zacznij od 60%. Dla okna 1M ustaw twardy limit w tokenach zamiast procentu:

   ```json
   {
     "env": {
       "CLAUDE_CODE_AUTO_COMPACT_WINDOW": "200000"
     },
     "autoCompactEnabled": true
   }
   ```

7. **Obserwuj.** Przez kilka sesji patrz, kiedy compact faktycznie startuje (pasek statusu pokazuje zapełnienie kontekstu) i skoryguj próg o 5-10 punktów.
8. **Przy dużym zadaniu przypomnij skill.** Napisz na początku: oszczędzaj tokeny, albo wywołaj `/budget-routing`. Claude poda szacunek kosztu i zapyta o zgodę przed uruchomieniem wielu agentów.

Opcjonalnie dopisz do własnego pliku `CLAUDE.md` jedną linię, która sprawi, że zasady obowiązują zawsze, a nie tylko po wywołaniu skilla:

```
Przy zadaniach z wieloma agentami stosuj skill budget-routing: tani model do masówki, mocny tylko do planu i weryfikacji, krótki szacunek kosztu przed startem.
```

## Który model do czego

| Model | Używaj do | Nie używaj do |
|---|---|---|
| Haiku | masowa, prosta robota z jasnym wzorcem: szukanie w plikach, wyciąganie pól, klasyfikacja, formatowanie, krótkie streszczenia | decyzji, trudnego kodu, niejednoznacznych poleceń |
| Sonnet | domyślny wybór: kod, pisanie, analiza dokumentów, wykonanie zatwierdzonego planu | wielkich, niejasnych decyzji architektonicznych |
| Opus | plan wieloplikowy, architektura, trudny debug, audyt i weryfikacja zarzutów o wysokiej stawce | masówki i rutyny |

Reguła kciuka: im wyższy koszt pomyłki i im mniej oczywiste zadanie, tym mocniejszy model. Im bardziej powtarzalne zadanie, tym tańszy.

Repozytorium nie podaje cen ani stosunku kosztów modeli, bo zmieniają się z wersjami. Aktualny cennik sprawdź u dostawcy.

## Plan na mocnym, wykonanie na tanim

Najtańszy sposób na dobrą jakość to oddzielenie myślenia od pisania:

1. **Plan.** Przełącz się na mocny model (Opus) i włącz tryb planowania. W tym trybie Claude niczego nie zmienia w plikach, tylko pisze plan: kroki, pliki, kryterium ukończenia. Plan ma być krótki i konkretny, żeby wykonawca nie musiał zgadywać.
2. **Zatwierdzenie.** Czytasz plan i akceptujesz go albo poprawiasz.
3. **Wykonanie.** Przełącz model na Sonneta i wykonaj plan. Kontekst zostaje, więc plan nie ginie. Masówkę z planu (przesiew, szukanie) Claude oddaje agentom na Haiku.
4. **Kontrola.** Mocny model wraca tylko tam, gdzie pomyłka jest droga, na przykład do sprawdzenia wyniku audytu.

**Zmiana modelu w trakcie sesji ma koszt.** Może unieważnić cache promptu, więc pierwsze zapytanie po przełączeniu kosztuje więcej. Dlatego skill każe nie przełączać modelu sesji bez Twojej zgody i przełączać rzadko: raz po planie, a nie co chwilę.

**Lepsza alternatywa: agenci z własnym modelem.** Claude może zlecić kawałek pracy agentowi z parametrem `model` (haiku, sonnet albo opus). Sesja zostaje na jednym modelu, a pojedyncze zadania idą do tańszego lub mocniejszego wykonawcy. To nie resetuje cache głównej rozmowy.

Przy małych zadaniach pomiń Opusa. Plan na mocnym modelu opłaca się przy pracy wieloplikowej, architekturze i audytach.

## Budżet agentów

Gdy zadanie wymaga wielu agentów (na przykład audyt dziesiątek plików), skill każe Claude'owi:

1. **Policzyć agentów.** Domyślnie poniżej 5, twardy limit 12. Powyżej 10 Claude podaje szacunek kosztu i pyta o zgodę.
2. **Zrobić wspólny skrót faktów.** Zamiast kazać każdemu agentowi czytać wszystko, jeden agent na Haiku przygotowuje skrót dla grupy plików i zapisuje go do pliku roboczego. Kolejne etapy czytają skrót i otwierają pełny plik tylko przy konkretnym podejrzeniu. To zwykle największa oszczędność.
3. **Ograniczyć wyniki.** Wynik agenta to krótka tabela (plik, problem, waga), około 500 tokenów, bez opowiadania.
4. **Weryfikować tylko to, co ważne.** Drugi agent (sceptyk) sprawdza zarzuty o najwyższej i drugiej wadze. Niższe trafiają do raportu bez weryfikacji.
5. **Poprawiać jednym przebiegiem.** Zamiast osobnego agenta na każdą poprawkę, wszystkie nanosi jeden przebieg.
6. **Podać szacunek przed startem.** Liczba agentów i orientacyjne tokeny. Jeśli środowisko udostępnia odczyt zużycia limitu, także procent okna. Start dopiero po Twojej zgodzie.

Po zakończeniu Claude porównuje faktyczne zużycie z szacunkiem i zgłasza rozjazd większy niż dwukrotny.

## Próg compactu

Compact to streszczenie dotychczasowej rozmowy, które zastępuje długą historię i zwalnia miejsce w oknie kontekstu. Claude Code robi to automatycznie, gdy okno zbliża się do zapełnienia. Im później to następuje, tym dłuższy i droższy kontekst nosisz, a im wcześniej, tym częściej płacisz za samo streszczanie i gubisz szczegóły.

Są trzy ustawienia:

| Ustawienie | Gdzie | Działanie |
|---|---|---|
| `autoCompactEnabled` | `settings.json` albo `/config autoCompact=true` | włącza lub wyłącza automat |
| `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` | `env` w `settings.json` | procent okna (1-100), przy którym startuje compact |
| `CLAUDE_CODE_AUTO_COMPACT_WINDOW` | `env` w `settings.json` | ogranicza efektywne okno do podanej liczby tokenów (od 100 000 do 1 000 000) |

**Jak liczy się próg procentowy.** Zgodnie z lekturą kodu Claude Code 2.1.215 próg to mniejsza z dwóch wartości: procent okna albo okno pomniejszone o 13 000 tokenów. Przykłady:

| Okno | Ustawienie | Compact startuje około |
|---|---|---|
| 200 000 | 60% | 120 000 tokenów |
| 200 000 | 80% | 160 000 tokenów |
| 1 000 000 | 40% | 400 000 tokenów |
| 1 000 000 | 60% | 600 000 tokenów |

**Dla dużego okna** (na przykład 1M) procent bywa mało intuicyjny, bo nawet 20% to 200 tys. tokenów. Wtedy wygodniej użyć `CLAUDE_CODE_AUTO_COMPACT_WINDOW`, który ustawia twardy limit w tokenach, na przykład `200000`.

**Punkt wyjścia.** Proponuję 60-70% okna, a przy pracy na dużych plikach około 50%. To heurystyka, nie pomiar. Zbyt niski próg zwiększa koszt, bo każdy compact też kosztuje.

**Dodatkowe wskazówki:**

- Ręczny `/compact` z instrukcją, co zachować (decyzje, ścieżki plików, otwarte zadania), daje lepszy wynik niż automat.
- Dla niezależnych zadań lepsza jest nowa sesja z krótkim skrótem niż compact.

Przykład ręcznego wpisu w `~/.claude/settings.json`:

```json
{
  "env": {
    "CLAUDE_AUTOCOMPACT_PCT_OVERRIDE": "60"
  },
  "autoCompactEnabled": true
}
```

## Przykładowa sesja

Zadanie: audyt 40 plików dokumentacji pod kątem błędów.

1. Piszesz: oszczędzaj tokeny, zrób audyt tych 40 plików.
2. Skill się ładuje. Claude proponuje: 4 agentów na Haiku robią skróty faktów (po 10 plików), jeden agent na Sonnecie analizuje skróty, jeden na Opusie weryfikuje tylko zarzuty najwyższej wagi. Razem 6 agentów, wyniki w tabelach.
3. Claude podaje szacunek kosztu i pyta o zgodę.
4. Po Twojej zgodzie wykonuje audyt, a na końcu porównuje faktyczne zużycie z szacunkiem.

Bez skilla to samo zadanie często kończy się 40 agentami, z których każdy czyta swój plik i pisze długi raport, a potem drugi komplet agentów to weryfikuje.

## Aktualizacja i odinstalowanie

**Aktualizacja.** Pobierz najnowszą wersję (`git pull`), usuń stary folder skilla i uruchom instalator ponownie:

```bash
rm -rf ~/.claude/skills/budget-routing
./install.sh
```

**Odinstalowanie.**

```bash
rm -rf ~/.claude/skills/budget-routing
```

Jeśli użyłeś `--settings`, usuń ręcznie z `~/.claude/settings.json` klucz `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` z sekcji `env` oraz, jeśli chcesz, `autoCompactEnabled`.

## FAQ i problemy

**Skill się nie włącza.** Sprawdź, czy folder `~/.claude/skills/budget-routing/SKILL.md` istnieje, i uruchom nową sesję. Możesz też wywołać go wprost: `/budget-routing`.

**Compact nie startuje tam, gdzie ustawiłem.** Sprawdź, czy to nowa sesja (zmienne czytane są przy starcie), czy `autoCompactEnabled` jest `true` i czy wartość to liczba w cudzysłowie lub bez. Nazwy i zachowanie zmiennych sprawdzono w wersji 2.1.215, w innych mogą się różnić.

**Czy to zmienia mój model domyślny?** Nie. Instalator nie dotyka klucza `model` w ustawieniach.

**Czy skill działa w aplikacji desktopowej i w terminalu?** Skill to zwykły plik w `~/.claude/skills`, więc działa wszędzie, gdzie Claude Code czyta ten folder. Ustawienia środowiskowe czyta zarówno terminalowy Claude Code, jak i aplikacja, ale zachowanie w poszczególnych wersjach aplikacji nie było tu testowane.

**Czy mogę zmienić limity (5 agentów, 12 agentów, 500 tokenów)?** Tak, edytuj `SKILL.md`. To zwykły tekst. Pamiętaj, że instalator nie nadpisuje istniejącej instalacji, więc po zmianie w repo skopiuj plik ręcznie.

**Czy skill pomaga przy zwykłej rozmowie, bez agentów?** Częściowo: podpowiada dobór modelu i próg compactu. Największy efekt daje przy zadaniach wieloagentowych i długich sesjach.

## Zastrzeżenia

- Zachowanie zmiennych compactu sprawdzono w Claude Code 2.1.215. Po aktualizacji zwróć uwagę, czy compact startuje tam, gdzie oczekujesz.
- Progi (60-70% okna, limit agentów, 500 tokenów na wynik) to punkty wyjścia, nie wyniki pomiarów. Dobierz je do własnej pracy.
- Skill to instrukcje dla Claude'a, nie mechanizm wymuszający. Claude może się od nich odchylić, więc w razie potrzeby przypomnij je poleceniem `/budget-routing`.
- Repozytorium nie podaje cen modeli.

## Struktura repozytorium

```
claude-code-budget-kit/
  skills/budget-routing/SKILL.md   treść skilla
  install.sh                       instalator (opcja --settings)
  settings.example.json            przykład progu compactu
  README.md                        ten plik
  LICENSE                          MIT
```

## Wkład

Uwagi i poprawki zgłaszaj przez Issues albo Pull Requesty. Szczególnie przydatne są pomiary: przy jakim progu compactu i jakim doborze modeli oszczędzasz najwięcej w swojej pracy.

## English

A Claude Code skill that cuts token spend while keeping most of the quality. It teaches Claude to route work across Haiku, Sonnet and Opus, to plan on the strong model and execute on a cheaper one, to cap agent count and result length, and to tune the auto-compact threshold.

**How it works.** A skill is a folder with a `SKILL.md`: a short description (when to load it) and a body (what to do). Claude Code reads the descriptions of all installed skills and loads the body only when the task matches or when you call `/budget-routing`. The skill changes Claude's behaviour, not your settings, and it never switches your session model on its own.

**What it covers.**

- Model routing table: Haiku for bulk simple work, Sonnet as the default workhorse, Opus for plans, architecture, hard debugging and verification of high-stakes findings.
- Plan-then-execute: plan in plan mode on Opus, approve, switch to Sonnet to execute. Switching models mid-session can invalidate the prompt cache, so prefer delegating pieces to sub-agents with an explicit `model` parameter.
- Agent budget: fewer than 5 agents by default (hard cap 12), a shared fact digest instead of every agent re-reading everything, short tabular results (about 500 tokens), a skeptic pass only on the top two severity levels, one fix pass, and a cost estimate before launch.
- Auto-compact threshold via `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` (percent of window; effective threshold is the smaller of that percent and window minus 13,000 tokens) and `CLAUDE_CODE_AUTO_COMPACT_WINDOW` (caps the effective window, 100k to 1M tokens). Both are set under `env` in `~/.claude/settings.json` and take effect on the next session.

**Install.**

```bash
git clone https://github.com/FennecOS-PL/claude-code-budget-kit.git
cd claude-code-budget-kit
./install.sh               # skill only
./install.sh --settings    # also writes the compact threshold (PCT=60 by default)
```

The installer never overwrites an existing skill folder and merges into `settings.json` without touching other keys. Uninstall with `rm -rf ~/.claude/skills/budget-routing` and remove the keys you added.

**Caveats.** Variable behaviour was verified against Claude Code 2.1.215 and may differ in other versions. Thresholds are starting points, not measurements. The skill is guidance for the model, not enforcement. No pricing is claimed; check your provider's current price list.

## Licencja

MIT
