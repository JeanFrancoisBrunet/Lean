#!/usr/bin/env bash
# Crée un menu Lean 4 et une icône de lancement sur le Raspberry Pi 5.
# Usage : bash installer_icone_lean.sh
set -euo pipefail

LEAN_DIR="$HOME/lean"
PROJET="$LEAN_DIR/decouverte"
MENU="$LEAN_DIR/lean_menu.sh"
ICONE="$LEAN_DIR/lean_icone.svg"
APPS_DIR="$HOME/.local/share/applications"

if [ ! -d "$PROJET" ]; then
    echo "Projet introuvable : $PROJET"
    echo "Lance d'abord install_lean.sh."
    exit 1
fi

mkdir -p "$APPS_DIR"

# ---------------------------------------------------------------
# 1. Le menu
# ---------------------------------------------------------------
cat > "$MENU" <<'MENU_EOF'
#!/usr/bin/env bash
# Menu de travail Lean 4
export PATH="$HOME/.elan/bin:$PATH"
cd "$HOME/lean/decouverte" || { echo "Dossier du projet introuvable."; read -r; exit 1; }

FICHIER=""

choisir_editeur() {
    for e in geany mousepad code; do
        if command -v "$e" >/dev/null 2>&1; then echo "$e"; return; fi
    done
    echo "nano"
}

choisir_fichier() {
    mapfile -t fichiers < <(ls -1 *.lean 2>/dev/null)
    if [ "${#fichiers[@]}" -eq 0 ]; then
        echo "Aucun fichier .lean dans le dossier." >&2
        return 1
    fi
    echo "Fichiers disponibles :" >&2
    local i=1
    for f in "${fichiers[@]}"; do
        echo "  $i) $f" >&2
        i=$((i + 1))
    done
    read -rp "Numéro : " n
    if [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "${#fichiers[@]}" ]; then
        FICHIER="${fichiers[$((n - 1))]}"
        return 0
    fi
    echo "Choix invalide." >&2
    return 1
}

verifier() {
    choisir_fichier || return
    echo
    echo "=== Vérification de $FICHIER ==="
    lake env lean "$FICHIER"
    echo "=== Fin (aucun message = tout est prouvé) ==="
}

modifier() {
    choisir_fichier || return
    local ed
    ed="$(choisir_editeur)"
    "$ed" "$FICHIER"
}

surveiller() {
    choisir_fichier || return
    local ed
    ed="$(choisir_editeur)"
    if [ "$ed" = "nano" ]; then
        echo
        echo "Aucun éditeur graphique trouvé."
        echo "Ouvre un 2e terminal et tape :  nano ~/lean/decouverte/$FICHIER"
    else
        "$ed" "$FICHIER" >/dev/null 2>&1 &
    fi
    echo
    echo "Surveillance de $FICHIER : modifie-le et enregistre (Ctrl+S)."
    echo "Le résultat s'affiche ici à chaque enregistrement. Ctrl+C pour arrêter."
    (
        trap 'exit 0' INT
        last=""
        while true; do
            cur="$(stat -c %Y "$FICHIER")"
            if [ "$cur" != "$last" ]; then
                clear
                echo "=== $(date +%H:%M:%S) : $FICHIER ==="
                lake env lean "$FICHIER"
                echo "=== Fin (aucun message = tout est prouvé) ==="
                last="$cur"
            fi
            sleep 1
        done
    )
}

nouveau() {
    read -rp "Nom du nouveau fichier (sans .lean) : " nom
    if ! [[ "$nom" =~ ^[A-Za-z0-9_]+$ ]]; then
        echo "Nom invalide : lettres, chiffres et _ uniquement."
        return
    fi
    if [ -e "$nom.lean" ]; then
        echo "$nom.lean existe déjà."
        return
    fi
    cat > "$nom.lean" <<'LEAN_EOF'
import Mathlib

-- Mon fichier d'essai

theorem mon_theoreme (a b : Nat) : a + b = b + a := by
  omega

#eval 2 + 2
#check Nat.add_comm
LEAN_EOF
    echo "Fichier $nom.lean créé."
}

