# Regles du jeu - Automatisation n8n

## Presentation du projet

Ce projet consiste a creer, corriger et ameliorer des automatisations sur n8n en exploitant pleinement les capacites avancees de l'IA et des outils specialises disponibles.

### Objectifs principaux
- Creer des workflows n8n sur mesure et performants
- Corriger les workflows existants presentant des erreurs ou dysfonctionnements
- Ameliorer et optimiser les automatisations en place
- Assurer une qualite maximale des workflows produits

---

## STATUT DES OUTILS - PRETS A L'EMPLOI

| Outil | Statut | Acces |
|-------|--------|-------|
| n8n MCP Server | ACTIF | Via `.mcp.json` - demarrage automatique |
| n8n-expression-syntax | ACTIF | `/n8n-expression-syntax` |
| n8n-mcp-tools-expert | ACTIF | `/n8n-mcp-tools-expert` |
| n8n-workflow-patterns | ACTIF | `/n8n-workflow-patterns` |
| n8n-validation-expert | ACTIF | `/n8n-validation-expert` |
| n8n-node-configuration | ACTIF | `/n8n-node-configuration` |
| n8n-code-javascript | ACTIF | `/n8n-code-javascript` |
| n8n-code-python | ACTIF | `/n8n-code-python` |

**Sources locales:**
- Skills: [n8n-skills/skills/](n8n-skills/skills/)
- Configuration MCP: [.mcp.json](.mcp.json)

---

## Outils et ressources disponibles

### 1. n8n MCP Server
**Serveur Model Context Protocol offrant un acces complet a l'ecosysteme n8n**

