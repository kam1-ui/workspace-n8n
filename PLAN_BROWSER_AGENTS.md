# PLAN — Installation Playwright MCP + Browser-Use sur VPS
**Auteur** : Gwen (Claude Code CLI VPS)
**Date** : 2026-03-15
**Statut** : À évaluer par Claude PC avant implémentation

---

## 1. Objectif

Ajouter deux outils d'automatisation de navigateur sur le VPS pour permettre à l'agent orchestrateur de déléguer des tâches web interactives (login, formulaires, scraping authentifié, souscriptions, etc.) à des sous-agents spécialisés.

---

## 2. État actuel du VPS

| Ressource | Valeur |
|-----------|--------|
| CPU | 8 cores AMD EPYC |
| RAM | 32 GB (8.9 utilisés, 22 dispo) |
| Disque | 387 GB (69 utilisés, 319 libres) |
| Node.js | v20.20.1 ✅ |
| Python | 3.12.3 ✅ |
| Docker | 29.3.0 ✅ |
| Ports 9222/9223 | Libres ✅ |

### MCP servers déjà configurés (`~/.claude.json`)
- `hostinger-mcp`
- `sequential-thinking`
- `github`
- `n8n-mcp`
- `firecrawl`
- `gemini-grounding`
- `knowledge-api`

---

## 3. Les deux outils à installer

