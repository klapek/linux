# [FIX] ThinkPad E16 Gen 2 - Fingerprint Reader (ELAN 04f3:0c8c)
**Środowisko:** Linux Mint MATE / Kernel 6.x+
**Strategia:** Safe & Stable (Minimal Invasiveness)

---

## ⚠️  OSTATNIA AKTUALIZACJA / LAST UPDATE  ⚠️ 

# Kernel 6.8.0-110: The "Stability Milestone" for Meteor Lake

## PL: Przełom w stabilności (Koniec ery protez)

Jądro w wersji **6.8.0-110** wprowadza kluczowe poprawki, które eliminują błędy regresji występujące w serii **-101 do -109**. Dzięki tym zmianom, zaawansowane skrypty naprawcze stają się zbędne.

### Kluczowe poprawki w wersji -110:
* **Stabilizacja IRQ (Klawiatura):** Naprawiono błędy synchronizacji przerwaniami i8042. Klawiatura inicjalizuje się poprawnie nawet po długim "Zimnym Starcie" (Cold Boot), bez potrzeby stosowania `unbind/bind`.
* **Zarządzanie energią Meteor Lake:** Poprawiono sterownik `intel_pstate` oraz stany uśpienia. Eliminuje to błędy "zaspanych" magistral USB, przez co czytnik linii papilarnych reaguje natychmiast po otwarciu klapy.
* **Synchronizacja biometrii:** Dioda czytnika pulsuje od razu po wznowieniu sesji, co oznacza, że hardware jest gotowy bez sztucznego "budzenia" (fingerprint-warmup).

### Co z protezami?
* **keyboard-fix.service:** Można wyłączyć/usunąć (natywna obsługa jest już stabilna).
* **fingerprint-warmup.sh:** Można wyłączyć (USB nie wymaga już ręcznej inicjalizacji).
* **PAM max-tries=2:** **ZALECANE** zostawić dla czystej wygody użytkowania.

---

## EN: Stability Milestone (End of Workarounds)

Kernel version **6.8.0-110** introduces critical fixes that resolve the regressions observed in the **-101 to -109** series. These updates render previous manual workarounds obsolete.

### Key Fixes in v110:
* **IRQ Stabilization (Keyboard):** Fixed i8042 interrupt synchronization issues. The keyboard initializes correctly even after a "Cold Boot" without requiring `unbind/bind` scripts.
* **Meteor Lake Power Management:** Improvements to `intel_pstate` and C-states. This fixes "sleepy" USB buses, ensuring the fingerprint sensor is ready immediately upon lid open.
* **Biometric Sync:** The sensor LED pulses instantly upon session resume, meaning the hardware is ready without the need for manual "warmup" scripts.

### What about the workarounds?
* **keyboard-fix.service:** Can be disabled/removed (native handling is now stable).
* **fingerprint-warmup.sh:** Can be disabled (USB no longer requires manual polling to wake up).
* **PAM max-tries=2:** **RECOMMENDED** to keep for a better user experience (UX).

---

## ⚠️ OSTRZEŻENIE / WARNING
Nie próbuj walczyć z tym czytnikiem w sposób agresywny (skrypty `systemd-sleep`, wymuszanie restartów usługi `fprintd`, symulacje klawiszy `xdotool`). 

Nowoczesna architektura (Meteor Lake) i magistrala USB w tym modelu reagują bardzo negatywnie na próby "oszukiwania" zasilania i sesji. Agresywne zmiany mogą doprowadzić do **pętli błędów autoryzacji**, zablokowania `sudo` i konieczności naprawy systemu z poziomu terminala ratunkowego. Lepiej zaakceptować drobne specyfiki hardware'u niż ryzykować stabilność pracy.

---

## PL: Optymalizacja Czytnika - Wersja Stabilna

### 1. Stan faktyczny:
* Czytnik ELAN w modelu E16 Gen 2 ma tendencję do "pierwszego błędu" (Cold Boot Bug) po starcie systemu lub wybudzeniu. Sytuacja przy pierwszym zapytaniu (np. `sudo`) czytnik wysyła błędny sygnał. Skutkuje to albo natychmiastowym błędem, albo (rzadziej) niebezpiecznym autologowaniem bez dotknięcia skanera. Na architekturze Meteor Lake, czytnik przy zimnym starcie zawsze zgłasza błąd inicjalizacji (Ghost Error). 

