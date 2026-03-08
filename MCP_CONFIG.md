# Configuration MCP pour n8n

## 📋 Résumé

Le serveur MCP HTTP est déployé et accessible pour contrôler n8n via le Model Context Protocol.
**Architecture** : Nginx (proxy SSL) → MCP Server (Docker) → n8n API

## 🔗 URLs

- **Serveur MCP** : https://mcp.chnnlcrypto.cloud
- **Health check** : https://mcp.chnnlcrypto.cloud/health
- **Endpoint MCP** : https://mcp.chnnlcrypto.cloud/mcp
- **Instance n8n** : https://n8n.chnnlcrypto.cloud

## 🔐 Authentification

### Token MCP (Bearer)
```
<VOTRE_AUTH_TOKEN>
```

### Clé API n8n
```
<VOTRE_N8N_API_KEY>
```

## 🐳 Gestion Docker

### Démarrer
```bash
cd /home/ne0rignr/workspace-n8n
docker-compose -f docker-compose-mcp.yml up -d
```

### Arrêter
```bash
docker-compose -f docker-compose-mcp.yml down
```

### Logs
```bash
docker logs -f n8n-mcp-server
```

### Redémarrer
```bash
docker restart n8n-mcp-server
```

## 🧪 Tests

### Health check
```bash
curl -H "Authorization: Bearer <VOTRE_AUTH_TOKEN>" \
  https://mcp.chnnlcrypto.cloud/health
```

### Liste des workflows n8n
```bash
curl -H "X-N8N-API-KEY: <VOTRE_N8N_API_KEY>" \
  https://n8n.chnnlcrypto.cloud/api/v1/workflows
```

## 📝 Configuration VSCode

Fichier : `.vscode/settings.json`

```json
{
  "mcpServers": {
    "n8n": {
      "command": "npx",
      "args": [
        "-y",
        "mcp-remote",
        "https://mcp.chnnlcrypto.cloud/mcp",
        "--header",
        "Authorization: Bearer <VOTRE_AUTH_TOKEN>"
      ]
    }
  }
}
```

## 🔄 Workflow importé

- **ID** : `R31TqM6ks1cBpLkA`
- **Nom** : Transcription YouTube - Gemini + Whisper
- **Active** : Oui
- **MCP disponible** : Oui

## 🌐 DNS

```
Type: A
Name: mcp
Domain: chnnlcrypto.cloud
Value: 72.60.175.177
TTL: 300s
```

## 📚 Documentation

- [n8n-mcp GitHub](https://github.com/czlonkowski/n8n-mcp)
- [HTTP Deployment](https://github.com/czlonkowski/n8n-mcp/blob/main/docs/HTTP_DEPLOYMENT.md)
- [n8n API](https://docs.n8n.io/api/)

## ⚙️ Variables d'environnement (serveur MCP)

```env
MCP_MODE=http
USE_FIXED_HTTP=true
AUTH_TOKEN=<VOTRE_AUTH_TOKEN>
PORT=3000
HOST=0.0.0.0
LOG_LEVEL=info
TRUST_PROXY=1
BASE_URL=https://mcp.chnnlcrypto.cloud
N8N_API_URL=https://n8n.chnnlcrypto.cloud
N8N_API_KEY=<VOTRE_N8N_API_KEY>
```

## 🏗️ Infrastructure

### Architecture actuelle (2025-12-20)

```
Internet (HTTPS)
    ↓
Nginx (ports 80/443)
    ├── n8n.chnnlcrypto.cloud → 127.0.0.1:5678 (n8n Docker)
    └── mcp.chnnlcrypto.cloud → 127.0.0.1:3000 (MCP Docker)
```

Architecture: Nginx (système) → conteneurs Docker.

### Composants

- **Nginx** : Reverse proxy système avec SSL Let's Encrypt
- **n8n** : Version 1.123.6 (queue mode + worker)
  - PostgreSQL 15 + Redis 7
  - Port local : 5678
- **MCP Server** : Version 2.30.1 (http-fixed mode)
  - Port local : 3000
  - Réseau : root_default

### Certificats SSL

- n8n : `/etc/letsencrypt/live/n8n.chnnlcrypto.cloud/`
- MCP : `/etc/letsencrypt/live/mcp.chnnlcrypto.cloud/`
- Renouvellement automatique via Certbot

## ✅ Statut actuel

- ✅ Serveur MCP HTTP déployé et actif
- ✅ DNS configuré et propagé
- ✅ Certificat SSL Let's Encrypt valide (expire 2026-03-20)
- ✅ Nginx reverse proxy configuré
- ✅ Port 3000 exposé sur localhost
- ✅ Health check fonctionnel
- ✅ Endpoint MCP opérationnel
- ✅ VSCode configuré avec mcp-remote
- ✅ Authentification Bearer token active
- ✅ 17 outils MCP disponibles

## 🧪 Tests de validation

### Health check
```bash
curl https://mcp.chnnlcrypto.cloud/health
# {"status":"ok","mode":"http-fixed","version":"2.30.1",...}
```

### Liste des outils MCP
```bash
curl -H "Authorization: Bearer <VOTRE_AUTH_TOKEN>" \
  -H "Content-Type: application/json" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' \
  https://mcp.chnnlcrypto.cloud/mcp
```

### Test depuis VSCode
La configuration `.vscode/settings.json` utilise `mcp-remote` pour se connecter au serveur MCP.

---
*Mis à jour le 2025-12-20 par Claude Code*
