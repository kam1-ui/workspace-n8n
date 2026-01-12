#!/bin/bash
# Génère nginx-n8n.conf à partir du template et des variables d'environnement

set -a
source .env
set +a

envsubst < nginx-n8n.conf.template > nginx-n8n.conf

echo "nginx-n8n.conf généré avec succès. Placez-le dans /etc/nginx/sites-available/ puis activez et rechargez nginx."
