#!/bin/bash
# Script pour configurer Nginx + HTTPS pour n8n
# À exécuter avec : sudo bash setup-nginx-https.sh

set -e

echo "=== Configuration Nginx + HTTPS pour n8n ==="
echo ""

# Vérifier que le script est exécuté en root
if [ "$EUID" -ne 0 ]; then
   echo "❌ Ce script doit être exécuté en tant que root (sudo)"
   exit 1
fi

# Copier la configuration Nginx
echo "📝 Installation de la configuration Nginx..."
cp /home/ne0rignr/workspace-n8n/nginx-n8n.conf /etc/nginx/sites-available/n8n
ln -sf /etc/nginx/sites-available/n8n /etc/nginx/sites-enabled/n8n

# Désactiver le site par défaut si présent
if [ -L /etc/nginx/sites-enabled/default ]; then
    rm /etc/nginx/sites-enabled/default
    echo "✅ Site par défaut Nginx désactivé"
fi

# Tester la configuration Nginx
echo "🔍 Test de la configuration Nginx..."
nginx -t

# Recharger Nginx
echo "🔄 Rechargement de Nginx..."
systemctl reload nginx

# Vérifier que Nginx tourne
systemctl status nginx --no-pager || systemctl start nginx

echo ""
echo "✅ Configuration Nginx installée !"
echo ""
echo "=== Prochaine étape : Génération du certificat SSL ==="
echo ""
echo "Exécute cette commande :"
echo ""
echo "  sudo certbot --nginx -d n8n.chnnlcrypto.cloud --email letsencrypt@chnnlcrypto.cloud --agree-tos --no-eff-email"
echo ""
echo "Certbot va :"
echo "  1. Générer le certificat SSL Let's Encrypt"
echo "  2. Modifier automatiquement la config Nginx"
echo "  3. Configurer le renouvellement automatique"
echo ""
