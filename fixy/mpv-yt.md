# [PL/EN] Fix: mpv + yt-dlp Optimization  
**System:** Linux Mint 22.3 (ThinkPad)  
**Tools:** mpv, yt-dlp (Git version)  

---

## 🛠️ [PL] Naprawa i optymalizacja mpv/yt-dlp  
**Problem:** `mpv` nie otwiera linków z YT lub wolno buforuje. Wersja `yt-dlp` z menedżera pakietów (`apt`) jest często nieaktualna i nie radzi sobie z nowymi API YouTube.  

✅ **Status:** Przetestowane (V)  

### Krok 1: Instalacja najnowszej wersji z Git
Usuwamy wersję repozytoryjną i instalujemy binarkę bezpośrednio od twórców:

```bash
# Usuń wersję systemową
sudo apt remove yt-dlp

# Pobierz najnowszą wersję do /usr/local/bin
sudo wget [https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp](https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp) -O /usr/local/bin/yt-dlp

# Nadaj uprawnienia do wykonywania
sudo chmod a+rx /usr/local/bin/yt-dlp
```

### Krok 2: Aktualizacja (Gdy YT znowu coś zmieni)

Jeśli odtwarzanie nagle przestanie działać, wykonaj szybki update:

```bash

sudo yt-dlp -U
```

### Krok 3: Optymalizacja mpv.conf (~/.config/mpv/mpv.conf)


```Ini, TOML

# Precyzyjne skakanie (2-3s zamiast 6s)
hr-seek=yes

ytdl-format="bestvideo[height<=?1080][vcodec^=avc1]+bestaudio[ext=m4a]/best"

# Agresywny bufor w RAM (1GB)
cache=yes
demuxer-max-bytes=1000MiB
demuxer-readahead-secs=300
demuxer-max-back-bytes=500MiB

# Akceleracja sprzętowa (Intel/AMD)
hwdec=vaapi
vo=gpu
```
---

## 🛠️ [EN] mpv/yt-dlp Fix & Optimization

Issue: mpv fails to open YT links or seeks slowly. The yt-dlp version from standard repos is often outdated.

✅ Status: Tested (V)

### Step 1: Install latest version from Git
```bash

sudo apt remove yt-dlp
sudo wget [https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp](https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp) -O /usr/local/bin/yt-dlp
sudo chmod a+rx /usr/local/bin/yt-dlp
```

### Step 2: Update (When playback fails)
```bash

sudo yt-dlp -U
```

### Step 3: Buffering & Seeking Tweaks

Set hr-seek=yes and increase demuxer-max-bytes in mpv.conf for smooth seeking.
