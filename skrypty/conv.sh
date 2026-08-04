#!/bin/bash

# Wymuszamy standardowy format liczb (kropka jako separator dla printf)
export LC_NUMERIC=C

if [ $# -ne 2 ]; then
  echo -e "💡 Użycie: conv <wartość> <jednostka>"
  echo -e "Imperialne -> Metryczne: in, ft, yd, mi, oz, lb, gal, F"
  echo -e "Metryczne  -> Imperialne: cm, m, km, g, kg, l, C"
  exit 1
fi

VAL=$1
UNIT=$2

# Zamieniamy przecinek na kropkę, jeśli wpiszesz np. "15,5"
VAL=${VAL//,/.}

case $UNIT in
  # --- IMPERIALNE NA METRYCZNE ---
  in|inch)   RES=$(awk "BEGIN {print $VAL * 2.54}"); SYM="cm" ;;
  ft|foot)   RES=$(awk "BEGIN {print $VAL * 0.3048}"); SYM="m" ;;
  yd|yard)   RES=$(awk "BEGIN {print $VAL * 0.9144}"); SYM="m" ;;
  mi|mile)   RES=$(awk "BEGIN {print $VAL * 1.60934}"); SYM="km" ;;
  oz|ounce)  RES=$(awk "BEGIN {print $VAL * 28.3495}"); SYM="g" ;;
  lb|pound)  RES=$(awk "BEGIN {print $VAL * 0.453592}"); SYM="kg" ;;
  gal|gallon)RES=$(awk "BEGIN {print $VAL * 3.78541}"); SYM="l" ;;
  F|f)       RES=$(awk "BEGIN {print ($VAL - 32) * 5 / 9}"); SYM="°C" ;;

  # --- METRYCZNE NA IMPERIALNE ---
  cm)        RES=$(awk "BEGIN {print $VAL / 2.54}"); SYM="in" ;;
  m)         RES=$(awk "BEGIN {print $VAL / 0.3048}"); SYM="ft" ;;
  km)        RES=$(awk "BEGIN {print $VAL / 1.60934}"); SYM="mi" ;;
  g)         RES=$(awk "BEGIN {print $VAL / 28.3495}"); SYM="oz" ;;
  kg)        RES=$(awk "BEGIN {print $VAL / 0.453592}"); SYM="lb" ;;
  l|liter)   RES=$(awk "BEGIN {print $VAL / 3.78541}"); SYM="gal" ;;
  C|c)       RES=$(awk "BEGIN {print ($VAL * 9 / 5) + 32}"); SYM="°F" ;;

  *) echo "❌ Nieznana jednostka: $UNIT"; exit 1 ;;
esac

printf "✅ %.2f %s = %.2f %s\n" "$VAL" "$UNIT" "$RES" "$SYM"
