#!/bin/bash
# Plik: /skrypty/thinkpad-fingerprint-fast-eko.sh

UDEV_FILE="/etc/udev/rules.d/99-elan-fingerprint.rules"
PAM_FILE="/etc/pam.d/common-auth"

# 30s to czas, w którym czytnik jest 'gorący' i reaguje natychmiast
UDEV_RULE='SUBSYSTEM=="usb", ATTR{idVendor}=="04f3", ATTR{idProduct}=="0c8c", ATTR{power/control}="auto", ATTR{power/autosuspend}="30"'
PAM_FPRINT='auth    [success=2 default=ignore]    pam_fprintd.so max-tries=2 timeout=10'

if [ "$EUID" -ne 0 ]; then 
  echo "V Uruchom jako root."
  exit 1
fi

# Aplikowanie zmian
echo "$UDEV_RULE" > "$UDEV_FILE"
udevadm control --reload-rules && udevadm trigger

sed -i '/pam_fprintd.so/d' "$PAM_FILE"
sed -i "/pam_unix.so/i $PAM_FPRINT" "$PAM_FILE"

systemctl restart fprintd
echo "V Gotowe! Brak laga przy sudo, a bateria oszczędzana po 30s bezczynności."
