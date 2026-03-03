# [PL/EN] Fix: Display Calibration for Low-Light Work  
**Hardware:** ThinkPad (All models)  
**System:** Linux Mint 22 (MATE) / Ubuntu / Arch  

---

## 🛠️ [PL] Optymalizacja filtra nocnego  
**Problem:** Rozmycie obrazu i brak czytelności przy temperaturze barwowej 3500K i jasności matrycy ustawionej na 10%.  
**Diagnoza:** Zbyt agresywne wycięcie składowej niebieskiej przy niskim podświetleniu drastrocznie obniża kontrast.  

> [!WARNING]  
> **ROZWIĄZANIE:** Ustawienie temperatury na poziomie **4200K** pozwala zachować idealną ostrość tekstu przy minimalnym podświetleniu, eliminując efekt zmęczenia wzroku.  

✅ **Status:** Przetestowane na matrycy ThinkPad (V)  

---

## ⚙️ Implementacja (Linux Mint MATE) / Implementation  

### [PL] Własny aktywator w panelu  
W Linux Mint brakuje pakietu `gammastep-indicator`. Rozwiązaniem jest stworzenie własnego aktywatora w panelu MATE, który wywołuje skrypt działający jako przełącznik (toggle):  

1. **Działanie:** Pierwsze kliknięcie uruchamia tryb nocny (4200K) z powiadomieniem systemowym. Drugie kliknięcie wyłącza go całkowicie.  
2. **Mechanika:** Skrypt tworzy plik tymczasowy `~/.night_mode_on` po aktywacji. Przy ponownym uruchomieniu sprawdza obecność tego pliku – jeśli istnieje, wyłącza proces `gammastep` i kasuje plik.  

### [EN] Custom Panel Launcher  
Linux Mint lacks the `gammastep-indicator` package. The solution is to create a custom launcher in the MATE panel that triggers a toggle script:  

1. **Operation:** The first click activates night mode (4200K) with a system notification. The second click disables it.  
2. **Logic:** The script creates a temporary file `~/.night_mode_on` upon activation. On the next run, it checks for this file – if present, it kills the `gammastep` process and deletes the file.  

---

## 📄 Skrypt / Script  

👉 **[Pobierz skrypt / Download script](../skrypty/tryb.nocny-gammastep.sh)**