**Configuration:** [.mcp.json](.mcp.json)
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "command": "npx",
      "args": ["-y", "n8n-mcp"],
      "env": {
        "MCP_MODE": "stdio",
        "LOG_LEVEL": "error",
        "DISABLE_CONSOLE_OUTPUT": "true"
      }
    }
  }
}
```

**Statistiques:**
- **1,084 nodes n8n** disponibles (537 core + 547 community verified)
- **99% de couverture** des proprietes des nodes avec schemas detailles
- **87% de documentation** provenant des sources officielles n8n
- **2,646 configurations reelles** pre-extraites
- **2,709 templates de workflows** avec metadonnees completes
- **265 variantes d'outils** documentees pour l'IA

---

### OUTILS MCP - Reference Complete

#### Outils de Decouverte (Toujours disponibles)

| Outil | Description | Temps |
|-------|-------------|-------|
| `search_nodes` | Rechercher des nodes par mot-cle | <20ms |
| `get_node` | Details complets d'un node (modes: info, docs, search_properties, versions) | <10ms |
| `search_templates` | Rechercher parmi 2,700+ templates (modes: keyword, by_nodes, by_task, by_metadata) | <50ms |
| `get_template` | Recuperer un template specifique | <50ms |

#### Outils de Validation (Toujours disponibles)

| Outil | Description | Temps |
|-------|-------------|-------|
| `validate_node` | Valider configuration d'un node (modes: minimal, full) | <100ms |
| `validate_workflow` | Valider un workflow complet | 100-500ms |

#### Outils de Gestion de Workflows (Requiert API n8n)

| Outil | Description | Temps |
|-------|-------------|-------|
| `n8n_create_workflow` | Creer un nouveau workflow | 100-500ms |
| `n8n_update_partial_workflow` | Modifier un workflow (17 types d'operations!) | 50-200ms |
| `n8n_validate_workflow` | Valider par ID | 100-500ms |
| `n8n_deploy_template` | Deployer un template vers n8n | 200-500ms |
| `n8n_workflow_versions` | Gestion des versions et rollback | 100-300ms |
| `n8n_test_workflow` | Tester l'execution d'un workflow | Variable |
| `n8n_executions` | Gerer les executions | Variable |
| `n8n_autofix_workflow` | Correction automatique des problemes | 100-300ms |

#### Outils d'Aide

| Outil | Description |
|-------|-------------|
| `tools_documentation` | Meta-documentation de tous les outils |
| `ai_agents_guide` | Guide complet pour workflows IA |
| `n8n_health_check` | Verification de sante du serveur |

---

### CRITIQUE: Formats nodeType

**DEUX formats differents selon les outils!**

#### Format Court (pour search/validate)
```javascript
"nodes-base.slack"
"nodes-base.httpRequest"
"nodes-base.webhook"
"nodes-langchain.agent"
```

**Utilise par:** search_nodes, get_node, validate_node, validate_workflow

#### Format Long (pour workflow management)
```javascript
"n8n-nodes-base.slack"
"n8n-nodes-base.httpRequest"
"n8n-nodes-base.webhook"
"@n8n/n8n-nodes-langchain.agent"
```

**Utilise par:** n8n_create_workflow, n8n_update_partial_workflow

#### Conversion Automatique
```javascript
// search_nodes retourne LES DEUX formats
{
  "nodeType": "nodes-base.slack",              // Pour search/validate
  "workflowNodeType": "n8n-nodes-base.slack"   // Pour workflow tools
}
```

---

### Niveaux de Detail get_node

| Niveau | Tokens | Usage |
|--------|--------|-------|
| `minimal` | ~200 | Decouverte rapide |
| `standard` | ~1-2K | **RECOMMANDE** - 95% des cas |
| `full` | ~3-8K | Debug/analyse complete |

**Modes supplementaires:**
- `docs` - Documentation markdown lisible
- `search_properties` - Recherche de proprietes specifiques
- `versions` - Liste des versions avec breaking changes

---

### Profils de Validation

| Profil | Usage | Strictness |
|--------|-------|------------|
| `minimal` | Check rapide | Champs requis seulement |
| `runtime` | **RECOMMANDE** | Valeurs + types |
| `ai-friendly` | Workflows IA | Reduit les faux positifs |
| `strict` | Production | Toutes les verifications |

---

### Configuration avancee (pour gestion des workflows)

Ajouter dans `.mcp.json`:
```json
{
  "mcpServers": {
    "n8n-mcp": {
      "env": {
        "N8N_API_URL": "https://votre-instance.n8n.io",
        "N8N_API_KEY": "votre_api_key_ici",
        "WEBHOOK_SECURITY_MODE": "moderate"
      }
    }
  }
}
```

**Source:** https://github.com/czlonkowski/n8n-mcp

---

## 2. n8n Skills (7 competences specialisees)
**Source:** https://github.com/czlonkowski/n8n-skills

Les skills sont invocables via commande slash ou s'activent automatiquement selon le contexte.

**Installation locale:** [n8n-skills/skills/](n8n-skills/skills/)

---

### Skill #1: n8n-mcp-tools-expert [PRIORITE HAUTE]
**Commande:** `/n8n-mcp-tools-expert`

**Utiliser quand:**
- Recherche de nodes avec `search_nodes`
- Configuration des parametres des outils MCP
- Choix du niveau de detail pour `get_node`
- Acces aux templates et validation
- Gestion de workflows avec l'API

**Documentation detaillee:**
- [SEARCH_GUIDE.md](n8n-skills/skills/n8n-mcp-tools-expert/SEARCH_GUIDE.md)
- [VALIDATION_GUIDE.md](n8n-skills/skills/n8n-mcp-tools-expert/VALIDATION_GUIDE.md)
- [WORKFLOW_GUIDE.md](n8n-skills/skills/n8n-mcp-tools-expert/WORKFLOW_GUIDE.md)

**Pattern le plus utilise (38,287 occurrences):**
```
n8n_update_partial_workflow (99.0% success rate)
→ 56 secondes en moyenne entre les edits
```

**Workflow typique:**
```
search_nodes → get_node (18s avg) → validate_node → n8n_create_workflow
→ n8n_validate_workflow → n8n_update_partial_workflow (x plusieurs) → activateWorkflow
```

---

### Skill #2: n8n-expression-syntax
**Commande:** `/n8n-expression-syntax`

**Utiliser quand:**
- Ecriture d'expressions `{{ }}`
- Acces aux donnees entre nodes
- Erreurs "Cannot read property"
- Mapping de donnees

**Documentation:** [n8n-skills/skills/n8n-expression-syntax/](n8n-skills/skills/n8n-expression-syntax/)

**POINT CRITIQUE - A RETENIR:**
```javascript
// Donnees webhook = TOUJOURS sous $json.body
{{ $json.body.email }}           // Correct
{{ $json.email }}                // ERREUR pour webhook!

// Acces aux donnees d'un autre node
{{ $node["HTTP Request"].json.data }}

