#!/bin/bash

# --- KONFIGURACJA ---
DRUKARKI=("XERO" "XERO-KOLOR")
ARCHIWUM="xero_export.tar.gz"
FOLDER_TEMP="xero_backup"
LOG_FILE="/var/log/mint_manager.log"

# Kolory dla lepszej czytelności
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

log_message() {
    local MSG="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo -e "${BLUE}$MSG${NC}"
    echo "$MSG" >> "$LOG_FILE" 2>/dev/null
}

# --- FUNKCJE ---

# 1. Instalacja oprogramowania i UFW
install_soft_and_ufw() {
    log_message "Instalacja softu i konfiguracja UFW..."
    apt update
    apt install -y samba caja-image-converter caja-share caja-actions caja-rename flatpak ufw
    
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub org.gimp.GIMP com.github.tchx84.Flatseal org.localsend.localsend_app
    
    # UFW
    ufw --force reset
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow Samba
    ufw allow 53317/tcp
    ufw allow 53317/udp
    ufw allow 5353/udp
    ufw allow 631
    ufw --force enable
    
    caja -q
    log_message "Zakończono instalację softu."
}

# 2. Zależności RC-HURT
install_rc_hurt() {
    log_message "Instalacja zależności RC-HURT..."
    mkdir -p /tmp/deb_install
    cd /tmp/deb_install
    wget -N http://mirrors.kernel.org/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb
    wget -N http://mirrors.kernel.org/ubuntu/pool/universe/n/ncurses/libncurses5_6.3-2ubuntu0.1_amd64.deb
    apt-get update
    apt-get install -y ./libtinfo5_6.3-2ubuntu0.1_amd64.deb ./libncurses5_6.3-2ubuntu0.1_amd64.deb
    apt-get install -f -y
    apt-get install -y libqt5multimedia5
    cd - > /dev/null
    rm -rf /tmp/deb_install
    log_message "RC-HURT gotowe."
}

# 3. Drukarki XERO (Import/Export)
manage_printers() {
    ALREADY_INSTALLED=false
    for name in "${DRUKARKI[@]}"; do
        if lpstat -p "$name" >/dev/null 2>&1; then ALREADY_INSTALLED=true; break; fi
    done

    if [ "$ALREADY_INSTALLED" = true ]; then
        log_message "Wykryto drukarki - TRYB EKSPORTU"
        mkdir -p "$FOLDER_TEMP/ppd"
        for name in "${DRUKARKI[@]}"; do
            if [ -f "/etc/cups/ppd/$name.ppd" ]; then
                cp "/etc/cups/ppd/$name.ppd" "$FOLDER_TEMP/ppd/"
                sed -n "/<Printer $name>/,/<\/Printer>/p" /etc/cups/printers.conf >> "$FOLDER_TEMP/printers_subset.conf"
            fi
        done
        tar -czf "$ARCHIWUM" "$FOLDER_TEMP" && rm -rf "$FOLDER_TEMP"
        log_message "Eksport zakończony: $ARCHIWUM"
    else
        log_message "Brak drukarek - TRYB IMPORTU"
        if [ -f "$ARCHIWUM" ]; then
            tar -xzf "$ARCHIWUM"
            for name in "${DRUKARKI[@]}"; do
                ppd="./$FOLDER_TEMP/ppd/$name.ppd"
                if [ -f "$ppd" ]; then
                    uri=$(grep -A 15 "<Printer $name>" "./$FOLDER_TEMP/printers_subset.conf" | grep "DeviceURI" | awk '{print $2}')
                    lpadmin -p "$name" -v "$uri" -E -P "$ppd"
                    log_message "Zainstalowano: $name"
                fi
            done
            rm -rf "$FOLDER_TEMP"
            systemctl restart cups
        else
            log_message "BŁĄD: Nie znaleziono pliku $ARCHIWUM!"
        fi
    fi
}

# 4. Gemini AI WebApp + Skrót klawiszowy
install_gemini() {
    log_message "Konfiguracja Gemini AI WebApp..."
    REAL_USER=${SUDO_USER:-$USER}
    USER_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)
    
    APP_NAME="GeminiAI"
    ID="GeminiAI5568"
    SAFE_DIR="$USER_HOME/.mozilla/firefox/$ID"
    ICE_DIR="$USER_HOME/.local/share/ice/firefox/$ID"
    URL="https://gemini.google.com"

    rm -rf "$SAFE_DIR" "$ICE_DIR"
    mkdir -p "$SAFE_DIR/chrome"
    mkdir -p "$(dirname "$ICE_DIR")"
    ln -s "$SAFE_DIR" "$ICE_DIR"
    chown -R "$REAL_USER:$REAL_USER" "$SAFE_DIR" "$(dirname "$ICE_DIR")"

    # Tworzenie userChrome.css
    cat <<EOF > "$SAFE_DIR/chrome/userChrome.css"
#nav-bar, #TabsToolbar, #PersonalToolbar { visibility: collapse !important; }
#browser-panel { border: none !important; }
EOF

    # Tworzenie prefs.js
    cat <<EOF > "$SAFE_DIR/prefs.js"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.homepage", "$URL");
user_pref("browser.tabs.drawInTitlebar", true);
EOF

    # Skrót klawiszowy F9 w MATE
    log_message "Dodawanie skrótu klawiszowego F9..."
    COMMAND="sh -c '__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia MOZ_X11_EGL=1 MOZ_DISABLE_RDD_SANDBOX=1 firefox --class WebApp-$ID --name WebApp-$ID --profile $ICE_DIR --no-remote \"$URL\"'"
    
    # MATE przechowuje skróty w dconf. Tworzymy nowy wpis custom-keybinding.
    BIND_PATH="org.mate.Marco.global-keybindings"
    CUSTOM_PATH="org.mate.Marco.custom-keybindings.custom0"
    
    sudo -u "$REAL_USER" dconf write /org/mate/marco/global-keybindings/run-command-1 "'F9'"
    sudo -u "$REAL_USER" dconf write /org/mate/marco/global-keybindings/command-1 "'$COMMAND'"

    log_message "Gotowe! Gemini pod F9 zainstalowane (Nvidia Offload włączone)."
}

# --- MENU GŁÓWNE ---
show_menu() {
    clear
    echo -e "${GREEN}==========================================${NC}"
    echo -e "${GREEN}    MINT 22.3 MATE - SYSTEM MANAGER      ${NC}"
    echo -e "${GREEN}==========================================${NC}"
    echo "1. Instalacja softu (GIMP, LocalSend, Samba, UFW)"
    echo "2. Instalacja zależności RC-HURT (libncurses5/Qt)"
    echo "3. Synchronizacja drukarek XERO (Import/Export)"
    echo "4. Instalacja Gemini AI (WebApp + F9)"
    echo "q. Wyjście"
    echo -n "Wybierz opcję: "
}

# Sprawdzenie uprawnień
if [[ $EUID -ne 0 ]]; then
   echo "BŁĄD: Uruchom skrypt przez sudo!"
   exit 1
fi

while true; do
    show_menu
    read -r opt
    case $opt in
        1) install_soft_and_ufw ;;
        2) install_rc_hurt ;;
        3) manage_printers ;;
        4) install_gemini ;;
        q) exit 0 ;;
        *) echo -e "${RED}Nieprawidłowa opcja!${NC}" ;;
    esac
    echo -e "\n${GREEN}Akcja wykonana. Naciśnij Enter, aby wrócić do menu...${NC}"
    read -r
done
