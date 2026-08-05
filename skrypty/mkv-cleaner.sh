#!/bin/bash

# Uruchomienie w nowym oknie mate-terminal z Caji
if [ ! -t 0 ]; then
    tmp_file=$(mktemp /tmp/mkv_files.XXXXXX)
    printf "%s\n" "$@" > "$tmp_file"

    mate-terminal -- bash -c '
        script_path="$1"
        list_file="$2"
        "$script_path" --from-file "$list_file"
        rm -f "$list_file"
        echo ""
        read -p "Naciśnij Enter, aby zamknąć..." < /dev/tty
    ' _ "$0" "$tmp_file"
    exit 0
fi

# Wymuszenie odczytu z TTY dla menu
exec < /dev/tty

# Kolory dla lepszej czytelności
G='\033[0;32m'
B='\033[0;34m'
R='\033[0;31m'
NC='\033[0m'

clear
echo -e "${B}=================================================="${NC}
echo -e "${B}          MKV STREAM CLEANER (TERMINAL)           "${NC}
echo -e "${B}=================================================="${NC}
echo ""

PS3="Wybierz opcję (1-3): "
options=("Czyszczenie NAPISOW (Subtitles)" "Czyszczenie AUDIO" "Wyjscie")

select opt in "${options[@]}"
do
    case $REPLY in
        1) MODE_TYPE="SUB"; break ;;
        2) MODE_TYPE="AUDIO"; break ;;
        3) echo "Anulowano."; exit 0 ;;
        *) echo "Nieprawidłowy wybór. Wpisz 1, 2 lub 3." ;;
    esac
done

clear

if [ "$MODE_TYPE" == "SUB" ]; then
    echo -e "${B}--- OPCJE NAPISOW ---"${NC}
    PS3="Wybierz opcję (1-3): "
    sub_options=(
        "Usun WSZYSTKIE napisy"
        "Zostaw TYLKO POLSKIE napisy (najwieksza sciezka)"
        "Zostaw TYLKO ANGIELSKIE napisy (najwieksza sciezka)"
    )
    select sub_opt in "${sub_options[@]}"
    do
        case $REPLY in
            1) MODE="SUB_a"; break ;;
            2) MODE="SUB_b"; break ;;
            3) MODE="SUB_c"; break ;;
            *) echo "Wybierz 1, 2 lub 3." ;;
        esac
    done

elif [ "$MODE_TYPE" == "AUDIO" ]; then
    echo -e "${B}--- OPCJE AUDIO ---"${NC}
    PS3="Wybierz opcję (1-3): "
    audio_options=(
        "Zostaw ORYGINALNE audio (pierwsza sciezka w pliku)"
        "Zostaw TYLKO POLSKIE audio"
        "Zostaw TYLKO ANGIELSKIE audio"
    )
    select audio_opt in "${audio_options[@]}"
    do
        case $REPLY in
            1) MODE="AUDIO_a"; break ;;
            2) MODE="AUDIO_b"; break ;;
            3) MODE="AUDIO_c"; break ;;
            *) echo "Wybierz 1, 2 lub 3." ;;
        esac
    done
fi

echo ""
echo -e "${G}Rozpoczynam przetwarzanie dla trybu: $MODE...${NC}"
echo "--------------------------------------------------"

# Wczytanie listy plików z pliku tymczasowego
file_list=()
if [ "$1" == "--from-file" ] && [ -f "$2" ]; then
    mapfile -t file_list < "$2"
else
    file_list=("$@")
fi

count=0

