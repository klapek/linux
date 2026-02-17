# ThinkPad Battery Management Guide (Linux)

## PL: Dlaczego praca na kablu (AC) z progami jest lepsza?
**Mit:** "Odłączaj kabel po naładowaniu, bo zniszczysz baterię".  
**Fakt:** Ciągłe rozładowywanie i ładowanie nabija cykle (**Cycle Count**), co fizycznie zużywa chemię ogniw.

**Nowoczesne podejście:**
* **Ustaw progi:** (np. 40% start / 80% stop).
* **Trzymaj na kablu:** Tak długo, jak to możliwe.
* **Bypass Mode:** Elektronika ThinkPada zasila komponenty bezpośrednio z zasilacza, omijając baterię.
* **Wynik:** Bateria odpoczywa (**0,00W w Conky**), temperatura spada, a licznik cykli stoi w miejscu.

> [!TIP]
> Gotowy skrypt do przełączania trybów znajdziesz [tutaj](../skrypty/thinkpad_battery_mode.sh).

---

## EN: Why AC Power with Thresholds Beats Discharge Cycles?
**Myth:** "Unplug after charging to save the battery".  
**Fact:** Constant discharging and charging increases **Cycle Count**, physically wearing out the cells.

**Modern Approach:**
* **Set thresholds:** (e.g., 40% start / 80% stop).
* **Keep it plugged in:** As much as possible.
* **Bypass Mode:** ThinkPad electronics power components directly from the AC adapter, skipping the battery.
* **Result:** Battery stays idle (**0.00W in Conky**), stays cool, and cycle count doesn't increase.

> [!TIP]
> Ready-to-use switching script is available [here](../skrypty/thinkpad_battery_mode.sh).

---
---

## PL: Kolejność ustawiania progów (Fix)
**Problem:** Komenda `echo X > charge_control_start_threshold` jest ignorowana.  
**Przyczyna:** Kernel Linuxa (sterownik `thinkpad_acpi`) nie przyjmie progu startowego, który jest wyższy niż aktualnie ustawiony próg końcowy (`end_threshold`).  
**Rozwiązanie:** Przy zwiększaniu limitów (np. z 80% na 100%) zawsze zachowuj odpowiednią kolejność:
1. Najpierw podnieś **End Threshold**.
2. Dopiero potem podnieś **Start Threshold**.

**Przykład w skrypcie:**
```bash
echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
echo 95 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold
```

---

## EN: Threshold Ordering Issue (Fix)

**Issue:** Setting charge_control_start_threshold fails or is ignored.

**Cause:** The Linux kernel will reject a start threshold value that exceeds the current end_threshold.

**Fix:** When increasing limits (e.g., from 80% to 100%), always follow this order:

 1. Update **End Threshold** first.

 2. Update **Start Threshold** second.

Script Example:
```bash
echo 100 | sudo tee /sys/class/power_supply/BAT0/charge_control_end_threshold
echo 95 | sudo tee /sys/class/power_supply/BAT0/charge_control_start_threshold
```
