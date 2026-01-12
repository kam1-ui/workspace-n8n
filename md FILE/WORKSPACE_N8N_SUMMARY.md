# Résumé minimal — workspace `workspace-n8n`

Contient uniquement les informations système / accès / endpoints utiles trouvées dans ce workspace.

## Endpoints & URLs
- Interface n8n : https://n8n.chnnlcrypto.cloud
- Webhook exemple : https://n8n.chnnlcrypto.cloud/webhook/transcribe
- Whisper API (local) : http://localhost:9000 (endpoint health: /health)

## Conteneurs & services cités
- n8n (container Docker)
- whisper / whisper-api (container Docker)
- Services locaux de test : http://localhost:9000/transcribe

## Variables d'environnement importantes (extraits)
- N8N_HOST = n8n.chnnlcrypto.cloud
- N8N_PORT = 5678 (exemple)
- N8N_PROTOCOL = https
- WEBHOOK_URL = https://n8n.chnnlcrypto.cloud
- NODE_FUNCTION_ALLOW_BUILTIN = * (recommandé pour autoriser child_process dans certains workflows)

## Auth / clés
- Clé API n8n : attendue via `N8N_API_KEY` (référence dans `.vscode/mcp.json` : input `n8n-api-key`)
- `.gitignore` contient `.env`, `.env.local`, `*.token` — ne pas committer les secrets

## Ports récurrents
- Whisper API : 9000
- n8n (exposé via HTTPS) : 5678 (interne), routé via `n8n.chnnlcrypto.cloud`

## Emplacements et notes
- Workflows d'exemple et scripts de test se trouvent dans `Video Transcript n8n/` (tests curl, scripts shell).
- Vérifier `docker logs n8n` et `docker logs whisper-api` pour debugging.

---
Si vous voulez que j'ajoute des chemins précis de fichiers de clés ou que je copie un `.env.example` vers `.env` (avec placeholders), indiquez le fichier exact à traiter.