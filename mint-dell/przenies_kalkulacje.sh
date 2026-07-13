#!/bin/bash

# Definiujemy ścieżki
SOURCE_DIR="$HOME/Pobrane"
TARGET_DIR="$HOME/Dokumenty/kalkulacje/kalkulator-produkcja-json"

# Stwórz katalog docelowy, jeśli jeszcze nie istnieje
mkdir -p "$TARGET_DIR"

# Włączamy nullglob, aby pętla nie sypała błędami przy braku plików
shopt -s nullglob

# Sprawdzamy pliki pasujące do wzorca
FILES=("$SOURCE_DIR"/kalkulator-dane-*.json)
COUNT=${#FILES[@]}

if [ $COUNT -gt 0 ]; then
    for file in "${FILES[@]}"; do
        mv "$file" "$TARGET_DIR/"
    done
    
    # Dymek z sukcesem dla MATE
    notify-send -i folder-download "Kalkulator danych" "Pomyślnie przeniesiono pliki ($COUNT szt.) do katalogu kalkulacje."
else
    # Dymek z informacją o braku plików
    notify-send -i dialog-error "Kalkulator danych" "Brak nowych plików 'kalkulator-dane-*.json' w folderze Pobrane."
fi

# Wyłączamy nullglob
shopt -u nullglob