// Variables core
$json      // Donnees du node precedent
$input     // Acces programmatique aux inputs
$node      // Acces aux autres nodes
$now       // DateTime actuel (Luxon)
$env       // Variables d'environnement
```

**Regles essentielles:**
1. Toujours utiliser `{{ }}` pour le contenu dynamique
2. Donnees webhook sous `.body`
3. Pas de `{{ }}` dans les Code nodes
4. Guillemets pour les noms de nodes avec espaces
5. Les noms de nodes sont sensibles a la casse

---

### Skill #3: n8n-workflow-patterns
**Commande:** `/n8n-workflow-patterns`

**Utiliser quand:**
- Creation d'un nouveau workflow
- Choix d'architecture
- Questions sur les bonnes pratiques

**Documentation:** [n8n-skills/skills/n8n-workflow-patterns/](n8n-skills/skills/n8n-workflow-patterns/)

**5 patterns architecturaux eprouves (issus de 2,653+ templates):**

| Pattern | Declencheur | Cas d'usage | Doc |
|---------|-------------|-------------|-----|
| Webhook Processing | Webhook Node | Reception de donnees externes | [webhook_processing.md](n8n-skills/skills/n8n-workflow-patterns/webhook_processing.md) |
| HTTP API Integration | Schedule/Webhook | Appels d'APIs externes | [http_api_integration.md](n8n-skills/skills/n8n-workflow-patterns/http_api_integration.md) |
| Database Operations | Any trigger | CRUD, synchronisation | [database_operations.md](n8n-skills/skills/n8n-workflow-patterns/database_operations.md) |
| AI Agent Workflows | Webhook/Chat | Chatbots, agents IA | [ai_agent_workflow.md](n8n-skills/skills/n8n-workflow-patterns/ai_agent_workflow.md) |
| Scheduled Tasks | Schedule Trigger | Taches periodiques | [scheduled_tasks.md](n8n-skills/skills/n8n-workflow-patterns/scheduled_tasks.md) |

---

### Skill #4: n8n-validation-expert
**Commande:** `/n8n-validation-expert`

**Utiliser quand:**
- Erreurs de validation retournees
- Debugging de workflows
- Comprehension des warnings
- Faux positifs de validation

**Documentation:**
- [SKILL.md](n8n-skills/skills/n8n-validation-expert/SKILL.md)
- [ERROR_CATALOG.md](n8n-skills/skills/n8n-validation-expert/ERROR_CATALOG.md)
- [FALSE_POSITIVES.md](n8n-skills/skills/n8n-validation-expert/FALSE_POSITIVES.md)

**La validation est ITERATIVE (telemetrie: 7,841 occurrences):**
```
1. Configurer node
   ↓
2. validate_node (23 secondes de reflexion)
   ↓
3. Lire les erreurs attentivement
   ↓
4. Corriger les erreurs
   ↓
5. validate_node a nouveau (58 secondes de correction)
   ↓
6. Repeter jusqu'a validation (generalement 2-3 iterations)
```

**Types d'erreurs:**
- `missing_required` - Champ requis manquant
- `invalid_value` - Valeur non autorisee
- `type_mismatch` - Mauvais type de donnee
- `invalid_reference` - Node reference inexistant
- `invalid_expression` - Syntaxe d'expression incorrecte

---

### Skill #5: n8n-node-configuration
**Commande:** `/n8n-node-configuration`

**Utiliser quand:**
- Configuration de nodes complexes
- Proprietes avec dependances
- Nodes AI/LangChain
- Choix du niveau de detail `get_node`

**Documentation:**
- [SKILL.md](n8n-skills/skills/n8n-node-configuration/SKILL.md)
- [DEPENDENCIES.md](n8n-skills/skills/n8n-node-configuration/DEPENDENCIES.md)
- [OPERATION_PATTERNS.md](n8n-skills/skills/n8n-node-configuration/OPERATION_PATTERNS.md)

**Dependances entre proprietes:**
```
HTTP Request:
  - method: GET → pas de body
  - method: POST → body requis
  - authentication: OAuth2 → credentials specifiques

AI Agent:
  - connectionType: "ai_agent" → memory optionnelle
  - connectionType: "ai_tool" → pas de memory
```

---

### Skill #6: n8n-code-javascript
**Commande:** `/n8n-code-javascript`

**Utiliser quand:**
- Ecriture de code dans Code nodes
- Transformation de donnees complexes
- Logique conditionnelle avancee
- Requetes HTTP dans le code

**Documentation:**
- [SKILL.md](n8n-skills/skills/n8n-code-javascript/SKILL.md)
- [DATA_ACCESS.md](n8n-skills/skills/n8n-code-javascript/DATA_ACCESS.md)
- [BUILTIN_FUNCTIONS.md](n8n-skills/skills/n8n-code-javascript/BUILTIN_FUNCTIONS.md)
- [COMMON_PATTERNS.md](n8n-skills/skills/n8n-code-javascript/COMMON_PATTERNS.md)
- [ERROR_PATTERNS.md](n8n-skills/skills/n8n-code-javascript/ERROR_PATTERNS.md)

**Patterns essentiels:**

```javascript
// Acces aux donnees - MODES
const allItems = $input.all();      // Tous les items
const firstItem = $input.first();   // Premier item seulement
const itemData = $json;             // Donnees de l'item courant

