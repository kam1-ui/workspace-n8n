#!/usr/bin/env bash
# Script de backup manuel pour n8n
# Usage: ./backup.sh

set -euo pipefail

# Configuration
WORKSPACE_DIR="/root/workspace-n8n"
BACKUP_BASE_DIR="$WORKSPACE_DIR/backups"
BACKUP_DIR="$BACKUP_BASE_DIR/$(date +%F_%H%M)"

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}=== Backup n8n - $(date) ===${NC}\n"

# Créer le répertoire de backup
echo -e "${GREEN}[1/4]${NC} Création du répertoire de backup..."
mkdir -p "$BACKUP_DIR"
echo "      → $BACKUP_DIR"

# Backup Postgres
echo -e "\n${GREEN}[2/4]${NC} Backup de la base de données Postgres..."
docker exec -t n8n-postgres pg_dumpall -c -U n8n | gzip > "$BACKUP_DIR/n8n-postgres.sql.gz"
SIZE_PG=$(du -h "$BACKUP_DIR/n8n-postgres.sql.gz" | cut -f1)
echo "      → n8n-postgres.sql.gz ($SIZE_PG)"

# Backup volume n8n-data
echo -e "\n${GREEN}[3/4]${NC} Backup du volume n8n-data (workflows, credentials)..."
docker run --rm \
  -v workspace-n8n_n8n-data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine sh -c "cd /data && tar czf /backup/n8n-data.tgz ."
SIZE_DATA=$(du -h "$BACKUP_DIR/n8n-data.tgz" | cut -f1)
echo "      → n8n-data.tgz ($SIZE_DATA)"

# Backup .env (sécurisé)
echo -e "\n${GREEN}[4/4]${NC} Backup du fichier .env..."
if [ -f "$WORKSPACE_DIR/.env" ]; then
  cp "$WORKSPACE_DIR/.env" "$BACKUP_DIR/.env.backup"
  chmod 600 "$BACKUP_DIR/.env.backup"
  echo "      → .env.backup (permissions 600)"
else
  echo -e "      ${RED}⚠ Fichier .env introuvable${NC}"
fi

# Résumé
echo -e "\n${GREEN}✓ Backup terminé avec succès !${NC}"
echo -e "\nEmplacement: ${YELLOW}$BACKUP_DIR${NC}"
echo -e "\nContenu:"
ls -lh "$BACKUP_DIR" | tail -n +2 | awk '{print "  - " $9 " (" $5 ")"}'

# Afficher l'espace total utilisé
TOTAL_SIZE=$(du -sh "$BACKUP_DIR" | cut -f1)
echo -e "\nTaille totale: ${YELLOW}$TOTAL_SIZE${NC}"

# Liste des backups existants
echo -e "\n${YELLOW}Backups existants:${NC}"
ls -lh "$BACKUP_BASE_DIR" | grep "^d" | awk '{print "  - " $9}' || echo "  Aucun backup précédent"

echo ""
