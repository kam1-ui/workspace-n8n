#!/usr/bin/env python3
"""
Script pour mettre à jour les chemins yt-dlp et ffmpeg dans le workflow n8n
"""
import requests
import json
import os

# Configuration
N8N_API_URL = "https://n8n.chnnlcrypto.cloud/api/v1"
N8N_API_KEY = os.getenv("N8N_API_KEY", "")
WORKFLOW_ID = "YZjpaE2KW9BJvzYR"

# Headers
headers = {
    "X-N8N-API-KEY": N8N_API_KEY,
    "Content-Type": "application/json"
}

# Récupérer le workflow actuel
print(f"📥 Récupération du workflow {WORKFLOW_ID}...")
response = requests.get(f"{N8N_API_URL}/workflows/{WORKFLOW_ID}", headers=headers)

if response.status_code != 200:
    print(f"❌ Erreur lors de la récupération: {response.status_code}")
    print(response.text)
    exit(1)

workflow = response.json()
print(f"✅ Workflow récupéré: {workflow['name']}")

# Compter les modifications
modifications = 0

# Parcourir les nœuds
for node in workflow['nodes']:
    if 'parameters' in node and 'jsCode' in node['parameters']:
        code = node['parameters']['jsCode']

        # Remplacer les chemins
        old_yt_dlp = '/home/ne0rignr/.local/bin/yt-dlp'
        new_yt_dlp = '/usr/bin/yt-dlp'
        old_ffmpeg = '/home/ne0rignr/.local/bin/ffmpeg'
        new_ffmpeg = '/usr/bin/ffmpeg'

        if old_yt_dlp in code:
            code = code.replace(old_yt_dlp, new_yt_dlp)
            print(f"🔧 Modification de '{node['name']}': yt-dlp")
            modifications += 1

        if old_ffmpeg in code:
            code = code.replace(old_ffmpeg, new_ffmpeg)
            print(f"🔧 Modification de '{node['name']}': ffmpeg")
            modifications += 1

        # Mettre à jour le code
        node['parameters']['jsCode'] = code

if modifications == 0:
    print("ℹ️  Aucune modification nécessaire")
    exit(0)

print(f"\n📊 Total de modifications: {modifications}")

# Préparer le payload pour la mise à jour
# L'API n8n n'accepte que certains champs
update_payload = {
    "name": workflow['name'],
    "nodes": workflow['nodes'],
    "connections": workflow['connections'],
    "settings": workflow['settings'],
    "staticData": workflow.get('staticData'),
    "pinData": workflow.get('pinData', {})
}

# Mettre à jour le workflow
print(f"\n📤 Mise à jour du workflow...")
response = requests.put(
    f"{N8N_API_URL}/workflows/{WORKFLOW_ID}",
    headers=headers,
    json=update_payload
)

if response.status_code == 200:
    print("✅ Workflow mis à jour avec succès!")
    print(f"\n🔗 Workflow: https://n8n.chnnlcrypto.cloud/workflow/{WORKFLOW_ID}")
else:
    print(f"❌ Erreur lors de la mise à jour: {response.status_code}")
    print(response.text)
    exit(1)
