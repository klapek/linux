# [PL/EN] Fix: Ultra-Fast HEVC Encoding - Intel Meteor Lake (Gen12)  
**Hardware:** ThinkPad E16 Gen 2 (Core Ultra)  
**System:** Linux Mint 22 / Ubuntu 24.04+ (Kernel 6.8+)  

---

## 🛠️ [PL] Opis Rozwiązania  
Zestaw skryptów optymalizuje konwersję wideo pod architekturę **Intel Meteor Lake**, wykorzystując pełną moc silnika Media Engine przez **VA-API**. Gwarantuje stabilność przy prędkościach **x40** i pełną kompatybilność z TV Samsung (Tizen).  

✅ **Status:** Przetestowane na ThinkPad E16 Gen 2 (V)  

## 🛠️ [EN] Solution Description  
A set of scripts optimized for **Intel Meteor Lake** architecture, utilizing the full power of the Media Engine via **VA-API**. It guarantees stability at **x40** speeds and full compatibility with Samsung TVs (Tizen).  

✅ **Status:** Tested on ThinkPad E16 Gen 2 (V)  

---

## 1. Wymagania / Requirements  

[PL] Aby GPU mogło przetwarzać dane, musisz mieć odpowiednie sterowniki i uprawnienia:  
[EN] To enable GPU processing, you need the correct drivers and permissions:  

```bash
# Dodanie użytkownika do grup / Add user to groups
sudo usermod -aG video,render $USER
```

**Instalacja sterowników / Driver installation**
```bash
sudo apt update && sudo apt install intel-media-va-driver-non-free
```
> [!WARNING]
> **[!] RESTART SYSTEMU / SYSTEM RESTART REQUIRED!**

---

## 2. Podgląd pracy GPU / Monitor GPU (intel-gpu-tools)

[PL] Jeśli chcesz widzieć, jak Twój Meteor Lake "poci się" przy pracy (Video 80%+), zainstaluj narzędzia Intela:

[EN] To see your Meteor Lake working hard (Video 80%+), install the Intel tools:  
```bash

sudo apt install intel-gpu-tools
```

**Uruchomienie podglądu w nowym terminalu / Run monitor in new terminal:**
```bash
sudo intel_gpu_top
```

## 3. Skrypty / Scripts

🚀 D-Turbo (Fastest 1:1 Pass)

[PL] Idealny do polskich filmów. Najmniejszy rozmiar pliku, zerowy narzut.

[EN] Ideal for local movies. Smallest file size, zero overhead.

👉 [Pobierz / Download](../skrypty/serial-multi-convert-turbo-qsv-hevc-thinkpad) 

 
✂️ Chirurg (PL Audio Selection + Cleaning)

[PL] Automatycznie wybiera polską ścieżkę, wycina inne języki i napisy.

[EN] Automatically selects the Polish audio track, strips other languages and subtitles.

👉 [Pobierz / Download](../skrypty/serial-multi-convert-plcut-qsv-hevc-thinkpad)  

---

## 4. Dlaczego to jest "Pancerne"? / Why is it "Bulletproof"?

    -extra_hw_frames 64 [PL] Zapobiega błędom bufora przy filmach > 1h.

    [EN] Prevents buffer errors for movies longer than 1 hour.

    -max_muxing_queue_size 1024 [PL] Zabezpiecza przed I/O error przy prędkościach x40.

    [EN] Protects against I/O errors at x40 speeds.

    -c:a copy [PL] Omija CPU, dźwięk leci prosto do pliku (max speed).

    [EN] Bypasses the CPU, audio goes straight to the file (max speed).
