#!/bin/bash

# Wybór trybu przez proste menu
echo "Wybierz tryb pracy baterii:"
echo "1) Biuro (40% - 80%) - chroni ogniwa"
echo "2) Podróż (95% - 100%) - pełna bateria"
read -p "Wybór [1-2]: " choice

case $choice in
    1)
        echo 40 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold
        echo 80 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
        notify-send "Bateria" "Ustawiono tryb BIURO (limit 80%)" -i battery-good
        ;;
    2)
        # Najpierw podnosimy limit końcowy do 100
        echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
        # Dopiero teraz podnosimy próg startowy na 95
        echo 95 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold
        notify-send "Bateria" "Ustawiono tryb PODRÓŻ (limit 100%)" -i battery-full
        ;;
    *)
        echo "Nieprawidłowy wybór."
        ;;
esac