// CRITIQUE: Webhook data
const webhookData = $input.first().json.body;  // Correct!

// Format de retour OBLIGATOIRE
return [{json: { key: "value" }}];  // Toujours un tableau d'objets avec .json

// Acces aux autres nodes
const httpResult = $node["HTTP Request"].json;

// HTTP requests avec helpers
const response = await $helpers.httpRequest({
  method: 'POST',
  url: 'https://api.example.com/data',
  body: { key: 'value' },
  headers: { 'Content-Type': 'application/json' }
});

// DateTime avec Luxon (built-in)
const now = DateTime.now();
const formatted = now.toFormat('yyyy-MM-dd');
```

**Top 5 erreurs a eviter:**
1. Oublier `return [{json: ...}]`
2. Acceder a `$json` directement pour webhook (utiliser `$json.body`)
3. Modifier les items originaux au lieu de creer des copies
4. Oublier `await` pour les operations async
5. Retourner un objet au lieu d'un tableau

---

### Skill #7: n8n-code-python
**Commande:** `/n8n-code-python`

**REGLE D'OR: Utilisez JavaScript pour 95% des cas**

**Utiliser Python uniquement quand:**
- Manipulation de dates complexes
- Calculs mathematiques avances
- Parsing de formats specifiques
- Vous etes plus a l'aise avec Python

**Documentation:**
- [SKILL.md](n8n-skills/skills/n8n-code-python/SKILL.md)
- [DATA_ACCESS.md](n8n-skills/skills/n8n-code-python/DATA_ACCESS.md)
- [STANDARD_LIBRARY.md](n8n-skills/skills/n8n-code-python/STANDARD_LIBRARY.md)

**Limitations Python dans n8n:**
- Pas de libraries externes (pas de requests, pandas, numpy)
- Bibliotheque standard uniquement
- Performance legerement inferieure

```python
# Acces aux donnees
items = _input.all()
first_item = _input.first()
data = _json

# Webhook data
webhook_data = _input.first()['json']['body']

# Format de retour
return [{"json": {"key": "value"}}]
```

---

## n8n_update_partial_workflow - OUTIL LE PLUS UTILISE

**38,287 utilisations - 99.0% de taux de succes**

### 17 Types d'Operations

**Operations sur les Nodes (6 types):**
1. `addNode` - Ajouter un nouveau node
2. `removeNode` - Supprimer un node par ID ou nom
3. `updateNode` - Mettre a jour les proprietes (notation pointee)
4. `moveNode` - Changer la position
5. `enableNode` - Activer un node desactive
6. `disableNode` - Desactiver un node actif

**Operations sur les Connexions (5 types):**
7. `addConnection` - Connecter des nodes (smart params supportes)
8. `removeConnection` - Supprimer une connexion
9. `rewireConnection` - Changer la cible d'une connexion
10. `cleanStaleConnections` - Supprimer les connexions cassees
11. `replaceConnections` - Remplacer toutes les connexions

**Operations sur les Metadonnees (4 types):**
12. `updateSettings` - Parametres du workflow
13. `updateName` - Renommer le workflow
14. `addTag` - Ajouter un tag
15. `removeTag` - Supprimer un tag

**Operations d'Activation (2 types):**
16. `activateWorkflow` - Activer le workflow
17. `deactivateWorkflow` - Desactiver le workflow

### Smart Parameters

**Nodes IF - Noms de branches semantiques:**
```javascript
{
  type: "addConnection",
  source: "IF",
  target: "True Handler",
  branch: "true"  // Au lieu de sourceIndex: 0
}

{
  type: "addConnection",
  source: "IF",
  target: "False Handler",
  branch: "false"  // Au lieu de sourceIndex: 1
}
```

**Nodes Switch - Numeros de cas semantiques:**
```javascript
{
  type: "addConnection",
  source: "Switch",
  target: "Handler A",
  case: 0
}
```

### Types de Connexions IA (8 types)

```javascript
// Language Model
{
  type: "addConnection",
  source: "OpenAI Chat Model",
  target: "AI Agent",
  sourceOutput: "ai_languageModel"
}

