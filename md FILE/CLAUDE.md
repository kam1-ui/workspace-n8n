# CLAUDE.md - Workspace n8n MCP

Instructions Claude Code pour le workspace n8n MCP.

## Import des instructions partagées

@.github/copilot-instructions.md

## Contexte

Workspace dédié à la configuration et l'utilisation du serveur MCP n8n avec VS Code et Claude Code.

## Architecture

- **Serveur n8n MCP** : Connexion HTTP vers instance n8n de production
- **Sequential Thinking MCP** : Bridge local sur http://127.0.0.1:3101
- Configuration centralisée dans `.vscode/mcp.json`

## Sécurité

- ❌ Ne JAMAIS commiter le token n8n (`AUTH_TOKEN`)
- ✅ Utiliser les inputs interactifs dans `mcp.json`
- ✅ Token demandé au démarrage de VS Code
