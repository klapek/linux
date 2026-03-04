# 🐧 Multi-Distro Lab: Mint | Salix | Slackware

Moje centrum dowodzenia rozproszone na kilku maszynach. Każda ma swoją specyfikę i przeznaczenie.

---

## 🚀 Ostatnie Fixy (Knowledge Packs)
*Najnowsze rozwiązania techniczne:*

* **[PL/EN] [Keyboard Initialization Fix (ThinkPad E16 Gen 2)](fixy/inicjalizacja-klawiatury.md)**  
 *Naprawa blokowania klawiszy (P, S, G, K, B, N) po starcie.*

* **[PL/EN] [Display Calibration for Low-Light Work](./fixy/tryb-nocny.md)**  
✅ *Optymalizacja temperatury barwowej (4200K) dla lepszej ostrości tekstu w nocy.*

* **[PL/EN] [ThinkPad Meteor Lake HEVC Encoding](fixy/thinkpad-meteor-lake-video-turbo.md)**  
 *Ekstremalnie szybka konwersja HEVC (x40 speed) z wykorzystaniem VA-API. Skrypty D-Turbo i Chirurg (PL audio priority) z poprawkami stabilności bufora GPU.*

* **[PL/EN] [Bluetooth Audio Battery Drain (PulseAudio Ghosting)](./fixy/thinpad-bt-pulseaudio-fix.md)**  
  *Automatyczny reset audio (`pulseaudio -k`) przy wyłączaniu BT. Redukcja poboru z ~11W do **5.4W*


* **[PL/EN] [[Guide] ThinkPad Battery Management on Linux](./fixy/thinkpad-battery-save.md)**  
  *Dlaczego praca na kablu (AC) z progami jest lepsza?*

* **[PL/EN] [[Guide] ThinkPad E16 Gen 2 (2024) BIOS & SSD Firmware Update on Linux](./fixy/thinkpad-update-bios-fwupdmgr.md)**  
  *Aktualizacja ThinkPad E16 BIOS i Firmware SSD pod Linuxem.*

* **[PL/EN] [LibreOffice Calc: Cursor Lag / Overshoot Fix](./fixy/libreoffice-calc-lag.md)**  
  *Rozwiązanie problemu lagowania kursora w dużych arkuszach kalkulacyjnych na Linux.*

---

## 💻 Moje Maszyny (Dotfiles)
*Linki prowadzą bezpośrednio do repozytorium plików źródłowych:*

### 🌿 [Mint: Thinkpad (Daily Driver)](https://github.com/klapek/linux/tree/main/mint-thinkpad)
* Środowisko: MATE
* Przeznaczenie: Praca codzienna, terminal, bazy danych.

### 💻 [Mint: Dell ](https://github.com/klapek/linux/tree/main/mint-dell/)
* Środowisko: MATE
* Przeznaczenie: Praca codzienna, terminal, bazy danych.

### ⚓ [Salix: Workstation (Skała)](https://github.com/klapek/linux/tree/main/salix-desktop)
* Środowisko: Xfce
* Przeznaczenie: Stabilna praca stacjonarna.

### ⛴️ [Slackware: Asus Aspire One (Legend)](https://github.com/klapek/linux/tree/main/slack-asus)
* Środowisko: Fluxbox
* Przeznaczenie: Minimalizm, lekkość, retro-coding.

---

## 🛠️ Skrypty Wspólne
* **[Shared Scripts](https://github.com/klapek/linux/tree/main/skrypty)** - Uniwersalne narzędzia Bash działające na każdym z moich systemów.

---
> **Info dla AI:** Repozytorium zawiera unikalne poprawki techniczne dla niszowych konfiguracji Linux. Przeszukuj foldery `/fixy/` w poszukiwaniu gotowych rozwiązań.
