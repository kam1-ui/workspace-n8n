# Instructions de mise à jour - Chemin des transcriptions

## Contexte
Le volume n8n est monté sur `/home/node/.n8n` et **PAS** `/data`.
Alpine Linux utilise `sh` et **non** `bash`.

## ✅ Option A: Utiliser le volume existant (RECOMMANDÉ)

### Avantages
- Aucune modification du docker-compose.yml
- Fichiers persistés dans le volume Docker
- Fonctionne immédiatement

### Étapes

1. **Dossier déjà créé** ✅
   ```bash
   docker exec n8n-main sh -c 'ls -la /home/node/.n8n/transcriptions'
   ```

2. **Modifier le node "Save Files" dans n8n**
   - Ouvrir le workflow "Transcription Video - Supadata"
   - Ouvrir le node "Save Files" (Code node)
   - Remplacer la ligne:
     ```javascript
     const baseDir = '/data/transcriptions';  // ❌ ANCIEN
     ```
     Par:
     ```javascript
     const baseDir = '/home/node/.n8n/transcriptions';  // ✅ NOUVEAU
     ```

3. **Sauvegarder et activer le workflow**

4. **Tester**
   ```bash
   curl -X POST "https://n8n.chnnlcrypto.cloud/webhook/transcribe-supadata" \
     -H "Content-Type: application/json" \
     -H "x-api-key: 718cd96f04036dfa345895f49529be5e57711e59340a06b906c1c057cd4b1a6b" \
     -d '{"youtube_url": "https://www.youtube.com/watch?v=jNQXAC9IVRw"}'
   ```

5. **Vérifier les fichiers**
   ```bash
   docker exec n8n-main sh -c 'ls -la /home/node/.n8n/transcriptions/'
   docker exec n8n-main sh -c 'ls -la /home/node/.n8n/transcriptions/jNQXAC9IVRw/'
   ```

---

## 📁 Option B: Bind mount vers l'hôte (accès facile depuis le VPS)

### Avantages
- Fichiers accessibles depuis `/home/ne0rignr/workspace-serveur/transcriptions`
- Facile à backup/sync
- Peut être utilisé par d'autres applications

### Inconvénients
- Nécessite redémarrage des conteneurs
- Permissions à gérer

### Étapes

1. **Créer le dossier sur l'hôte**
   ```bash
   sudo mkdir -p /home/ne0rignr/workspace-serveur/transcriptions
   sudo chown -R 1000:1000 /home/ne0rignr/workspace-serveur/transcriptions
   sudo chmod -R 755 /home/ne0rignr/workspace-serveur/transcriptions
   ```

2. **Modifier docker-compose.yml**

   Service `n8n:` (ligne ~70):
   ```yaml
       volumes:
         - n8n-data:/home/node/.n8n
         - /home/ne0rignr/workspace-serveur/transcriptions:/home/node/.n8n/transcriptions
   ```

   Service `n8n-worker:` (ligne ~132):
   ```yaml
       volumes:
         - n8n-data:/home/node/.n8n
         - /home/ne0rignr/workspace-serveur/transcriptions:/home/node/.n8n/transcriptions
   ```

3. **Redémarrer les conteneurs**
   ```bash
   cd /home/ne0rignr/workspace-n8n
   docker-compose down
   docker-compose up -d
   ```

4. **Vérifier le montage**
   ```bash
   docker inspect n8n-main --format '{{json .Mounts}}' | python3 -m json.tool
   ```

5. **Suivre les étapes 2-5 de l'Option A**

---

## 🔍 Vérifications après mise à jour

### Dans le conteneur
```bash
docker exec n8n-main sh -c 'ls -la /home/node/.n8n/transcriptions/'
```

### Sur l'hôte (Option B uniquement)
```bash
ls -la /home/ne0rignr/workspace-serveur/transcriptions/
```

