#!/usr/bin/env bash
# Synchronise ce dépôt avec GitHub : git add, commit, push.
# Usage : ./sync.sh ["message de commit"]
set -euo pipefail

cd "$(dirname "$0")"

MSG="${1:-Mise à jour $(date '+%Y-%m-%d %H:%M')}"

if [ ! -d .git ]; then
    echo "Ce dossier n'est pas un dépôt git."
    exit 1
fi

if ! git remote get-url origin >/dev/null 2>&1; then
    echo "Aucun dépôt distant 'origin' configuré."
    echo "Voir ReadMe.md, section « Synchroniser avec GitHub »."
    exit 1
fi

git add -A

# Modifications à valider ?
CHANGED=0
if ! git diff --cached --quiet; then
    git commit -m "$MSG"
    CHANGED=1
fi

# Commits à envoyer ? (sans branche suivie : premier envoi)
if git rev-parse --abbrev-ref --symbolic-full-name '@{upstream}' >/dev/null 2>&1; then
    HAS_UPSTREAM=1
    AHEAD="$(git rev-list --count '@{upstream}..HEAD')"
else
    HAS_UPSTREAM=0
    AHEAD=1
fi

if [ "$CHANGED" -eq 0 ] && [ "$AHEAD" -eq 0 ]; then
    echo "Aucune modification"
    exit 0
fi

if [ "$HAS_UPSTREAM" -eq 1 ]; then
    git push
else
    git push -u origin "$(git rev-parse --abbrev-ref HEAD)"
fi

echo "✅ Synchronisation Ok"
