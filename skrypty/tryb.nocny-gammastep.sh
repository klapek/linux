#!/bin/bash

# Ścieżka do pliku-flagi
FLAG_FILE="$HOME/.night_mode_on"
# Ikona żarówki z MATE (biała/symboliczna)
ICON="gammastep"

if [ -f "$FLAG_FILE" ]; then
    # TRYB: WYŁĄCZANIE (Powrót do bieli)
    gammastep -m randr -x
    rm "$FLAG_FILE"
    notify-send -i "$ICON" "Ekran: Tryb Dzienny" "Przywrócono standardową temperaturę barw (6500K)."
    echo "Reset barw - Dzień"
else
    # TRYB: WŁĄCZANIE (Filtr nocny)
    gammastep -m randr -x
    sleep 0.1
    # Ustawiamy 4200K (balans między vege-ciepłem a czytelnością)
    gammastep -m randr -O 4200
    touch "$FLAG_FILE"
    notify-send -i "$ICON" "Ekran: Tryb Nocny" "Ustawiono filtr światła niebieskiego (4200K)."
    echo "Noc - 4200K"
fi
