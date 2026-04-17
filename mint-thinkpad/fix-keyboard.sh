#!/bin/bash
# Wymuszenie ponownego skanowania portu klawiatury - wersja 1 łagodna - działa na start bez enter w grub
#echo -n "rescan" > /sys/bus/serio/devices/serio0/drvctl

# Wymuszenie twardego resetu sterownika klawiatury
# 1. Odpięcie sterownika atkbd od urządzenia serio0
#echo -n "serio0" > /sys/bus/serio/drivers/atkbd/unbind
#sleep 0.2
# 2. Ponowne przypięcie (to wymusza pełną inicjalizację rejestrów)
#echo -n "serio0" > /sys/bus/serio/drivers/atkbd/bind

# Dajemy systemowi czas na wstępną próbę jądra
sleep 5
if ! grep -q "atkbd" /proc/bus/input/devices; then
    echo "$(date): Klawiatura nie wykryta. Reanimacja..." >> /var/log/kbd-fix.log
    echo -n "serio0" > /sys/bus/serio/drivers/atkbd/unbind
    sleep 0.5
    echo -n "serio0" > /sys/bus/serio/drivers/atkbd/bind
else
    echo "$(date): Klawiatura OK. Nie robie nic." >> /var/log/kbd-fix.log
fi
