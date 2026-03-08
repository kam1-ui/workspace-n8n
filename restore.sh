#!/usr/bin/env bash
# Script de restauration manuelle pour n8n
# Usage: ./restore.sh <nom-du-backup>
# Exemple: ./restore.sh 2025-12-20_0845

set -euo pipefail

# Couleurs pour l'affichage
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
WORKSPACE_DIR="/root/workspace-n8n"
BACKUP_BASE_DIR="$WORKSPACE_DIR/backups"

# Vérifier l'argument
if [ $# -eq 0 ]; then
    echo -e "${RED}❌ Erreur: Vous devez spécifier le nom du backup à restaurer${NC}\n"
    echo -e "${YELLOW}Backups disponibles:${NC}"
    ls -1 "$BACKUP_BASE_DIR" | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{4}$" || echo "  Aucun backup trouvé"
    echo ""
    echo -e "${BLUE}Usage:${NC} ./restore.sh <nom-du-backup>"
    echo -e "${BLUE}Exemple:${NC} ./restore.sh 2025-12-20_0845"
    exit 1
fi

BACKUP_NAME="$1"
BACKUP_DIR="$BACKUP_BASE_DIR/$BACKUP_NAME"

# Vérifier que le backup existe
if [ ! -d "$BACKUP_DIR" ]; then
    echo -e "${RED}❌ Erreur: Le backup '$BACKUP_NAME' n'existe pas${NC}"
    echo -e "\n${YELLOW}Backups disponibles:${NC}"
    ls -1 "$BACKUP_BASE_DIR" | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{4}$" || echo "  Aucun backup trouvé"
    exit 1
fi

# Vérifier que les fichiers nécessaires existent
echo -e "${BLUE}Vérification du backup...${NC}"
MISSING=0

if [ ! -f "$BACKUP_DIR/n8n-postgres.sql.gz" ]; then
    echo -e "${RED}  ✗ n8n-postgres.sql.gz manquant${NC}"
    MISSING=1
else
    echo -e "${GREEN}  ✓ n8n-postgres.sql.gz${NC}"
fi

if [ ! -f "$BACKUP_DIR/n8n-data.tgz" ]; then
    echo -e "${RED}  ✗ n8n-data.tgz manquant${NC}"
    MISSING=1
else
    echo -e "${GREEN}  ✓ n8n-data.tgz${NC}"
fi

if [ ! -f "$BACKUP_DIR/.env.backup" ]; then
    echo -e "${YELLOW}  ⚠ .env.backup manquant (optionnel)${NC}"
else
    echo -e "${GREEN}  ✓ .env.backup${NC}"
fi

if [ $MISSING -eq 1 ]; then
    echo -e "\n${RED}❌ Backup incomplet, restauration impossible${NC}"
    exit 1
fi

# Avertissement
echo -e "\n${YELLOW}⚠️  ATTENTION ⚠️${NC}"
echo -e "${RED}Cette opération va ÉCRASER toutes les données actuelles de n8n !${NC}"
echo -e "  - Tous les workflows actuels seront remplacés"
echo -e "  - Toutes les executions actuelles seront perdues"
echo -e "  - Toutes les credentials actuelles seront remplacées"
echo -e "\n${YELLOW}Backup à restaurer:${NC} $BACKUP_NAME"
echo -e "${YELLOW}Date du backup:${NC} $(stat -c %y "$BACKUP_DIR" | cut -d' ' -f1,2 | cut -d'.' -f1)"
echo ""

read -p "Voulez-vous continuer ? (tapez 'OUI' en majuscules pour confirmer): " CONFIRM

if [ "$CONFIRM" != "OUI" ]; then
    echo -e "\n${BLUE}Restauration annulée${NC}"
    exit 0
fi

echo -e "\n${YELLOW}=== Restauration n8n - $(date) ===${NC}\n"

# 1. Arrêter la stack
echo -e "${GREEN}[1/5]${NC} Arrêt de la stack n8n..."
cd "$WORKSPACE_DIR"
docker compose down
echo -e "      ${GREEN}✓ Stack arrêtée${NC}"

# 2. Restaurer le volume n8n-data
echo -e "\n${GREEN}[2/5]${NC} Restauration du volume n8n-data..."
docker run --rm \
  -v workspace-n8n_n8n-data:/data \
  -v "$BACKUP_DIR":/backup \
  alpine sh -c "rm -rf /data/* && cd /data && tar xzf /backup/n8n-data.tgz"
echo -e "      ${GREEN}✓ Volume n8n-data restauré${NC}"

# 3. Démarrer temporairement Postgres pour la restauration
echo -e "\n${GREEN}[3/5]${NC} Démarrage temporaire de Postgres..."
docker compose up -d n8n-postgres
sleep 5
echo -e "      ${GREEN}✓ Postgres démarré${NC}"

# 4. Restaurer la base de données
echo -e "\n${GREEN}[4/5]${NC} Restauration de la base de données..."
gunzip -c "$BACKUP_DIR/n8n-postgres.sql.gz" | docker exec -i n8n-postgres psql -U n8n -d postgres 2>&1 | grep -v "^SET$" | grep -v "^DROP" | grep -v "^CREATE" | head -20 || true
echo -e "      ${GREEN}✓ Base de données restaurée${NC}"

# 5. Vérifier N8N_ENCRYPTION_KEY
echo -e "\n${GREEN}[5/5]${NC} Vérification de N8N_ENCRYPTION_KEY..."
if [ -f "$BACKUP_DIR/.env.backup" ]; then
    BACKUP_KEY=$(grep "N8N_ENCRYPTION_KEY" "$BACKUP_DIR/.env.backup" | cut -d'=' -f2 | tr -d '"' | tr -d "'")
    CURRENT_KEY=$(grep "N8N_ENCRYPTION_KEY" "$WORKSPACE_DIR/.env" | cut -d'=' -f2 | tr -d '"' | tr -d "'")

    if [ "$BACKUP_KEY" != "$CURRENT_KEY" ]; then
        echo -e "      ${RED}⚠️  AVERTISSEMENT: N8N_ENCRYPTION_KEY différente !${NC}"
        echo -e "      ${YELLOW}Les credentials ne pourront PAS être déchiffrées${NC}"
        echo -e "      ${YELLOW}Restaurez la clé depuis .env.backup si nécessaire${NC}"
    else
        echo -e "      ${GREEN}✓ N8N_ENCRYPTION_KEY identique${NC}"
    fi
else
    echo -e "      ${YELLOW}⚠️  Impossible de vérifier la clé (.env.backup manquant)${NC}"
fi

# Redémarrer la stack complète
echo -e "\n${BLUE}Redémarrage de la stack complète...${NC}"
docker compose up -d
sleep 3

# Afficher les logs
echo -e "\n${GREEN}✓ Restauration terminée !${NC}\n"
echo -e "${YELLOW}Vérification des services:${NC}"
docker compose ps

echo -e "\n${YELLOW}Logs récents (Ctrl+C pour quitter):${NC}"
docker compose logs --tail 50 -f n8n-main

