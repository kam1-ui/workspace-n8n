# Workspace n8n avec MCP

Instance n8n avec support MCP (Model Context Protocol) pour contrôle via Claude Code.

## 🚀 Services actifs

- **n8n** : https://n8n.chnnlcrypto.cloud (v1.123.6)
- **MCP** : https://mcp.chnnlcrypto.cloud (v2.30.1)

## Version installée

- **n8n** : 1.123.6 (queue mode + worker)
- **PostgreSQL** : 15
- **Redis** : 7-alpine
- **MCP Server** : 2.30.1 (http-fixed mode)
- **Support MCP** : ✅ 17 outils disponibles

## Démarrage rapide

```bash
cd /home/ne0rignr/workspace-n8n
docker-compose up -d
```

## Gestion des services

### Démarrer

```bash
docker-compose up -d
```

### Arrêter

```bash
docker-compose down
```

### Redémarrer

```bash
docker-compose restart
```

### Voir les logs

```bash
# Tous les services
docker-compose logs -f

# Seulement n8n
docker-compose logs -f n8n

# Seulement PostgreSQL
docker-compose logs -f postgres
```

### Vérifier l'état

```bash
docker-compose ps
```

## Mise à jour de version

### ⚠️ NE PAS mettre à jour vers 1.93.0+ (bug MCP)

Pour changer de version (si nécessaire) :

1. Édite [docker-compose.yml](docker-compose.yml)
2. Change `image: docker.n8n.io/n8nio/n8n:1.92.0` vers la version souhaitée
3. Applique les changements :

```bash
docker-compose pull
docker-compose down
docker-compose up -d
```

## Backup de la base de données

### Créer un backup

```bash
docker exec n8n-postgres pg_dump -U n8n n8n > backups/n8n-backup-$(date +%Y%m%d).sql
```

### Restaurer un backup

```bash
cat backups/n8n-backup-YYYYMMDD.sql | docker exec -i n8n-postgres psql -U n8n -d n8n
```

## Accès

- **Interface web** : http://72.60.175.177:5678
- **Webhooks** : http://72.60.175.177:5678/webhook/...

## Structure des dossiers

```
workspace-n8n/
├── docker-compose.yml          # Configuration Docker
├── README.md                   # Ce fichier
├── backups/                    # Backups PostgreSQL
│   └── n8n-backup-before-downgrade.sql
└── n8n gemini whisper/         # Workflows
    └── workflow-complet-gemini-whisper-final.json
```

## Credentials configurées

- **Gemini 2.0 Flash API** (Query Auth)
  - Type : HTTP Query Auth
  - Domaine : generativelanguage.googleapis.com

## Workflows disponibles

### Transcription Video - Gemini - Whisper

Workflow double méthode pour transcrire des vidéos YouTube :

- **Méthode Gemini** : Utilise Gemini 2.0 Flash API
- **Méthode Whisper** : Utilise serveur Whisper local (port 9000)

**Endpoint** : `POST http://72.60.175.177:5678/webhook/transcribe`

**Payload** :

```json
{
  "youtube_url": "https://www.youtube.com/watch?v=...",
  "method": "gemini" // ou "whisper"
}
```

## Dépannage

### Les nœuds affichent "?" dans le workflow

1. Vide le cache du navigateur (Ctrl+Shift+R)
2. Vérifie que les credentials sont créées
3. Vérifie la version n8n : `docker exec n8n-main n8n --version`

### n8n ne démarre pas

```bash
# Voir les logs
docker-compose logs n8n

# Vérifier PostgreSQL
docker-compose logs postgres
```

### Reset complet (⚠️ EFFACE TOUT)

```bash
docker-compose down -v
docker-compose up -d
```

## 🔧 Support MCP

Le serveur MCP est configuré et accessible via Claude Code CLI.

### Configuration VSCode

Voir [`.vscode/settings.json`](.vscode/settings.json) pour la configuration MCP.

### Outils disponibles (17)

- Gestion workflows (create, update, delete, validate, autofix)
- Templates n8n (search, get, deploy)
- Exécution et tests
- Documentation nodes (search, get, validate)
- Gestion versions
- Et plus...

### Documentation complète

Voir [MCP_CONFIG.md](MCP_CONFIG.md) pour la configuration détaillée.

## 🏗️ Architecture

```
Internet (HTTPS)
    ↓
Nginx (ports 80/443) - SSL Let's Encrypt
    ├── n8n.chnnlcrypto.cloud → 127.0.0.1:5678 (n8n Docker)
    │   ├── n8n-main (queue mode)
    │   ├── n8n-worker (concurrency: 2)
    │   ├── PostgreSQL 15
    │   └── Redis 7
    └── mcp.chnnlcrypto.cloud → 127.0.0.1:3000 (MCP Docker)
        └── n8n API (17 outils)
```

## Changelog

- **2025-12-20** : Configuration MCP HTTPS avec Nginx + SSL
- **2025-12-20** : Exposition port 3000 pour MCP
- **2025-12-20** : Certificat SSL MCP (expire 2026-03-20)
- **2024-12-19** : Mise à jour vers n8n 1.123.6
- **2024-12-19** : Ajout credential Gemini 2.0 Flash API

---

## Gestion des variables d'environnement et configuration Nginx

Toutes les variables sensibles et spécifiques à l'environnement sont centralisées dans le fichier `.env` (voir `.env.example`).

### Génération automatique de la configuration Nginx

Utilisez le template `nginx-n8n.conf.template` pour générer le fichier final Nginx avec vos variables d'environnement :

```bash
# Exporter les variables d'environnement depuis .env
set -a
source .env
set +a

# Générer le fichier Nginx final
envsubst < nginx-n8n.conf.template > nginx-n8n.conf
```

- Placez le fichier généré dans `/etc/nginx/sites-available/` puis activez-le avec un lien symbolique dans `/etc/nginx/sites-enabled/`.
- Redémarrez Nginx pour appliquer la configuration :

```bash
sudo systemctl reload nginx
```

### Bonnes pratiques

- Ne jamais committer le fichier `.env` (utilisez `.env.example` pour le partage).
- Documentez toutes les variables dans le README ou `.env.example` pour faciliter l'onboarding.
- Utilisez le template Nginx pour tous les environnements (dev, prod, staging).

---
