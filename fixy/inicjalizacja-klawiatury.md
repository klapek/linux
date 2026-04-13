# Knowledge Pack: Keyboard Initialization Fix (ThinkPad E16 Gen 2)

## PL: Naprawa blokowania klawiszy (P, S, G, K, B, N) i przywrócenie diod LED

**Problem:**  
 Na systemie Mint 22.3 (MATE) z jądrem od 6.8.0-100, po zimnym starcie i samoczynnym przejściu przez menu GRUB, wybrane klawisze (P, S, G, K, B, N) przestawały reagować. Standardowy parametr `i8042.dumbkbd` naprawiał klawisze, ale wyłączał diody CapsLock i NumLock.

---

## ⚠️ OSTATNIA AKTUALIZACJA / LAST UPDATE .:: START ::.



## PL: Podsumowanie naprawy klawiatury (Regresja Jądra 6.8)

### 1. Diagnoza (Dlaczego wersja 6.8.0-94?)
Na podstawie logów systemowych i zgłoszeń na forach (kernel.org / Ubuntu Launchpad), wersje jądra **6.8.0-100 i nowsze** wprowadziły zmiany w zarządzaniu energią (ASPM) oraz obsłudze przerwaniami (IRQ) dla platformy Intel Meteor Lake.
* **Problem:** Zbyt agresywne timeouty i błędy synchronizacji powodują, że przy "zimnym starcie" (Cold Boot) jądro porzuca inicjalizację kontrolera i8042, uznając go za martwy.
* **Rozwiązanie:** Powrót do wersji **6.8.0-94**, która wspiera nowy sprzęt, ale nie posiada jeszcze błędnych poprawek w kodzie ACPI/Power Management.

### 2. Konfiguracja GRUB (/etc/default/grub)
Aby uniknąć loterii przy starcie, wymuszamy ładowanie sprawdzonej wersji jądra i czyścimy zbędne parametry.

**Kroki:**
1. Edytuj plik: `sudo xed /etc/default/grub`
2. Ustaw start na sztywno:
   `GRUB_DEFAULT="Advanced options for Linux Mint 22.3 MATE>Linux Mint 22.3 MATE, with Linux 6.8.0-94-generic"`
3. Przywróć czyste parametry (diody LED działają tu natywnie):
   `GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"`
4. Zaktualizuj: `sudo update-grub`

### 3. Wyłączenie zbędnych usług
Skrypty resetujące (`unbind/bind`) nie są potrzebne na stabilnym jądrze.
```bash
sudo systemctl disable keyboard-fix.service
```



## EN: Keyboard Regression Fix Summary (Kernel 6.8)

### 1. Diagnosis (Why 6.8.0-94?)
Community reports and kernel logs indicate that versions **6.8.0-100** and newer introduced regressions in power management (ASPM) and interrupt handling for Intel Meteor Lake platforms.

Issue: Aggressive timeouts during "Cold Boot" cause the kernel to fail the i8042 controller initialization before the hardware is fully ready.

Solution: Reverting to **6.8.0-94**, which provides hardware support without the buggy ACPI/IRQ commits found in later 100+ builds.

### 2. GRUB Configuration (/etc/default/grub)
Forcing the system to boot from the stable kernel and removing legacy workarounds.

**Steps**:
Edit config: `sudo xed /etc/default/grub`  
Pin the stable version:
 `GRUB_DEFAULT="Advanced options for Linux Mint 22.3 MATE>Linux Mint 22.3 MATE, with Linux 6.8.0-94-generic"`  
Clean boot parameters (LEDs work natively on this build):
`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash"`  
Apply changes: `sudo update-grub`

### 3. Disabling Workarounds
The unbind/bind reset service is no longer required on the stable kernel.
```Bash

sudo systemctl disable keyboard-fix.service
```

Status: Testing Cold Boot (Success so far). LEDs functional.


## ⚠️ OSTATNIA AKTUALIZACJA / LAST UPDATE  ::. END .::

---


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

⚙️  4a. (UPDATE) Naprawa blokady klawiszy po użyciu GRUB (Kernel 6.8.0-107)

   Symptom: Klawiatura działa przy starcie bezczynnym, ale blokuje się po naciśnięciu Enter w GRUB.

    Przyczyna: Konflikt przerwań (IRQ 1) podczas przekazywania kontrolera z BIOS do jądra.

    Fix: Zmiana metody resetu ze słabego rescan na agresywny unbind/bind sterownika atkbd.

```bash
#!/bin/bash
# Wymuszenie twardego resetu sterownika klawiatury
# 1. Odpięcie sterownika atkbd od urządzenia serio0
echo -n "serio0" > /sys/bus/serio/drivers/atkbd/unbind
sleep 0.2
# 2. Ponowne przypięcie (to wymusza pełną inicjalizację rejestrów)
echo -n "serio0" > /sys/bus/serio/drivers/atkbd/bind
```

Dodaj parametr GRUB "i8042.noloop"

W jądrze 6.8 ten parametr pomaga uniknąć zapętlenia przy sprawdzaniu kontrolera po naciśnięciu klawisza w BIOS.
`sudo xed /etc/default/grub`
Dodaj go do listy:
`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i8042.direct i8042.reset i8042.nomux i8042.nopnp i8042.noloop"`  
`sudo update-grub`

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

⚙️  4a (UPDATE) Keyboard Lockup after GRUB Interaction (Kernel 6.8.0-107)

    Issue: Keyboard works fine on auto-boot but fails after pressing Enter in GRUB.

    Cause: Interrupt conflict (IRQ 1) during the BIOS-to-Kernel handoff.

    Fix: Switching from a soft rescan to a hard unbind/bind of the atkbd driver in the systemd service.

```bash
#!/bin/bash
# Wymuszenie twardego resetu sterownika klawiatury
# 1. Odpięcie sterownika atkbd od urządzenia serio0
echo -n "serio0" > /sys/bus/serio/drivers/atkbd/unbind
sleep 0.2
# 2. Ponowne przypięcie (to wymusza pełną inicjalizację rejestrów)
echo -n "serio0" > /sys/bus/serio/drivers/atkbd/bind
```

Add to GRUB "i8042.noloop"

`sudo xed /etc/default/grub`
Add:
`GRUB_CMDLINE_LINUX_DEFAULT="quiet splash i8042.direct i8042.reset i8042.nomux i8042.nopnp i8042.noloop"`  
`sudo update-grub`

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
