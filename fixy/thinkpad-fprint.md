# [FIX] ThinkPad E16 Gen 2 - Fingerprint Reader (ELAN 04f3:0c8c)
**Środowisko:** Linux Mint MATE / Kernel 6.x+
**Strategia:** Safe & Stable (Minimal Invasiveness)

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

#### 4: Rozgrzewka Czytnika (Cicha Inicjalizacja)
Jeśli mimo poprawek PAM, aplikacje w GUI (np. Menadżer aktualizacji) przy pierwszym uruchomieniu autologuje zamiast palca, zastosuj "rozgrzewkę" w tle. Pozwala to zużyć ten pierwszy, błędny odczyt (Cold Boot Bug) zanim w ogóle dotkniesz czytnika.

1. Stwórz skrypt `~/skrypty/fingerprint-warmup.sh`:
```bash
   #!/bin/bash
   # Wymuszenie pierwszej, błędnej próby w tle (rozgrzewka hardware'u)
   timeout 0.5s fprintd-verify > /dev/null 2>&1
```
2. Dodaj go do Programów startowych MATE (Startup Applications).

3. Efekt: Po zalogowaniu system "puka" do czytnika. Gdy Ty później otwierasz GUI, czytnik jest już w trybie "drugiej szansy" i od razu prosi o palec i faktycznie czeka ąz go przyłożysz.

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

### 4. Pro-Tip: The Warmup Hack (Silent Background Init)
**Status:** Recommended for GUI (Update Manager / Synaptic) consistency.

EN: Reader Warmup (Silent Background Init)

If GUI apps (like Update Manager) still goes without password on the first try despite PAM tweaks, use this silent background "warmup". It exhausts the initial "Cold Boot Bug" poll before you even interact with the UI.

1. Create a script `~/skrypty/fingerprint-warmup.sh:`
    
```bash

    #!/bin/bash
    # Trigger the initial failed poll in the background
    timeout 0.5s fprintd-verify > /dev/null 2>&1
```
2.  Add it to MATE Startup Applications.

3.  Result: Upon login, the system "pokes" the hardware. When you later trigger a GUI auth, the reader is already in its stable "second-poll" state and prompts for a finger immediately and wait for your finger.
