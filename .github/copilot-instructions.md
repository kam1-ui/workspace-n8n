je comprend rien de ce que tu fais # Instructions IA - Workspace n8n MCP

## Contexte

Workspace dédié à l'intégration MCP (Model Context Protocol) avec :

- Serveur n8n MCP (production)
- Sequential Thinking MCP (local)

## Serveurs MCP configurés

### 1. n8n-mcp (Production)

````markdown
# Instructions IA - Workspace n8n MCP

Ce fichier donne l'essentiel pour qu'un assistant IA (Copilot/Claude) soit immédiatement productif
dans ce workspace centré sur l'intégration MCP (Model Context Protocol).

Principes courts et actionnables

- Le workspace est configuré pour 2 serveurs MCP :
  - n8n-mcp (production) — URL principale : https://n8n.chnnlcrypto.cloud/mcp (voir `README.md`).
  - Sequential Thinking (local) — http://127.0.0.1:3101/mcp (bridge géré par `~/servers/src/sequentialthinking/bridge-manager.sh`).

Fichiers et points d'entrée importants

- `.vscode/mcp.json` : configuration centralisée des serveurs MCP (les tokens sont fournis en input interactif).
- `workspace-n8n.code-workspace` : ouvrir VS Code avec les bonnes extensions/settings.
- `README.md` et `CLAUDE.md` : documentation locale et instructions spécifiques à Claude Code.

Commandes utilitaires fréquemment utilisées

````bash
# Vérifier le bridge Sequential Thinking
cd ~/servers/src/sequentialthinking
# Instructions IA - Workspace n8n MCP

Ce fichier donne l'essentiel pour qu'un assistant IA (Copilot/Claude) soit immédiatement productif
dans ce workspace centré sur l'intégration MCP (Model Context Protocol).

Principes courts et actionnables
- Le workspace est configuré pour 2 serveurs MCP :
  - n8n-mcp (production) — URL principale : https://n8n.chnnlcrypto.cloud/mcp (voir `README.md`).
  - Sequential Thinking (local) — http://127.0.0.1:3101/mcp (bridge géré par `~/servers/src/sequentialthinking/bridge-manager.sh`).

Fichiers et points d'entrée importants
- `.vscode/mcp.json` : configuration centralisée des serveurs MCP (les tokens sont fournis en input interactif).
- `workspace-n8n.code-workspace` : ouvrir VS Code avec les bonnes extensions/settings.
- `README.md` et `CLAUDE.md` : documentation locale et instructions spécifiques à Claude Code.

Commandes utilitaires fréquemment utilisées
```bash
# Vérifier le bridge Sequential Thinking
cd ~/servers/src/sequentialthinking
./bridge-manager.sh status

# Démarrer / arrêter / logs
./bridge-manager.sh start
./bridge-manager.sh stop
## .github/copilot-instructions.md — workspace-n8n (guide rapide pour assistants IA)

But : rendre un agent IA rapidement productif pour développer, documenter et faire du diagnostic dans ce workspace centré sur l'intégration n8n + MCP.

Contexte rapide
- Projet : collection de workflows n8n et outils d'intégration MCP.
- Points d'entrée : `README.md`, `CLAUDE.md`, dossier `n8n gemini whisper/` (workflows JSON).

Serveurs / bridge
- n8n-mcp (production) : https://n8n.chnnlcrypto.cloud/mcp — NE PAS modifier sans approbation humaine.
- Sequential Thinking (local) : http://127.0.0.1:3101/mcp — bridge contrôlé par `~/servers/src/sequentialthinking/bridge-manager.sh`.

Fichiers importants
- `/.vscode/mcp.json` — configuration des endpoints MCP (tokens fournis interactivement par VS Code).
- `workspace-n8n.code-workspace` — configuration d'ouverture VS Code (extensions, settings).
- `n8n gemini whisper/` — workflows n8n (.json) à relire pour endpoints et credentials.

Commandes utiles (exemples)
```bash
# Vérifier le status du bridge local
cd ~/servers/src/sequentialthinking
./bridge-manager.sh status

# Logs / démarrage / arrêt
./bridge-manager.sh start
./bridge-manager.sh stop
./bridge-manager.sh logs 50

# Ouvrir le workspace localement
code ~/workspace-n8n/workspace-n8n.code-workspace
````
````

Règles de sécurité et d'intervention humaine

- Ne jamais committer de tokens ou secrets. Si vous trouvez un secret en clair, signalez immédiatement.
- Toute modification touchant aux endpoints de production, aux tokens ou aux scripts d'infrastructure doit être proposée sous forme de diff et validée par un humain avant merge.

Comportement attendu d'un agent IA

- Avant d'exécuter des commandes qui touchent aux serveurs ou flux de données, demander confirmation explicite.
- Pour les modifications de fichiers sensibles (`.vscode/mcp.json`, scripts bridge, workflows avec credentials), proposer un patch/diff et attendre approbation.
- Quand vous éditez un workflow `.json` de `n8n gemini whisper/`, signalez les endpoints et champs potentiellement sensibles (ex : credentials, webhook URLs).

Conventions projet (observées)

- Workflows n8n stockés en JSON dans `n8n gemini whisper/` : privilégier modifications via export/import n8n (ne pas casser la structure JSON interne).
- Scripts d'administration du bridge sous `~/servers/src/sequentialthinking/bridge-manager.sh` (utiliser exactement ces commandes pour status/start/stop/logs).

Points non découverts / à confirmer

- CI/CD : emplacement et commandes (pas clairement identifiées dans le repo — demandez accès ou présence d'un fichier `.github/workflows/`).
- Accès aux tokens : confirmer où sont stockés les secrets pour déploiement (Vault / variables CI / .env écartés du repo).

Quand demander du feedback

- Si une tâche nécessite modification d'URL de production, accès secret, ou exécution de scripts sur la machine hôte.
- Si la structure d'un workflow n8n demande une migration ou une refactorisation (expliquer l'impact).

Références rapides dans le repo

- `README.md` — guide d'installation et dépannage
- `CLAUDE.md` — notes d'usage spécifiques aux assistants IA
- `n8n gemini whisper/` — workflows et scripts d'exemple

Demande de retour

- Indiquez si la CI existe (chemin), où sont gérés les secrets, et si des endpoints supplémentaires doivent être listés ici.

Merci — dites ce que vous voulez que j'édite ensuite (ex : ajout CI, policy secrets, ou exemples de modification de workflow).
Si un point important manque (p.ex. accès CI, URL supplémentaires, ou workflows sensibles), demandez les détails avant d'appliquer des changements en production.
