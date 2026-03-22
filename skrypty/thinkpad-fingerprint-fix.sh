#!/bin/bash
# ThinkPad E16 Gen 2 - Fingerprint Ultimate Fix (MATE Edition)
# Funkcja: Fixuje błąd startowy, lagi w sudo oraz autoodświeżanie po klapie.

if [ "$EUID" -ne 0 ]; then 
  echo "V Uruchom skrypt przez sudo!"
  exit 1
fi

echo "--- START OPTYMALIZACJI CZYTNIKA ELAN ---"

# 1. Sprawdzenie i instalacja xdotool (potrzebny do oszukania Matrixa)
if ! command -v xdotool &> /dev/null; then
    echo "V Instaluję xdotool (wymagany do odświeżania ekranu blokady)..."
    apt update && apt install xdotool -y
else
    echo "V xdotool jest już zainstalowany."
fi

# 2. Konfiguracja UDEV (Eliminacja laga 2s w sudo / GUI)
echo "V Ustawiam regułę Udev (autosuspend=3600)..."
cat <<EOF > /etc/udev.d/rules.d/99-elan-fingerprint.rules
SUBSYSTEM=="usb", ATTR{idVendor}=="04f3", ATTR{idProduct}=="0c8c", ATTR{power/control}="auto", ATTR{power/autosuspend}="3600", ATTR{power/persist}="1"
EOF
udevadm control --reload-rules && udevadm trigger

# 3. Konfiguracja PAM (Fix błędu 'Głosowania' / Ghost Error)
echo "V Konfiguruję PAM (max-tries=2)..."
sed -i '/pam_fprintd.so/d' /etc/pam.d/common-auth
sed -i "/pam_unix.so/i auth [success=2 default=ignore] pam_fprintd.so max-tries=2 timeout=10" /etc/pam.d/common-auth

# 4. Tworzenie reguły Fingerprint Resume (Naprawa klapy w MATE)
echo "V Tworzę skrypt wybudzania (Lid-Open Fix)..."
cat <<EOF > /lib/systemd/system-sleep/fingerprint-resume
#!/bin/sh
case \$1/\$2 in
  post/*)
    # Czekamy na stabilizację USB
    sleep 0.4
    # Restart usługi
    systemctl restart fprintd
    # 'Oszukanie Matrixa' - automatyczny Enter w sesji użytkownika
    sudo -u klapek DISPLAY=:0 xdotool key Return
    ;;
esac
EOF
chmod +x /lib/systemd/system-sleep/fingerprint-resume

# 5. Restart usług i weryfikacja
systemctl restart fprintd
echo "--- KONFIGURACJA ZAKOŃCZONA ---"
echo "V Czytnik ELAN 04f3:0c8c powinien teraz działać:"
echo "  1. Natychmiast w terminalu (sudo)."
echo "  2. Automatycznie po otwarciu klapy (z lekkim mignięciem)."
echo "V Sprawdź działanie zamykając laptopa na chwilę!"
