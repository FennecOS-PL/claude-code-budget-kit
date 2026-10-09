---
name: budget-routing
description: Dobór modelu i budżetu tokenów w Claude Code. Dzieli zadania między Haiku, Sonnet i Opus, planuje na mocnym modelu a wykonuje na tańszym, ogranicza liczbę agentów i długość ich wyników oraz podpowiada próg automatycznego compactu. Użyj gdy użytkownik mówi "oszczędzaj tokeny", "mały budżet", "jaki model do czego", "zaplanuj i wykonaj taniej", "ile to zużyje", "budget", "cheaper model", albo gdy planujesz wielu agentów, Workflow lub audyt wielu plików.
---

# Budget routing

Cel: mniejsze zużycie tokenów przy zachowaniu większości jakości. Odpowiadaj w języku użytkownika.

## 1. Który model do czego

| Model | Używaj do | Nie używaj do |
|---|---|---|
| Haiku | masowa, prosta robota z jasnym wzorcem: szukanie w plikach, wyciąganie pól, klasyfikacja, formatowanie, krótkie streszczenia | decyzji, trudnego kodu, niejednoznacznych poleceń |
| Sonnet | domyślny wybór: kod, pisanie, analiza dokumentów, wykonanie zatwierdzonego planu | wielkich, niejasnych decyzji architektonicznych |
| Opus | plan wieloplikowy, architektura, trudny debug, audyt i weryfikacja zarzutów o wysokiej stawce | masówki i rutyny |

Reguła kciuka: im wyższy koszt pomyłki i im mniej oczywiste zadanie, tym mocniejszy model. Im bardziej powtarzalne, tym tańszy.

## 2. Wzorzec: plan mocny, wykonanie tanie

1. Opus (tryb planowania) pisze krótki plan: kroki, pliki, kryterium ukończenia. Bez zmian w plikach.
2. Użytkownik zatwierdza plan.
3. Wykonanie przechodzi na Sonneta. Masówkę (przesiew, szukanie) robi Haiku.
4. Opus wraca tylko do sprawdzenia wyników o dużej stawce.

Nie przełączaj modelu sesji bez zgody użytkownika: zmiana w trakcie rozmowy może unieważnić cache promptu i podnieść koszt. Zamiast tego zlecaj kawałki agentom z parametrem `model` (haiku, sonnet, opus). Sesja zostaje na jednym modelu.

## 3. Budżet agentów

Przed uruchomieniem wielu agentów lub Workflow:

1. Policz agentów. Domyślnie poniżej 5, twardy limit 12. Powyżej 10 podaj użytkownikowi szacunek kosztu i zapytaj o zgodę.
2. Nie każ każdemu agentowi czytać wszystkiego. Jeden agent Haiku robi skrót faktów dla grupy plików i zapisuje go do pliku roboczego. Kolejne etapy czytają skrót i otwierają pełny plik tylko przy konkretnym podejrzeniu.
3. Wynik agenta ma być krótki: tabela (plik, problem, waga), około 500 tokenów, bez opowiadania.
4. Sceptyk (drugi agent weryfikujący) sprawdza tylko zarzuty wagi najwyższej i drugiej. Niższe idą do raportu bez weryfikacji.
5. Poprawki nanoś jednym przebiegiem, nie osobnym agentem na każdą.
6. Podaj użytkownikowi szacunek: liczba agentów, orientacyjne tokeny. Jeśli środowisko udostępnia odczyt zużycia limitu, podaj też procent okna. Start po zgodzie.

Po zakończeniu porównaj faktyczne zużycie z szacunkiem. Rozjazd większy niż dwukrotny zgłoś użytkownikowi.

## 4. Próg automatycznego compactu

Claude Code ma dwie zmienne środowiskowe (ustawiane w `env` w `~/.claude/settings.json`, działają od nowej sesji):

- `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE` - procent okna (1-100), przy którym startuje compact. Efektywny próg to mniejsza z wartości: procent okna albo okno minus 13 000 tokenów.
- `CLAUDE_CODE_AUTO_COMPACT_WINDOW` - ogranicza efektywne okno do podanej liczby tokenów (zakres 100 000 do 1 000 000).

Dodatkowo sam przełącznik `autoCompactEnabled` (`/config autoCompact=true`) włącza i wyłącza automat.

Punkt wyjścia: 60-70% okna, a przy pracy na dużych plikach około 50%. Zbyt niski próg zwiększa koszt, bo każdy compact kosztuje. Ręczny `/compact` z instrukcją, co zachować, daje lepszy wynik niż automat. Dla niezależnych zadań lepsza jest nowa sesja z krótkim skrótem.

Wartości progu to punkt startowy, nie pomiar. Poproś użytkownika, by obserwował, kiedy compact faktycznie startuje, i skoryguj.

## Czego nie robić

- Nie podawaj cen ani stosunku kosztów modeli z pamięci. Odeślij do aktualnego cennika dostawcy.
- Nie włączaj trybu wielu agentów dla zadania, które mieści się w jednym.
- Nie ustawiaj ustawień użytkownika bez jego zgody.
