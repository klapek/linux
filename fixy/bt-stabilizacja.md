# Knowledge Pack: Intel AX211 BT Fix (ThinkPad E16 Gen 2)
**Status:** FULLY STABILIZED
**Strategy:** Boot-time initialization + Session-level rfkill block.

## PL: Rozwiązanie problemu znikającego Bluetooth
Problem wynikał z błędu firmware (-19) przy próbie włączenia "zimnej" karty. 

### Kroki:
1. **Stabilny start:** `AutoEnable=true` w `/etc/bluetooth/main.conf` (wgrywa firmware przy boocie).
2. **Blokada uśpienia:** Reguła udev w `/etc/udev/rules.d/10-local-powersave.rules` dla ID 8087:0033.
3. **Oszczędność prądu:** Dodanie `rfkill block bluetooth` do autostartu sesji MATE.

## EN: Final Stability Fix
Fixed the "missing adapter" issue caused by firmware load timeouts.

### Steps:
1. **Firmware at boot:** Set `AutoEnable=true` in `/etc/bluetooth/main.conf`.
2. **No USB Suspend:** Udev rule for 8087:0033 to keep the controller active.
3. **Power Management:** Use `rfkill block bluetooth` in MATE startup apps to keep radio OFF by default without breaking driver stability.
