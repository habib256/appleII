# Apple II - Moteurs de Jeu Pilotés par Données

Deux jeux d'aventure pour Apple IIe Enhanced démontrant une architecture moderne : moteur compact (~13 KB) + contenu illimité sur disque ProDOS.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## 📖 Philosophie

**Architecture pilotée par données** : Le moteur reste en mémoire (~13 KB), seule la scène actuelle est chargée depuis le disque.

**Avantages** :
- Contenu illimité (limité uniquement par l'espace disque, jusqu'à 32 MB ProDOS)
- Ajout de scènes sans recompilation
- Contenu moddable par les joueurs
- Ratio efficacité : 1000:1 (contenu vs. empreinte mémoire)

## 🎮 Projets inclus

| Projet | Description | Scènes | Contenu |
|--------|-------------|--------|---------|
| **SCOSWAMP** | Le Marais aux Scorpions (livre-jeu) | 401 | ~9 MB |
| **SPACETRIP** | Space Explorer Trip (aventure sci-fi) | 14 | ~150 KB |

---

## 🎮 SCOSWAMP - Le Marais aux Scorpions

Adaptation du livre-jeu "Scorpion Swamp" (1985) par Steve JACKSON & Ian LIVINGSTONE.

### Statistiques

| Métrique | Valeur |
|----------|--------|
| **Moteur** | 13-15 KB |
| **Scènes** | 401 paragraphes (livre-jeu complet) |
| **Images HGR** | 57 × 8 KB = 456 KB |
| **Fichiers texte** | 802 fichiers (401 FR + 401 EN) ✓ 100% |
| **Traduction** | Bilingue FR/EN complet (Oct. 2024) |
| **Contenu total** | ~9 MB |
| **Ratio efficacité** | 692:1 (9 MB / 13 KB) |

### Fonctionnalités

- **401 scènes** : Livre-jeu complet adapté pour Apple II
- **Bilingue FR/EN** : Traduction 100% complète (802 fichiers texte)
- **Graphismes HGR** : 280×192 pixels, 6 couleurs, 57 images
- **Mode texte 80 colonnes** : Lecture confortable et immersive
- **Bascule instantanée** : Image ↔ texte (ESPACE/RETURN/ESC)
- **Navigation par choix** : Branches narratives interactives
- **Optimisé** : Memory swap pour transitions ultra-rapides

### Compilation

```bash
cd SCOSWAMP/SRC
make
```

Ou manuellement :
```bash
cl65 -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o ../SCOSWAMP.BIN scoswamp.c paths.c
```

### Exécution

1. Monter SCOSWAMP/ comme disque ProDOS (Virtual ][)
2. `]BRUN SCOSWAMP`
3. Choisir langue : `F` (Français) ou `E` (English)

**Contrôles** : `ESPACE/RETURN/ESC`=basculer image/texte | `A-Z`=choix | `Q`=quitter

---

## 🚀 SPACETRIP - Space Explorer Trip

Aventure galactique interactive démontrant l'architecture pilotée par données.

### Statistiques

| Métrique | Valeur |
|----------|--------|
| **Moteur** | 13 KB |
| **Scènes** | 14 (FR + EN) |
| **Images HGR** | 14 × 8 KB = 112 KB |
| **Fichiers texte** | 28 fichiers (14 FR + 14 EN) |
| **Contenu total** | ~150 KB |
| **Ratio efficacité** | 11:1 (150 KB / 13 KB) |
| **Potentiel** | 1000+ scènes (limité par espace disque) |

### Fonctionnalités

- Graphismes HGR 280×192 pixels
- Chargement dynamique : seule la scène actuelle en RAM
- Bilingue FR/EN
- Moddable : ajout de scènes sans recompilation
- Extensible : ~16 KB libres pour fonctionnalités RPG futures

### Compilation

```bash
cd SPACETRIP
cl65 -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o SPACETRIP.BIN spacetrip.c paths.c
```

### Exécution

1. Monter SPACETRIP/ comme disque ProDOS
2. `]BRUN SPACETRIP`
3. Choisir langue : `F` (Français) ou `E` (English)

**Contrôles** : identiques à SCOSWAMP

### Ajouter du contenu (sans recompilation)

1. Créer `TXTFR/N015` et `TXTEN/N015` (description + choix)
2. Créer `IMG/N015.HGR` (8192 octets)
3. Lier depuis une scène : ajouter `C 015 Titre du choix`
4. Terminé ! Jouable immédiatement.

---

## 🛠️ Développement

### Prérequis

