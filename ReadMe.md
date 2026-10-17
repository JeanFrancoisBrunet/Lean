# Lean 4 : carnet de découverte sur Raspberry Pi 5

Carnet d'apprentissage de **Lean 4** et de sa bibliothèque mathématique **Mathlib**, sur un Raspberry Pi 5 (16 Go de RAM, SSD NVMe de 1 To, Debian Bookworm, Lean 4.35.0).

Ce dépôt n'est pas un logiciel : c'est un journal de découverte. Il contient les exercices faits, le dispositif d'installation et les pièges rencontrés en chemin. Il grandit au fil de l'apprentissage.

## Qu'est-ce que Lean ?

Lean est à la fois un langage de programmation et un **assistant de preuve** : on y écrit des énoncés mathématiques et leurs preuves, et Lean **vérifie** que chaque preuve est correcte, pas à pas. Mathlib est la grande bibliothèque communautaire de mathématiques formalisées qui s'utilise avec Lean.

On ne « lance » donc pas Lean comme une application : on écrit un fichier `.lean`, puis on demande à Lean de le vérifier.

## Contenu du dépôt

| Élément                                                 | Rôle                                                                                      |
|---                                                      |---                                                                                        |
| `Exercices.lean`                                        | 10 exercices progressifs et un défi (arithmétique, logique, réels, ensembles, récurrence) |
| `Hello.lean`                                            | premier fichier de test : `#eval`, un théorème, un `#check`                               |
| `Decouverte.lean`, `Decouverte/`                        | structure générée par `lake new` (bibliothèque du projet)                                 |
| `lakefile.toml`, `lake-manifest.json`, `lean-toolchain` | fixent les versions de Lean et de Mathlib pour reconstruire à l'identique                 |
| `scripts/install_lean.sh`                               | installation complète depuis zéro (elan, Lean, projet Mathlib, cache)                     |
| `scripts/installer_icone_lean.sh`                       | crée l'icône « Lean 4 » et son menu de travail                                            |
| `sync.sh`                                               | synchronise le dépôt avec GitHub (add, commit, push)                                      |
| `.github/`                                              | workflow d'intégration continue généré par `lake new`                                     |

Le dossier `.lake/` (Mathlib et ses fichiers compilés, plusieurs Go) n'est **pas** versionné : il se reconstruit avec `lake exe cache get`.

## Installation

### Option A : depuis zéro, sur un Pi 5 vierge

```bash
bash scripts/install_lean.sh
```

Le script installe `elan` (le gestionnaire de versions de Lean), crée le projet `~/lean/decouverte` avec Mathlib, télécharge le cache pré-compilé, puis teste un fichier `Hello.lean`.

### Option B : reprendre ce dépôt sur une autre machine

```bash
# 1. Installer elan
curl https://elan.lean-lang.org/elan-init.sh -sSf | sh -s -- -y
export PATH="$HOME/.elan/bin:$PATH"

# 2. Cloner le dépôt
mkdir -p ~/lean
git clone git@github.com:JeanFrancoisBrunet/Lean.git ~/lean/decouverte
cd ~/lean/decouverte

# 3. Télécharger le cache Mathlib (évite des heures de compilation)
lake exe cache get

# 4. Tester
lake env lean Hello.lean
```

La bonne version de Lean est téléchargée automatiquement grâce au fichier `lean-toolchain`.

Résultat attendu pour le test :

```
"Bonjour Lean sur Pi 5"
[0, 1, 4, 9, 16, 25, 36, 49, 64, 81]
Nat.add_comm (n m : ℕ) : n + m = m + n
```

### Rendre `lake` et `lean` disponibles dans tous les terminaux

Si un nouveau terminal répond « commande introuvable » :

