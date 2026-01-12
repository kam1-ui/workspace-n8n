# Workflow Transcription YouTube - Gemini + Whisper

Workflow n8n pour transcrire automatiquement des vidéos YouTube en utilisant Gemini 2.0 Flash ou Whisper.

## Statut : PRÊT À L'EMPLOI

Toutes les dépendances sont installées et les services sont opérationnels.

## Prérequis installés

- **yt-dlp** : v2025.12.08 (installé dans `~/.local/bin`)
- **ffmpeg** : N-122186 (installé dans `~/.local/bin`)
- **Whisper API** : Actif sur port 9000 (modèle medium, CPU)
- **n8n** : Service actif
- **Dossier de sortie** : `/home/ne0rignr/workspace-serveur/transcriptions/`

## Démarrage rapide

### 1. Importer le workflow dans n8n

Fichier à importer : `workflow-complet-gemini-whisper-final.json`

Dans l'interface n8n :
1. Menu → "Import from file"
2. Sélectionner le fichier workflow
3. Activer le workflow

### 2. Tester le workflow

**Option A - Interface HTML** :
```bash
firefox formulaire-test.html
```

**Option B - Script CLI** :
```bash
./test-webhook.sh whisper "https://www.youtube.com/watch?v=VIDEO_ID"
```

**Option C - curl** :
```bash
curl -X POST http://localhost:5678/webhook/transcribe \
  -H "Content-Type: application/json" \
  -d '{"method":"whisper","youtube_url":"https://www.youtube.com/watch?v=VIDEO_ID"}'
```

## Utilisation

### Format de requête

**Endpoint** : `POST /webhook/transcribe`

**Corps de la requête** :
```json
{
  "method": "whisper",
  "youtube_url": "https://www.youtube.com/watch?v=VIDEO_ID"
}
```

**Paramètres** :
- `method` : `"whisper"` (local, gratuit) ou `"gemini"` (cloud, nécessite API key)
- `youtube_url` : URL complète de la vidéo YouTube

### Format de réponse

```json
{
  "success": true,
  "message": "Transcription terminée",
  "video_id": "VIDEO_ID",
  "method": "whisper",
  "output_directory": "/home/ne0rignr/workspace-serveur/transcriptions/VIDEO_ID",
  "text_length": 1234,
  "cleanup_success": true
}
```

### Fichiers générés

Pour chaque transcription :
```
/home/ne0rignr/workspace-serveur/transcriptions/{video_id}/
├── transcription_brute.txt    # Texte de la transcription
└── metadata.json               # Métadonnées (URL, méthode, date, etc.)
```

## Configuration Gemini (optionnel)

Pour utiliser Gemini au lieu de Whisper :

1. Obtenir une clé API : https://makersuite.google.com/app/apikey
2. Dans n8n → Credentials → "HTTP Query Auth"
   - **Name** : `Gemini API Key`
   - **Parameter Name** : `key`
   - **Value** : Votre clé API
3. Tester : `./test-webhook.sh gemini "URL_YOUTUBE"`

## Architecture du workflow

```
Webhook (POST /transcribe)
    ↓
Extraire Video ID
    ↓
Switch (Gemini ou Whisper ?)
    ├─→ [GEMINI]
    │   Download Video (yt-dlp)
    │   Read Video (base64)
    │   Upload to Gemini Files API
    │   Parse Upload Response
    │   Gemini 2.0 Flash API
    │   Parse Gemini Response
    │
    └─→ [WHISPER]
        Download Video (yt-dlp)
        Extract Audio (ffmpeg)
        Read Audio (base64)
        Whisper API (localhost:9000)
        Parse Whisper Response

    [Les deux branches convergent]
        ↓
    Save Files
        ↓
    Cleanup (/tmp)
        ↓
    Response (JSON)
```

## Fichiers du projet

- `workflow-complet-gemini-whisper-final.json` - Workflow à importer dans n8n
- `formulaire-test.html` - Interface de test web
- `test-webhook.sh` - Script de test CLI
- `README.md` - Ce fichier

## Dépannage

### Vérifier les services

```bash
# Whisper
curl http://localhost:9000/health

# n8n
ps aux | grep n8n
```

### Vérifier les binaires

```bash
/home/ne0rignr/.local/bin/yt-dlp --version
/home/ne0rignr/.local/bin/ffmpeg -version
```

### Vérifier le dossier de sortie

```bash
ls -la /home/ne0rignr/workspace-serveur/transcriptions/
```

## Notes techniques

- **Timeouts** : 600s pour Gemini, 3600s pour Whisper
- **Chemins absolus** : Utilise `/home/ne0rignr/.local/bin/` pour yt-dlp et ffmpeg
- **Nettoyage automatique** : Les fichiers `/tmp/*.mp4` et `/tmp/*.mp3` sont supprimés après traitement
- **API Gemini** : Utilise l'API Files Upload (pas besoin de Google Cloud Storage)

---

**Serveur** : 72.60.175.177
**Utilisateur** : ne0rignr
**Dernière mise à jour** : 2025-12-20
