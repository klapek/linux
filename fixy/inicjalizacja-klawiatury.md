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
   - `i8042.nopnp`: Kluczowy dla stabilności przy bezczynności. Ignoruje instrukcje ACPI dotyczące usypiania klawiatury.
3. Aktualizacja: `sudo update-grub`.

⚙️  4. Jeśli parametry GRUB nie gwarantują 100% skuteczności, należy wdrożyć wymuszony rescan portu klawiatury przed ekranem logowania. Skrypt wysyła sygnał `rescan` do kontrolera i8042.
# Utwórz plik skryptu 
```bash
sudo xed /usr/local/bin/fix-keyboard.sh
```
```Ini, TOML
#!/bin/bash
# Wymuszenie ponownego skanowania portu (serio0)
echo -n "rescan" > /sys/bus/serio/devices/serio0/drvctl
```
# Nadaj uprawnienia 
```bash
sudo chmod +x /usr/local/bin/fix-keyboard.sh
```
⚙️  5. Systemd Service Unit / Jednostka Systemd

Usługa uruchomi skrypt automatycznie na bardzo wczesnym etapie bootowania (zaraz po modułach, ale przed managerem logowania).

# Utwórz plik usługi 
```bash
sudo xed /etc/systemd/system/keyboard-fix.service
```
Zawartość `keyboard-fix.service`:
```Ini, TOML
[Unit]
Description=Fix ThinkPad Keyboard Matrix Lockup (Cold Boot)
DefaultDependencies=no
After=systemd-modules-load.service
Before=display-manager.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/fix-keyboard.sh
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
```
🚀  6. Aktywacja i Weryfikacja

Przeładuj konfigurację i włącz usługę, aby startowała automatycznie.
```bash
# Komendy aktywacyjne / Activation commands
sudo systemctl daemon-reload
sudo systemctl enable keyboard-fix.service
sudo systemctl start keyboard-fix.service
```
Sprawdzenie stanu
```bash
systemctl status keyboard-fix.service
```
Interpretacja 

    Active: active (exited) – ✅ Skrypt wykonał zadanie i zakończył się sukcesem.

    status=0/SUCCESS – ✅ Sygnał rescan wysłany poprawnie.

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
   - `i8042.nopnp`: Critical for idle stability. Bypasses ACPI-based power management for the i8042 controller.
3. Update: `sudo update-grub`.

⚙️  4. If GRUB parameters fail to provide 100% reliability, implement a forced keyboard port rescan before the login screen. This script sends a `rescan` signal to the i8042 controller.
# Create script file
```bash
sudo xed /usr/local/bin/fix-keyboard.sh
```
```Ini, TOML
#!/bin/bash
# Wymuszenie ponownego skanowania portu (serio0)
echo -n "rescan" > /sys/bus/serio/devices/serio0/drvctl
```
# Grant execution rights
```bash
sudo chmod +x /usr/local/bin/fix-keyboard.sh
```
⚙️  5. Systemd Service Unit

This service triggers the script at a very early boot stage (right after modules load, but before the display manager).

# Create service file
```bash
sudo xed /etc/systemd/system/keyboard-fix.service
```
Content `keyboard-fix.service`:
```Ini, TOML
[Unit]
Description=Fix ThinkPad Keyboard Matrix Lockup (Cold Boot)
DefaultDependencies=no
After=systemd-modules-load.service
Before=display-manager.service

[Service]
Type=oneshot
ExecStart=/usr/local/bin/fix-keyboard.sh
RemainAfterExit=yes

[Install]
WantedBy=sysinit.target
```
🚀  6. Activation & Verification

Reload systemd configuration and enable the service for automatic boot start.
```bash
# Komendy aktywacyjne / Activation commands
sudo systemctl daemon-reload
sudo systemctl enable keyboard-fix.service
sudo systemctl start keyboard-fix.service
```
Status check:
```bash
systemctl status keyboard-fix.service
```
Interpretation:

    Active: active (exited) – ✅ Skrypt wykonał zadanie i zakończył się sukcesem.

    status=0/SUCCESS – ✅ Sygnał rescan wysłany poprawnie.

**Status:**   
Verified - keys are responsive, Caps/Num LEDs functional.
