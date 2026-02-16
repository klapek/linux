#!/bin/bash

# --- KONFIGURACJA ---
APP_NAME="GeminiAI"
ID="GeminiAI5568"
SAFE_DIR="$HOME/.mozilla/firefox/$ID"
ICE_DIR="$HOME/.local/share/ice/firefox/$ID"
URL="https://gemini.google.com"

echo "🚀 Rozpoczynam profesjonalną konfigurację profilu dla $APP_NAME..."

# 1. Czyszczenie i przygotowanie struktury
rm -rf "$SAFE_DIR"
rm -rf "$ICE_DIR"
mkdir -p "$SAFE_DIR/chrome"
mkdir -p "$(dirname "$ICE_DIR")"

# 2. Tworzenie linku symbolicznego (Ominięcie AppArmor/Sandboxa)
ln -s "$SAFE_DIR" "$ICE_DIR"
echo "✅ Połączono: $ICE_DIR -> $SAFE_DIR"

# 3. Inicjalizacja profilu (generowanie plików bazowych)
echo "⏳ Inicjalizacja profilu (poczekaj chwilę)..."
firefox --profile "$SAFE_DIR" --no-remote "$URL" &
sleep 6
pkill -f "$SAFE_DIR"

# 4. Tworzenie pliku userChrome.css (Ukrycie interfejsu przeglądarki)
echo "🎨 Tworzenie interfejsu bezramkowego (userChrome.css)..."
cat <<EOF > "$SAFE_DIR/chrome/userChrome.css"
/* Ukrywa pasek kart i pasek adresu dla efektu WebApp */
#nav-bar, 
#TabsToolbar, 
#PersonalToolbar {
    visibility: collapse !important;
}

/* Usuwa obramowanie okna jeśli występuje */
#browser-panel {
    border: none !important;
}
EOF

# 5. Konfiguracja prefs.js
echo "⚙️ Optymalizacja ustawień..."
cat <<EOF >> "$SAFE_DIR/prefs.js"
user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
user_pref("browser.shell.checkDefaultBrowser", false);
user_pref("browser.startup.homepage", "$URL");
user_pref("browser.tabs.warnOnClose", false);
user_pref("datareporting.healthreport.uploadEnabled", false);
user_pref("browser.messaging-system.whatsNewPanel.enabled", false);
user_pref("browser.tabs.drawInTitlebar", true);
user_pref("browser.toolbarbuttons.introduced.pocket-button", false);
user_pref("extensions.pocket.enabled", false);
user_pref("identity.fxaccounts.enabled", false);
user_pref("browser.anchor_color", "#1a73e8");
EOF

echo "------------------------------------------------------------"
echo "✨ GOTOWE! Gemini jest teraz prawdziwą aplikacją."
echo "------------------------------------------------------------"
echo "Użyj tej komendy w swoim Web App Managerze:"
echo "sh -c 'XAPP_FORCE_GTKWINDOW_ICON=\"web-google\" firefox --class WebApp-$ID --name WebApp-$ID --profile $ICE_DIR --no-remote \"$URL\"'"
