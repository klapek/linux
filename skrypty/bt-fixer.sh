#!/bin/bash

# Powitanie
notify-send "System" "Monitor energii ThinkPad: AKTYWNY" -i battery-charging

# Funkcja sprawdzająca czy kontroler w ogóle istnieje
is_bt_present() {
    if bluetoothctl show | grep -q "Controller"; then
        echo "present"
    else
        echo "absent"
    fi
}

PREV_STATE=$(is_bt_present)

while true; do
    CURR_STATE=$(is_bt_present)

    # Jeśli kontroler był, a teraz go nie ma (BT OFF)
    if [ "$PREV_STATE" = "present" ] && [ "$CURR_STATE" = "absent" ]; then
        pulseaudio -k
        notify-send "System" "BT OFF -> Reset Audio (Fix 5.5W)" -i audio-speakers-symbolic
    fi

    PREV_STATE=$CURR_STATE
    sleep 3
done
