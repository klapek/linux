# [FIX] ThinkPad E16 Gen 2 (Meteor Lake) - Fingerprint & PAM Stability
**Date:** 2026-03-22
**Device:** ELAN Fingerprint Reader (04f3:0c8c)
**Status:** SOLVED (Udev 30s + PAM Hardening)

---

## PL: Stabilizacja czytnika linii papilarnych

### ## 1. Problem: Ghost Error / Ghost Login
Na nowych ThinkPadach (Core Ultra) sytuacja przy pierwszym zapytaniu (np. `sudo`) czytnik wysyła błędny sygnał. Skutkuje to albo natychmiastowym błędem, albo (rzadziej) niebezpiecznym autologowaniem bez dotknięcia skanera. Na architekturze Meteor Lake, czytnik przy zimnym starcie zawsze zgłasza błąd inicjalizacji (Ghost Error). Zamiast walczyć z tym prądowo, pozwalamy systemowi na uśpienie urządzenia, a błąd "połykamy" w konfiguracji PAM.

### ## 2. Rozwiązanie (Udev)
Przywracamy standardowe zarządzanie energią, ale z lekkim opóźnieniem, by nie "męczyć" portu USB przy każdym sudo i dajemy 30 sek zanim przejdzie w stan uśpienia, by kolejne szybkie sudo nie czekało 2 sek na wybudzenie czytnika.
Plik: `/etc/udev/rules.d/99-elan-fingerprint.rules`
```text
SUBSYSTEM=="usb", ATTR{idVendor}=="04f3", ATTR{idProduct}=="0c8c", ATTR{power/control}="auto", ATTR{power/autosuspend}="30"
```
## 3. Konfiguracja PAM (The Double-Check)

Zwiększamy liczbę prób do 2, aby PAM automatycznie "skonsumował" pierwszy błąd sprzętowy i od razu dał użytkownikowi drugą, czystą szansę na autoryzację.
Plik: `/etc/pam.d/common-auth`
```Plaintext

auth [success=2 default=ignore] pam_fprintd.so max-tries=2 timeout=10
auth [success=1 default=ignore] pam_unix.so nullok try_first_pass
```
## 4. Automatyzacja

Pełny skrypt wdrażający te poprawki znajduje się tutaj:   
👉 [Pobierz / Download](../skrypty/thinkpad-fingerprint-fix.sh)

---

## EN: Fingerprint Reader Stability Fix
## 1. The Issue: Ghost Error / Ghost Login

On Meteor Lake ThinkPads, aggressive USB power management causes the ELAN reader to send a "glitch" signal during the first poll. This leads to an instant "Match Failed" error or a dangerous "Ghost Login" (bypass).

## 2. Hardware Fix (Udev)

Instead of forcing power "Always ON", we allow the system to suspend the device and handle the glitch via PAM retry logic.
File: `/etc/udev/rules.d/99-elan-fingerprint.rules`
```Plaintext

SUBSYSTEM=="usb", ATTR{idVendor}=="04f3", ATTR{idProduct}=="0c8c", ATTR{power/control}="auto", ATTR{power/autosuspend}="30"
```
## 3. Software Fix (PAM Hardening)

Set max-tries=2 to allow PAM to automatically "consume" the initial hardware glitch, providing a clean second prompt for the user.
File: `/etc/pam.d/common-auth`
```Plaintext

auth [success=2 default=ignore] pam_fprintd.so max-tries=2 timeout=10
auth [success=1 default=ignore] pam_unix.so nullok try_first_pass
```
