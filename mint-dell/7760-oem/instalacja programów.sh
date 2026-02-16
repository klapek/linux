#!/bin/bash

# --- KONFIGURACJA ---
LOG_FILE="/var/log/mint_install.log"

# Pakiety systemowe APT
PACKAGES=(
    samba
    caja-image-converter
    caja-share
    caja-actions
    caja-rename
)

# Aplikacje Flatpak
FLATPAKS=(
    org.gimp.GIMP
    com.github.tchx84.Flatseal
)

log_message() {
    local MSG="$(date '+%Y-%m-%d %H:%M:%S') - $1"
    echo "$MSG" | tee -a "$LOG_FILE"
}

# Sprawdzenie uprawnień
if [ "$EUID" -ne 0 ]; then 
  echo "Uruchom skrypt przez sudo!"
  exit 1
fi

# --- 1. INSTALACJA OPROGRAMOWANIA ---
log_message "Aktualizacja list pakietów..."
apt update

log_message "Instalacja pakietów systemowych i Caja extensions..."
apt install -y "${PACKAGES[@]}"

log_message "Konfiguracja Flatpak i instalacja aplikacji..."
apt install -y flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

for app in "${FLATPAKS[@]}"; do
    log_message "Instalacja $app..."
    flatpak install -y flathub "$app"
done

# Restart Caji, aby wtyczki zaczęły działać
caja -q

# --- 2. KONFIGURACJA ZAPORY UFW ---
log_message "Konfiguracja zapory sieciowej UFW..."

# Reset do bezpiecznych ustawień domyślnych
ufw --force reset
ufw default deny incoming
ufw default allow outgoing

# Samba (udostępnianie plików)
log_message "Otwieranie portów dla Samby..."
ufw allow Samba

# LocalSend (port 53317 TCP/UDP)
log_message "Otwieranie portów dla LocalSend..."
ufw allow 53317/tcp
ufw allow 53317/udp

# Wsparcie dla sieci (mDNS i CUPS)
log_message "Otwieranie portów dla mDNS i CUPS..."
ufw allow 5353/udp
ufw allow 631

# Aktywacja zapory
ufw --force enable

# --- PODSUMOWANIE ---
log_message "Instalacja i konfiguracja zapory zakończona."
echo "--------------------------------------"
ufw status verbose
echo "--------------------------------------"
echo "Logi znajdziesz w: $LOG_FILE"
