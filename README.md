# Apple II - Jeux d'Aventure et Moteurs de Jeu

Collection de jeux d'aventure interactifs et de moteurs de jeu pour Apple IIe Enhanced, développés en C avec cc65.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

---

## 📖 Vue d'ensemble

Ce dépôt contient des **moteurs de jeu pilotés par données** pour Apple II, illustrant une approche moderne du développement rétro : un moteur compact (~13-15 KB) charge dynamiquement du contenu illimité depuis le disque ProDOS (jusqu'à 32 MB).

**Philosophie** : Séparer le code (moteur) des données (contenu) pour permettre des jeux massifs avec une empreinte mémoire minimale.

### Projets inclus

| Projet | Description | Taille | Scènes | Langues |
|--------|-------------|--------|--------|---------|
| **SCOSWAMP** | Le Marais aux Scorpions - Livre dont vous êtes le héros | ~13-15 KB | 178 | FR/EN |
| **SPACETRIP** | Space Explorer Trip - Aventure galactique interactive | ~13 KB | 14 | FR/EN |

---

## 🎮 SCOSWAMP - Le Marais aux Scorpions

### Description

Adaptation pour Apple II du célèbre livre-jeu "Scorpion Swamp" (1985) par Steve JACKSON & Ian LIVINGSTONE.

**Caractéristiques :**
- ✅ **178 scènes** complètes (français et anglais)
- ✅ **Graphismes HGR** haute résolution (280×192 pixels, 6 couleurs)
- ✅ **Mode texte 80 colonnes** pour lecture confortable
- ✅ **Bascule instantanée** image ↔ texte (ESPACE/RETURN/ESC)
- ✅ **Navigation par choix** (système de branches narratives)
- ✅ **Textes optimisés** pour affichage 24 lignes (≤18 lignes par scène)

### Structure du projet

```
SCOSWAMP/
├── SCOSWAMP.BIN          # Exécutable (13-15 KB, démarre à $4000)
├── SRC/                  # Sources C
│   ├── scoswamp.c        # Programme principal
│   ├── paths.c           # Gestion des chemins ProDOS
│   ├── paths.h           # En-têtes
│   └── Makefile          # Compilation automatisée
├── IMG/                  # Images HGR (8 KB chacune)
│   ├── N000/             # Scènes 0-49
│   ├── N050/             # Scènes 50-99
│   └── ...               # Jusqu'à N350/
├── TEXTFR/               # Textes français (178 fichiers .TXT)
│   └── N000/ ... N350/   # Organisés par tranches de 50
├── TEXTEN/               # Textes anglais
└── DOCS/                 # Documentation technique

Total contenu : ~9 MB de données + 13 KB de moteur
```

### Compilation

```bash
cd SCOSWAMP/SRC

# Compilation complète
make

# Nettoyage et recompilation
make rebuild

# Afficher la configuration
make info

# Nettoyer les fichiers temporaires
make clean
```

**Compilation manuelle :**

```bash
cl65 -t apple2enh -O -Oirs \
     -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o ../SCOSWAMP.BIN scoswamp.c paths.c
```

**Flags importants :**
- `-t apple2enh` : Cible Apple IIe Enhanced (65C02)
- `-O -Oirs` : Optimisations (inline, registres, taille)
- `-Wl -S,0x4000` : Démarre à $4000 (préserve HGR Page 1 à $2000-$3FFF)
- `-Wl -D,__EXEHDR__=0` : Binaire brut sans en-tête AppleSingle

### Exécution

**Sur Virtual ][ (macOS) :**

1. Monter le dossier SCOSWAMP comme disque ProDOS :
   - Menu → "Mount Folder as ProDOS Disk"
2. Démarrer ProDOS
3. Exécuter : `]BRUN SCOSWAMP`

**Commandes en jeu :**

| Touche | Action |
|--------|--------|
| `F` ou `E` | Choix de langue (Français/English) au démarrage |
| `ESPACE` / `RETURN` / `ESC` | Basculer entre graphique HGR et texte |
| `A-Z` | Choisir une option (A = premier choix, B = deuxième, etc.) |
| `Q` | Quitter vers ProDOS |

**Comportement :** Chaque nouvelle scène s'affiche d'abord en mode graphique HGR, puis l'utilisateur peut basculer vers le texte pour lire l'histoire.

---

## 🚀 SPACETRIP - Space Explorer Trip

### Description

**Moteur de jeu d'aventure pilotée par données** démontrant une architecture moderne pour Apple II : moteur compact + contenu illimité sur disque.

**Architecture révolutionnaire :**

| Approche traditionnelle (1980-1990) | SPACETRIP (2025) |
|-------------------------------------|------------------|
| Contenu codé en dur dans le programme | Moteur 13 KB + données sur disque |
| Limité par 64 KB RAM | Contenu illimité (jusqu'à 32 MB) |
| 10-20 scènes maximum | Potentiel : 1000+ scènes |
| Ajout de contenu = recompilation | Ajout de contenu = copier des fichiers |

**Ratio d'efficacité : 1000:1** (contenu vs. empreinte mémoire)

### Caractéristiques

- ✅ **Moteur compact** : 13 KB en mémoire
- ✅ **Chargement dynamique** : Seule la scène actuelle est en RAM
- ✅ **Bilingue** : Français/Anglais (facilement extensible)
- ✅ **Moddable** : Les joueurs peuvent créer leur propre contenu
- ✅ **Extensible** : ~16 KB libres pour futures fonctionnalités (combat, inventaire)

### Structure

```
SPACETRIP/
├── SPACETRIP.BIN         # Moteur (13 KB)
├── spacetrip.c           # Source principale
├── paths.c / paths.h     # Gestion des chemins
├── IMG/                  # Images HGR (N001.HGR, N002.HGR, ...)
├── TXTFR/                # Textes français (N001, N002, ...)
└── TXTEN/                # Textes anglais (N001, N002, ...)

Contenu actuel : 14 scènes × 2 langues
Potentiel : 1000+ scènes (limité seulement par l'espace disque)
```

### Principe de fonctionnement

**Boucle de jeu pilotée par données :**

1. Moteur démarre (13 KB chargé en RAM à $4000)
2. Sélection de langue : FR ou EN
3. Pour chaque scène :
   - Construire les chemins (ex: Scène 5, FR → `IMG/N005.HGR` + `TXTFR/N005`)
   - Charger l'image HGR (8 KB) dans $2000-$3FFF
   - Charger le fichier texte (~1 KB) dans un buffer
   - Parser le texte : extraire description + choix
   - Afficher le contenu
   - Attendre l'entrée du joueur
4. Sur choix : Répéter avec le nouvel ID de scène

**L'empreinte mémoire reste constante** quelle que soit la quantité totale de contenu !

### Compilation

Identique à SCOSWAMP :

```bash
cl65 -t apple2enh -O -Oirs \
     -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o SPACETRIP.BIN spacetrip.c paths.c
```

### Créer du contenu

**La beauté de l'approche pilotée par données : aucune recompilation nécessaire !**

**Étapes pour ajouter une scène :**

1. Créer les fichiers texte :
   - `TXTFR/N015` (description française + choix)
   - `TXTEN/N015` (traduction anglaise)

2. Créer l'image HGR :
   - `IMG/N015.HGR` (8192 octets, 280×192 pixels)
   - Utiliser bmp2dhr ou extraire d'images disque

3. Lier depuis une scène existante :
   - Ajouter une ligne de choix : `C 015 Explorer la nébuleuse`

4. **Terminé !** La nouvelle scène est jouable immédiatement.

**Format des fichiers texte :**

```
Home, Sweet home
------------------

Here you stand at the threshold of an extraordinary cosmic adventure!
Your brand new spaceship awaits on the launch pad.

C 002 Heading to the planet of eternal forests
C 003 Racing towards the supermassive black hole
```

- Lignes de texte : Description narrative
- Lignes de choix : `C <scene_id> <titre du choix>`

---

## 🛠️ Développement

### Prérequis

- **cc65** : Compilateur C pour 6502/65C02
  - macOS : `brew install cc65`
  - Linux : `apt-get install cc65` ou télécharger depuis https://cc65.github.io/
- **make** : Automatisation de la compilation
- **Virtual ][** (macOS) ou autre émulateur Apple II
- **AppleCommander** (optionnel) : Manipulation d'images disque

### Configuration matérielle requise

- Apple IIe Enhanced ou ultérieur (65C02 nécessaire)
- 64 KB RAM
- Système d'exploitation ProDOS
- Carte 80 colonnes
- Disque dur ou CFFA recommandé (pour contenu complet 32 MB)

### Carte mémoire

```
$0000-$1FFF : Système (ProDOS, zero page, pile)
$2000-$3FFF : HGR Page 1 (buffer image actuelle, 8 KB)
$4000-$4FFF : Code du moteur (~13-15 KB)
$5000-$9FFF : Disponible pour futures fonctionnalités
$A000-$BFFF : Pile et tas C
$C000-$FFFF : I/O et ROM
```

**Empreinte totale du moteur** : ~22 KB (13 KB code + 9 KB scène actuelle)  
**Disponible pour extension** : ~16 KB (pour combat, inventaire, sauvegardes, etc.)

### Pourquoi démarrer à $4000 ?

La page HGR 1 occupe **$2000-$3FFF** (8192 octets). Si le programme démarrait à l'adresse par défaut (~$0803), il écraserait la zone graphique. En démarrant à **$4000**, on préserve toute la zone HGR.

---

## 📚 Documentation

### Structure du dépôt

```
appleIIsrc/
├── README.md                    # Ce fichier
├── LICENSE                      # GPL v3
├── SCOSWAMP/                    # Le Marais aux Scorpions (projet complet)
├── SPACETRIP/                   # Space Explorer Trip (projet complet)
├── SCOSWAMP.MORE/               # Assets additionnels (PNG, PDF)
└── DOCS/                        # Documentation technique
    ├── HELLO_WORLD-ASM/         # Exemple Hello World en assembleur
    ├── HELLO_WORLD-C/           # Exemple Hello World en C
    ├── cc65/                    # Documentation cc65 complète (HTML)
    ├── OPTIMISATION-RAPPORT.txt # Rapport d'optimisation des textes
    └── FICHIERS-OPTIMISES.txt   # Liste des fichiers optimisés
```

### Guides détaillés

- **SCOSWAMP/SRC/README.md** : Compilation et structure du projet Scorpion Swamp
- **SCOSWAMP/DOCS/README-TEXTES.md** : Format des fichiers texte, optimisations
- **SCOSWAMP/DOCS/PRODOS-MLI.md** : Gestion des chemins ProDOS
- **SPACETRIP/README.TXT** : Architecture pilotée par données, guide complet
- **SPACETRIP/IMPROVEMENTS.TXT** : Fonctionnalités RPG prévues
- **DOCS/HELLO_WORLD-C/README.md** : Guide de compilation Apple II

### Documentation cc65

Documentation HTML complète dans `DOCS/cc65/` :
- `apple2enh.html` : Cible Apple IIe Enhanced
- `cc65.html` : Compilateur C
- `ca65.html` : Assembleur
- `ld65.html` : Éditeur de liens
- `funcref.html` : Référence des fonctions de bibliothèque

---

## 🎯 Caractéristiques techniques

### Architecture pilotée par données

**Principe** : Séparer le code (moteur) des données (contenu)

**Avantages :**

| Aspect | Bénéfice |
|--------|----------|
| **Efficacité mémoire** | Moteur constant (~13 KB), contenu sur disque |
| **Évolutivité** | 1000 scènes = 9 MB sur disque, moteur inchangé |
| **Extensibilité** | Ajout de contenu = copier des fichiers |
| **Modding** | Joueurs peuvent créer leurs propres aventures |
| **Mises à jour** | Nouveaux fichiers de données uniquement |

**Comparaison approche traditionnelle :**
- Traditionnelle : 30 KB programme avec 20 scènes codées en dur
- Pilotée par données : 13 KB moteur + scènes illimitées sur disque
- **1000 scènes** nécessiteraient 1500 KB en approche traditionnelle
- **Pilotée par données** : toujours 13 KB moteur + stockage disque uniquement

### Gestion des chemins ProDOS

Module `paths.c` pour génération dynamique :

```c
build_paths(scene_id, language, imgPath, txtPath);

// Exemple :
build_paths(5, "FR", ...) → "IMG/N005.HGR", "TEXTFR/N005"
build_paths(5, "EN", ...) → "IMG/N005.HGR", "TXTEN/N005"
```

**Contraintes ProDOS :**
- Répertoire racine : 51 entrées max (fixe)
- Sous-répertoires : Aucune limite fixe (croissance dynamique)
- Chemins : ≤64 caractères, composants ≤15 caractères

Ces jeux utilisent seulement **3 entrées racine** (IMG/, TEXTFR/, TEXTEN/), chaque sous-répertoire peut contenir des centaines de fichiers.

### Soft switches vidéo

```c
$C050 (TXTCLR) - Graphiques activés
$C051 (TXTSET) - Mode texte activé
$C052 (MIXCLR) - Plein écran (pas de mixte)
$C054 (LOWSCR) - Page 1
$C057 (HIRES)  - Mode haute résolution
```

### Format des images HGR

- **Emplacement** : IMG/N<id>.HGR
- **Format** : Page HGR brute (8192 octets exactement)
- **Résolution** : 280×192 pixels, 6 couleurs
- **Nommage** : N001.HGR, N002.HGR, N999.HGR (3 chiffres + .HGR)

**Création d'images :**
- Convertisseur bmp2dhr
- Extraire depuis images disque Apple II
- Logiciels graphiques Apple II (Paintworks, etc.)

---

## 🔮 Évolutions futures

### Fonctionnalités RPG planifiées

L'architecture pilotée par données fournit **~16 KB de RAM libre** pour nouvelles fonctionnalités :

**Système de combat :**
- Rencontres dynamiques avec créatures spatiales
- Combat au tour par tour (Attaquer, Défendre, Objet, Fuir)
- Données de monstres chargées depuis fichiers (comme les scènes)
- Images HGR pour monstres (IMG/MONSTERS/)
- Points d'expérience et système de montée de niveau

**Inventaire et objets :**
- Collecter des objets pendant l'exploration
- Clés pour débloquer de nouvelles zones
- Armes et armures (augmentent les statistiques)
- Objets de soin (restaurent HP)
- Objets stockés dans fichiers de données (moddables)

**Statistiques et progression :**
- Statistiques du joueur : HP, Attaque, Défense, Niveau
- Système de sauvegarde/chargement (emplacements multiples)
- Suivi de progression (scènes découvertes)
- Système de score

**Extensions de fichiers de données :**
- MONSTERS.DAT : Définitions de monstres
- ITEMS.DAT : Catalogue d'objets
- DOORS.DAT : Exigences zones verrouillées
- IMG/MONSTERS/*.HGR : Images de combat

Tout en suivant la même philosophie pilotée par données :
→ Moteur reste petit (~15-18 KB avec fonctionnalités RPG)  
→ Contenu croît sur disque (illimité)  
→ Pas de recompilation pour nouveaux monstres/objets

---

## 🐛 Dépannage

### Fichier non trouvé

**Vérifier :**
- Fichiers dans bons répertoires (TEXTFR/, TEXTEN/, IMG/)
- Format 3 chiffres (N001, pas N1)
- Pas d'extension .TXT sur fichiers texte ProDOS
- Dossier Virtual ][ correctement monté
- Utiliser `]CAT` pour vérifier structure ProDOS

### Les choix ne s'affichent pas

**Vérifier :**
- Lignes de choix commencent par "C " (C + espace)
- Format : `C <scene_id> <titre>`
- Lignes sous 80 caractères

### Graphiques corrompus

**Vérifier :**
- Fichiers HGR exactement 8192 octets
- Compilation avec `-Wl -S,0x4000`

### Programme plante au démarrage

**Vérifier :**
- Compilé avec `-Wl -S,0x4000`
- Exécuté avec : `]BRUN <programme>`
- Cible correcte : `-t apple2enh` (nécessite 65C02)

---

## 📦 Outils et ressources

### Développement

- **cc65** : Compilateur C pour 6502 - https://cc65.github.io/
- **make** : Automatisation de la compilation
- **Virtual ][** : Émulateur Apple II pour macOS - https://www.virtualii.com/
- **AppleWin** : Émulateur Apple II pour Windows - https://github.com/AppleWin/AppleWin
- **bmp2dhr** : Convertisseur d'images pour HGR
- **AppleCommander** : Manipulation d'images disque - https://applecommander.github.io/

### Documentation

- **cc65 Apple II docs** : https://cc65.github.io/doc/apple2enh.html
- **Format HGR** : https://www.kreativekorp.com/miscpages/a2info/hgr.shtml
- **ProDOS 8** : https://prodos8.com/
- **Apple II Documentation** : http://www.easy68k.com/paulrsm/6502/index.html

---

## 📝 Licence

Ce projet est sous licence **GNU General Public License v3.0**.

Voir le fichier [LICENSE](LICENSE) pour plus de détails.

**En résumé :**
- ✅ Libre d'utiliser, modifier et distribuer
- ✅ Code source doit rester disponible
- ✅ Modifications doivent être sous même licence
- ✅ Pas de garantie

---

## 👨‍💻 Auteur

**Arnaud VERHILLE**  
📧 gist974@gmail.com

### Œuvres adaptées

- **Le Marais aux Scorpions** (SCOSWAMP)  
  Adaptation du livre "Scorpion Swamp" (1985)  
  par Steve JACKSON & Ian LIVINGSTONE  
  Série : Défis Fantastiques #8

### Contributions

Ce projet démontre une approche moderne du développement de jeux Apple II :
- Architecture pilotée par données (13 KB moteur + contenu disque illimité)
- Chargement dynamique de fichiers ProDOS
- Support multilingue (facilement extensible)
- Code C propre avec cc65
- Contenu moddable sans recompilation

N'hésitez pas à utiliser ces moteurs comme modèles pour vos propres aventures Apple II !

---

## 🌟 Remerciements

- **cc65 team** : Excellent compilateur C pour 6502
- **Steve JACKSON & Ian LIVINGSTONE** : Créateurs de l'univers Fighting Fantasy
- **Communauté Apple II** : Pour avoir maintenu vivante cette plateforme légendaire
- **Virtual ][ team** : Émulateur macOS exceptionnel

---

## 📊 Statistiques du projet

| Métrique | Valeur |
|----------|--------|
| **Lignes de code C** | ~600 lignes (moteurs combinés) |
| **Taille moteurs** | ~13-15 KB chacun |
| **Scènes totales** | 192 scènes (178 SCOSWAMP + 14 SPACETRIP) |
| **Fichiers texte** | ~384 fichiers (FR + EN) |
| **Images HGR** | ~57 images × 8 KB = ~456 KB |
| **Contenu total** | ~10 MB de données |
| **Ratio efficacité** | 1000:1 (contenu vs. empreinte mémoire) |
| **Langues** | 2 (FR/EN, extensible) |

---

## 🚀 Démarrage rapide

### 1. Cloner le dépôt

```bash
git clone <url-du-depot>
cd appleIIsrc
```

### 2. Compiler un projet

```bash
# Le Marais aux Scorpions
cd SCOSWAMP/SRC
make

# Space Explorer Trip
cd ../../SPACETRIP
cl65 -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o SPACETRIP.BIN spacetrip.c paths.c
```

### 3. Exécuter sur Virtual ][ (macOS)

1. Lancer Virtual ][
2. Menu → "Mount Folder as ProDOS Disk"
3. Sélectionner le dossier SCOSWAMP/ ou SPACETRIP/
4. Démarrer le système ProDOS
5. Exécuter : `]BRUN SCOSWAMP` ou `]BRUN SPACETRIP`

### 4. Jouer !

- Choisissez votre langue (F=Français, E=English)
- Admirez les graphiques HGR
- Appuyez sur ESPACE/RETURN/ESC pour basculer vers le texte
- Utilisez A-Z pour faire vos choix
- Q pour quitter

---

**Bon voyage dans l'univers rétro-moderne d'Apple II ! 🍎✨**
