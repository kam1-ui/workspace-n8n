# Workspace n8n MCP

Workspace dédié à l'intégration des serveurs MCP (Model Context Protocol) avec VS Code et Claude Code.

## 🎯 Serveurs MCP configurés

### 1. n8n-mcp (Production)
- **URL** : https://n8n.chnnlcrypto.cloud/mcp
- **Type** : HTTP avec authentification Bearer
- **Token** : Demandé de manière interactive au démarrage

### 2. Sequential Thinking (Local)
- **URL** : http://127.0.0.1:3101/mcp
- **Port** : 3101
- **Manager** : `/home/ne0rignr/servers/src/sequentialthinking/bridge-manager.sh`

## 🚀 Démarrage rapide

### 1. Vérifier que Sequential Thinking est actif

```bash
cd ~/servers/src/sequentialthinking
./bridge-manager.sh status
```

Si inactif :
```bash
./bridge-manager.sh start
```

### 2. Ouvrir le workspace dans VS Code

```bash
code ~/workspace-n8n/workspace-n8n.code-workspace
```

### 3. Au premier lancement

VS Code vous demandera le token n8n-MCP :
- Entrer votre `AUTH_TOKEN` de n8n
- Le token sera stocké de manière sécurisée
- Ne sera jamais commité dans git

## 📁 Structure

```
workspace-n8n/
├── .vscode/
│   └── mcp.json              # Configuration MCP (serveurs n8n + Sequential Thinking)
├── .github/
│   └── copilot-instructions.md  # Instructions pour les assistants IA
├── CLAUDE.md                 # Instructions Claude Code spécifiques
├── workspace-n8n.code-workspace  # Fichier workspace VS Code
├── .gitignore                # Exclusions git (tokens, secrets)
└── README.md                 # Ce fichier
```

## 🔧 Commandes utiles

### Sequential Thinking Bridge

```bash
# Status
~/servers/src/sequentialthinking/bridge-manager.sh status

# Démarrer
~/servers/src/sequentialthinking/bridge-manager.sh start

# Arrêter
~/servers/src/sequentialthinking/bridge-manager.sh stop

# Logs en temps réel
~/servers/src/sequentialthinking/bridge-manager.sh follow
```

## 🔒 Sécurité

- ✅ Token n8n demandé de manière interactive (input sécurisé)
- ✅ Pas de secrets en dur dans les fichiers
- ✅ `.gitignore` configuré pour exclure les credentials
- ❌ Ne JAMAIS commiter de tokens/API keys

## 📚 Documentation

- [Sequential Thinking - Quick Start](/home/ne0rignr/servers/src/sequentialthinking/QUICK_START.md)
- [n8n-MCP - VS Code Setup](https://github.com/czlonkowski/n8n-mcp/blob/main/docs/VS_CODE_PROJECT_SETUP.md)
- [Claude Code - Documentation](https://docs.claude.ai/)

## 🆘 Dépannage

### Le bridge Sequential Thinking ne répond pas

```bash
cd ~/servers/src/sequentialthinking
./bridge-manager.sh restart
./bridge-manager.sh test
```

### VS Code ne détecte pas les serveurs MCP

1. Vérifier que l'extension Claude Code est installée
2. Redémarrer VS Code
3. Vérifier les logs : `Ctrl+Shift+P` → "Claude: Show Logs"

### Commande "Claude: Show MCP Status" introuvable

Si la palette retourne "No matching results" pour `Claude: Show MCP Status` :

- Ouvrez la vue Extensions (`Ctrl+Shift+X`) et vérifiez que `Claude Code` (ou une extension MCP équivalente) est installée et activée.
- Palette → `Developer: Show Running Extensions` pour confirmer que l'extension est démarrée.
- View → Output → sélectionnez le canal `Claude` (ou nom de l'extension) pour consulter les erreurs d'activation.
- Palette → `Developer: Toggle Developer Tools` → Console pour voir d'éventuelles exceptions.

Fallback rapide : démarrez le bridge local et redémarrez VS Code

```bash
cd ~/servers/src/sequentialthinking
./bridge-manager.sh start
```

Puis faites `Developer: Reload Window` et retentez la palette.

### Token n8n invalide

1. Vérifier le token dans votre instance n8n
2. Redémarrer VS Code pour redemander le token
3. Vérifier l'URL : https://n8n.chnnlcrypto.cloud/mcp

---

**Workspace créé le** : 2025-12-18
**Dernière mise à jour** : 2025-12-18
