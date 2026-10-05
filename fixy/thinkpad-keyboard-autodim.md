# Knowledge Pack: ThinkPad Keyboard Auto-Dimming via rc.local in systemd

## [PL] Automatyczne wygaszanie klawiatury ThinkPada przez /etc/rc.local (systemd)

### Opis problemu
W przeciwieństwie do laptopów Dell Precision (gdzie podświetleniem steruje układ EC), ThinkPady z serii E/T/X nie wygaszają automatycznie podświetlenia klawiatury podczas bezczynności, gdy są podłączone do zasilacza AC. Lekkie środowiska graficzne (MATE, Xfce) nie posiadają natywnych opcji do zarządzania modułem `thinkpad_acpi`.

### Rozwiązanie
Przywrócenie obsługi klasycznego pliku `/etc/rc.local` w `systemd` oraz uruchomienie demona w tle (jako root), który odczytuje czas bezczynności X11 via `xprintidle` i steruje magistralą sysfs `tpacpi::kbd_backlight`.

---

### Wymagania
```bash
sudo apt update && sudo apt install xprintidle
```

### Kroki:

1: **Włączenie rc-local.service w systemd**

Utwórz plik `/etc/systemd/system/rc-local.service:`

```
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=journal
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

2. **Skrypt /etc/rc.local**

Utwórz lub zmodyfikuj plik `/etc/rc.local` (pamiętaj o sudo chmod +x /etc/rc.local):

```
#!/bin/sh
# /etc/rc.local

(
  # Czekamy na załadowanie sesji MATE
  until pgrep -x "mate-session" > /dev/null; do
    sleep 2
  done

  sleep 3

  IDLE_TIME=15000  # czas bezczynności w ms (np. 15000 = 15 sek)
  BRIGHTNESS_FILE="/sys/class/leds/tpacpi::kbd_backlight/brightness"
  LAST_STATE=1

  while true; do
    if [ -f "$BRIGHTNESS_FILE" ]; then
      CURRENT_IDLE=$(sudo -u klapek DISPLAY=:0 XAUTHORITY=/home/klapek/.Xauthority xprintidle 2>/dev/null || echo 0)

      if [ "$CURRENT_IDLE" -gt "$IDLE_TIME" ]; then
        CURRENT_VAL=$(cat "$BRIGHTNESS_FILE")
        if [ "$CURRENT_VAL" -ne 0 ]; then
          LAST_STATE=$CURRENT_VAL
          echo 0 > "$BRIGHTNESS_FILE"
        fi
      else
        CURRENT_VAL=$(cat "$BRIGHTNESS_FILE")
        if [ "$CURRENT_VAL" -eq 0 ] && [ "$LAST_STATE" -ne 0 ]; then
          echo "$LAST_STATE" > "$BRIGHTNESS_FILE"
        fi
      fi
    fi
    sleep 2
  done
) &

exit 0
```

3. **Aktywacja usługi**

```
sudo systemctl daemon-reload
sudo systemctl enable --now rc-local
```

## [EN] Automatic ThinkPad Keyboard Backlight Dimming via /etc/rc.local (systemd)
Problem Description

Unlike Dell Precision laptops (where the Embedded Controller natively controls keyboard LED timeout), ThinkPad laptops do not automatically dim or turn off keyboard backlighting during user inactivity when connected to AC power. Lightweight DEs like MATE or Xfce lack built-in options to handle thinkpad_acpi LED timers.
Solution

Re-enable classic `/etc/rc.local` execution under systemd and run a background loop (as root) that queries X11 idle time via xprintidle and directly controls the tpacpi::kbd_backlight sysfs interface.
Prerequisites

`sudo apt update && sudo apt install xprintidle`

Step 1: Create systemd service unit

Create `/etc/systemd/system/rc-local.service`:

```
[Unit]
Description=/etc/rc.local Compatibility
ConditionPathExists=/etc/rc.local

[Service]
Type=forking
ExecStart=/etc/rc.local start
TimeoutSec=0
StandardOutput=journal
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
```

Step 2: Configure `/etc/rc.local`

Create or update `/etc/rc.local `and ensure execution permissions (sudo chmod +x /etc/rc.local):

```
#!/bin/sh
# /etc/rc.local

(
  until pgrep -x "mate-session" > /dev/null; do
    sleep 2
  done

  sleep 3

  IDLE_TIME=15000  # idle timeout in ms (e.g. 15000 = 15 sec)
  BRIGHTNESS_FILE="/sys/class/leds/tpacpi::kbd_backlight/brightness"
  LAST_STATE=1

  while true; do
    if [ -f "$BRIGHTNESS_FILE" ]; then
      CURRENT_IDLE=$(sudo -u klapek DISPLAY=:0 XAUTHORITY=/home/klapek/.Xauthority xprintidle 2>/dev/null || echo 0)

      if [ "$CURRENT_IDLE" -gt "$IDLE_TIME" ]; then
        CURRENT_VAL=$(cat "$BRIGHTNESS_FILE")
        if [ "$CURRENT_VAL" -ne 0 ]; then
          LAST_STATE=$CURRENT_VAL
          echo 0 > "$BRIGHTNESS_FILE"
        fi
      else
        CURRENT_VAL=$(cat "$BRIGHTNESS_FILE")
        if [ "$CURRENT_VAL" -eq 0 ] && [ "$LAST_STATE" -ne 0 ]; then
          echo "$LAST_STATE" > "$BRIGHTNESS_FILE"
        fi
      fi
    fi
    sleep 2
  done
) &

exit 0
```

Step 3: Enable & Start Service

```
sudo systemctl daemon-reload
sudo systemctl enable --now rc-local
```
