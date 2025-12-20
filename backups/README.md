# 📦 Backups n8n - Guide rapide

## 🎯 C'est quoi ?

Ce dossier contient les **sauvegardes complètes** de votre installation n8n.
Chaque backup permet de restaurer n8n exactement comme il était au moment de la sauvegarde.

---

## 📁 Structure d'un backup

Chaque dossier de backup (ex: `2025-12-20_0845`) contient **3 fichiers** :

```
2025-12-20_0845/
├── n8n-postgres.sql.gz      # 💾 Base de données (executions, metadata)
├── n8n-data.tgz             # 📦 Workflows, credentials, configuration
└── .env.backup              # 🔐 Clé de chiffrement (CRITIQUE!)
```

### Détails des fichiers

| Fichier | Contenu | Importance |
|---------|---------|------------|
| **n8n-postgres.sql.gz** | Toutes les données PostgreSQL : historique d'exécutions, paramètres, etc. | ⭐⭐⭐ |
| **n8n-data.tgz** | Volume Docker : workflows, credentials chiffrées, fichiers de config | ⭐⭐⭐ |
| **.env.backup** | Variables d'environnement, notamment `N8N_ENCRYPTION_KEY` | ⭐⭐⭐⭐⭐ |

> **⚠️ IMPORTANT** : Sans la bonne `N8N_ENCRYPTION_KEY`, les credentials ne peuvent PAS être déchiffrées !

---

## 🚀 Comment créer un backup ?

```bash
cd /home/ne0rignr/workspace-n8n
./backup.sh
```

**Quand faire un backup ?**
- ✅ Avant toute mise à jour de n8n
- ✅ Avant toute modification importante des workflows
- ✅ Régulièrement (1x par semaine minimum si production)
- ✅ Après avoir créé des workflows importants

---

## 🔄 Comment restaurer un backup ?

### 1️⃣ Lister les backups disponibles

```bash
ls -lh /home/ne0rignr/workspace-n8n/backups/
```

### 2️⃣ Lancer la restauration

```bash
cd /home/ne0rignr/workspace-n8n
./restore.sh 2025-12-20_0845
```

> Remplacez `2025-12-20_0845` par le nom du backup que vous voulez restaurer

### 3️⃣ Confirmer

Le script vous demandera de taper **OUI** (en majuscules) pour confirmer.

---

## ⚠️ Avertissements

### Avant de restaurer

1. **La restauration ÉCRASE toutes les données actuelles**
   - Tous vos workflows actuels seront remplacés
   - Toutes les executions actuelles seront perdues
   - Si vous avez des modifications non sauvegardées, elles seront perdues

2. **Créez un backup de l'état actuel avant de restaurer**
   ```bash
   ./backup.sh  # Sauvegarder l'état actuel
   ./restore.sh 2025-12-20_0845  # Puis restaurer
   ```

3. **Vérifiez la clé de chiffrement**
   - Si `N8N_ENCRYPTION_KEY` est différente, les credentials ne fonctionneront pas
   - Le script `restore.sh` vous avertira automatiquement

---

## 🔐 La clé de chiffrement (N8N_ENCRYPTION_KEY)

### Pourquoi c'est critique ?

n8n chiffre toutes vos **credentials** (API keys, mots de passe, tokens) avec cette clé.
Sans la bonne clé, vos credentials sont **inutilisables**.

### Où la trouver ?

1. **Dans le fichier .env actuel** :
   ```bash
   grep N8N_ENCRYPTION_KEY /home/ne0rignr/workspace-n8n/.env
   ```

2. **Dans le backup** :
   ```bash
   grep N8N_ENCRYPTION_KEY backups/2025-12-20_0845/.env.backup
   ```

### Que faire si la clé est perdue ?

❌ **Il n'y a PAS de solution** - les credentials sont définitivement perdues.
✅ **Solution** : Gardez toujours une copie sécurisée de `.env` ou `.env.backup`

---

## 📊 Exemples pratiques

### Scénario 1 : Mise à jour de n8n

```bash
# 1. Backup avant mise à jour
./backup.sh

# 2. Mettre à jour n8n
docker compose pull
docker compose up -d

# 3. Si problème, restaurer
./restore.sh 2025-12-20_0845
```

### Scénario 2 : Migration vers un nouveau serveur

```bash
# Sur l'ancien serveur
./backup.sh
scp -r backups/2025-12-20_0845 user@nouveau-serveur:/home/ne0rignr/workspace-n8n/backups/

# Sur le nouveau serveur
cd /home/ne0rignr/workspace-n8n
./restore.sh 2025-12-20_0845
```

### Scénario 3 : Test de workflows risqué

```bash
# 1. Backup avant test
./backup.sh

# 2. Faire vos tests

# 3. Si ça casse, restaurer
./restore.sh 2025-12-20_0845
```

---

## 🛡️ Bonnes pratiques

### Sécurité

- ✅ **Ne jamais committer** les backups dans Git (contiennent des secrets)
- ✅ Stocker les backups sur un **disque externe** ou **cloud chiffré**
- ✅ Garder au minimum **3 backups** (actuel, semaine dernière, mois dernier)
- ✅ Tester la restauration **au moins 1x par mois** pour vérifier que ça fonctionne

### Organisation

- ✅ Créer un backup **avant chaque opération risquée**
- ✅ Nommer clairement si vous renommez (ex: `2025-12-20_avant-migration`)
- ✅ Supprimer les vieux backups après 30-60 jours (sauf les importants)

### Automatisation (optionnel)

Si vous voulez des backups automatiques quotidiens :

```bash
# Éditer crontab
crontab -e

# Ajouter cette ligne (backup tous les jours à 2h du matin)
0 2 * * * cd /home/ne0rignr/workspace-n8n && ./backup.sh >> /var/log/n8n-backup.log 2>&1
```

---

## 🆘 Aide & dépannage

### Le script backup.sh échoue

```bash
# Vérifier que les conteneurs sont actifs
docker ps | grep n8n

# Vérifier les permissions
ls -la /home/ne0rignr/workspace-n8n/backup.sh

# Réessayer avec plus de détails
bash -x ./backup.sh
```

### La restauration ne fonctionne pas

1. Vérifier que le backup est complet :
   ```bash
   ls -lh backups/2025-12-20_0845/
   # Doit afficher les 3 fichiers
   ```

2. Vérifier que Docker fonctionne :
   ```bash
   docker compose ps
   ```

3. Consulter les logs :
   ```bash
   docker compose logs n8n-main
   ```

---

## 📚 Ressources

- [PLAYBOOK-BACKUP-RESTORE.md](../PLAYBOOK-BACKUP-RESTORE.md) - Procédures détaillées
- Documentation n8n : https://docs.n8n.io

---

**Dernière mise à jour** : 2025-12-20
**Créé par** : Assistant Claude Code
