#!/bin/bash

# Test du webhook en PRODUCTION
WEBHOOK_URL="https://n8n.chnnlcrypto.cloud/webhook/transcribe"
METHOD="${1:-whisper}"
YOUTUBE_URL="${2:-https://www.youtube.com/watch?v=dQw4w9WgXcQ}"

echo "🧪 Test du workflow de transcription (PRODUCTION)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Méthode    : $METHOD"
echo "URL YouTube: $YOUTUBE_URL"
echo "Webhook    : $WEBHOOK_URL"
echo ""

PAYLOAD=$(cat <<PAYLOAD_EOF
{
  "method": "$METHOD",
  "youtube_url": "$YOUTUBE_URL"
}
PAYLOAD_EOF
)

echo "📤 Envoi de la requête..."
echo ""

RESPONSE=$(curl -s -X POST \
  -H "Content-Type: application/json" \
  -d "$PAYLOAD" \
  "$WEBHOOK_URL" \
  -w "\nHTTP_CODE:%{http_code}\n")

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
