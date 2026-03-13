# Knowledge Pack: Keyboard Initialization Fix (ThinkPad E16 Gen 2)

## PL: Naprawa blokowania klawiszy (P, S, G, K, B, N) i przywrócenie diod LED

**Problem:**  
 Na systemie Mint 22.3 (MATE) z jądrem 6.8.0-101, po zimnym starcie i samoczynnym przejściu przez menu GRUB, wybrane klawisze (P, S, G, K, B, N) przestawały reagować. Standardowy parametr `i8042.dumbkbd` naprawiał klawisze, ale wyłączał diody CapsLock i NumLock.

**Diagnoza:**  
Problem wynika z błędu synchronizacji (race condition) między jądrem a Embedded Controllerem (EC). Próba inicjalizacji diod LED w tym samym momencie co matrycy klawiatury powodowała zawieszenie jednej z linii sygnałowych matrycy.

**Rozwiązanie (Wersja stabilna z diodami):**  
Zastosowanie parametrów wymuszających pełny reset kontrolera i wyłączających multipleksowanie, co stabilizuje init bez blokowania diod LED.

1. Edycja `/etc/default/grub`.
2. Dodanie parametrów:
   `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i8042.direct i8042.reset i8042.nomux"`
   - `i8042.direct`: Bezpośrednie odpytywanie portów.
   - `i8042.reset`: Wymusza reset kontrolera przy starcie (kluczowe dla diod LED).
   - `i8042.nomux`: Wyłącza aktywne multipleksowanie, poprawiając stabilność matrycy.
3. Aktualizacja: `sudo update-grub`.

**Status:**   
Zweryfikowano - klawisze działają, diody Caps/Num świecą poprawnie.

---

## EN: Keyboard Init Fix (Keys P, S, G, K, B, N & LED Recovery)

**Issue:**  
 On Mint 22.3 (MATE) with kernel 6.8.0-101, keys (P, S, G, K, B, N) became unresponsive after GRUB timeout. While `i8042.dumbkbd` fixed the keys, it disabled CapsLock/NumLock LEDs.

**Diagnosis:**  
A race condition between the kernel and the Embedded Controller (EC). Initializing LEDs simultaneously with the keyboard matrix caused a strobe line lockup in the matrix.

**Solution (Stable version with LEDs):**  
Using parameters that force a controller reset and disable multiplexing to stabilize initialization without blocking LED communication.

1. Edit `/etc/default/grub`.
2. Append the following parameters:
   `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i8042.direct i8042.reset i8042.nomux"`
   - `i8042.direct`: Enables direct port polling.
   - `i8042.reset`: Forces controller reset during boot (essential for LED sync).
   - `i8042.nomux`: Disables active multiplexing to prevent matrix conflicts.
3. Update: `sudo update-grub`.

**Status:**   
Verified - keys are responsive, Caps/Num LEDs functional.
