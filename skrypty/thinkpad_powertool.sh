#!/bin/bash

# Kolory
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Funkcja wysyłająca powiadomienie (dymek systemowy)
send_notification() {
    local profil=$1
    local ikona="power-profile-balanced-symbolic"
    
    case $profil in
        "Performance") ikona="power-profile-performance-symbolic" ;;
        "Power-save")  ikona="power-profile-power-saver-symbolic" ;;
    esac

    # notify-send wysyła powiadomienie do środowiska graficznego (np. Cinnamon)
    notify-send -i "$ikona" "Zasilanie ThinkPad" "Zmieniono profil na: $profil"
}

get_current_profile() {
    powerprofilesctl get
}

# Funkcja sprawdzająca stan zdrowia baterii
get_battery_health() {
    echo -e "${BLUE}--- STAN BATERII ---${NC}"
    # Pobieranie danych z /sys/class/power_supply/
    ENERGY_FULL_DESIGN=$(cat /sys/class/power_supply/BAT0/energy_full_design)
    ENERGY_FULL=$(cat /sys/class/power_supply/BAT0/energy_full)
    HEALTH=$(echo "scale=2; $ENERGY_FULL*100/$ENERGY_FULL_DESIGN" | bc)
    
    echo -e "Oryginalna pojemność: $(echo "$ENERGY_FULL_DESIGN/1000000" | bc) Wh"
    echo -e "Obecna pojemność:     $(echo "$ENERGY_FULL/1000000" | bc) Wh"
    echo -e "Kondycja baterii (Health): ${GREEN}$HEALTH%${NC}"
}

show_monitor() {
    echo -e "${YELLOW}Naciśnij Ctrl+C, aby wrócić do menu...${NC}"
    sleep 1
    watch -n 1 "echo '--- STATUS PROCESORA ---' && \
                grep 'cpu MHz' /proc/cpuinfo | head -n 8 && \
                echo '-----------------------' && \
                sensors | grep -E 'Package id 0|Core 0|fan1' || echo 'Uruchom: sudo sensors-detect'"
}

show_menu() {
    CURRENT=$(get_current_profile)
    echo -e "\n${BLUE}--- ThinkPad E16 Power Management ---${NC}"
    echo -e "Aktualny profil: ${YELLOW}$CURRENT${NC}"
    echo -e "-------------------------------------"
    echo "1. Performance (Maks. wydajność)"
    echo "2. Balanced    (Optymalny balans)"
    echo "3. Power-save  (Oszczędzanie baterii)"
    echo "4. MONITOR     (Temperatury i MHz na żywo)"
    echo "5. BATERIA     (Sprawdź kondycję baterii)"
    echo "q. Wyjście"
    echo -ne "\nWybierz opcję: "
}

set_profile() {
    case $1 in
        performance) 
            sudo powerprofilesctl set performance
            echo -e "${RED}Ustawiono: Performance${NC}"
            send_notification "Performance"
            ;;
        balanced)    
            sudo powerprofilesctl set balanced
            echo -e "${GREEN}Ustawiono: Balanced${NC}"
            send_notification "Balanced"
            ;;
        power-save)  
            sudo powerprofilesctl set power-saver
            echo -e "${BLUE}Ustawiono: Power-saver${NC}"
            send_notification "Power-saver"
            ;;
    esac
}

# Główna pętla
while true; do
    show_menu
    read choice
    case $choice in
        1) set_profile performance ;;
        2) set_profile balanced ;;
        3) set_profile power-save ;;
        4) show_monitor ;;
        5) get_battery_health ;;
        q) exit 0 ;;
        *) echo -e "${RED}Nieprawidłowa opcja.${NC}" ;;
    esac
done
