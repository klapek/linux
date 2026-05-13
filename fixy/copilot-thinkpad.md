# Fix: Remapping 'Copilot' Key to 'AltGr' (Right Alt)
# Status: Verified on Linux Mint MATE (Kernel 6.17 / 6.8)

## Opis (PL)
Nowe modele ThinkPad (np. E16 Gen 2) posiadają klawisz Copilot, który sprzętowo wysyła sekwencję makra: `Shift + Super + TouchpadOff`. Standardowe mapowania X11/MATE (xmodmap, GUI) często zawodzą lub blokują kursor przy próbie wpisywania polskich znaków. Rozwiązaniem jest użycie `input-remapper`, który przechwytuje zdarzenie na poziomie evdev.

### Kroki:
1. Zainstaluj `input-remapper` (repozytorium lub GitHub).
2. W GUI narzędzia wybierz klawiaturę ThinkPad.
3. Stwórz nowy preset (np. `copilot-fix`).
4. Nagraj klawisz Copilot i przypisz mu symbol: `ISO_Level3_Shift`.
5. Zaznacz 'Autoload' w ustawieniach presetu.
6. Aktywuj usługę systemową, aby mapowanie działało po restarcie.

---

## Description (EN)
Newer ThinkPad models (e.g., E16 Gen 2) feature a 'Copilot' key that emits a hardware-level macro: `Shift + Super + TouchpadOff`. Standard X11/MATE mapping tools (xmodmap, GUI shortcuts) often fail or freeze the input buffer when typing diacritics. The fix involves using `input-remapper` to intercept the key at the evdev level.

### Steps:
1. Install `input-remapper` via your package manager or GitHub.
2. Select the ThinkPad keyboard in the GUI.
3. Create a new preset (e.g., `copilot-fix`).
4. Map the captured Copilot key sequence to: `ISO_Level3_Shift`.
5. Enable 'Autoload' for the preset in the GUI.
6. Enable the systemd service to ensure persistence across reboots.

---

## Technical Commands
# Verify and enable the daemon
sudo systemctl enable --now input-remapper-daemon.service

# Check status
systemctl status input-remapper-daemon.service