- **cc65** : `brew install cc65` (macOS) ou https://cc65.github.io/
- **Virtual ][** ou autre émulateur Apple II
- **Apple IIe Enhanced** (65C02) avec 64 KB RAM et carte 80 colonnes

### Carte mémoire

```
$0000-$1FFF : Système ProDOS
$2000-$3FFF : HGR Page 1 (8 KB image)
$4000-$4FFF : Moteur (13-15 KB)
$5000-$9FFF : Libre (~16 KB pour extensions)
$A000-$BFFF : Pile/tas C
$C000-$FFFF : I/O et ROM
```

**Note** : Démarrage à $4000 pour préserver HGR Page 1 ($2000-$3FFF)

---

## 📚 Documentation

### Guides détaillés

- **SCOSWAMP/SRC/README.md** : Compilation et structure
- **SCOSWAMP/DOCS/PRODOS-MLI.md** : Gestion des chemins ProDOS
- **SCOSWAMP/DOCS/README-TEXTES.md** : Format des fichiers texte
- **SCOSWAMP/DOCS/TRADUCTION-STATUS.md** : Statut traduction bilingue (401 scènes FR/EN)
- **SPACETRIP/README.TXT** : Architecture et guide complet
- **DOCS/cc65/** : Documentation cc65 complète (HTML)

### Techniques

**Architecture pilotée par données**
- Code séparé du contenu
- Moteur constant en mémoire (~13 KB)
- Contenu illimité sur disque ProDOS

**Format fichiers**
- Images : `IMG/N###.HGR` (8192 octets, 280×192, 6 couleurs)
- Textes : `TEXTFR/N###/N###.TXT` et `TEXTEN/N###/N###.TXT`
- Choix : `C <scene_id> <titre>`

**Chemins ProDOS**
```c
build_paths(5, "FR", ...) → "IMG/N005.HGR", "TEXTFR/N000/N005.TXT"
```

---

## 🔮 Évolutions futures (RPG)

~16 KB de RAM libre permettent d'ajouter :
- **Combat** : Rencontres, tour par tour, monstres depuis fichiers
- **Inventaire** : Objets, clés, armes, armures (moddables)
- **Progression** : HP, stats, expérience, niveaux
- **Sauvegarde** : Système multi-emplacements
- **Fichiers** : MONSTERS.DAT, ITEMS.DAT, IMG/MONSTERS/*.HGR

Moteur reste ~15-18 KB, contenu illimité sur disque.

---

## 🐛 Dépannage

| Problème | Solution |
|----------|----------|
| Fichier non trouvé | Vérifier format N### (3 chiffres), chemins corrects |
| Choix absents | Lignes commencent par `C ` (C+espace) |
| Graphiques corrompus | Fichiers HGR = 8192 octets exactement |
| Plantage au démarrage | Compiler avec `-Wl -S,0x4000` |

---

## 📦 Ressources

- **cc65** : https://cc65.github.io/
- **Virtual ][** (macOS) : https://www.virtualii.com/
- **AppleWin** (Windows) : https://github.com/AppleWin/AppleWin
- **bmp2dhr** : Convertisseur HGR
- **ProDOS 8** : https://prodos8.com/

---

## 📊 Vue d'ensemble des projets

| Métrique | SCOSWAMP | SPACETRIP | Total |
|----------|----------|-----------|-------|
| **Moteur** | 13-15 KB | 13 KB | 26-28 KB |
| **Scènes** | 401 | 14 | 415 |
| **Fichiers texte** | 802 (401×2 langues) | 28 (14×2 langues) | 830 |
| **Traduction** | ✓ 100% FR/EN | ✓ 100% FR/EN | ✓ 100% |
| **Images HGR** | 57 × 8 KB = 456 KB | 14 × 8 KB = 112 KB | 568 KB |
| **Contenu total** | ~9 MB | ~150 KB | ~9.15 MB |
| **Ratio efficacité** | 692:1 | 11:1 | - |
| **Code C** | ~290 lignes | ~310 lignes | ~600 lignes |

---

## 🚀 Démarrage rapide

```bash
# 1. Installer cc65
brew install cc65  # macOS

# 2. Compiler
cd SCOSWAMP/SRC && make
cd ../../SPACETRIP && cl65 -t apple2enh -O -Oirs \
    -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 -o SPACETRIP.BIN spacetrip.c paths.c

# 3. Exécuter (Virtual ][)
# - Menu → "Mount Folder as ProDOS Disk" → sélectionner SCOSWAMP/ ou SPACETRIP/
# - ]BRUN SCOSWAMP (ou SPACETRIP)
# - F=Français, E=English
# - ESPACE=basculer image/texte, A-Z=choix, Q=quitter
```

---

## 👨‍💻 Auteur & Licence

**Arnaud VERHILLE** (gist974@gmail.com)  
Licence : **GNU GPL v3.0** - Libre d'utiliser, modifier, distribuer

**SCOSWAMP** : Adaptation de "Scorpion Swamp" (1985) par Steve JACKSON & Ian LIVINGSTONE  
Traduction anglaise complète : Octobre 2024 (401 scènes, 802 fichiers)

**Remerciements** : cc65 team, communauté Apple II, Virtual ][ team

---

**Bon voyage dans l'univers rétro-moderne d'Apple II ! 🍎✨**