// Les 8 types:
// - ai_languageModel
// - ai_tool
// - ai_memory
// - ai_outputParser
// - ai_embedding
// - ai_vectorStore
// - ai_document
// - ai_textSplitter
```

### Parametre Intent (IMPORTANT!)

Toujours inclure `intent` pour de meilleures reponses:

```javascript
n8n_update_partial_workflow({
  id: "workflow-id",
  intent: "Ajouter la gestion d'erreurs pour les echecs API",
  operations: [...]
})
```

---

## Systeme d'Auto-Sanitization

**S'execute automatiquement sur TOUTE mise a jour de workflow**

### Ce qu'il corrige

**Operateurs Binaires** (equals, contains, greaterThan, etc.):
- Supprime `singleValue` (ces operateurs comparent deux valeurs)

**Operateurs Unaires** (isEmpty, isNotEmpty, true, false):
- Ajoute `singleValue: true` (ces operateurs verifient une seule valeur)

**IF/Switch Metadata:**
- Ajoute les metadonnees `conditions.options` manquantes

### Ce qu'il NE PEUT PAS corriger

- Connexions cassees vers des nodes inexistants
- Nombre de branches ne correspondant pas aux regles
- Etats corrompus paradoxaux

**Solution pour les connexions cassees:**
```javascript
n8n_update_partial_workflow({
  id: "workflow-id",
  operations: [{type: "cleanStaleConnections"}]
})
```

---

## REGLE D'OR DE SECURITE

> **"Ne modifiez JAMAIS vos workflows de production directement avec l'IA"**
>
> Processus obligatoire:
> 1. Copiez le workflow
> 2. Testez en environnement de developpement
> 3. Exportez des backups
> 4. Validez avant deploiement en production

---

## Methodologie de travail

### Phase 1: Analyse
1. **Comprendre le besoin**
   - Lire attentivement la demande
   - Identifier les objectifs du workflow
   - Clarifier les points ambigus avec l'utilisateur

2. **Analyser l'existant** (si correction/amelioration)
   - Utiliser le n8n MCP Server pour recuperer le workflow
   - Identifier les erreurs, inefficacites ou points d'amelioration
   - Documenter les problemes trouves

### Phase 2: Conception
1. **Planifier la solution**
   - Utiliser les **n8n-workflow-patterns** pour choisir l'architecture appropriee
   - Identifier les nodes necessaires avec **search_nodes**
   - Prevoir la gestion des erreurs et cas limites

2. **Valider l'approche**
   - S'assurer que la solution repond au besoin
   - Verifier la compatibilite avec l'infrastructure existante
   - Demander confirmation si des choix architecturaux majeurs sont necessaires

### Phase 3: Implementation
1. **Creer/Modifier le workflow**
   - Utiliser **n8n_create_workflow** pour creer
   - Utiliser **n8n_update_partial_workflow** pour editer (iteratif!)
   - Appliquer les bonnes pratiques de **n8n-node-configuration**
   - Ecrire du code propre avec **n8n-code-javascript** ou **n8n-code-python**

2. **Valider**
   - Utiliser **validate_node** apres chaque configuration
   - Utiliser **n8n_validate_workflow** regulierement
   - **Attendre 2-3 cycles de validation** (c'est normal!)

3. **Activer le workflow**
   - Utiliser `{type: "activateWorkflow"}` une fois pret

### Phase 4: Documentation et livraison
1. **Documenter**
   - Expliquer les choix techniques
   - Documenter les nodes complexes
   - Fournir des instructions d'utilisation si necessaire

2. **Livrer**
   - Presenter le workflow finalise
   - Expliquer les ameliorations apportees
   - Fournir des recommandations pour l'utilisation

---

## Standards de qualite

### Qualite du code
- Code lisible et bien structure
- Variables et fonctions nommees de maniere explicite
- Commentaires sur les parties complexes
- Gestion appropriee des erreurs

### Architecture des workflows
- Structure logique et claire
- Separation des responsabilites
- Reutilisabilite des composants
- Performance optimisee

### Robustesse
- Gestion des cas d'erreur
- Validation des donnees entrantes
- Retry logic appropriee
- Logging et monitoring

### Securite
- Utilisation securisee des credentials
- Validation des inputs
- Pas de donnees sensibles en dur dans le workflow
- Respect des bonnes pratiques de securite

---

## Workflow de creation/correction/amelioration

### Pour une CREATION
```
1. Analyse du besoin
   ↓