### 2. Rozwiązanie (Nieinwazyjne):
Zamiast skryptów, stosujemy jedynie delikatną korektę w module PAM, która pozwala systemowi na "drugą szansę" przy odczycie palca, bez przerywania sesji.

**Krok 1: Przywrócenie standardu**
W terminalu wykonaj:
`sudo pam-auth-update`
*(Upewnij się, że gwiazdka [*] jest przy 'Fingerprint authentication', zatwierdź OK).*

**Krok 2: Korekta 'Drugiej Szansy'**
Edytuj plik: `sudo xed /etc/pam.d/common-auth`
Znajdź linię `pam_fprintd.so` i dopisz na jej końcu `max-tries=2`.

Przykład:
`auth [success=2 default=ignore] pam_fprintd.so max-tries=2`

### 3. Dlaczego to wystarczy?
* **Brak lagów:** Rezygnacja z reguł Udev `autosuspend` sprawia, że system zarządza energią domyślnie (zazwyczaj trzyma czytnik aktywny), co eliminuje 2-sekundowe opóźnienia w terminalu.
* **Bezpieczeństwo:** Eliminujemy randomowe autologowanie `sudo` poprzez drugą szansę opcji `max-tries=2`.

### 4: Cichy Start Hardware'u (Metoda Schludna)
Aby uniknąć błędu "pierwszego odczytu" w GUI i jednocześnie nie pokazywać okienek autoryzacji przy starcie, stosujemy ciche "puknięcie" i restart demona. To czyści błędy inicjalizacji USB i przygotowuje czytnik na pierwsze realne dotknięcie.

1. Skrypt `~/skrypty/fingerprint-warmup.sh`:
```bash
   #!/bin/bash
   # 1. Czekamy na stabilizację sesji pulpitu (USB Ready)
   sleep 5

   # 2. Budzimy hardware przez zapytanie o bazę danych (nie wymaga hasła/palca)
   fprintd-list $USER > /dev/null 2>&1

   # 3. Zużywamy pierwszy, potencjalnie błędny odczyt sesji
   timeout 0.5s fprintd-verify > /dev/null 2>&1
```

2. Dodaj go do Programów startowych MATE.

3. Zaleta: Całkowicie niewidoczne dla użytkownika, nie wymaga uprawnień roota, rozwiązuje problem "błędnego hasła lub autologowania bez palca" w Menadżerze Aktualizacji i innych aplikacjach GUI.

---

## EN: Fingerprint Reader - Stable Version

### 1. Current State:
* The ELAN reader on E16 Gen 2 hardware exhibits a "first poll failure" after boot or resume (Meteor Lake quirk).
* MATE Desktop is rigid with its screensaver and doesn't always re-poll the USB bus dynamically.

### 2. Solution (Safe Method):
Avoid automation scripts. Use a simple PAM adjustment to allow a seamless second attempt.

**Step 1: Reset to Defaults**
Run: `sudo pam-auth-update`
*(Ensure 'Fingerprint authentication' is checked).*

**Step 2: The 'Second Chance' Tweak**
Edit: `sudo xed /etc/pam.d/common-auth`
Append `max-tries=2` to the `pam_fprintd.so` line.

### 3. Conclusion:
Keep it simple. On this hardware set `max-tries=2` to allow PAM to automatically "consume" the initial hardware glitch, providing a clean second prompt for the user. loops.

###  4. Pro-Tip: The PolicyKit Poke (GUI Cold-Start Fix)
**Status:** Best for Meteor Lake hardware stability.

EN: The Clean Hardware Kickstart (Stealth Warmup)

The most elegant way to bypass the Cold Boot Bug without flashing GUI windows. It wakes the USB hardware and resets the daemon state for a fresh start.

1. Create a script `~/skrypty/fingerprint-warmup.sh:`
    
```bash

      #!/bin/bash
   # 1. Czekamy na stabilizację sesji pulpitu (USB Ready)
   sleep 5

   # 2. Budzimy hardware przez zapytanie o bazę danych (nie wymaga hasła/palca)
   fprintd-list $USER > /dev/null 2>&1

   # 3. Zużywamy pierwszy, potencjalnie błędny odczyt sesji
   timeout 0.5s fprintd-verify > /dev/null 2>&1
```
2.  Add it to MATE Startup Applications.

3. Benefit: 100% transparent to the user, runs in user-space (no sudo needed), and fixes the "reverts to password or autologin without fingerprint" issue in Update Manager/GUI apps.
