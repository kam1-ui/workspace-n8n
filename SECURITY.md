# Sécurité - Workspace n8n MCP

## 🔒 Gestion des secrets

### Fichiers sensibles

Les secrets sont stockés dans `.env.mcp` et **ne doivent JAMAIS être commités** dans Git.

**Fichiers à protéger** :
- `.env.mcp` - Secrets MCP (token, clé API n8n)
- `.vscode/settings.json` - Configuration locale VSCode

**Fichiers sûrs** (peuvent être commités) :
- `.env.mcp.example` - Template sans secrets
- `docker-compose-mcp.yml` - Configuration sans secrets

### Configuration actuelle

```bash
# Fichier : .env.mcp
AUTH_TOKEN=<token_bearer>
N8N_API_KEY=<cle_api_n8n>
N8N_API_URL=https://n8n.chnnlcrypto.cloud
BASE_URL=https://mcp.chnnlcrypto.cloud
```

## 🔐 Régénération des secrets

### Token Bearer MCP

Générer un nouveau token :

```bash
openssl rand -base64 32
```

Mettre à jour :
1. `.env.mcp` → `AUTH_TOKEN=<nouveau_token>`
2. `.vscode/settings.json` → Header Authorization
3. Redémarrer MCP : `docker compose -f docker-compose-mcp.yml up -d`

### Clé API n8n

1. Connectez-vous à https://n8n.chnnlcrypto.cloud
2. Allez dans **Settings** → **API**
3. Créez une nouvelle **API Key**
4. Mettez à jour `.env.mcp` → `N8N_API_KEY=<nouvelle_cle>`
5. Redémarrer MCP : `docker compose -f docker-compose-mcp.yml up -d`

## ✅ Vérifications de sécurité

### Vérifier que .env.mcp est bien ignoré

```bash
git status
# .env.mcp ne doit PAS apparaître dans les fichiers à committer
```

### Vérifier les permissions

```bash
chmod 600 .env.mcp
# Seul le propriétaire peut lire/écrire
```

### Audit des secrets exposés

```bash
# Vérifier qu'aucun secret n'est dans docker-compose
grep -i "token\|key" docker-compose-mcp.yml
# Devrait retourner uniquement des références à variables d'environnement
```

## 🚨 En cas de fuite de secrets

### Si un secret a été commité dans Git

1. **NE PAS** simplement supprimer le fichier dans un nouveau commit
2. Révoquer IMMÉDIATEMENT le secret :
   - Token Bearer → Régénérer
   - Clé API n8n → Révoquer dans n8n UI
3. Nettoyer l'historique Git :
   ```bash
   git filter-branch --tree-filter 'rm -f .env.mcp' HEAD
   git push --force
   ```
4. Générer de nouveaux secrets

### Si un secret est exposé publiquement

1. **Révoquer immédiatement** tous les secrets
2. Régénérer de nouveaux secrets
3. Vérifier les logs n8n pour des accès suspects
4. Changer les mots de passe liés si nécessaire

## 📋 Checklist de sécurité

- [ ] `.env.mcp` est dans `.gitignore`
- [ ] `.env.mcp` a les permissions 600
- [ ] Aucun secret dans `docker-compose-mcp.yml`
- [ ] `.env.mcp.example` ne contient aucun vrai secret
- [ ] Token Bearer est unique et aléatoire
- [ ] Clé API n8n est active et valide
- [ ] Accès HTTPS uniquement (pas de HTTP)
- [ ] Certificats SSL valides

## 🔄 Rotation des secrets (recommandé)

**Fréquence** : Tous les 90 jours

1. Générer nouveaux secrets
2. Mettre à jour `.env.mcp`
3. Redémarrer services
4. Vérifier fonctionnement
5. Révoquer anciens secrets

---
*Mis à jour le 2025-12-20*
