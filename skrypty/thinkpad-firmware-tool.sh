#!/bin/bash

# Kolory dla lepszej czytelności
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== ThinkPad E16 Gen 2 Firmware Manager ===${NC}"

show_menu() {
    echo -e "\n1. Sprawdź dostępne aktualizacje (rozmiar)"
    echo -e "2. Sprawdź miejsce w EFI i bezpieczeństwo"
    echo -e "3. Rozpocznij aktualizację (fwupdmgr update)"
    echo -e "q. Wyjście"
    echo -ne "\nWybierz opcję: "
}

get_updates_size() {
    echo -e "\n${YELLOW}Pobieranie metadanych i obliczanie rozmiaru...${NC}"
    # Odświeżamy bazę danych
    fwupdmgr refresh > /dev/null 2>&1
    
    # Wyciągamy rozmiary z fwupdmgr get-updates
    SIZE_BYTES=$(fwupdmgr get-updates --json | grep -i "Size" | awk '{print $2}' | sed 's/,//g' | awk '{s+=$1} END {print s}')
    
    if [ -z "$SIZE_BYTES" ] || [ "$SIZE_BYTES" -eq 0 ]; then
        echo -e "${GREEN}Brak dostępnych aktualizacji w systemie.${NC}"
        UPDATES_MB=0
    else
        UPDATES_MB=$(echo "scale=2; $SIZE_BYTES/1024/1024" | bc)
    fi

    # --- SEKCJA TESTOWA (odkomentuj linię poniżej, aby symulować 300MB) ---
    # UPDATES_MB=300 
    # ---------------------------------------------------------------------

    if [ "$UPDATES_MB" != "0" ]; then
        echo -e "${GREEN}Do pobrania: $UPDATES_MB MB${NC}"
    fi
}

check_efi_space() {
    if [ -z "$UPDATES_MB" ]; then
        get_updates_size
    fi

    if [ "$UPDATES_MB" == "0" ]; then
        echo -e "${GREEN}Wszystko aktualne. Nie musisz sprawdzać miejsca.${NC}"
        return
    fi

    echo -e "${YELLOW}Sprawdzanie partycji EFI...${NC}"
    
    # Pobieranie wolnego miejsca w /boot/efi (w KB)
    EFI_FREE_KB=$(df /boot/efi --output=avail | tail -n 1)
    EFI_FREE_MB=$(echo "scale=2; $EFI_FREE_KB/1024" | bc)

    echo -e "Aktualizacja do pobrania: ${YELLOW}$UPDATES_MB MB${NC}"
    echo -e "Dostępne miejsce w EFI:   ${YELLOW}$EFI_FREE_MB MB${NC}"

    # Margines bezpieczeństwa: rozmiar aktualizacji + 20MB na zapas
    SAFE_MARGIN=$(echo "$UPDATES_MB + 20" | bc)

    if (( $(echo "$EFI_FREE_MB > $SAFE_MARGIN" | bc -l) )); then
        echo -e "${GREEN}[OK] Można bezpiecznie przejść do kolejnego kroku.${NC}"
    else
        echo -e "${RED}[OSTRZEŻENIE] Mało miejsca w EFI!${NC}"
        echo -e "Sugestia: Sprawdź katalog /boot/efi/EFI/ i usuń stare logi lub nieużywane wpisy bootloadera."
        echo -e "Uważaj, aby nie usunąć folderu 'ubuntu', 'fedora' lub 'Microsoft'!"
    fi
}

do_update() {
    echo -e "${RED}!!! UWAGA !!!${NC}"
    echo "Upewnij się, że zasilacz jest podłączony."
    read -p "Czy na pewno chcesz rozpocząć? (t/N): " confirm
    if [[ $confirm == [tT] ]]; then
        fwupdmgr update
    else
        echo "Anulowano."
    fi
}

while true; do
    show_menu
    read choice
    case $choice in
        1) get_updates_size ;;
        2) check_efi_space ;;
        3) do_update ;;
        q) exit 0 ;;
        *) echo -e "${RED}Nieprawidłowa opcja.${NC}" ;;
    esac
done
