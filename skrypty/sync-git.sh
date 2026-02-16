#!/bin/bash

# --- KONFIGURACJA INTELIGENTNA ---
# Sprawdzamy, czy jesteśmy w folderze, który jest pod kontrolą Git
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    notify-send -i "vcs-conflicting" "Git Sync" "To nie jest folder repozytorium!"
    echo "❌ Błąd: Musisz być wewnątrz folderu repo (np. linux lub starex4x4)."
    exit 1
fi

# Automatyczne wykrycie nazwy repozytorium i jego głównej ścieżki
REPO_DIR=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_DIR")
MESSAGE="Automatyczny update ($REPO_NAME): $(date '+%Y-%m-%d %H:%M')"
ICON_OK="vcs-normal"
ICON_ERR="vcs-conflicting"

echo "🚀 Start synchronizacji repozytorium: $REPO_NAME"
cd "$REPO_DIR" || exit 1

# --- 1. POBIERZ NOWOŚCI Z SERWERA ---
echo "📥 Pobieranie zmian (Pull) dla $REPO_NAME..."
if git pull origin main; then
    echo "Pobrano pomyślnie."
else
    notify-send -i "$ICON_ERR" "Git Sync" "Błąd Pull w $REPO_NAME!"
    exit 1
fi

# --- 2. SPRAWDŹ LOKALNE ZMIANY ---
if [[ -n $(git status -s) ]]; then
    echo "📤 Wysyłanie zmian (Push) dla $REPO_NAME..."
    git add .
    git commit -m "$MESSAGE"
    if git push origin main; then
        notify-send -i "$ICON_OK" "Git Sync" "Repozytorium $REPO_NAME zaktualizowane!"
        echo "✅ Zrobione!"
    else
        notify-send -i "$ICON_ERR" "Git Sync" "Błąd Push w $REPO_NAME!"
    fi
else
    notify-send -i "$ICON_OK" "Git Sync" "$REPO_NAME: Wszystko aktualne."
    echo "✨ Brak zmian."
fi
