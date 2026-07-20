#!/bin/bash
set -euo pipefail

pokaz_pomoc() {
    echo "--- BASH-WIKI: KOMPENDIUM ---"
    echo "1. Zabezpieczenia (set)"
    echo "2. Warunki i flagi plików (-f, -z, itp.)"
    echo "3. Zmienne i operatory"
    echo "4. Pętle i sterowanie (for, while, case)"
    echo "5. Tablice i Funkcje"
    echo "6. Trap i obsługa błędów"
}

if [[ -z "${1:-}" ]]; then pokaz_pomoc; exit 0; fi

case "$1" in
    1) echo "--- SEKCJA 1: set ---
set -e: wyjście przy błędzie.
set -u: wyjście przy braku zmiennej.
set -o pipefail: wyjście przy błędzie w potoku." ;;
    2) echo "--- SEKCJA 2: Flagi ---
-f [plik]: istnieje i jest plikiem.
-d [dir]: istnieje i jest folderem.
-z [str]: ciąg pusty.
-e [obj]: obiekt istnieje.
[[ A == B ]]: równe.
[[ A -eq B ]]: liczby równe." ;;
    3) echo "--- SEKCJA 3: Zmienne ---
\$0: nazwa skryptu.
\$1: pierwszy parametr.
\$#: liczba parametrów.
\$?: ostatni kod błędu (0 = sukces).
\${VAR:-domyslna}: jeśli zmienna pusta, użyj wartości domyślnej." ;;
    4) echo "--- SEKCJA 4: Pętle ---
for i in *; do ... done: pętla po plikach.
while read line; do ... done < plik: czytanie pliku linia po linii." ;;
    5) echo "--- SEKCJA 5: Tablice i Funkcje ---
arr=( 'a' 'b' 'c' ): deklaracja tablicy.
\${arr[0]}: pierwszy element.
\${#arr[@]}: ilość elementów.
funkcja() { return 0; }: definicja funkcji." ;;
    6) echo "--- SEKCJA 6: Trap ---
trap 'komenda' EXIT: wykonaj przy zakończeniu.
trap 'komenda' ERR: wykonaj przy błędzie (set -e)." ;;
    *) echo "Brak takiej sekcji.";;
esac
