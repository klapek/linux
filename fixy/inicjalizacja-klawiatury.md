# Knowledge Pack: Keyboard Initialization Fix (ThinkPad E16 Gen 2)

## PL: Naprawa blokowania klawiszy (P, S, G, K, B, N) po starcie
**Problem:** Na systemie Mint 22.3 (MATE) z jądrem 6.8.0-101, po zimnym starcie i samoczynnym przejściu przez menu GRUB (timeout), wybrane klawisze (P, S, G, K, B, N) przestawały reagować na ekranie logowania. Problem nie występował, jeśli użytkownik manualnie zatwierdził wybór w GRUB klawiszem Enter.

**Diagnoza:**
Błąd wynika z "wyścigu" (race condition) podczas inicjalizacji kontrolera i8042 (odpowiedzialnego za klawiaturę i trackpoint) w nowszych wersjach jądra. Klawisze P, S, G, K, B, N współdzielą wspólną linię w matrycy klawiatury (Keyboard Matrix). Błąd synchronizacji powodował zablokowanie konkretnego rejestru kontrolera EC (Embedded Controller), co "wycinało" całą sekcję matrycy.

**Rozwiązanie:**
Wymuszenie stabilnego trybu komunikacji z kontrolerem poprzez parametry jądra.

1. Edycja pliku `/etc/default/grub`.
2. Dodanie parametrów do linii `GRUB_CMDLINE_LINUX_DEFAULT`:
   - `i8042.direct`: Bezpośrednie odpytywanie portów kontrolera (pomija błędne ACK).
   - `i8042.dumbkbd`: Wyłączenie sterowania LED podczas initu (zapobiega przepełnieniu bufora).
3. Aktualizacja: `sudo update-grub`.

**Status:** Zweryfikowano (7/7 udanych startów bez ingerencji w GRUB).

---

## EN: Keyboard Init Fix (Keys P, S, G, K, B, N Unresponsive)
**Issue:** On Mint 22.3 (MATE) with kernel 6.8.0-101, after a cold boot and GRUB timeout, specific keys (P, S, G, K, B, N) would fail at the login screen. The issue was absent if the user manually pressed Enter in the GRUB menu.

**Diagnosis:**
The problem is caused by a race condition during the i8042 controller initialization (handling the keyboard and trackpoint) in the 6.8 kernel series. The keys P, S, G, K, B, and N share a common strobe line in the keyboard matrix. An initialization sync error caused the Embedded Controller (EC) register to lock up, effectively disabling that part of the matrix.



**Solution:**
Forcing a stable communication mode with the controller via kernel parameters.

1. Edit `/etc/default/grub`.
2. Add the following to `GRUB_CMDLINE_LINUX_DEFAULT`:
   - `i8042.direct`: Enables direct polling of controller ports (bypasses faulty ACK checks).
   - `i8042.dumbkbd`: Disables LED control during initialization (prevents buffer overflows).
3. Update: `sudo update-grub`.

**Status:** Verified (7/7 successful boots without manual GRUB interaction).
