# 🚀 Workspace n8n MCP - Démarrage rapide

Bienvenue dans le workspace n8n MCP !

## 📝 Première utilisation

### Étape 1 : Obtenir votre clé API n8n

👉 **Lisez ce guide** : [GET_N8N_API_KEY.md](GET_N8N_API_KEY.md)

Résumé rapide :
1. Aller sur https://n8n.chnnlcrypto.cloud
2. Settings → API
3. Créer une clé API
4. La copier (elle ne sera visible qu'une fois !)

### Étape 2 : Ouvrir le workspace

```bash
code ~/workspace-n8n/workspace-n8n.code-workspace
```

### Étape 3 : Entrer la clé API

Au premier lancement, VS Code demandera :
```
Votre clé API n8n : _
```

Coller la clé obtenue à l'étape 1.

### Étape 4 : Vérifier les serveurs MCP

Dans VS Code :
- `Ctrl+Shift+P`
- Chercher : "Claude: Show MCP Status"
- Vérifier que les 2 serveurs sont actifs

## 🔧 Serveurs MCP disponibles

### 1. n8n-mcp
Accès à vos workflows n8n depuis Claude Code

**Outils disponibles** :
- Lister les workflows
- Exécuter un workflow
- Créer/modifier des workflows
- Gérer les credentials

### 2. sequential-thinking-http
Raisonnement étape par étape pour les LLMs

**Usage** : Problèmes complexes nécessitant une réflexion structurée

## 📚 Documentation

| Fichier | Description |
|---------|-------------|
| [README.md](README.md) | Documentation complète du workspace |
| [GET_N8N_API_KEY.md](GET_N8N_API_KEY.md) | Guide pour obtenir la clé API n8n |
| [INSTALL_SUMMARY.md](INSTALL_SUMMARY.md) | Résumé de l'installation |
| [TEST_INSTALLATION.md](TEST_INSTALLATION.md) | Tests et validation |

## 🆘 Besoin d'aide ?

### Le bridge Sequential Thinking ne répond pas

```bash
cd ~/servers/src/sequentialthinking
./bridge-manager.sh restart
./bridge-manager.sh test
```

### Erreur d'authentification n8n

1. Vérifier que votre clé API est valide
2. Redémarrer VS Code pour redemander la clé
3. Consulter [GET_N8N_API_KEY.md](GET_N8N_API_KEY.md)

### Les serveurs MCP n'apparaissent pas

1. Vérifier que l'extension Claude Code est installée
2. Redémarrer VS Code
3. Vérifier le fichier [.vscode/mcp.json](.vscode/mcp.json)

## ⚡ Commandes rapides

```bash
# Ouvrir le workspace
code ~/workspace-n8n/workspace-n8n.code-workspace

# Status du bridge Sequential Thinking
~/servers/src/sequentialthinking/bridge-manager.sh status

# Logs du bridge
~/servers/src/sequentialthinking/bridge-manager.sh logs 50

# Test de l'API n8n
curl -H "X-N8N-API-KEY: YOUR_KEY" \
     https://n8n.chnnlcrypto.cloud/api/v1/workflows
```

---

**Prêt à commencer ?** Ouvrez le workspace et suivez les étapes ci-dessus ! 🎉