```bash
echo 'export PATH="$HOME/.elan/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Utilisation

### Le principe : le verdict de Lean

```bash
cd ~/lean/decouverte
lake env lean Exercices.lean
```

| Ce que dit Lean                     | Signification                                                     |
|---                                  |---                                                                |
| aucun message                       | tout est accepté                                                  |
| `warning: declaration uses 'sorry'` | une preuve reste à écrire                                         |
| `error`                             | une preuve est fausse ou mal écrite, le message explique pourquoi |

Le travail est un cycle : **modifier le fichier, enregistrer, lire le verdict, corriger**.

### Le menu et l'icône

```bash
bash scripts/installer_icone_lean.sh
```

Le script crée une icône « Lean 4 » (un λ blanc sur fond bleu) sur le bureau et dans le menu des applications. Elle ouvre un menu en mode texte :

1. vérifier un fichier ;
2. modifier un fichier (Geany, Mousepad ou nano selon ce qui est installé) ;
3. créer un nouveau fichier d'essai à partir d'un modèle ;
4. **mode surveillance** : à chaque enregistrement, le fichier est revérifié automatiquement dans le terminal ;
5. aide-mémoire ;
6. terminal ouvert dans le dossier du projet.

Au premier clic, le bureau peut demander une confirmation : choisir « Exécuter » ou « Faire confiance ».

### Faire les exercices

Dans `Exercices.lean`, chaque `sorry` est une preuve à compléter, avec un indice en commentaire au-dessus.

| Exercices | Thème                                 | Tactiques utiles              |
|---        |---                                    |---                            |
| ex1 à ex3 | arithmétique sur les entiers naturels | `omega`, `simp`               |
| ex4 à ex7 | logique (et, ou, implication)         | `intro`, `And.intro`, `tauto` |
| ex8, ex9  | nombres réels (Mathlib)               | `ring`, `positivity`          |
| ex10      | ensembles                             | `Set.inter_comm`              |
| défi      | récurrence sur la somme des entiers   | `induction`, `rw`, `ring`     |

Astuce : l'avertissement `Exercices.lean:14:8` désigne la ligne 14, celle du `theorem` ; le `sorry` est sur la ligne suivante. Pour remplacer une ligne sans ouvrir d'éditeur :

```bash
sed -i '15s/.*/  omega/' Exercices.lean
```

### Aide-mémoire des tactiques

| Tactique               | Rôle                                    |
|---                     |---                                      |
| `omega`                | arithmétique sur les entiers            |
| `simp`                 | simplification automatique              |
| `ring`                 | égalités algébriques                    |
| `positivity`           | prouver qu'une expression est positive  |
| `tauto`                | logique pure                            |
| `intro h`              | supposer une hypothèse et la nommer `h` |
| `exact t`              | conclure avec le terme `t`              |
| `rw [th]`              | réécrire avec un théorème               |
| `induction n with ...` | preuve par récurrence                   |
| `sorry`                | laisser une preuve à compléter          |

Deux commandes pratiques dans un fichier : `#eval expr` calcule une expression, `#check nom` affiche l'énoncé d'un théorème existant.

## Pièges rencontrés

- **Le cache Mathlib s'interrompt en cours de route** (erreurs `HTTP/2 stream ... was not closed cleanly`, `curl exit code 18`). Relancer `lake exe cache get` ne télécharge que les fichiers manquants. Si les échecs persistent :
  ```bash
  echo "--http1.1" >> ~/.curlrc
  lake exe cache get
  ```
  puis supprimer cette ligne de `~/.curlrc`.
- **`lake` introuvable dans un nouveau terminal** : voir la section sur le `PATH` plus haut.
- **Du code Lean tapé dans le terminal** : le terminal exécute du bash, pas du Lean. Le code Lean va dans un fichier `.lean`.
- **Avertissements `could not canonicalize path`** d'elan : sans conséquence.

## Synchroniser avec GitHub

Le dépôt est hébergé sur <https://github.com/JeanFrancoisBrunet/Lean>.

Le script `sync.sh` enchaîne `git add`, `git commit` et `git push` :

```bash
./sync.sh                       # message de commit automatique (date et heure)
./sync.sh "Exercices 1 à 5"     # message personnalisé
```

### Première mise en place

Le dépôt vide `Lean` existe déjà sur GitHub. Dans le dossier du projet :

```bash
cd ~/lean/decouverte
chmod +x sync.sh
git branch -M main
git remote add origin git@github.com:JeanFrancoisBrunet/Lean.git
./sync.sh "Premier envoi : carnet d'apprentissage Lean 4"
```

(`git remote -v` permet de vérifier si un dépôt distant est déjà configuré ; dans ce cas, `git remote set-url origin git@github.com:JeanFrancoisBrunet/Lean.git` corrige l'adresse.)

La connexion se fait en SSH : la clé publique doit être enregistrée dans les paramètres GitHub. L'adresse SSH (`git@github.com:...`) est préférable à l'adresse HTTPS, qui demanderait un mot de passe ou un jeton à chaque envoi.

## Pour aller plus loin

- **Natural Number Game** (en ligne) : construire à la main les preuves que `omega` fait automatiquement.
- **Theorem Proving in Lean 4** : le livre de référence sur le langage.
- **Mathematics in Lean** : les mathématiques avec Mathlib, directement utilisable dans ce projet.
- **VS Code + extension Lean 4** (éventuellement en SSH vers le Pi) : affichage de l'état des preuves en direct, très utile pour les preuves longues.
