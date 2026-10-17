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

if git diff --cached --quiet; then
    echo "Rien de nouveau à valider."
else
    git commit -m "$MSG"
fi

BRANCHE="$(git rev-parse --abbrev-ref HEAD)"
git push -u origin "$BRANCHE"

echo "Synchronisation terminée."
