# Mémoire — Camille (kam1-ui)

## Principe de collaboration fondamental

**Réserver mes tokens pour ce qui dépasse les capacités de l'utilisateur.**

- Ne PAS automatiser les démarches simples que Camille peut faire lui-même (installer un logiciel, cliquer dans une UI, entrer un code d'auth, etc.)
- Intervenir uniquement quand la tâche est trop complexe, technique ou longue pour être faite manuellement
- Poser la question : "Est-ce que Camille peut faire ça en 30 secondes lui-même ?" — si oui, lui dire quoi faire plutôt que de le faire

**Exemples concrets :**
- Authentification GitHub (gh auth login) → lui donner le code, il entre lui-même
- Installer un logiciel/extension → lui donner la commande, il exécute
- Clics dans VS Code settings → lui dire quoi cocher, il le fait
- Écrire du code complexe, analyser des erreurs, configurer des fichiers → faire moi-même

## Contexte technique actuel
- GitHub CLI authentifié : compte kam1-ui, scopes : copilot, gist, read:org, repo
- Copilot CLI : à installer manuellement par Camille

## Serveurs MCP configurés (dans ~/.claude.json)

### n8n-mcp
- **Repo** : https://github.com/czlonkowski/n8n-mcp
- **Commande** : `npx n8n-mcp`
- **Instance n8n** : https://n8n.chnnlcrypto.cloud/
- **Fonction** : contrôler n8n depuis Claude Code (créer/modifier/tester des workflows, chercher des nodes/templates, valider des configs)
- **Env vars** : MCP_MODE=stdio, LOG_LEVEL=error, DISABLE_CONSOLE_OUTPUT=true, N8N_API_URL, N8N_API_KEY (JWT)

### n8n-skills (compagnon de n8n-mcp)
- **Repo** : https://github.com/czlonkowski/n8n-skills
- **Installé dans** : `~/.claude/skills/`
- **7 skills** : n8n-code-javascript, n8n-code-python, n8n-expression-syntax, n8n-mcp-tools-expert, n8n-node-configuration, n8n-validation-expert, n8n-workflow-patterns
- **Fonction** : fournir expertise contextuelle sur n8n (syntax, patterns, validation, config nodes)

### hostinger-mcp
- **Commande** : `npx hostinger-api-mcp@latest`
- **Fonction** : gérer l'hébergement Hostinger (VPS, domaines, DNS, etc.) depuis Claude Code
- **Env vars** : API_TOKEN

## Infrastructure cloud — VPS Hostinger

### Serveur
- **CPU** : 8 cores AMD EPYC | **RAM** : 32 GB | **Disque** : 332 GB | Pas de GPU
- **IP** : 72.60.175.177 | **Domaine** : chnnlcrypto.cloud
- **Reverse proxy** : Nginx + SSL Let's Encrypt
- **OS** : Linux (systemd)

### Services actifs (19 conteneurs Docker)
| Stack | Conteneurs | URL publique |
|-------|-----------|-------------|
| n8n | n8n-main, n8n-worker, n8n-postgres, n8n-redis | n8n.chnnlcrypto.cloud |
| n8n MCP (serveur) | n8n-mcp-server (port 3000) | mcp.chnnlcrypto.cloud |
| Firecrawl | api, redis, rabbitmq, postgres, playwright, searxng | firecrawl.chnnlcrypto.cloud |
| Knowledge API | knowledge-api, qdrant | knowledge.chnnlcrypto.cloud |
| chnnlcrypto | api (8000), dashboard (3001) | — |
| Dev | voice-to-text-web, devcontainer, influxdb, redis | — |
| Ollama | systemd (pas Docker) port 11434 | host direct |

### MCP sur le VPS (accessibles par Gwen)
- **n8n MCP** : https://mcp.chnnlcrypto.cloud/mcp (17 outils, Bearer token)
- **Firecrawl MCP** : /mcp/sse interne (10 outils : scrape, crawl, extract, knowledge)
- **Ollama** : localhost:11434 (modèles qwen3:8b, nomic-embed-text)
- **Knowledge API** : localhost:8001 (search/ingest Qdrant)

### Gwen = Claude Code CLI v2.1.71 sur le VPS
- **Accès** : via VS Code Remote-SSH depuis le PC Windows
- **Équipé de** : n8n-skills (7), CLAUDE.md (règles n8n), hostinger-mcp, n8n MCP, Firecrawl MCP
- Accès direct : n8n API, Docker, nginx, certbot, fichiers /root/projects/
- Manque : Sequential Thinking (uniquement sur Windows local)

### Ollama (service séparé sur le VPS)
- **Modèles** : qwen3:8b, nomic-embed-text
- **Rôle** : LLM local utilisé par Firecrawl et n8n pour les tâches locales (pas Gwen)
- **Port** : localhost:11434

### Alertes
- **SSL** : tous les certificats valides (vérifié 2026-03-12), certbot auto-renew en place

### Workflows n8n existants
- Transcription YouTube (Gemini 2.0 Flash + Whisper) : POST /webhook/transcribe
- Transcription Video (Supadata) : POST /webhook/transcribe-supadata
