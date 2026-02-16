# LibreOffice Calc: Fix for Cursor Lag & Overshoot (Linux)
# LibreOffice Calc: Poprawka opóźnienia kursora (Linux)

---

## [PL] Opis problemu
W systemach Linux (Mint, Salix, Slackware) LibreOffice Calc może wykazywać znaczne opóźnienie (lag) podczas przewijania lub używania strzałek w dużych arkuszach (np. 100+ zakładek). Kursor "płynie" dalej przez kilka sekund po puszczeniu klawisza.

### Rozwiązanie
Problem wynika z kolejkowania zdarzeń w backendzie GTK3. Rozwiązaniem jest wymuszenie natywnego backendu X11 (**gen**) oraz uruchomienie dokumentu w osobnej instancji profilu użytkownika, aby uniknąć konfliktów z innymi otwartymi oknami LO.

### Komenda Turbo:
Otwórz terminal i wpisz:
```bash
env SAL_USE_VCLPLUGIN=gen libreoffice "-env:UserInstallation=file:///tmp/lo_speed_session" --calc /sciezka/do/pliku.ods
```
## [EN] Problem Description
On Linux systems (Mint, Salix, Slackware), LibreOffice Calc may experience significant cursor lag/overshoot when navigating large spreadsheets (e.g., 100+ tabs). The cursor continues to move for several seconds after the arrow key is released.

### Solution
The issue is caused by event buffering in the GTK3 backend. The fix involves forcing the native X11 backend (gen) and running the document in a separate user profile instance to prevent interference with other running LO processes.

### Turbo Command:
Open your terminal and run:
```bash
env SAL_USE_VCLPLUGIN=gen libreoffice "-env:UserInstallation=file:///tmp/lo_speed_session" --calc /path/to/file.ods
```

### Tested on / Testowano na:

Linux Mint 21,x, 22.x (MATE)

Salix 15.0 (Xfce)

