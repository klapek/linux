#!/bin/bash
export PATH="$HOME/.local/bin:$PATH"

PELNA_SCIEZKA="$1"
KATALOG=$(dirname "$PELNA_SCIEZKA")
NAZWA_Z_ROZSZERZENIEM=$(basename "$PELNA_SCIEZKA")
NAZWA_BEZ_ROZSZERZENIA="${NAZWA_Z_ROZSZERZENIEM%.*}"
WYJSCIE_PNG="$KATALOG/${NAZWA_BEZ_ROZSZERZENIA}-bez_tla.png"

# Wycinanie tła z pulsującym paskiem Zenity
(
    /home/grafika/.local/bin/rembg i -m isnet-general-use -a "$PELNA_SCIEZKA" "$WYJSCIE_PNG"
) | zenity --progress \
  --title="Usuwanie tła" \
  --text="Trwa przetwarzanie pliku:\n$NAZWA_Z_ROZSZERZENIEM" \
  --pulsate \
  --auto-close \
  --no-cancel

# DODATKOWA KOMPRESJA: Jeśli plik powstał, odchudź go drastycznie
if [ -f "$WYJSCIE_PNG" ]; then
    # --ext .png --force oznacza, że skompresowany plik zastąpi ten ciężki wyjściowy
    pngquant --quality=65-80 --ext .png --force "$WYJSCIE_PNG"
fi