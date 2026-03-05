# Fix: Timeshift Excessive Disk Usage on Linux Mint (MATE)
# Fix: Nadmierne zużycie dysku przez Timeshift na Linux Mint (MATE)

## Description / Opis
(PL) Problem polegał na tym, że Timeshift zajmował niemal 100 GB przy zaledwie dwóch kopiach. Przyczyną było włączone dołączanie plików ukrytych z `/home`, co powodowało fizyczne kopiowanie ogromnych ilości danych (cache, configi) zamiast stosowania oszczędnych hard linków.

(EN) The issue was Timeshift consuming nearly 100 GB with only two snapshots. This was caused by including hidden files from `/home`, which forced physical copying of massive amounts of data (cache, configs) instead of using efficient hard links.

---

## Analysis / Analiza

### Check real vs reported space / Sprawdź realne vs raportowane miejsce
```bash
# DF might show virtual usage, DU with --count-links shows physical reality
# DF może pokazywać wirtualne zużycie, DU z --count-links pokazuje fizyczną prawdę
sudo du -sh --count-links /timeshift
```
---

## Solution / Rozwiązanie

**1. Correct Filters / Popraw filtry**

    Exclude /home: Settings -> Users -> Exclude All.

    APT Cache: Run sudo apt clean before big snapshots.

    Limit: Keep max 2-3 snapshots to save NVMe lifecycle.

    Wyklucz /home: Ustawienia -> Użytkownicy -> Wyklucz wszystko.

    Cache APT: Używaj sudo apt clean przed robieniem dużych migawek.

    Limit: Trzymaj max 2-3 migawki, aby oszczędzać NVMe.

**2. Cleanup / Czyszczenie**

(PL) Usuń stare, spuchnięte migawki przez GUI Timeshift.
(EN) Delete old, bloated snapshots via Timeshift GUI.

**3. Maintenance / Konserwacja**

(PL) Po czystce system powinien zajmować ok. 20-30 GB na partycji /.
(EN) After cleanup, the system should occupy approx. 20-30 GB on the / partition.

---

## Technical Summary / Podsumowanie techniczne
(PL) Timeshift w trybie RSYNC używa hard linków. Pierwsza kopia zajmuje tyle, co system (~35GB). Kolejne kopie zajmują tylko różnice, ale narzędzia GUI (Caja) i proste `df` mogą błędnie raportować sumaryczne zużycie.

(EN) Timeshift in RSYNC mode uses hard links. The first copy takes as much as the system (~35GB). Subsequent copies take only differences, but GUI tools (Caja) and simple `df` may incorrectly report total usage.

## Correct Verification / Prawidłowa weryfikacja
(PL) Nie ufaj standardowemu `du` bez flag. Użyj:
(EN) Do not trust standard `du` without flags. Use:
```bash
sudo du -sh -l /timeshift 2>/dev/null
```

V Status: Resolved / Naprawiono
Device: ThinkPad
OS: Linux Mint 22.3 MATE
