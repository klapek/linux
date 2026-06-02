#!/bin/bash

# Folder na tymczasowe i wynikowe dane miedzy migracjami
BACKUP_DIR="$HOME/cups_migration_backup"
ARCHIVE_NAME="$HOME/printer_migration.tar.gz"

# Kolorki dla lepszej czytelnosci w terminalu
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

export_printers() {
    echo -e "${BLUE}===> Rozpoczynam eksport wszystkich drukarek i plików PPD...${NC}"
    
    # Czyszczenie starego katalogu, jesli istnieje
    rm -rf "$BACKUP_DIR"
    mkdir -p "$BACKUP_DIR/ppd"
    
    # Inicjalizacja skryptu instalacyjnego
    INSTALL_SCRIPT="$BACKUP_DIR/import_commands.sh"
    echo "#!/bin/bash" > "$INSTALL_SCRIPT"
    echo "echo 'Rozpoczynam przywracanie kolejek CUPS...'" >> "$INSTALL_SCRIPT"
    
    # Pobranie listy drukarek przez lpstat -e
    lpstat -e | while read -r printer_name; do
        if [ -z "$printer_name" ]; then continue; fi
        
        echo -e "${GREEN}[+] Eksportuję: $printer_name${NC}"
        
        # 1. Pobranie URI (adresu sieciowego/USB) drukarki
        # Wycinamy błędy i filtrujemy wynik, aby dostac czysty URI
        URI=$(lpstat -v "$printer_name" | awk -F': ' '{print $2}' | awk '{print $1}')
        
        # 2. Skopiowanie dedykowanego pliku PPD (wymaga sudo, bo /etc/cups/ppd ma restrykcyjne prawa)
        if [ -f "/etc/cups/ppd/${printer_name}.ppd" ]; then
            sudo cp "/etc/cups/ppd/${printer_name}.ppd" "$BACKUP_DIR/ppd/"
            # Zmiana uprawnien kopii, zeby mozna bylo ja spakowac bez roota
            sudo chmod 644 "$BACKUP_DIR/ppd/${printer_name}.ppd"
        else
            echo -e "${RED}[!] Ostrzeżenie: Brak pliku PPD dla $printer_name w /etc/cups/ppd/${NC}"
        fi
        
        # 3. Zapisanie konfiguracji lpadmin do skryptu odtwarzajacego
        # Dodajemy sciezke do lokalnego PPD, ktory zaraz spakujemy
        echo "echo '-> Przywracam: $printer_name'" >> "$INSTALL_SCRIPT"
        echo "sudo lpadmin -p \"$printer_name\" -v \"$URI\" -P \"./ppd/${printer_name}.ppd\" -E" >> "$INSTALL_SCRIPT"
        
        # 4. Eksport opcji domyslnych (duplex, kasety, jakosc) do osobnego pliku tekstowego
        lpoptions -p "$printer_name" -l > "$BACKUP_DIR/${printer_name}_options.txt"
        
        # 5. Dopisywanie ustawiania opcji linia po linii do skryptu importu
        while read -r option_line; do
            # Wyciagamy tylko aktualnie ustawiona opcje (oznaczona gwiazdka *)
            current_opt=$(echo "$option_line" | awk -F: '{print $1}')
            current_val=$(echo "$option_line" | awk -F: '{print $2}' | grep -o '\*[a-zA-Z0-9_-]\+' | tr -d '*')
            
            if [ ! -z "$current_val" ]; then
                echo "lpoptions -p \"$printer_name\" -o \"$current_opt=$current_val\" >/dev/null" >> "$INSTALL_SCRIPT"
            fi
        done < "$BACKUP_DIR/${printer_name}_options.txt"
        
    done
    
    # Pakowanie wszystkiego do jednego gzippa
    echo -e "${BLUE}===> Pakowanie archiwum...${NC}"
    cd "$BACKUP_DIR" || exit
    tar -czf "$ARCHIVE_NAME" ./*
    
    # Czyszczenie smieci
    rm -rf "$BACKUP_DIR"
    
    echo -e "${GREEN}===> GOTOWE! Gotowa paczka do przeniesienia to: $ARCHIVE_NAME${NC}"
}

import_printers() {
    echo -e "${BLUE}===> Rozpoczynam import drukarek na nowym systemie...${NC}"
    
    if [ ! -f "$ARCHIVE_NAME" ]; then
        echo -e "${RED}[!] Błąd: Nie znaleziono pliku $ARCHIVE_NAME w katalogu domowym!${NC}"
        exit 1
    fi
    
    # Przygotowanie i rozpakowanie w bezpiecznym miejscu
    mkdir -p "$BACKUP_DIR"
    tar -xzf "$ARCHIVE_NAME" -C "$BACKUP_DIR"
    
    cd "$BACKUP_DIR" || exit
    
    if [ ! -f "import_commands.sh" ]; then
        echo -e "${RED}[!] Błąd: Archiwum jest uszkodzone lub nie zawiera skryptu instalacyjnego!${NC}"
        rm -rf "$BACKUP_DIR"
        exit 1
    fi
    
    # Uruchomienie wygenerowanych wczesniej polecen CUPS
    chmod +x import_commands.sh
    ./import_commands.sh
    
    # Restart demona CUPS na Salixie (Slackware uzywa rc.cups)
    echo -e "${BLUE}===> Restartuję serwer CUPS...${NC}"
    if [ -x /etc/rc.d/rc.cups ]; then
        sudo /etc/rc.d/rc.cups restart
    else
        # Fallback na systemd, gdyby to byl nowszy Salix lub powrot na Minta
        sudo systemctl restart cups 2>/dev/null || sudo systemctl restart cups.service 2>/dev/null
    fi
    
    # Sprzątanie po imporcie
    rm -rf "$BACKUP_DIR"
    echo -e "${GREEN}===> IMPORT ZAKOŃCZONY SUKCESEM! Drukarki powinny być widoczne w systemie.${NC}"
}

# Proste menu wyboru
echo -e "${BLUE}CUPS Migration Tool (Mint <-> Salix)${NC}"
echo "1) Eksportuj drukarki"
echo "2) Importuj drukarki"
read -p "Wybierz opcję [1 lub 2]: " -r opt

case $opt in
    1) export_printers ;;
    2) import_printers ;;
    *) echo -e "${RED}Nieprawidłowy wybór.${NC}" ;;
esac
