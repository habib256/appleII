# Apple II - Moteurs de Jeu Pilotés par Données

Deux jeux d'aventure pour Apple IIe Enhanced démontrant une architecture moderne : moteur compact (~13 Ko) + contenu illimité sur disque ProDOS.

[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## 📖 Philosophie

**Architecture pilotée par données** : le moteur reste en mémoire (~13 Ko), seule la scène actuelle est chargée depuis le disque.

**Avantages** :
- Contenu illimité (limité uniquement par l'espace disque, jusqu'à 32 Mo ProDOS)
- Ajout de scènes sans recompilation
- Contenu moddable par les joueurs
- Ratio efficacité : 1000:1 (contenu vs. empreinte mémoire)

---

## 📊 État du projet

> Les chiffres ci-dessous sont **produits par `./tools/check-project.sh`**, pas saisis à la main.
> Relancer le script après toute modification de contenu pour les mettre à jour.
> Dernière vérification : 4 août 2026 — 0 erreur.

| Module | Rôle | Moteur | Scènes | Textes | Images | État |
|--------|------|--------|--------|--------|--------|------|
| **SCOSWAMP** | Le Marais aux Scorpions (livre-jeu) | 13 322 o | 402 | 804 ✅ | 79 / 402 | 🚧 Images en cours |
| **SPACETRIP** | Space Explorer Trip (aventure sci-fi) | 12 835 o | 14 | 28 ✅ | 14 / 14 ✅ | ✅ Complet |
| **COMBAT** | Système de combat RPG | 14 490 o | — | — | 5 monstres | 🔬 Prototype autonome, **non intégré** |

**Progression par axe** (pas de pourcentage global : les axes ne sont pas comparables)

```
SCOSWAMP  texte FR/EN   [####################] 100%  (804/804 fichiers)
SCOSWAMP  moteur        [####################] 100%
SCOSWAMP  images HGR    [####................]  20%  (79/402 scènes)
SPACETRIP tout          [####################] 100%
COMBAT    prototype     [####################] 100%  (fonctionne isolément)
COMBAT    intégration   [....................]   0%  (voir COMBAT/README.md)
Distribution            [....................]   0%  (voir DOCS/RELEASE.md)
```

**Intégrité** : 101 images HGR, toutes à 8192 octets exactement. Aucun trou de numérotation, aucune scène FR sans équivalent EN, aucun fichier texte vide.

### Vérifier soi-même

```bash
./tools/check-project.sh          # rapport complet
./tools/check-project.sh --quiet  # erreurs seules (code de sortie 1 si problème)
```

Le script valide les tailles HGR, l'appariement FR/EN, la continuité des scènes, la taille des moteurs face au budget mémoire, et l'absence d'artefacts de build versionnés.

---

## 🎮 SCOSWAMP - Le Marais aux Scorpions

Adaptation du livre-jeu « Scorpion Swamp » (1985) par Steve JACKSON & Ian LIVINGSTONE.

### Ce qui est terminé

- **402 scènes** (N000 → N401), livre-jeu complet adapté
- **Bilingue FR/EN** : 804 fichiers texte, appariement complet vérifié
- **Mode texte 80 colonnes** : lecture confortable et immersive
- **Bascule instantanée** image ↔ texte (ESPACE / RETURN / ESC)
- **Navigation par choix** : branches narratives interactives
- **Memory swap** : transitions optimisées

### Ce qui reste

**Images HGR : 79 sur 402 scènes illustrées.** Répartition actuelle :

| Bloc | Images / Scènes | | Bloc | Images / Scènes |
|------|-----------------|-|------|-----------------|
| N000 | 30 / 50 | | N200 | 4 / 50 |
| N050 | 15 / 50 | | N250 | 3 / 50 |
| N100 | 9 / 50  | | N300 | 6 / 50 |
| N150 | 6 / 50  | | N350 | 6 / 50 |

Les images existantes sont en noir et blanc ; aucune n'est colorisée.

> **Note de périmètre.** Illustrer les 402 scènes représente 165–330 h de travail
> artistique. Un objectif intermédiaire réaliste est d'illustrer et coloriser
> les ~120 scènes structurantes (embranchements majeurs, rencontres, fins),
> ce qui donne un jeu perçu comme complet sans le coût du 100 %.

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

1. Monter `SCOSWAMP/` comme disque ProDOS (Virtual ][)
2. `]BRUN SCOSWAMP`
3. Choisir la langue : `F` (Français) ou `E` (English)

**Contrôles** : `ESPACE/RETURN/ESC` = basculer image/texte | `A-Z` = choix | `Q` = quitter

---

## 🚀 SPACETRIP - Space Explorer Trip

Aventure galactique interactive démontrant l'architecture pilotée par données. **Complet** : 14 scènes, 14 images, bilingue.

| Métrique | Valeur |
|----------|--------|
| Moteur | 12 835 o |
| Scènes | 14 (FR + EN) |
| Images HGR | 14 × 8 Ko = 112 Ko |
| Fichiers texte | 28 (14 FR + 14 EN) |
| Ratio efficacité | 11:1 |

### Compilation

```bash
cd SPACETRIP
cl65 -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o SPACETRIP.BIN spacetrip.c paths.c
```

### Ajouter du contenu (sans recompilation)

1. Créer `TXTFR/N015` et `TXTEN/N015` (description + choix)
2. Créer `IMG/N015.HGR` (8192 octets exactement)
3. Lier depuis une scène : ajouter `C 015 Titre du choix`
4. Terminé, jouable immédiatement. Valider avec `./tools/check-project.sh`.

---

## ⚔️ COMBAT - Système de combat RPG

Prototype **fonctionnel mais autonome** : 847 lignes de C, son propre `main()`, compilé
séparément en `COMBAT.BIN`. Il ne s'exécute pas depuis SCOSWAMP ni SPACETRIP à ce jour.

C'est une **étape assumée du projet**, pas du code mort : l'intégration est planifiée.
Le détail des mécaniques, les obstacles techniques identifiés et la feuille de route
en 5 étapes se trouvent dans **[COMBAT/README.md](COMBAT/README.md)**.

Résumé des obstacles à lever :

| # | Obstacle | Nature | État |
|---|----------|--------|------|
| 1 | **Budget mémoire** : la fusion statique déborde de 6 204 o dans la zone ProDOS | overlay requis | ✅ mesuré |
| 2 | `set_video_mode()` dupliqué, avec deux comportements **incompatibles** | refactorisation | ✅ identifié |
| 3 | Données monstres codées en dur, contraires à l'architecture pilotée par données | `MONSTERS.DAT` | à faire |
| 4 | Bestiaire sci-fi inadapté à l'univers médiéval-fantastique de SCOSWAMP | contenu | à faire |
| 5 | Pas de persistance HP/XP entre les scènes | moteur | à faire |

> **Résultat de la mesure (étape 1)** : le binaire fusionné fait 21 343 o, sous
> la limite de chargement — mais sa BSS s'étend jusqu'à `$A63C`, soit 6 204 o
> au-dessus du plafond `$8E00`, en pleine zone ProDOS. Et `ld65` **ne signale
> rien** : la taille de zone se calcule en négatif et le contrôle d'overflow est
> neutralisé par un débordement non signé. La fusion statique est donc écartée
> au profit d'un overlay. Détail complet dans [COMBAT/README.md](COMBAT/README.md).

---

## 🛠️ Développement

### Prérequis

- **cc65** : `brew install cc65` (macOS) ou https://cc65.github.io/
- **Virtual ][** ou autre émulateur Apple II
- **Apple IIe Enhanced** (65C02), 64 Ko RAM, carte 80 colonnes

### Carte mémoire

```
$0000-$1FFF : Système ProDOS (page zéro, pile 6502, buffers)
$2000-$3FFF : HGR Page 1 (8 Ko image)
$4000-$8DFF : Moteur : CODE + RODATA + DATA + BSS  (19 968 o utilisables)
$8E00-$95FF : Pile C (__STACKSIZE__ = 2 Ko)
$9600-$BFFF : ProDOS 8 — MLI, page globale ($BF00), buffers fichier (1 Ko/fichier)
$C000-$FFFF : I/O et ROM
```

Démarrage à `$4000` pour préserver HGR Page 1 (`$2000-$3FFF`).

**Le plafond est `$9600`, pas `$A000`.** cc65 définit `__HIMEM__ = $9600` pour la
cible `apple2enh` : au-delà commence ProDOS 8, qu'un moteur trop gros écraserait
silencieusement à la première ouverture de fichier.

Deux contraintes distinctes, à ne pas confondre :

| Contrainte | Limite | Vérifiée par |
|------------|--------|--------------|
| Taille du `.BIN` chargé | 22 016 o (`$9600-$4000`) | `check-project.sh` |
| Empreinte totale **BSS comprise** | 19 968 o (`$8E00-$4000`) | fichier `.map` uniquement |

Le `.BIN` **ne contient pas la BSS** (variables non initialisées), allouée au
lancement. Un binaire sous les 22 016 o peut donc quand même déborder à
l'exécution. Pour le vérifier :

```bash
cl65 ... -Wl -m,build.map -o SCOSWAMP.BIN ...
sed -n '/Segment list/,/^$/p' build.map   # fin de BSS doit rester < $8E00
```

> **Piège `ld65`.** Si la BSS démarre déjà au-delà de `$8E00`, la taille de sa
> zone se calcule en négatif, déborde en non signé, et le contrôle d'overflow
> est neutralisé : **le link réussit sans le moindre avertissement**. Seule la
> lecture du `.map` révèle le problème. Ce cas est réel — voir la mesure de
> fusion dans [COMBAT/README.md](COMBAT/README.md).

Marge actuelle de SCOSWAMP : BSS finit à `$8516`, soit 2 282 octets sous le plafond.

### Format des fichiers

- **Images** : `IMG/N###.HGR` — **exactement 8192 octets**, 280×192, 6 couleurs
  Une page HGR fait 7680 octets affichés + 512 octets de « screen holes » non
  affichés. Un fichier plus court est chargé partiellement et laisse des résidus
  de la scène précédente à l'écran.
- **Textes** : `TEXTFR/N###/N###.TXT` et `TEXTEN/N###/N###.TXT`
- **Choix** : `C <scene_id> <titre>` (la ligne commence par `C` + espace)

### Chemins ProDOS

```c
build_paths(5, "FR", ...) → "IMG/N005.HGR", "TEXTFR/N000/N005.TXT"
```

---

## 📚 Documentation

| Document | Contenu |
|----------|---------|
| [SCOSWAMP/SRC/README.md](SCOSWAMP/SRC/README.md) | Compilation et structure du moteur |
| [SCOSWAMP/DOCS/README-TEXTES.md](SCOSWAMP/DOCS/README-TEXTES.md) | Format des fichiers texte |
| [DOCS/PRODOS-MLI.md](DOCS/PRODOS-MLI.md) | Gestion des chemins ProDOS |
| [DOCS/RELEASE.md](DOCS/RELEASE.md) | Génération et publication des images disque |
| [COMBAT/README.md](COMBAT/README.md) | Système de combat et feuille de route d'intégration |
| [SPACETRIP/README.TXT](SPACETRIP/README.TXT) | Architecture et guide complet |
| [DOCS/cc65/](DOCS/cc65/) | Documentation cc65 complète (HTML) |

> Le statut chiffré du projet vit **uniquement ici**, alimenté par
> `tools/check-project.sh`. L'ancien `SCOSWAMP/DOCS/PROJECT-STATUS.md` a été
> fusionné dans ce README pour éviter deux sources de vérité divergentes.

---

## 📦 Images disque

Les fichiers `.2mg` **ne sont pas versionnés** : ce sont des artefacts de build
régénérables, et les committer ajoutait 5 à 32 Mo à l'historique Git à chaque
mise à jour, de façon définitive.

Ils sont publiés en **GitHub Release**. Voir [DOCS/RELEASE.md](DOCS/RELEASE.md)
pour la procédure de génération et de publication.

---

## 🔮 Évolutions futures

Au-delà de l'intégration de COMBAT :

- **Inventaire** : objets, clés, armes, armures (moddables via fichiers)
- **Sauvegarde** : système multi-emplacements
- **Fichiers de données** : `MONSTERS.DAT`, `ITEMS.DAT`, `IMG/MONSTERS/*.HGR`

Le moteur resterait ~15-18 Ko, le contenu illimité sur disque.

---

## 🐛 Dépannage

| Problème | Solution |
|----------|----------|
| Fichier non trouvé | Vérifier le format `N###` (3 chiffres) et les chemins |
| Choix absents | Les lignes doivent commencer par `C ` (C + espace) |
| Graphiques corrompus | Les fichiers HGR doivent faire 8192 octets — lancer `./tools/check-project.sh` |
| Plantage au démarrage | Compiler avec `-Wl -S,0x4000` |
| Texte manquant dans une langue | `./tools/check-project.sh` détecte les scènes non appariées FR/EN |

---

## 📦 Ressources

- **cc65** : https://cc65.github.io/
- **Virtual ][** (macOS) : https://www.virtualii.com/
- **AppleWin** (Windows) : https://github.com/AppleWin/AppleWin
- **bmp2dhr** : convertisseur HGR
- **ProDOS 8** : https://prodos8.com/

---

## 🚀 Démarrage rapide

```bash
# 1. Installer cc65
brew install cc65  # macOS

# 2. Vérifier l'intégrité du dépôt
./tools/check-project.sh

# 3. Compiler
cd SCOSWAMP/SRC && make
cd ../../SPACETRIP && cl65 -t apple2enh -O -Oirs \
    -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 -o SPACETRIP.BIN spacetrip.c paths.c

# 4. Exécuter (Virtual ][)
# - Menu → « Mount Folder as ProDOS Disk » → sélectionner SCOSWAMP/ ou SPACETRIP/
# - ]BRUN SCOSWAMP (ou SPACETRIP)
# - F = Français, E = English
# - ESPACE = basculer image/texte, A-Z = choix, Q = quitter
```

---

## 👨‍💻 Auteur & Licence

**Arnaud VERHILLE** (gist974@gmail.com)
Licence : **GNU GPL v3.0** — libre d'utiliser, modifier, distribuer

**SCOSWAMP** : adaptation de « Scorpion Swamp » (1985) par Steve JACKSON & Ian LIVINGSTONE
- ✅ Traduction anglaise complète : octobre 2024 (402 scènes, 804 fichiers)
- 🚧 Images et colorisation : en cours (79/402 images, 0 % colorisées)

**Remerciements** : équipe cc65, communauté Apple II, équipe Virtual ][

---

**Bon voyage dans l'univers rétro-moderne d'Apple II ! 🍎✨**
