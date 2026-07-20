#!/usr/bin/python3
import http.client
import json

HOST = "api.open-meteo.com"
PATH = "/v1/forecast?latitude=52.23&longitude=21.01&current=temperature_2m,apparent_temperature,wind_speed_10m,wind_direction_10m,weather_code&wind_speed_unit=kmh"

def get_wind_arrow(deg):
    arrows = ['↑', '↗', '→', '↘', '↓', '↙', '←', '↖']
    return arrows[int((deg + 22.5) % 360 / 45)]

try:
    conn = http.client.HTTPSConnection(HOST, timeout=10)
    conn.request("GET", PATH, headers={"User-Agent": "Mozilla/5.0"})
    response = conn.getresponse()
    
    if response.status == 200:
        data = json.loads(response.read().decode())['current']
        temp = round(data['temperature_2m'])
        felt = round(data['apparent_temperature'])
        w_speed = round(data['wind_speed_10m'])
        w_dir = data['wind_direction_10m']
        code = data['weather_code']
        
                 # Najbardziej podstawowe znaki Unicode (zestaw Basic) - v10-ok czcionki starsze DejaVu
       # if code <= 1: icon = "☀️"       # Słońce
      #  elif code <= 3: icon = "☁"      # Chmura
       # elif code == 45 or code == 48: icon = "≡" 
        # elif code >= 51 and code <= 67: icon = "☂" # Parasol - jedyny pewny znak deszczu
       # elif code >= 51 and code <= 67: icon = "🌦" # Chmura z deszczem (ten symbol jest bardzo stabilny - wymaga fontu Symbola)
       # elif code >= 71: icon = "❄"     # Śnieżynka
       # else: icon = "☁"

        # Te znaki w czcionce Symbola wyglądają spójnie i profesjonalnie:
        if code <= 1: icon = "🌣"       # Clear sky (U+1F323) - ładniejsze słońce w Symbola
        elif code <= 3: icon = "☁"      # Cloud (U+2601)
        elif code == 45 or code == 48: icon = "≡" # Fog (używamy symbolu identyczności)
        elif code >= 51 and code <= 67: icon = "🌦" # Rain (U+1F326) - chmura z deszczem i słońcem
        elif code >= 71: icon = "❄"     # Snowflake (U+2744)
        else: icon = "☁"

        arrow = get_wind_arrow(w_dir)
        # WAŻNE: Tu musi być spacja po {icon}
        wynik = f"{icon} {temp}°C ({felt}°C) {arrow} {w_speed}kmh"
        
        with open("/tmp/pogoda", "w", encoding="utf-8") as f:
            f.write(wynik)

    conn.close()
except:
    pass
