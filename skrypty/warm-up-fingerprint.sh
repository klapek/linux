#!/bin/bash
# 1. Czekamy chwilę na pełny start pulpitu
sleep 5

# 2. Pukamy do czytnika - listowanie palców budzi chip ELAN
# Robimy to jako Twój użytkownik
fprintd-list $USER > /dev/null 2>&1

# 3. Dodatkowy strzał weryfikacją z krótkim timeoutem
timeout 0.5s fprintd-verify > /dev/null 2>&1