for raw_filename in "${file_list[@]}"
do
    # Dekodowanie URI z Pythona (obsługuje %20, polskie znaki i prefix file://)
    filename=$(python3 -c "import sys, urllib.parse; print(urllib.parse.unquote(sys.argv[1]))" "$raw_filename" | sed 's/^file:\/\///')

    if [[ -z "$filename" ]]; then
        continue
    fi

    if [[ -f "$filename" ]] && [[ "${filename##*.}" =~ ^[mM][kK][vV]$ ]]; then
        
        # Określenie sufiksu w zależności od wybranego trybu (-n dla napisów, -a dla audio)
        if [[ "$MODE" == SUB_* ]]; then
            SUFFIX="-n"
        else
            SUFFIX="-a"
        fi

        output_file="${filename%.*}${SUFFIX}.mkv"

        json_data=$(mkvmerge -J "$filename" 2>/dev/null)
        mkv_args=""

        case "$MODE" in
            # --- NAPISY ---
            "SUB_a")
                mkv_args="-S"
                ;;
            
            "SUB_b"|"SUB_c")
                LANG_CODE=$([ "$MODE" == "SUB_b" ] && echo "pol" || echo "eng")
                
                best_sub_id=$(echo "$json_data" | jq -r --arg lang "$LANG_CODE" '
                    [.tracks[] | select(.type=="subtitles" and .properties.language==$lang)] 
                    | sort_by(.properties.number_of_bytes // 0) 
                    | reverse 
                    | .[0].id' 2>/dev/null)

                if [[ -n "$best_sub_id" && "$best_sub_id" != "null" ]]; then
                    mkv_args="-s $best_sub_id --forced-track $best_sub_id:0 --default-track $best_sub_id:1"
                else
                    mkv_args="-S"
                fi
                ;;

            # --- AUDIO ---
            "AUDIO_a")
                orig_audio_id=$(echo "$json_data" | jq -r '.tracks[] | select(.type=="audio") | .id' 2>/dev/null | head -n 1)
                
                if [[ -n "$orig_audio_id" && "$orig_audio_id" != "null" ]]; then
                    mkv_args="-a $orig_audio_id --default-track $orig_audio_id:1"
                else
                    mkv_args="-a 0"
                fi
                ;;

            "AUDIO_b"|"AUDIO_c")
                LANG_CODE=$([ "$MODE" == "AUDIO_b" ] && echo "pol" || echo "eng")
                
                audio_ids=$(echo "$json_data" | jq -r --arg lang "$LANG_CODE" '
                    [.tracks[] | select(.type=="audio" and .properties.language==$lang) | .id] | join(",")' 2>/dev/null)

                if [[ -n "$audio_ids" && "$audio_ids" != "null" && "$audio_ids" != "" ]]; then
                    first_audio=$(echo "$audio_ids" | cut -d',' -f1)
                    mkv_args="-a $audio_ids --default-track $first_audio:1"
                else
                    orig_audio_id=$(echo "$json_data" | jq -r '.tracks[] | select(.type=="audio") | .id' 2>/dev/null | head -n 1)
                    mkv_args="-a ${orig_audio_id:-0}"
                fi
                ;;
        esac

        if [[ -n "$mkv_args" ]]; then
            ((count++))
            echo -e "Przetwarzam: ${B}$(basename "$filename")${NC}"
            
            mkvmerge $mkv_args -o "$output_file" "$filename" > /dev/null 2>&1
            
            if [ $? -eq 0 ]; then
                echo -e "V Zapisano:  ${G}$(basename "$output_file")${NC}"
            else
                echo -e "${R}X Błąd mkvmerge dla pliku: $(basename "$filename")${NC}"
            fi
            echo "--------------------------------------------------"
        fi
    else
        echo -e "${R}Pominięto (nie znaleziono pliku lub nie jest to MKV):${NC} $(basename "$filename")"
        echo "--------------------------------------------------"
    fi
done

echo ""
if [ $count -gt 0 ]; then
    echo -e "${G}V Gotowe! Przetworzono plików: $count${NC}"
    notify-send "MKV Cleaner" "Zakończono! Przetworzono plików: $count" -i dialog-ok
else
    echo -e "${R}X Błąd: Nie przetworzono żadnego pliku .mkv! (Wybrany tryb: '$MODE')${NC}"
    notify-send "Błąd" "Nie przetworzono żadnego pliku." -i dialog-error
fi