aide() {
    cat <<'AIDE_EOF'

=== Mémo Lean ===

Principe : un fichier .lean contient des énoncés (theorem) et leurs preuves.
  - Aucun message  : tout est accepté.
  - warning sorry  : une preuve reste à écrire.
  - error          : une preuve est fausse (le message dit pourquoi).

Cycle de travail :
  1. Modifier le fichier (option 2, ou option 4 pour un retour automatique)
  2. Enregistrer
  3. Lire le résultat de Lean, corriger, recommencer

Tactiques utiles :
  omega       arithmétique sur les entiers
  simp        simplification automatique
  ring        égalités algébriques
  positivity  prouver qu'une expression est positive
  tauto       logique pure
  intro h     supposer une hypothèse et la nommer h
  exact t     conclure avec le terme t
  rw [th]     réécrire avec un théorème
  induction n with ...   preuve par récurrence

Commandes pratiques dans un fichier :
  #eval expr     calculer une expression
  #check nom     voir l'énoncé d'un théorème existant

AIDE_EOF
}

trap : INT

while true; do
    clear
    echo "=========================================="
    echo "   Lean 4 + Mathlib  -  Raspberry Pi 5"
    echo "   Dossier : ~/lean/decouverte"
    echo "=========================================="
    echo "  1) Vérifier un fichier"
    echo "  2) Modifier un fichier"
    echo "  3) Créer un nouveau fichier d'essai"
    echo "  4) Mode surveillance (vérification à chaque enregistrement)"
    echo "  5) Aide-mémoire"
    echo "  6) Ouvrir un terminal dans le dossier du projet"
    echo "  0) Quitter"
    echo
    read -rp "Ton choix : " choix
    case "$choix" in
        1) verifier ;;
        2) modifier ;;
        3) nouveau ;;
        4) surveiller ;;
        5) aide ;;
        6) echo "Tape 'exit' pour revenir au menu."; bash ;;
        0) exit 0 ;;
        *) echo "Choix invalide." ;;
    esac
    echo
    read -rp "Appuie sur Entrée pour revenir au menu..." _
done
MENU_EOF
chmod +x "$MENU"

# ---------------------------------------------------------------
# 2. L'icône
# ---------------------------------------------------------------
cat > "$ICONE" <<'SVG_EOF'
<svg xmlns="http://www.w3.org/2000/svg" width="128" height="128" viewBox="0 0 128 128">
  <rect x="4" y="4" width="120" height="120" rx="24" fill="#1b2b4a"/>
  <text x="64" y="94" font-size="84" font-family="DejaVu Sans, sans-serif"
        font-weight="bold" fill="#ffffff" text-anchor="middle">λ</text>
</svg>
SVG_EOF

# ---------------------------------------------------------------
# 3. Le lanceur (menu des applications + bureau)
# ---------------------------------------------------------------
LANCEUR="$APPS_DIR/lean.desktop"
cat > "$LANCEUR" <<DESKTOP_EOF
[Desktop Entry]
Type=Application
Name=Lean 4
Comment=Atelier Lean 4 + Mathlib
Exec=$MENU
Icon=$ICONE
Terminal=true
Categories=Education;Science;Development;
DESKTOP_EOF
chmod +x "$LANCEUR"

DESKTOP_DIR="$(xdg-user-dir DESKTOP 2>/dev/null || echo "$HOME/Desktop")"
if [ -d "$DESKTOP_DIR" ]; then
    cp "$LANCEUR" "$DESKTOP_DIR/Lean.desktop"
    chmod +x "$DESKTOP_DIR/Lean.desktop"
    gio set "$DESKTOP_DIR/Lean.desktop" metadata::trusted true 2>/dev/null || true
    echo "Icône créée sur le bureau : $DESKTOP_DIR/Lean.desktop"
fi

echo
echo "Terminé."
echo "  - Icône « Lean 4 » sur le bureau et dans le menu des applications."
echo "  - Menu lançable aussi à la main : $MENU"
echo "Si le bureau demande une confirmation au premier clic,"
echo "choisis « Exécuter » (ou « Faire confiance »)."
