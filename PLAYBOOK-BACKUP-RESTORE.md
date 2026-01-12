PLAYBOOK — Sauvegarde & Restauration — workspace-n8n

But : procédures sûres et reproductibles pour sauvegarder et restaurer la stack n8n (Postgres, Redis, volumes n8n-data).

Important : avant toute restauration, notez la valeur de N8N_ENCRYPTION_KEY (/.env) — sinon les credentials chiffrés ne seront pas lisibles.

1. Sauvegarde manuelle (point-in-time)

- Arrêter temporairement les services (optionnel mais propre) :
  docker compose -f docker-compose.yml down

- Sauvegarder Postgres (dump compressé) :
  docker exec -t n8n-postgres pg*dumpall -c -U $POSTGRES_USER | gzip > /tmp/n8n-postgres-$(date +%F*%H%M).sql.gz

  # ou depuis l'hôte si vous préférez :

  docker run --rm --network container:n8n-postgres postgres:15 pg_dumpall -c -h localhost -U $POSTGRES_USER | gzip > /tmp/...

- Sauvegarder volume n8n-data (workflows, creds, config) :
  docker run --rm -v workspace-n8n*n8n-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar czf /backup/n8n-data-$(date +%F*%H%M).tgz ."

- Sauvegarder Redis (si vous utilisez persistence RDB/AOF) :
  docker exec n8n-redis redis-cli SAVE
  docker exec n8n-redis sh -c 'cp /data/dump.rdb /tmp/dump-$(date +%F_%H%M).rdb && chown 1000:1000 /tmp/*'
  docker cp n8n-redis:/tmp/dump-$(date +%F\_%H%M).rdb ./

- Rassembler métadonnées :
  - Copiez le fichier .env utilisé (ne jamais committer les secrets).
  - Notez la valeur de N8N_ENCRYPTION_KEY et DB password (stocker dans Vault ou fichier chiffré).

2. Restauration manuelle

- Arrêter la stack :
  docker compose down

- Restaurer volume n8n-data :
  docker run --rm -v workspace-n8n_n8n-data:/data -v $(pwd):/backup alpine sh -c "cd /data && tar xzf /backup/n8n-data-YYYY-MM-DD_HHMM.tgz"

  # Vérifier permissions : chmod 600 /data/config si nécessaire (voir note).

- Restaurer Postgres :
  gunzip -c /path/to/n8n-postgres-YYYY-MM-DD_HHMM.sql.gz | docker exec -i n8n-postgres psql -U $POSTGRES_USER

  # Si la base n'existe pas, créer puis importer.

- Restaurer Redis: copy back dump.rdb into redis container /data and restart redis.

- Remettre .env à jour (N8N_ENCRYPTION_KEY doit être identique à celui présent dans /data/config si vous restaurez le volume n8n-data).

- Démarrer la stack :
  docker compose up -d

- Vérifier logs et l'accès :
  docker compose logs --tail 100 n8n-main n8n-worker n8n-postgres n8n-redis

3. Automatisation simple (cron)

Exemple (sauvegarde quotidienne à 02:00, conserve 7 jours) :

0 2 \* \* \* /usr/local/bin/n8n-backup.sh >/var/log/n8n-backup.log 2>&1

Contenu minimal de n8n-backup.sh :

#!/usr/bin/env bash
set -euo pipefail
OUTDIR=/backups/n8n/$(date +%F)
mkdir -p "$OUTDIR"

# Postgres dump

docker exec -t n8n-postgres pg_dumpall -c -U "$POSTGRES_USER" | gzip > "$OUTDIR/n8n-postgres-$(date +%H%M).sql.gz"

# n8n-data

docker run --rm -v workspace-n8n_n8n-data:/data -v "$OUTDIR":/backup alpine sh -c "cd /data && tar czf /backup/n8n-data-$(date +%H%M).tgz ."

# rotate: supprimer >7 jours

find /backups/n8n -maxdepth 2 -type f -mtime +7 -delete

Rendre exécutable: chmod +x /usr/local/bin/n8n-backup.sh

4. Vérifications post-restore

- Se connecter à l'UI n8n et vérifier que les credentials apparaissent.
- Vérifier que les workflows sont listés et déclenchables.
- Contrôler que les jobs en file (queue) sont correctement consommés.

5. Notes & pièges connus

- N8N_ENCRYPTION_KEY : si différent, les credentials chiffrés ne seront pas déchiffrables. Toujours sauvegarder la clé avec les backups (sécurisé).
- Permissions du fichier config : n8n signale parfois "Permissions 0644... trop larges" ; appliquer chmod 600 sur /data/config peut réduire les warnings, mais n8n recrée parfois le fichier à 0644 au démarrage. Considérez N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true pour alerter/forcer ou ignorer si vous acceptez le comportement.
- Testez la restauration régulièrement dans un environnement isolé.

6. Restauration d'urgence (sur nouveau host)

- Préparer .env avec mêmes valeurs N8N_ENCRYPTION_KEY et DB creds.
- Démarrer Postgres et Redis, restaurer dumps, restaurer volume n8n-data, puis docker compose up.

---

Fichier créé automatiquement par l'assistant. Place: /home/ne0rignr/workspace-n8n/PLAYBOOK-BACKUP-RESTORE.md
