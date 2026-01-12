# Mise à jour des chemins yt-dlp et ffmpeg dans n8n

## ✅ Outils installés dans le conteneur

- **yt-dlp** : `/usr/bin/yt-dlp` (version 2025.12.08)
- **ffmpeg** : `/usr/bin/ffmpeg` (version 6.1.2)

## 🔧 Modifications à effectuer dans n8n

### Accéder au workflow
1. Ouvrir https://n8n.chnnlcrypto.cloud
2. Ouvrir le workflow "Transcription Video - Gemini - Whisper"

### Nœud 1 : Download Video (Gemini)

**Remplacer** :
```javascript
const command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;
```

**Par** :
```javascript
const command = `cd /tmp && /usr/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;
```

### Nœud 2 : Download Video (Whisper)

**Remplacer** :
```javascript
const command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;
```

**Par** :
```javascript
const command = `cd /tmp && /usr/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;
```

### Nœud 3 : Extract Audio

**Remplacer** :
```javascript
const command = `/home/ne0rignr/.local/bin/ffmpeg -i "${videoPath}" -vn -ar 16000 -ac 1 -b:a 64k -y "/tmp/${videoId}.mp3" 2>&1`;
```

**Par** :
```javascript
const command = `/usr/bin/ffmpeg -i "${videoPath}" -vn -ar 16000 -ac 1 -b:a 64k -y "/tmp/${videoId}.mp3" 2>&1`;
```

## 📝 Résumé des changements

- `/home/ne0rignr/.local/bin/yt-dlp` → `/usr/bin/yt-dlp`
- `/home/ne0rignr/.local/bin/ffmpeg` → `/usr/bin/ffmpeg`

## 🧪 Test après modification

```bash
curl -X POST "https://n8n.chnnlcrypto.cloud/webhook/transcribe" \
  -H "Content-Type: application/json" \
  -H "X-API-Key: 718cd96f04036dfa345895f49529be5e57711e59340a06b906c1c057cd4b1a6b" \
  -d '{"youtube_url":"https://www.youtube.com/watch?v=jNQXAC9IVRw","method":"whisper"}'
```

Devrait retourner HTTP 200 avec une transcription réussie.
