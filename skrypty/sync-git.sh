#!/bin/bash

# --- KONFIGURACJA ---
REPO_DIR="$HOME/Projekty/linux"
MESSAGE="Automatyczny update: $(date '+%Y-%m-%d %H:%M')"
# Ikony systemowe (działają na większości distro)
ICON_OK="vcs-normal"
ICON_ERR="vcs-conflicting"

echo "🚀 Start synchronizacji repozytorium..."
cd "$REPO_DIR" || { 
    notify-send -i "$ICON_ERR" "Git Sync" "Błąd: Nie znaleziono katalogu!"
    exit 1; 
}

# 1. Pobierz nowości z serwera
echo "📥 Pobieranie zmian (Pull)..."
if git pull origin main; then
    echo "Pobrano pomyślnie."
else
    notify-send -i "$ICON_ERR" "Git Sync" "Błąd podczas pobierania danych (Pull)!"
    exit 1
fi

# 2. Sprawdź czy są lokalne zmiany do wysłania
if [[ -n $(git status -s) ]]; then
    echo "📤 Wykryto lokalne zmiany. Wysyłanie (Push)..."
    git add .
    git commit -m "$MESSAGE"
    if git push origin main; then
        notify-send -i "$ICON_OK" "Git Sync" "Synchronizacja OK! Wysłano nowe zmiany."
        echo "✅ Zrobione!"
    else
        notify-send -i "$ICON_ERR" "Git Sync" "Błąd podczas wysyłania (Push)!"
    fi
else
    notify-send -i "$ICON_OK" "Git Sync" "Wszystko aktualne (nic nie wysłano)."
    echo "✨ Brak zmian."
fi