### 3.1 Playwright MCP (Microsoft)
- **Repo** : https://github.com/microsoft/playwright-mcp
- **Licence** : MIT — gratuit
- **Type** : Serveur MCP stdio (s'intègre directement dans `~/.claude.json`)
- **Runtime** : Node.js 20 (déjà installé ✅)
- **RAM** : ~400-600 MB
- **Rôle** : Claude exécute des actions navigateur précises via outils MCP
- **Port navigateur** : 9222

### 3.2 Browser-Use
- **Repo** : https://github.com/browser-use/browser-use
- **Licence** : MIT — gratuit
- **Type** : Agent Python autonome (reçoit un objectif, décide seul)
- **Runtime** : Python 3.11+ (Python 3.12.3 installé ✅)
- **RAM** : ~1.5 GB
- **Rôle** : Sous-agent autonome piloté par LLM (Claude ou Ollama qwen3:8b local)
- **Port navigateur** : 9223

---

## 4. Architecture cible

```
┌──────────────────────────────────────────────────────┐
│         ORCHESTRATEUR (Claude Opus 4.6)              │
│   Décide quelle tâche → quel sous-agent              │
└────────────┬─────────────────────┬───────────────────┘
             │                     │
   ┌──────────▼──────┐   ┌─────────▼──────────────────┐
   │  Playwright MCP │   │     Browser-Use Agent       │
   │  (MCP natif)    │   │     (Python subprocess)     │
   │                 │   │                             │
   │ Instructions    │   │ Objectifs autonomes         │
   │ step-by-step :  │   │ en langage naturel :        │
   │ • click(x)      │   │ • "Inscris-moi sur X"       │
   │ • fill(field)   │   │ • "Compare les plans Y/Z"   │
   │ • screenshot()  │   │ • "Souscris au plan Pro"    │
   │ • navigate(url) │   │ • "Extrais les données"     │
   └─────────────────┘   └─────────────────────────────┘
             │                     │
   ┌──────────▼──────┐   ┌─────────▼───────────────────┐
   │ Chromium :9222  │   │ Chromium :9223               │
   └─────────────────┘   └──────────────────────────────┘
```

**Règle de routage orchestrateur :**
- → Playwright MCP quand les étapes sont connues et précises
- → Browser-Use quand l'objectif est flou et l'agent doit décider seul

---

## 5. Plan d'installation étape par étape

### Étape 1 — Playwright MCP

```bash
# Installation globale
npm install -g @playwright/mcp@latest

# Installer les navigateurs Playwright
npx playwright install chromium --with-deps

# Ajouter dans ~/.claude.json (mcpServers)
{
  "playwright-mcp": {
    "command": "npx",
    "args": ["@playwright/mcp@latest", "--headless", "--port", "9222"],
    "type": "stdio"
  }
}

# Vérification
claude mcp list
```

### Étape 2 — Browser-Use

```bash
# Créer un environnement Python isolé
mkdir -p /root/projects/browser-use-agent
cd /root/projects/browser-use-agent
python3 -m venv venv
source venv/bin/activate

# Installer browser-use
pip install browser-use playwright

# Installer Chromium pour browser-use
playwright install chromium --with-deps

# Créer le script agent wrapper
cat > agent.py << 'EOF'
"""
Browser-Use Agent — Sous-agent web autonome
Reçoit une tâche via argument CLI, l'exécute, retourne le résultat en JSON
Usage: python agent.py "Inscris-moi sur ce site avec email X et mot de passe Y"
"""
import asyncio
import sys
import json
from browser_use import Agent
from langchain_anthropic import ChatAnthropic

async def run(task: str):
    agent = Agent(
        task=task,
        llm=ChatAnthropic(model="claude-sonnet-4-6"),
    )
    result = await agent.run()
    print(json.dumps({"status": "ok", "result": str(result)}))

if __name__ == "__main__":
    task = " ".join(sys.argv[1:])
    asyncio.run(run(task))
EOF
```

### Étape 3 — Wrapper n8n (optionnel)

Créer un workflow n8n qui expose Browser-Use via webhook :
- `POST /webhook/browser-agent` avec `{ "task": "..." }`
- Exécute `python3 agent.py "..."` via Execute Command node
- Retourne le résultat JSON

---

## 6. Intégration avec l'orchestrateur Claude

### Via Playwright MCP (direct)
Playwright MCP sera dans `~/.claude.json` → disponible automatiquement comme outil MCP dans chaque session Gwen.

```
# L'orchestrateur peut directement appeler :
browser_navigate(url="https://example.com")
browser_fill(selector="#email", value="user@mail.com")
browser_click(selector="button[type=submit]")
browser_screenshot()
```

### Via Browser-Use (sous-agent)
L'orchestrateur lance un sous-agent Claude avec instruction :

```python
# Dans un agent n8n-builder ou orchestrator :
result = subprocess.run([
    "/root/projects/browser-use-agent/venv/bin/python3",
    "/root/projects/browser-use-agent/agent.py",
    "Connecte-toi sur app.example.com avec email@test.com / pass123 et clique sur 'Upgrade to Pro'"
], capture_output=True, text=True)
```

---

## 7. Conflits potentiels

| Risque | Analyse | Mitigation |
|--------|---------|------------|
| Ports Chromium | 9222 vs 9223 → différents ✅ | Aucune action |
| RAM | +2 GB max si les 2 actifs simultanément | 22 GB libres → OK ✅ |
| Python 3.12 vs 3.11 requis | browser-use requiert 3.11+, 3.12 devrait marcher | Tester, fallback pyenv si nécessaire |
| Conflits Playwright binaries | Les 2 utilisent Chromium mais dans des venvs séparés | Chemins isolés ✅ |
| Conflit MCP stdio | Playwright MCP = stdio standard | Compatible avec architecture existante ✅ |

---

## 8. Critères d'évaluation demandés à Claude PC

**Compatibilité infrastructure :**
- [ ] Python 3.12.3 est-il compatible avec browser-use (qui requiert 3.11+) ?
- [ ] Node.js v20.20.1 est-il compatible avec `@playwright/mcp@latest` ?
- [ ] Les 19 conteneurs Docker existants posent-ils des conflits réseau ?

**Architecture agents :**
- [ ] La règle de routage Playwright MCP vs Browser-Use est-elle pertinente ?
- [ ] Browser-Use en subprocess Python est-il la bonne approche pour un sous-agent ?
- [ ] Faut-il containeriser Browser-Use dans Docker pour l'isoler ?

**Sécurité :**
- [ ] Browser-Use a accès aux credentials → comment les passer sans les exposer ?
- [ ] Faut-il un réseau Docker isolé pour les sessions navigateur ?

**Performance :**
- [ ] 22 GB RAM libres suffisent-ils pour les 2 agents + stack existante ?
- [ ] Faut-il des limites mémoire Docker pour Browser-Use ?

**Alternatives à évaluer :**
- [ ] Steel Browser (Docker natif, anti-bot intégré) serait-il meilleur que Browser-Use ?
- [ ] Faut-il un seul outil ou les 2 sont vraiment complémentaires ?

---

## 9. Fichiers qui seront modifiés

| Fichier | Modification |
|---------|-------------|
| `~/.claude.json` | Ajout entrée `playwright-mcp` dans `mcpServers` |
| `/root/projects/browser-use-agent/` | Nouveau dossier (créé, pas modifié) |
| `~/.claude/CLAUDE.md` (si existant) | Ajout doc des nouveaux outils |

**Aucune modification des stacks existantes (n8n, Firecrawl, Knowledge API).**

---

## 10. Rollback

```bash
# Supprimer Playwright MCP
claude mcp remove playwright-mcp

# Supprimer Browser-Use
rm -rf /root/projects/browser-use-agent

# Désinstaller packages globaux
npm uninstall -g @playwright/mcp
```

Rollback complet en < 2 minutes, zéro impact sur les services existants.
