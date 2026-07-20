#!/bin/bash

# ==============================================================================
# ŚCIĄGA-BASH: Zrozumieć "dlaczego"
# ==============================================================================

# set -euo pipefail:
# -e (errexit): jeśli jakakolwiek komenda się nie uda (błąd), skrypt staje. 
# -u (nounset): jeśli użyjesz nazwy zmiennej, która nie istnieje, skrypt staje (chroni przed literówkami).
# -o pipefail: jeśli masz np. "komenda1 | komenda2" i pierwsza padnie, skrypt wyłapie ten błąd.
set -euo pipefail

# ZMIENNE I TABLICE
# "${...[@]}" - używamy w pętlach, żeby Bash nie "pożarł" spacji w nazwach plików.
imie="Klapek"
tablica=("jeden" "dwa" "trzy")
echo "Witaj ${imie}, drugi element tablicy to: ${tablica[1]}"

# PĘTLA FOR (iteracja)
# "${tablica[@]}" - to ważne: cudzysłowy mówią: "traktuj każdy element jako oddzielny byt".
for element in "${tablica[@]}"; do
    echo "Element: $element"
done

# WARUNEK IF (sprawdzanie pliku i zmiennych)
# [[ ... ]] - podwójne nawiasy to "inteligentne" sprawdzanie (bezpieczniejsze niż pojedyncze [ ]).
# -f "$0" - sprawdza czy obiekt to zwykły plik (f = file).
# -z "$1" - sprawdza czy długość zmiennej wynosi zero (z = zero, czyli sprawdzamy czy pusta).
if [[ -f "$0" ]]; then
    echo "Ten skrypt istnieje."
fi

# FUNKCJA
# local - to bardzo ważne: sprawia, że zmienna żyje tylko wewnątrz funkcji.
# bez "local", zmienna nadpisałaby wszystko poza funkcją (tzw. zasięg globalny).
moja_funkcja() {
    local lokalna="Wewnątrz funkcji"
    echo "$lokalna - argument przekazany do funkcji: $1"
}
moja_funkcja "test"

# TRAP (automatyczne sprzątanie)
# trap to "pułapka" na zdarzenia:
# EXIT - wyzwala się gdy skrypt kończy pracę (poprawnie lub przez błąd).
# ERR - wyzwala się tylko gdy coś pójdzie nie tak (wymaga ustawionego -e).
cleanup() { echo "Sprzątam pliki tymczasowe przed wyjściem..."; }
trap cleanup EXIT

echo "Koniec demonstracji."
