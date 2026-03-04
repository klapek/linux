# [PL/EN] Fix: Markdown Terminal Viewer on Linux Mint  
**System:** Linux Mint (MATE)  
**Tool:** Python3 Rich  

---

## 🛠️ [PL] Podgląd plików MD w terminalu  
**Problem:** `batcat` nie renderuje Markdowna (pokazuje surowe tagi), a brak `glow` w oficjalnym repozytorium utrudnia podgląd dokumentacji.  
**Rozwiązanie:** Wykorzystanie modułu `rich.markdown` z Pythona z wymuszeniem kolorów i pagerem.  

✅ **Status:** Przetestowane na ThinkPad (V)  

### Implementacja (Alias):
Dodaj do `~/.bashrc`:  
`alias mdview='f(){ python3 -m rich.markdown -c "$1" | less -R; }; f'`  

---

## 🛠️ [EN] Markdown Terminal Preview  
**Issue:** `batcat` shows raw markdown tags, and `glow` is missing from official Mint repos.  
**Solution:** Using Python's `rich.markdown` module with forced color output and a pager.  

✅ **Status:** Tested on ThinkPad (V)  

### Implementation (Alias):
Add to `~/.bashrc`:  
`alias mdview='f(){ python3 -m rich.markdown -c "$1" | less -R; }; f'`  

---

## ⚙️ Użycie / Usage  
`mdview nazwa_pliku.md`  
