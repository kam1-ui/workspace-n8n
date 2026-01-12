# Référence rapide - Workspace n8n MCP

## 📁 Structure complète

```
~/workspace-n8n/
├── .vscode/
│   └── mcp.json                      # Config serveurs MCP
├── .github/
│   └── copilot-instructions.md       # Instructions IA
├── CLAUDE.md                         # Instructions Claude Code
├── START_HERE.md                     # 👈 Commencez ici
├── GET_N8N_API_KEY.md               # Guide clé API
├── README.md                         # Documentation complète
├── INSTALL_SUMMARY.md               # Résumé installation
├── TEST_INSTALLATION.md             # Tests et validation
├── REFERENCE.md                      # Ce fichier
├── .gitignore                        # Exclusions git
└── workspace-n8n.code-workspace     # Fichier workspace
```

## 🔌 Configuration MCP (.vscode/mcp.json)

```json
{
  "inputs": [
    {
      "id": "n8n-api-key",
      "description": "Votre clé API n8n",
      "password": true
    }
  ],
  "servers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["-y", "n8n-mcp"],
      "env": {
        "N8N_API_URL": "https://n8n.chnnlcrypto.cloud",
        "N8N_API_KEY": "${input:n8n-api-key}"
      }
    },
    "sequential-thinking-http": {
      "command": "npx",
      "args": ["-y", "mcp-remote", "http://127.0.0.1:3101/mcp"]
    }
  }
}
```

## 🛠️ Commandes essentielles

### Workspace
```bash
# Ouvrir le workspace
code ~/workspace-n8n/workspace-n8n.code-workspace

# Aller dans le dossier
cd ~/workspace-n8n
```

### Sequential Thinking Bridge
```bash
# Répertoire du bridge
cd ~/servers/src/sequentialthinking

# Status
./bridge-manager.sh status

# Démarrer
./bridge-manager.sh start

# Arrêter
./bridge-manager.sh stop

# Redémarrer
./bridge-manager.sh restart

# Tester
./bridge-manager.sh test

# Logs (50 dernières lignes)
./bridge-manager.sh logs 50

# Logs en temps réel
./bridge-manager.sh follow
```

### API n8n
```bash
# Tester la connexion (n8n requiert l'en-tête X-N8N-API-KEY)
curl -v -H "X-N8N-API-KEY: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YzcxNzBlZC1lOGZkLTQzMjYtYWY4OS0zOTM5YWI1YmVmYmIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MDUzNjYwfQ.skHm5mSo4yukPwnF3MoFH96uUQPn-otoNLH2NobAoLY" \
  https://n8n.chnnlcrypto.cloud/api/v1/workflows

# Recommandé : stocker la clé dans une variable d'environnement et l'utiliser
export N8N_API_KEY="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YzcxNzBlZC1lOGZkLTQzMjYtYWY4OS0zOTM5YWI1YmVmYmIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MDUzNjYwfQ.skHm5mSo4yukPwnF3MoFH96uUQPn-otoNLH2NobAoLY"
curl -v -H "X-N8N-API-KEY: $N8N_API_KEY" https://n8n.chnnlcrypto.cloud/api/v1/workflows

# Health check
curl https://n8n.chnnlcrypto.cloud/healthz
```

## 🔐 Variables d'environnement

| Variable | Valeur | Source |
|----------|--------|--------|
| `N8N_API_URL` | `https://n8n.chnnlcrypto.cloud` | `.vscode/mcp.json` |
| `N8N_API_KEY` | Demandé interactivement | Input VS Code |
| `MCP_MODE` | `stdio` | `.vscode/mcp.json` |
| `LOG_LEVEL` | `error` | `.vscode/mcp.json` |

## 🌐 URLs importantes

| Service | URL | Description |
|---------|-----|-------------|
| n8n Production | https://n8n.chnnlcrypto.cloud | Instance n8n principale |
| Sequential Thinking | http://127.0.0.1:3101 | Bridge local (health) |
| Sequential Thinking MCP | http://127.0.0.1:3101/mcp | Endpoint MCP |
| n8n API | https://n8n.chnnlcrypto.cloud/api/v1 | API REST n8n |

## 📦 Dépendances npm

Ces packages sont téléchargés via `npx` (pas d'installation locale requise) :

- **n8n-mcp** : Client MCP pour n8n
- **mcp-remote** : Bridge HTTP pour MCP stdio

## 🔍 Diagnostic

### Vérifier que tout fonctionne

```bash
# 1. Bridge Sequential Thinking actif ?
cd ~/servers/src/sequentialthinking && ./bridge-manager.sh status

# 2. Endpoint health répond ?
curl http://127.0.0.1:3101/health

# 3. n8n accessible ?
curl -I https://n8n.chnnlcrypto.cloud

# 4. VS Code + extension Claude Code ?
code --list-extensions | grep anthropic.claude-code
```

### Erreurs communes

| Erreur | Cause | Solution |
|--------|-------|----------|
| `Connection refused` (127.0.0.1:3101) | Bridge arrêté | `./bridge-manager.sh start` |
| `Unauthorized` (401) | Clé API invalide | Vérifier la clé dans n8n |
| `SSL Certificate Invalid` | Certificat n8n invalide | Accepter temporairement ou corriger le cert |
| `Serveur MCP non détecté` | VS Code n'a pas chargé mcp.json | Redémarrer VS Code |

## 📚 Liens utiles

- [n8n Documentation](https://docs.n8n.io/)
- [n8n API Reference](https://docs.n8n.io/api/)
- [n8n-MCP GitHub](https://github.com/czlonkowski/n8n-mcp)
- [Sequential Thinking MCP](https://github.com/modelcontextprotocol/servers/tree/main/src/sequentialthinking)
- [Claude Code Documentation](https://docs.claude.ai/)

## 🎯 Cas d'usage typiques

### Lister les workflows n8n
Via Claude Code :
```
Liste tous mes workflows n8n actifs
```

### Exécuter un workflow
```
Execute le workflow "Test API" avec les paramètres {"user": "test"}
```

### Raisonnement complexe
```
Utilise sequential thinking pour analyser la meilleure architecture 
pour un système de notifications multi-canaux
```

## 🔄 Workflow de mise à jour

Si une nouvelle version de n8n-mcp ou mcp-remote est disponible :

```bash
# Forcer le téléchargement de la dernière version
npx -y n8n-mcp@latest
npx -y mcp-remote@latest

# Puis redémarrer VS Code
```

## 📝 Notes importantes

1. **Clé API n8n** : Ne JAMAIS la commiter dans git
2. **Bridge Sequential Thinking** : Doit être actif pour fonctionner
3. **npx -y** : Le flag `-y` évite les prompts de confirmation
4. **MCP_MODE: stdio** : Obligatoire pour Claude Code
5. **Certificat SSL** : Problème connu à corriger sur l'instance n8n

---

**Dernière mise à jour** : 2025-12-18
**Version** : 1.0
**Serveur** : VPS 72.60.175.177 (ne0rignr)