2. Choix du pattern architectural (n8n-workflow-patterns)
   ↓
3. Selection des nodes (search_nodes → get_node)
   ↓
4. Creation du workflow (n8n_create_workflow)
   ↓
5. Configuration iterative (n8n_update_partial_workflow x plusieurs)
   ↓
6. Validation (n8n_validate_workflow) - 2-3 cycles
   ↓
7. Tests et ajustements
   ↓
8. Activation (activateWorkflow)
   ↓
9. Documentation et livraison
```

### Pour une CORRECTION
```
1. Recuperation du workflow via n8n_get_workflow
   ↓
2. Identification des erreurs (n8n_validate_workflow)
   ↓
3. Analyse des causes racines
   ↓
4. Correction des erreurs (n8n_update_partial_workflow)
   ↓
5. Validation de la correction
   ↓
6. Tests de non-regression
   ↓
7. Documentation des corrections
```

### Pour une AMELIORATION
```
1. Analyse du workflow existant
   ↓
2. Identification des points d'amelioration
   ↓
3. Proposition d'optimisations
   ↓
4. Validation de l'approche avec l'utilisateur
   ↓
5. Implementation des ameliorations
   ↓
6. Tests de performance/fonctionnels
   ↓
7. Documentation des changements
```

---

## Bonnes pratiques

### Utilisation des outils MCP

**Workflow recommande:**
```javascript
// 1. Rechercher le node
search_nodes({query: "slack"})

// 2. Obtenir les details (detail: "standard" par defaut)
get_node({nodeType: "nodes-base.slack"})

// 3. Valider la configuration
validate_node({
  nodeType: "nodes-base.slack",
  config: {...},
  profile: "runtime"
})

// 4. Creer/modifier le workflow
n8n_create_workflow({...})
// ou
n8n_update_partial_workflow({
  id: "...",
  intent: "Description de l'intention",
  operations: [...]
})

// 5. Valider le workflow complet
n8n_validate_workflow({id: "..."})

// 6. Activer
n8n_update_partial_workflow({
  id: "...",
  operations: [{type: "activateWorkflow"}]
})
```

### A FAIRE
- Utiliser `get_node({detail: "standard"})` pour la plupart des cas
- Specifier le profil de validation explicitement (`profile: "runtime"`)
- Utiliser les smart parameters (`branch`, `case`) pour la clarte
- Inclure le parametre `intent` dans les mises a jour
- Valider apres chaque changement significatif
- Construire les workflows de maniere iterative (56s avg entre edits)
- Utiliser `includeExamples: true` pour les configs reelles
- Utiliser `n8n_deploy_template` pour demarrer rapidement

### A NE PAS FAIRE
- Utiliser `detail: "full"` sauf si necessaire (gaspille des tokens)
- Oublier le prefixe nodeType (`nodes-base.*`)
- Ignorer les profils de validation
- Essayer de construire des workflows en une seule fois
- Ignorer le comportement d'auto-sanitization
- Utiliser le prefixe complet (`n8n-nodes-base.*`) avec les outils search/validate

---

## Processus de validation finale

Avant de considerer un workflow comme termine, verifier:

- [ ] Le workflow repond au besoin exprime
- [ ] Aucune erreur de validation
- [ ] Tests fonctionnels passes
- [ ] Gestion des erreurs en place
- [ ] Code propre et documente
- [ ] Performance acceptable
- [ ] Securite respectee
- [ ] Documentation fournie
- [ ] Workflow active (si requis)

---

## Exemples pratiques d'utilisation

### Exemple 1: Creer un workflow webhook → API → Database

**Demande utilisateur:**
"Je veux recevoir des donnees via webhook, les enrichir avec une API externe, puis les stocker en base de donnees"

**Process automatique:**

1. **n8n-workflow-patterns** → Active le pattern "Webhook Processing" + "Database Operations"
2. **search_nodes** → Recherche des nodes:
   ```javascript
   search_nodes({query: "webhook"})
   search_nodes({query: "http request"})
   search_nodes({query: "postgres"})
   ```
3. **get_node** → Details de chaque node
4. **n8n_create_workflow** → Cree le workflow initial
5. **n8n_update_partial_workflow** → Ajoute les connexions et configurations
6. **n8n-code-javascript** → Ajoute un Code node pour transformer les donnees:
   ```javascript
   const webhookData = $input.first().json.body;
   const transformed = {
     id: webhookData.id,
     enriched_at: new Date().toISOString(),
     api_data: $node["HTTP Request"].json
   };
   return [{json: transformed}];
   ```
7. **n8n_validate_workflow** → Valide le workflow complet
8. **activateWorkflow** → Active le workflow

**Resultat:** Workflow production-ready, valide, documente

---

### Exemple 2: Corriger une erreur "Cannot read property"

**Demande utilisateur:**
"Mon workflow retourne 'Cannot read property body of undefined'"

**Process de correction:**

1. **n8n-validation-expert** → Identifie l'erreur comme un probleme d'acces aux donnees
2. **n8n-expression-syntax** → Explique que:
   - Donnees webhook: `$json.body` (pas juste `$json`)
   - Donnees d'un node precedent: `$node["Node Name"].json`
3. **n8n-code-javascript** → Corrige le code:
   ```javascript
   // INCORRECT
   const data = $json;

   // CORRECT pour webhook
   const data = $input.first().json.body;
   ```
4. **n8n_update_partial_workflow** → Applique la correction
5. **n8n_validate_workflow** → Re-valide apres correction

**Resultat:** Erreur corrigee, code robuste

---

### Exemple 3: Deployer un template rapidement

**Demande utilisateur:**
"Je veux un workflow webhook vers Slack rapidement"

**Process:**

```javascript
// 1. Rechercher un template
search_templates({
  query: "webhook slack notification",
  limit: 5
})

