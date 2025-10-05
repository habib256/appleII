# Le Marais aux Scorpions - Compilation

Ce répertoire contient les sources C du programme "Le Marais aux Scorpions" pour Apple IIe Enhanced.

## Fichiers source

- `scoswamp.c` : Programme principal (affichage, navigation, boucle de jeu)
- `paths.c` : Gestion des chemins ProDOS (images HGR et fichiers texte)
- `paths.h` : En-têtes pour la gestion des chemins

## Compilation

### Prérequis

- **cc65** : compilateur C pour 6502/65C02 (Apple II)
- Installation : https://cc65.github.io/

### Commandes Make

```bash
# Compiler le projet (crée SCOSWAMP.BIN dans le répertoire parent)
make

# Afficher la configuration
make info

# Recompiler complètement (nettoie puis compile)
make rebuild

# Nettoyer les fichiers intermédiaires (.o, .s)
make clean

# Nettoyer tout (inclut le binaire)
make distclean
```

### Compilation manuelle (sans Makefile)

```bash
# Avec cl65 (tout-en-un)
cl65 -t apple2enh -O -Oirs \
     -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o ../SCOSWAMP.BIN scoswamp.c paths.c

# Ou étape par étape
cc65 -t apple2enh -O -Oirs -o scoswamp.s scoswamp.c
cc65 -t apple2enh -O -Oirs -o paths.s paths.c
ca65 -t apple2enh -o scoswamp.o scoswamp.s
ca65 -t apple2enh -o paths.o paths.s
ld65 -t apple2enh -D __EXEHDR__=0 -S 0x4000 \
     -o ../SCOSWAMP.BIN scoswamp.o paths.o apple2enh.lib
```

**Flags importants :**
- `-t apple2enh` : Cible Apple IIe Enhanced (65C02)
- `-O -Oirs` : Optimisations (inline, registres, taille)
- `-Wl -S,0x4000` : Démarrage à $4000 (préserve HGR Page 1)
- `-Wl -D,__EXEHDR__=0` : Binaire brut sans en-tête AppleSingle

**Résultat :** `SCOSWAMP.BIN` (~13-15 KB, démarre à $4000)

## Structure ProDOS

Le programme s'attend à cette arborescence relative :

```
/SCOSWAMP/
  ├── SCOSWAMP.BIN        (binaire compilé)
  ├── BASIC.SYSTEM.SYS    (ProDOS BASIC.SYSTEM)
  ├── PRODOS.SYS          (noyau ProDOS)
  ├── STARTUP.BAS         (script de démarrage optionnel)
  ├── IMG/
  │   ├── N000/           (scènes 0-49)
  │   │   ├── N000.HGR.BIN
  │   │   ├── N001.HGR.BIN
  │   │   └── ...
  │   ├── N050/           (scènes 50-99)
  │   └── ...
  ├── TEXTFR/             (textes français)
  │   ├── N000/
  │   │   ├── N001        (pas d'extension .TXT)
  │   │   └── ...
  │   └── ...
  └── TEXTEN/             (textes anglais)
      └── ...
```

**Important** : Les chemins sont conformes ProDOS (≤64 caractères, composants ≤15 caractères).

## Configuration

### Flags de compilation

- `-t apple2enh` : Cible Apple IIe Enhanced (80 colonnes, 65C02)
- `-O -Oirs` : Optimisations (inline, registres, taille)
- `-Wl -S,0x4000` : Adresse de démarrage à $4000
- `-Wl -D,__EXEHDR__=0` : Binaire brut ProDOS (pas d'en-tête)

### Mémoire

**Pourquoi démarrer à $4000 ?**

La page HGR 1 occupe **$2000-$3FFF** (8192 octets). Si le programme démarrait à l'adresse par défaut (~$0803), il écraserait la zone graphique. En démarrant à **$4000**, on préserve toute la zone HGR.

```
$0000-$1FFF : Système, page texte, vecteurs
$2000-$3FFF : HGR Page 1 (8 KB, chargé depuis fichiers .HGR.BIN)
$4000-$BFFF : Programme SCOSWAMP.BIN et données
$C000-$FFFF : ROM et I/O
```

- **Adresse de chargement** : $4000 (16384)
- **Page HGR 1** : $2000-$3FFF (8192 octets, préservé)
- **Buffer I/O ProDOS** : 1 Ko par fichier ouvert (géré par libc)

## Référence

Voir la documentation ProDOS MLI : `../DOCS/PRODOS-MLI.md`

## Auteur

VERHILLE Arnaud - gist974@gmail.com

