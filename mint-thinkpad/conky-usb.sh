#!/bin/bash

# Ścieżka bazowa
BASE_PATH="/media/klapek"

# Sprawdzamy czy katalog istnieje, aby uniknąć błędów
if [ -d "$BASE_PATH" ]; then
    # Przeszukujemy podfoldery w /media/klapek
    for device_path in "$BASE_PATH"/*; do
        # Sprawdzamy czy to punkt montowania i czy nie jest to cdrom
        if mountpoint -q "$device_path"; then
            device=$(basename "$device_path")
            if [[ "$device" != cdrom* ]]; then
                # Formatowanie zgodne z Twoim Conky
                # 1. Nazwa (pogrubiona, pierwsze 10 znaków)
                # 2. Zajętość (od 100px)
                # 3. Wolne % (pogrubione, rozmiar 11)
                echo "\${color}\${font Ubuntu:style=Bold:size=9}${device^}:\${font} \${goto 100}\${fs_used $device_path} / \${fs_size $device_path} \${alignr}\${font Ubuntu:style=Bold:size=11}\${fs_free_perc $device_path}% \${font}"
            fi
        fi
    done
fi

