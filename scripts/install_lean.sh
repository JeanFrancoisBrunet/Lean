#!/usr/bin/env bash
# Installation de Lean 4 + Mathlib sur Raspberry Pi 5 (aarch64)
# Usage : bash install_lean.sh
set -euo pipefail

PROJET_DIR="$HOME/lean"
PROJET_NOM="decouverte"

echo "==> Vérification de l'architecture"
ARCH="$(uname -m)"
if [ "$ARCH" != "aarch64" ]; then
    echo "Architecture inattendue : $ARCH (attendu : aarch64). Arrêt."
    exit 1
fi

echo "==> Dépendances"
sudo apt update
sudo apt install -y git curl build-essential

echo "==> Installation d'elan (gestionnaire de versions Lean)"
if ! command -v elan >/dev/null 2>&1 && [ ! -x "$HOME/.elan/bin/elan" ]; then
    curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- -y
fi
export PATH="$HOME/.elan/bin:$PATH"

echo "==> Version installée"
elan --version
lean --version

echo "==> Création du projet Mathlib dans $PROJET_DIR/$PROJET_NOM"
mkdir -p "$PROJET_DIR"
cd "$PROJET_DIR"
if [ ! -d "$PROJET_NOM" ]; then
    lake new "$PROJET_NOM" math
fi
cd "$PROJET_NOM"

echo "==> Téléchargement du cache Mathlib (évite des heures de compilation)"
lake exe cache get

echo "==> Fichier de découverte : Hello.lean"
cat > Hello.lean <<'EOF'
import Mathlib

-- Évaluer des expressions
#eval "Bonjour Lean sur Pi 5"
#eval (List.range 10).map (· ^ 2)

-- Un premier théorème, prouvé automatiquement
theorem somme_comm (a b : Nat) : a + b = b + a := by
  omega

-- Une identité remarquable sur les réels (Mathlib)
example (a b : ℝ) : (a + b) ^ 2 = a ^ 2 + 2 * a * b + b ^ 2 := by
  ring

-- Inspecter un théorème existant
#check Nat.add_comm
EOF

echo "==> Test"
lake env lean Hello.lean

echo
echo "Terminé. Pour travailler :"
echo "  export PATH=\"\$HOME/.elan/bin:\$PATH\"   # si 'lean' est introuvable"
echo "  cd $PROJET_DIR/$PROJET_NOM"
echo "  lake env lean Hello.lean"
