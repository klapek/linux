#!/bin/bash

# Sprawdź, czy skrypt jest uruchomiony jako root
if [ "$EUID" -ne 0 ]; then
  # Jeśli nie, uruchom go ponownie przez pkexec
  pkexec "$0" "$@"
  exit $?
fi

# --- KONFIGURACJA ---
DRUKARKI=("XERO" "XERO-KOLOR")
ARCHIWUM="xero_export.tar.gz"
FOLDER_TEMP="xero_backup"
LOG_FILE="/var/log/mint_manager.log"

# Kolory interfejsu
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

log_msg() {
    echo -e "${BLUE}$(date '+%H:%M:%S') - $1${NC}"
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE" 2>/dev/null
}

# --- 1. SOFT & FIREWALL ---
opt_install_soft() {
    log_msg "Instalacja softu i UFW..."
    apt update
    apt install -y samba caja-image-converter caja-share caja-actions caja-rename flatpak ufw
    
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub org.gimp.GIMP com.github.tchx84.Flatseal org.localsend.localsend_app
    
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
    log_msg "Instalacja zakończona."
}

# --- 2. ZALEŻNOŚCI RC-HURT ---
opt_rc_hurt() {
    log_msg "Instalacja bibliotek RC-HURT..."
    mkdir -p /tmp/deb_hurt
    cd /tmp/deb_hurt
    wget -N http://mirrors.kernel.org/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb
    wget -N http://mirrors.kernel.org/ubuntu/pool/universe/n/ncurses/libncurses5_6.3-2ubuntu0.1_amd64.deb
    apt-get update
    apt-get install -y ./libtinfo5_6.3-2ubuntu0.1_amd64.deb ./libncurses5_6.3-2ubuntu0.1_amd64.deb
    apt-get install -f -y
    apt-get install -y libqt5multimedia5
    cd - > /dev/null
    rm -rf /tmp/deb_hurt
    log_msg "RC-HURT gotowe."
}

# --- 3. DRUKARKI XERO ---
opt_xero() {
    EXISTS=false
    for p in "${DRUKARKI[@]}"; do lpstat -p "$p" >/dev/null 2>&1 && EXISTS=true; done

    if [ "$EXISTS" = true ]; then
        log_msg "Eksportowanie drukarek..."
        mkdir -p "$FOLDER_TEMP/ppd"
        for p in "${DRUKARKI[@]}"; do
            if [ -f "/etc/cups/ppd/$p.ppd" ]; then
                cp "/etc/cups/ppd/$p.ppd" "$FOLDER_TEMP/ppd/"
                sed -n "/<Printer $p>/,/<\/Printer>/p" /etc/cups/printers.conf >> "$FOLDER_TEMP/printers_subset.conf"
            fi
        done
        tar -czf "$ARCHIWUM" "$FOLDER_TEMP" && rm -rf "$FOLDER_TEMP"
        log_msg "Eksport gotowy: $ARCHIWUM"
    else
        log_msg "Importowanie drukarek..."
        if [ -f "$ARCHIWUM" ]; then
            tar -xzf "$ARCHIWUM"
            for p in "${DRUKARKI[@]}"; do
                ppd="./$FOLDER_TEMP/ppd/$p.ppd"
                [ -f "$ppd" ] && uri=$(grep -A 15 "<Printer $p>" "./$FOLDER_TEMP/printers_subset.conf" | grep "DeviceURI" | awk '{print $2}')
                [ -n "$uri" ] && lpadmin -p "$p" -v "$uri" -E -P "$ppd"
            done
            rm -rf "$FOLDER_TEMP"
            systemctl restart cups
            log_msg "Import zakończony."
        else
            log_msg "BŁĄD: Brak pliku $ARCHIWUM"
        fi
    fi
}

# --- 4. GEMINI AI ---
opt_gemini() {
    log_msg "Konfiguracja Gemini WebApp..."
    R_USER=${SUDO_USER:-$USER}
    U_HOME=$(getent passwd "$R_USER" | cut -d: -f6)
    ID="GeminiAI5568"
    S_DIR="$U_HOME/.mozilla/firefox/$ID"
    I_DIR="$U_HOME/.local/share/ice/firefox/$ID"
    
    mkdir -p "$S_DIR/chrome" "$(dirname "$I_DIR")"
    [ ! -L "$I_DIR" ] && ln -s "$S_DIR" "$I_DIR"

    echo "user_pref(\"toolkit.legacyUserProfileCustomizations.stylesheets\", true);" > "$S_DIR/prefs.js"
    echo "user_pref(\"browser.startup.homepage\", \"https://gemini.google.com\");" >> "$S_DIR/prefs.js"
    echo "#nav-bar, #TabsToolbar { visibility: collapse !important; }" > "$S_DIR/chrome/userChrome.css"
    
    chown -R "$R_USER:$R_USER" "$S_DIR"

    # Skrót F9
    CMD="sh -c '__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia MOZ_X11_EGL=1 MOZ_DISABLE_RDD_SANDBOX=1 firefox --class WebApp-$ID --name WebApp-$ID --profile $I_DIR --no-remote \"https://gemini.google.com\"'"
    sudo -u "$R_USER" dconf write /org/mate/marco/global-keybindings/run-command-1 "'F9'"
    sudo -u "$R_USER" dconf write /org/mate/marco/global-keybindings/command-1 "'$CMD'"
    log_msg "Gemini pod F9 gotowe."
}

# --- MENU ---
while true; do
    clear
    echo -e "${GREEN}=== MINT MANAGER (Dell 7760) ===${NC}"
    echo "1. Soft (GIMP, LocalSend, Samba, UFW)"
    echo "2. Zależności RC-HURT"
    echo "3. Drukarki XERO (Import/Export)"
    echo "4. Gemini AI (WebApp + F9)"
    echo "q. Wyjście"
    echo -e "${GREEN}================================${NC}"
    read -p "Wybór: " o
    case $o in
        1) opt_install_soft ;;
        2) opt_rc_hurt ;;
        3) opt_xero ;;
        4) opt_gemini ;;
        q) exit 0 ;;
        *) echo "Błąd!" ;;
    esac
    read -p "Enter = Menu..."
done
