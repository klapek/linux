# [FIX] ThinkPad E16 Gen 2 - Fingerprint Reader (ELAN 04f3:0c8c)
**Środowisko:** Linux Mint MATE / Kernel 6.x+
**Strategia:** Safe & Stable (Minimal Invasiveness)

---

## ⚠️ OSTRZEŻENIE / WARNING
Nie próbuj walczyć z tym czytnikiem w sposób agresywny (skrypty `systemd-sleep`, wymuszanie restartów usługi `fprintd`, symulacje klawiszy `xdotool`). 

Nowoczesna architektura (Meteor Lake) i magistrala USB w tym modelu reagują bardzo negatywnie na próby "oszukiwania" zasilania i sesji. Agresywne zmiany mogą doprowadzić do **pętli błędów autoryzacji**, zablokowania `sudo` i konieczności naprawy systemu z poziomu terminala ratunkowego. Lepiej zaakceptować drobne specyfiki hardware'u niż ryzykować stabilność pracy.

---

## PL: Optymalizacja Czytnika - Wersja Stabilna

### ## 1. Stan faktyczny:
* Czytnik ELAN w modelu E16 Gen 2 ma tendencję do "pierwszego błędu" (Cold Boot Bug) po starcie systemu lub wybudzeniu. 
* Środowisko MATE nie odświeża dynamicznie modułu biometrii po otwarciu klapy.

### ## 2. Rozwiązanie (Nieinwazyjne):
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

### ## 3. Dlaczego to wystarczy?
* **Brak lagów:** Rezygnacja z reguł Udev `autosuspend` sprawia, że system zarządza energią domyślnie (zazwyczaj trzyma czytnik aktywny), co eliminuje 2-sekundowe opóźnienia w terminalu.
* **Bezpieczeństwo:** Nawet jeśli po otwarciu klapy czytnik nie zareaguje natychmiast, naciśnięcie [Enter] lub ponowne przyłożenie palca zadziała bez mignięć ekranu i ryzyka zawieszenia sesji.

---

## EN: Fingerprint Reader - Stable Version

### ## 1. Current State:
* The ELAN reader on E16 Gen 2 hardware exhibits a "first poll failure" after boot or resume (Meteor Lake quirk).
* MATE Desktop is rigid with its screensaver and doesn't always re-poll the USB bus dynamically.

### ## 2. Solution (Safe Method):
Avoid automation scripts. Use a simple PAM adjustment to allow a seamless second attempt.

**Step 1: Reset to Defaults**
Run: `sudo pam-auth-update`
*(Ensure 'Fingerprint authentication' is checked).*

**Step 2: The 'Second Chance' Tweak**
Edit: `sudo xed /etc/pam.d/common-auth`
Append `max-tries=2` to the `pam_fprintd.so` line.

### ## 3. Conclusion:
Keep it simple. On this hardware, a manual second tap or a quick [Enter] is far superior to complex scripts that cause screen flickering or authorization loops.
