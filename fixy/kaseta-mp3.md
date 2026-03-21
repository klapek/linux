# [PL/EN] Knowledge Pack: Analog to Digital Archiving (Cassette Edition)
**Status:** Verified & Stable (2026-03-21)  
**Platform:** Linux (ThinkPad / ALSA / PulseAudio)  
**Hardware:** Sony Walkman + UGREEN USB Sound Card (KTMicro)  

---

## 🛠️ 1. Hardware Setup / Konfiguracja Sprzętowa  

**PL:** * **Interfejs:** Użyj karty USB UGREEN (chipset KTMicro). Jest izolowana od szumów płyty głównej.  
* **Połączenie:** Walkman (wyjście słuchawkowe) ➔ Kabel Jack-Jack 3.5mm ➔ Karta USB (wejście mikrofonowe - różowe).  
* **Izolacja:** Połóż Walkmana na miękkiej powierzchni (podkładka/materiał) z dala od głośników laptopa, aby uniknąć sprzężeń mechanicznych ("pacania").  

**EN:** * **Interface:** Use UGREEN USB Sound Card (KTMicro chipset) for better isolation from motherboard noise.  
* **Connection:** Walkman (Headphone Out) ➔ 3.5mm Jack-Jack Cable ➔ USB Card (Mic-In / Pink port).  
* **Isolation:** Place the Walkman on a soft surface away from laptop speakers to prevent mechanical feedback/microphonics.  

---

## ⚙️ 2. Linux System Configuration / Konfiguracja Systemu  

**PL:** * **Terminal:** Wyłącz systemowe mostki audio przed nagrywaniem:  
    ```bash
    pactl unload-module module-loopback
    ```
* **pavucontrol:** Po rozpoczęciu nagrywania w Audacity, w zakładce **Nagrywanie** wybierz jako źródło: `KT USB Audio Mono`.  

**EN:** * **Terminal:** Unload audio bridges before recording:  
    ```bash
    pactl unload-module module-loopback
    ```
* **pavucontrol:** Once recording starts in Audacity, go to the **Recording** tab and set the source to: `KT USB Audio Mono`.  

---

## 🎙️ 3. Audacity Settings / Ustawienia Audacity  

**PL:** * **Host:** ALSA  
* **Urządzenie nagrywania:** `pulse` lub `default`  
* **Kanały:** 1 (Mono) — *Karty USB typu 'dongle' natywnie obsługują tylko 1 kanał wejściowy.* * **Głośność wejściowa:** Ustaw na ok. **25%** (zapobiega to przesterowaniu/clippingowi). Szczyty fali powinny oscylować wokół **-6 dB**.  

**EN:** * **Host:** ALSA  
* **Recording Device:** `pulse` or `default`  
* **Channels:** 1 (Mono) — *USB dongles natively support only 1 input channel.* * **Recording Volume:** Set to approx. **25%** to prevent digital clipping. Aim for peaks around **-6 dB**.  

---

## 💾 4. Archiving Strategy / Strategia Archiwizacji  

**PL (Zasada Master & Proxy):** 1.  **MASTER (Archiwum):** Eksportuj do formatu **FLAC** (bezstratny).  
    * *Dlaczego:* 50% mniejszy niż WAV, 0% straty jakości. Idealny do późniejszej obróbki (odszumiania).  
2.  **PROXY (Użytkowy):** Konwertuj do **MP3**.  
    * *Bitrate:* 320 kbps CBR (Constant Bitrate).  
    * *Zastosowanie:* Telefon, auto, codzienne słuchanie.  

**EN (Master & Proxy Principle):** 1.  **MASTER (Archive):** Export to **FLAC** (Lossless).  
    * *Why:* 50% smaller than WAV, 0% quality loss. Perfect for future processing.  
2.  **PROXY (Listening):** Convert to **MP3**.  
    * *Bitrate:* 320 kbps CBR.  
    * *Use Case:* Phone, car, daily listening.  

---

## 📝 5. Quick Workflow Summary / Szybka Ściąga  

**PL:** 1. Wepnij kartę, podłącz Walkmana.  
2. Odpal Audacity, ustaw głośność na **25%**.  
3. Wciśnij **Record** ➔ Włącz **Play** na Walkmanie.  
4. Sprawdź w `pavucontrol` czy sygnał idzie z **KT USB**.  
5. Po zakończeniu: Zapisz Projekt (`.aup3`) ➔ Eksportuj (**FLAC/MP3**).  

**EN:** 1. Plug in the card, connect the Walkman.  
2. Open Audacity, set gain to **25%**.  
3. Press **Record** ➔ Press **Play** on Walkman.  
4. Verify source in `pavucontrol` (must be **KT USB**).  
5. Finish: Save Project (`.aup3`) ➔ Export (**FLAC/MP3**).  


