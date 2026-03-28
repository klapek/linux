# [PL/EN] Knowledge Pack: Analog to Digital Archiving (Cassette Edition)
**Status:** Verified & Stable (2026-03-21)  
**Platform:** Linux (ThinkPad / ALSA / PulseAudio)  
**Hardware:** Sony Walkman + UGREEN USB Sound Card (KTMicro)  

---

## 🛠️  1. Hardware Setup / Konfiguracja Sprzętowa  

**PL:** * **Interfejs:** Użyj karty USB UGREEN (chipset KTMicro). Jest izolowana od szumów płyty głównej.  
* **Połączenie:** Walkman (wyjście słuchawkowe) ➔ Kabel Jack-Jack 3.5mm ➔ Karta USB (wejście mikrofonowe - różowe).  
* **Izolacja:** Połóż Walkmana na miękkiej powierzchni (podkładka/materiał) z dala od głośników laptopa, aby uniknąć sprzężeń mechanicznych ("pacania").  

**EN:** * **Interface:** Use UGREEN USB Sound Card (KTMicro chipset) for better isolation from motherboard noise.  
* **Connection:** Walkman (Headphone Out) ➔ 3.5mm Jack-Jack Cable ➔ USB Card (Mic-In / Pink port).  
* **Isolation:** Place the Walkman on a soft surface away from laptop speakers to prevent mechanical feedback/microphonics.  

---

## ⚙️  2. Linux System Configuration / Konfiguracja Systemu  

**PL:** * **Terminal:** Wyłącz systemowe mostki audio przed nagrywaniem:  
    ```bash
    pactl unload-module module-loopback
    ```
* **pavucontrol:** Po rozpoczęciu nagrywania w Audacity, w zakładce **Nagrywanie** wybierz jako źródło: `KT USB Audio Mono` lub po prostu `pulse` (nie zawsze widać KT USB).  

**EN:** * **Terminal:** Unload audio bridges before recording:  
    ```bash
    pactl unload-module module-loopback
    ```
* **pavucontrol:** Once recording starts in Audacity, go to the **Recording** tab and set the source to: `KT USB Audio Mono` or just `pulse`.  

---

## 🎙️  3. Audacity Settings / Ustawienia Audacity  

**PL:** * **Host:** ALSA  
* **Urządzenie nagrywania:** `pulse` lub `default`  
* **Kanały:** 1 (Mono) — *Karty USB typu 'dongle' natywnie obsługują tylko 1 kanał wejściowy.* * **Głośność wejściowa:** Ustaw na ok. **25%** (zapobiega to przesterowaniu/clippingowi). Szczyty fali powinny oscylować wokół **-6 dB** (nie zawsze da radę ustawić poprzez Audacity - w takiej sytuacji ustaw głośność mikrofonu dla `KT USB Audio` w ustawieniach dźwięku lub z konsoli w `AlsaMixer` do 40%.).  
**Odtwarzanie:** Z automatu ustawia na `KT USB Audio - Headphones` i nic nie słychać ;) - trzeba przestawić wyjście dźwięku na `Meteor Lake` w preferencjach dźwięku MATE.

**EN:** * **Host:** ALSA  
* **Recording Device:** `pulse` or `default`  
* **Channels:** 1 (Mono) — *USB dongles natively support only 1 input channel.* * **Recording Volume:** Set to approx. **25%** to prevent digital clipping. Aim for peaks around **-6 dB**.  

---

## 💾  4. Archiving Strategy / Strategia Archiwizacji  

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

## 🎵  5. Normalizacja Poziomu Głośności (Cassette-to-Digital)

**Cel (PL):**
Ujednolicenie głośności nagrań z kaset magnetofonowych z istniejącą biblioteką cyfrową (YouTube-rips, CD). Zapewnienie komfortu odsłuchu w środowisku o wysokim szumie tła (samochód).

**Procedura (PL):**
1. Nagrywanie surowego sygnału (Raw) z pikiem w okolicy -6 dB (strefa zielona).
2. Po zakończeniu nagrania: `Efekt -> Głośność i kompresja -> Normalizuj`.
3. Ustawienie szczytowej amplitudy na: `-3.0 dB`.

**Dlaczego -3.0 dB? (PL):**
- Zgodność: Większość plików z YouTube/Downloaderów ma piki w zakresie -1 do -4 dB.
- Headroom: Pozostawia 3 dB marginesu na błędy kwantyzacji podczas kompresji do MP3.
- Dynamika: Chroni przed cyfrowym przesterowaniem (clipping) przy jednoczesnym podbiciu odczuwalnej głośności.

---

**Objective (EN):**
Standardizing loudness levels for cassette tape rips to match existing digital libraries (YouTube, CD). Ensuring consistent playback volume in high-noise environments (e.g., car cabin).

**Procedure (EN):**
1. Record raw signal with peaks around -6 dB (Green zone).
2. Post-recording: `Effect -> Volume and Compression -> Normalize`.
3. Set Peak Amplitude to: `-3.0 dB`.

**Why -3.0 dB? (EN):**
- Compatibility: Matches the average peak levels of YouTube-sourced MP3s (-1 to -4 dB).
- Headroom: Provides a 3 dB safety margin to prevent inter-sample peaks during MP3 encoding.
- Fidelity: Enhances perceived loudness without risking digital clipping or flat-lining the dynamics.

**Technical (Cross-Language):**
- Format: 32-bit float (internal Audacity processing).
- Target Peak: -3.0 dBFS.
- Dithering: Not required if exporting to 24-bit/32-bit FLAC.

---

## 📝  6. Quick Workflow Summary / Szybka Ściąga  

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