// 2. Deployer directement
n8n_deploy_template({
  templateId: 2947,
  name: "Mon Slack Notifier",
  autoFix: true,
  autoUpgradeVersions: true
})
// Retourne: workflow ID, credentials requis, corrections appliquees

// 3. Configurer les credentials et activer
n8n_update_partial_workflow({
  id: "new-workflow-id",
  intent: "Activer le workflow",
  operations: [{type: "activateWorkflow"}]
})
```

---

### Exemple 4: Creer un agent IA conversationnel

**Demande utilisateur:**
"Je veux creer un chatbot IA qui repond via Slack"

**Process de creation:**

1. **n8n-workflow-patterns** → Active "AI Agent Workflows" + "Webhook Processing"

2. **search_nodes** → Trouve les nodes IA:
   ```javascript
   search_nodes({query: "openai", type: "ai"})
   search_nodes({query: "slack"})
   get_node({nodeType: "nodes-langchain.agent"})
   ```

3. **n8n_create_workflow** → Cree le workflow avec:
   - Webhook trigger
   - OpenAI Chat Model
   - AI Agent
   - Slack response

4. **n8n_update_partial_workflow** → Configure les connexions IA:
   ```javascript
   {
     type: "addConnection",
     source: "OpenAI Chat Model",
     target: "AI Agent",
     sourceOutput: "ai_languageModel"
   }
   ```

5. **n8n-code-javascript** → Formate les reponses:
   ```javascript
   const agentResponse = $node["AI Agent"].json.output;
   return [{
     json: {
       channel: $json.body.channel,
       text: agentResponse,
       thread_ts: $json.body.thread_ts
     }
   }];
   ```

6. **n8n_validate_workflow** → Valide la configuration de l'agent
7. **activateWorkflow** → Active le chatbot

**Resultat:** Chatbot IA fonctionnel avec memoire contextuelle

---

## Support et questions

En cas de doute ou pour toute clarification:
- Poser des questions precises a l'utilisateur
- Utiliser les skills appropries pour obtenir de l'aide
- Consulter la documentation locale dans [n8n-skills/](n8n-skills/)
- Utiliser `tools_documentation()` pour l'aide sur les outils MCP
- Utiliser `ai_agents_guide()` pour les workflows IA
- Proposer plusieurs solutions si applicable

---

**Principe directeur**: Viser l'excellence dans chaque workflow produit en exploitant pleinement la synergie entre le n8n MCP Server et les n8n Skills pour delivrer des automatisations robustes, performantes et maintenables.

---

## Ressources et documentation

### Fichiers du projet
| Fichier | Description |
|---------|-------------|
| [.mcp.json](.mcp.json) | Configuration du serveur MCP n8n (ACTIF) |
| [n8n-skills/](n8n-skills/) | Skills installes localement |
| Ce document | Regles du jeu et methodologie |

### Skills - Documentation detaillee
| Skill | Documentation |
|-------|---------------|
| n8n-mcp-tools-expert | [n8n-skills/skills/n8n-mcp-tools-expert/](n8n-skills/skills/n8n-mcp-tools-expert/) |
| n8n-expression-syntax | [n8n-skills/skills/n8n-expression-syntax/](n8n-skills/skills/n8n-expression-syntax/) |
| n8n-workflow-patterns | [n8n-skills/skills/n8n-workflow-patterns/](n8n-skills/skills/n8n-workflow-patterns/) |
| n8n-validation-expert | [n8n-skills/skills/n8n-validation-expert/](n8n-skills/skills/n8n-validation-expert/) |
| n8n-node-configuration | [n8n-skills/skills/n8n-node-configuration/](n8n-skills/skills/n8n-node-configuration/) |
| n8n-code-javascript | [n8n-skills/skills/n8n-code-javascript/](n8n-skills/skills/n8n-code-javascript/) |
| n8n-code-python | [n8n-skills/skills/n8n-code-python/](n8n-skills/skills/n8n-code-python/) |

### Liens externes
| Ressource | URL |
|-----------|-----|
| n8n MCP Server | https://github.com/czlonkowski/n8n-mcp |
| n8n Skills | https://github.com/czlonkowski/n8n-skills |
| Documentation n8n | https://docs.n8n.io |
| Model Context Protocol | https://spec.modelcontextprotocol.io |
| Communaute n8n | https://community.n8n.io |

---

## QUICK REFERENCE - Commandes essentielles

### Invoquer un skill
```
/n8n-mcp-tools-expert     # Guide d'utilisation des outils MCP
/n8n-expression-syntax    # Aide sur les expressions {{ }}
/n8n-workflow-patterns    # Patterns architecturaux
/n8n-validation-expert    # Interpreter les erreurs de validation
/n8n-node-configuration   # Configuration avancee des nodes
/n8n-code-javascript      # Code JavaScript dans Code nodes
/n8n-code-python          # Code Python dans Code nodes
```

### Patterns de donnees critiques
```javascript
// WEBHOOK: donnees sous body
$json.body.field              // Expression
$input.first().json.body      // JavaScript

