#!/bin/bash

# Script de test pour le webhook de transcription n8n
# Usage: ./test-webhook.sh [gemini|whisper] [url_youtube]

METHOD="${1:-whisper}"
YOUTUBE_URL="${2:-https://www.youtube.com/watch?v=dQw4w9WgXcQ}"

# URL du webhook n8n (à adapter selon votre configuration)
WEBHOOK_URL="${N8N_WEBHOOK_URL:-https://n8n.chnnlcrypto.cloud/webhook/transcribe}"

echo "🧪 Test du workflow de transcription"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Méthode    : $METHOD"
echo "URL YouTube: $YOUTUBE_URL"
echo "Webhook    : $WEBHOOK_URL"
echo ""

# Préparer le payload JSON
PAYLOAD=$(cat <<EOF
{
  "method": "$METHOD",
  "youtube_url": "$YOUTUBE_URL"
}
EOF
)

echo "📤 Envoi de la requête..."
echo ""

# Envoyer la requête avec curl
RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$WEBHOOK_URL" \
  -w "\nHTTP_CODE:%{http_code}\n")

# Extraire le code HTTP
HTTP_CODE=$(echo "$RESPONSE" | grep "HTTP_CODE:" | cut -d: -f2)
BODY=$(echo "$RESPONSE" | sed '/HTTP_CODE:/d')

echo "📥 Réponse reçue (Code HTTP: $HTTP_CODE)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

if [ "$HTTP_CODE" = "200" ]; then
  echo "✅ Succès !"
  echo "$BODY" | jq '.' 2>/dev/null || echo "$BODY"
else
  echo "❌ Erreur"
  echo "$BODY"
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
