## Knowledge Pack: BT-Audio Power Fix (ThinkPad E16 Gen2)
## PL: Optymalizacja poboru mocy po Bluetooth

---

## [PL] Opis problemu:
Po wyłączeniu Bluetooth i odłączeniu słuchawek, pobór energii nie spadał do wartości bazowych, utrzymując się na poziomie ~10W. Proces PulseAudio obciążał CPU (pętla błędów/resampling), mimo braku aktywnego wyjścia audio.

### Rozwiązanie: 
Skrypt monitorujący obecność kontrolera Bluetooth przez `bluetoothctl`. W momencie wykrycia stanu "absent" (brak kontrolera po wyłączeniu w blueman-manager), skrypt wymusza reset demona audio komendą `pulseaudio -k`.

### Efekt:
 Pobór mocy spada z ~11W do stabilnych **5.40W** przy pracy biurowej.

### [Skrypt](../skrypty/bt-fixer.sh):
1. Monitoruje stan w pętli co 3 sekundy.
2. Wysyła powiadomienia systemowe (`notify-send`).
3. Dodany do autostartu MATE.

> [!TIP]
> Gotowy skrypt do resetu pulseaudio po wyłączeniu bt znajdziesz [tutaj](../skrypty/bt-fixer.sh).


---

## EN: Bluetooth Audio Power Consumption Fix
**Issue:** After disabling Bluetooth and disconnecting headphones, power draw failed to return to baseline, staying around 10W. The PulseAudio process caused high CPU overhead (error looping/resampling) despite no active audio output.

**Solution:** A background script monitoring the Bluetooth controller's presence via `bluetoothctl`. When the "absent" state is detected (controller disappears after being disabled in blueman-manager), the script forces an audio daemon reset using `pulseaudio -k`.

**Effect:** Power draw drops from ~11W to a stable **5.40W** during office tasks.

**Script (`~/skrypty/bt-fixer.sh`):**
1. Monitors state in a 3-second loop.
2. Sends system notifications (`notify-send`).
3. Added to MATE startup applications.

> [!TIP]
> Ready-to-use script is available [here](../skrypty/bt-fixer.sh).