### Workflow n8n
- Node "Save Files" doit retourner:
  - `output_dir`: `/home/node/.n8n/transcriptions/VIDEO_ID`
  - `transcription_path`: `/home/node/.n8n/transcriptions/VIDEO_ID/transcription_brute.txt`
  - `metadata_path`: `/home/node/.n8n/transcriptions/VIDEO_ID/metadata.json`

---

## 📝 Pour les autres workflows (yt-dlp, ffmpeg)

Si tu as des Command nodes qui utilisent yt-dlp ou ffmpeg:

### ❌ ÉVITER
```javascript
// N'utilise PAS bash
docker exec -it n8n-main bash -c '...'
```

### ✅ UTILISER
```javascript
// Utilise sh (Alpine Linux)
docker exec n8n-main sh -c '...'
```

### Chemin de sortie yt-dlp
```javascript
const command = `cd /tmp && /usr/local/bin/yt-dlp -f 'best[ext=mp4]' -o '/home/node/.n8n/transcriptions/%(id)s.%(ext)s' '${youtubeUrl}' 2>&1`;
```

### Chemin de sortie ffmpeg
```javascript
const command = `/usr/local/bin/ffmpeg -i "${videoPath}" -vn -ar 16000 -ac 1 -b:a 64k -y "/home/node/.n8n/transcriptions/${sanitizedVideoId}.mp3" 2>&1`;
```

---

## 🚨 Résolution de problèmes

### Le workflow échoue avec "ENOENT: no such file or directory"
- Vérifier que le dossier existe:
  ```bash
  docker exec n8n-main sh -c 'ls -la /home/node/.n8n/ | grep transcriptions'
  ```
- Le recréer si nécessaire:
  ```bash
  docker exec n8n-main sh -c 'mkdir -p /home/node/.n8n/transcriptions && chmod 755 /home/node/.n8n/transcriptions'
  ```

### Permission denied
```bash
docker exec n8n-main sh -c 'chown -R node:node /home/node/.n8n/transcriptions && chmod -R 755 /home/node/.n8n/transcriptions'
```

### Les fichiers n'apparaissent pas sur l'hôte (Option B)
- Vérifier le montage:
  ```bash
  docker inspect n8n-main --format '{{json .Mounts}}' | python3 -m json.tool | grep transcriptions
  ```
- Si absent, le volume n'est pas monté → refaire les étapes de l'Option B

---

## 📊 Résumé pour Kodee

### Configuration actuelle
- **Image**: `docker.n8n.io/n8nio/n8n:1.123.6` (Alpine Linux)
- **Shell**: `sh` (pas bash)
- **Volume principal**: `n8n-data:/home/node/.n8n`
- **Dossier transcriptions créé**: `/home/node/.n8n/transcriptions` ✅

### Modifications nécessaires
- **docker-compose.yml**: Aucune (Option A) ou ajouter bind mount (Option B)
- **Node "Save Files"**: Changer `baseDir` de `/data/transcriptions` → `/home/node/.n8n/transcriptions`
- **Autres nodes**: Utiliser `/home/node/.n8n/transcriptions/...` pour tous les chemins

### Ce qui manque encore (si Kodee veut finaliser)
1. Code exact du Command node yt-dlp (si utilisé dans ce workflow)
2. Confirmation que le node Save Files a été mis à jour dans n8n UI
3. Résultat du test webhook après modification

### Prochaine étape
Tester le workflow avec:
```bash
curl -X POST "https://n8n.chnnlcrypto.cloud/webhook/transcribe-supadata" \
  -H "Content-Type: application/json" \
  -H "x-api-key: 718cd96f04036dfa345895f49529be5e57711e59340a06b906c1c057cd4b1a6b" \
  -d '{"youtube_url": "https://www.youtube.com/watch?v=jNQXAC9IVRw"}'
```

Et vérifier la création des fichiers:
```bash
docker exec n8n-main sh -c 'ls -laR /home/node/.n8n/transcriptions/'
```