// NODE PRECEDENT: donnees directes
$json.field                   // Expression
$input.first().json           // JavaScript

// AUTRE NODE: acces par nom
$node["HTTP Request"].json    // Expression et JavaScript

// RETOUR DE CODE NODE: toujours un tableau
return [{json: {key: "value"}}];
```

### Format nodeType - CRITIQUE
```javascript
// Pour search/validate tools
"nodes-base.slack"
"nodes-base.httpRequest"

// Pour workflow management tools
"n8n-nodes-base.slack"
"n8n-nodes-base.httpRequest"
```

### Niveaux de validation
| Profil | Usage | Strictness |
|--------|-------|------------|
| `minimal` | Check rapide | Champs requis seulement |
| `runtime` | **RECOMMANDE** | Valeurs + types |
| `ai-friendly` | Workflows IA | Reduit faux positifs |
| `strict` | Production | Toutes verifications |

### Outils MCP les plus utilises
| Outil | Usage | Succes |
|-------|-------|--------|
| `n8n_update_partial_workflow` | Editer workflows | 99.0% |
| `search_nodes` | Trouver nodes | 99.9% |
| `get_node` | Details nodes | 99.9% |
| `validate_workflow` | Valider | 98.5% |

---

## Quick Start

**Tout est pret pour creer des workflows n8n de haute qualite!**

1. **MCP Server:** Configure dans [.mcp.json](.mcp.json) - demarrage automatique
2. **7 Skills:** Installes dans [n8n-skills/skills/](n8n-skills/skills/) et accessibles via `/skill-name`
3. **Configuration optionnelle:** Ajouter API key n8n pour gestion des workflows

**Premier workflow suggere:**
> "Cree un webhook qui recoit des donnees JSON, les valide, puis envoie une notification Slack"

Ce workflow utilise:
- `/n8n-workflow-patterns` pour l'architecture
- `search_nodes` + `get_node` pour les nodes
- `/n8n-node-configuration` pour les nodes Webhook et Slack
- `/n8n-expression-syntax` pour le mapping des donnees ($json.body!)
- `/n8n-validation-expert` pour validation finale

---

**Version du document:** 4.0 - Installation complete MCP + Skills avec documentation exhaustive
**Derniere mise a jour:** 2026-01-23
**Sources:**
- https://github.com/czlonkowski/n8n-mcp
- https://github.com/czlonkowski/n8n-skills
