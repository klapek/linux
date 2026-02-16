# [Guide] ThinkPad E16 Gen 2 (2024) BIOS & SSD Firmware Update on Linux
**Target:** Lenovo ThinkPad E16 Gen 2 (Meteor Lake)
**OS:** Linux (Tested on Linux Mint 22)
**Tools:** fwupdmgr (LVFS)

---

## PL: Aktualizacja BIOS i Firmware SSD pod Linuxem

### ## 1. Dlaczego warto? 
W ThinkPadach E16 Gen 2, dyski Samsung (MZAL8512HDLU) na starym firmware potrafią powodować przycięcia systemu (SMBus hangs). Aktualizacja do wersji **9L2QKXD7** oraz BIOSu (**0.1.21+**) eliminuje te błędy i poprawia zarządzanie rdzeniami Intel Core Ultra.

### ## 2. Proces Aktualizacji (CLI)
Podłącz zasilacz! Otwórz terminal i wpisz:
```bash
# Odśwież metadane z LVFS
fwupdmgr refresh

# Sprawdź dostępne aktualizacje
fwupdmgr get-updates

# Wykonaj aktualizację
fwupdmgr update
```


## 3. Czego się spodziewać podczas restartu?
Pasek postępu: Standardowe 0-100%.

Czarny ekran: Laptop może wyglądać na martwy przez 30-60 sekund.

BIOS Self-healing backup: Zobaczysz komunikat "Processing backup...". To funkcja bezpieczeństwa Lenovo – tworzy kopię ratunkową nowego BIOSu.

Długie logo Lenovo: Cierpliwości, trwa tzw. RAM training. Nie dotykaj przycisku Power!

## 4. Pro-Tip: Skrypt sprawdzający miejsce na partycji EFI
Firmware bywa duży, a partycje EFI małe. Możesz użyć [mojego skryptu](../skrypty/thinkpad-firmware-tool.sh), który wszystko sprawdzi lub szybki check przed startem:
```bash
# Sprawdź sumaryczny rozmiar aktualizacji (JSON)
SIZE_BYTES=$(fwupdmgr get-updates --json | grep -i "Size" | awk '{print $2}' | sed 's/,//g' | awk '{s+=$1} END {print s}')

# Sprawdź wolne miejsce na /boot/efi
EFI_FREE=$(df /boot/efi --output=avail | tail -n1)
echo "Update size: $SIZE_BYTES | EFI Free: $EFI_FREE"
```
## 5. WAŻNY FIX po aktualizacji (Boot Speed)
Aktualizacja BIOS często resetuje ustawienia. Jeśli system wstaje 30s zamiast 10s:

Wejdź do BIOS (F1).

Security -> Memory Protection -> Execution Prevention ustaw na Disabled.

To wyłącza rygorystyczny test RAM, który blokuje szybki start.


### EN: BIOS & SSD Firmware Update on Linux
## 1. Why update?
Samsung SSDs (MZAL8512HDLU) in the E16 Gen 2 are known for occasional SMBus hangs (stutters) on older firmware. Updating to 9L2QKXD7 and BIOS 0.1.21+ resolves these issues and improves Intel Core Ultra core scheduling.

## 2. The Process (CLI)
Ensure your AC adapter is plugged in! Run:
```bash
# Refresh metadata from LVFS
fwupdmgr refresh

# Check for available updates
fwupdmgr get-updates

# Execute the update
fwupdmgr update
```
## 3. What to expect during reboot
Flash Progress: Standard 0-100% bar.

Black Screen: System may appear unresponsive for 30-60 seconds.

BIOS Self-healing backup: You'll see "Processing backup...". This is a Lenovo safety feature creating a recovery copy of the new BIOS.

Long Logo Boot: The Lenovo logo stays while RAM training occurs. Do NOT press the power button!

## 4. Pro-Tip: EFI Partition Space Check
Firmware files are getting larger. Use this snippet to check space before proceeding, or use my [automation script](../skrypty/thinkpad-firmware-tool.sh) which handles all checks for you.
```bash
# Check total update size via JSON
SIZE_BYTES=$(fwupdmgr get-updates --json | grep -i "Size" | awk '{print $2}' | sed 's/,//g' | awk '{s+=$1} END {print s}')

# Check available space in /boot/efi
EFI_FREE=$(df /boot/efi --output=avail | tail -n1)
echo "Update size: $SIZE_BYTES | EFI Free: $EFI_FREE"
```
## 5. IMPORTANT POST-UPDATE FIX (Boot Speed)
BIOS updates often revert settings to defaults. If boot time increases to 30s+:

Enter BIOS (F1).

Security -> Memory Protection -> Set Execution Prevention to Disabled.

This disables the redundant RAM test that slows down the boot process.
