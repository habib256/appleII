# Hello World Apple II - Guide de Compilation

## Description
Programme "Hello World" minimal pour Apple II/IIe utilisant cc65 et la bibliothèque conio.

## Prérequis
- **cc65** installé (via Homebrew sur macOS: `brew install cc65`)
- Émulateur Apple II ou matériel réel avec ProDOS 8

## Compilation

### Option 1 : Binaire brut (recommandé pour ProDOS/DOS 3.3)
Génère un binaire 6502 pur sans en-tête AppleSingle, directement compatible avec `BLOAD`/`BRUN`:

```bash
cl65 -t apple2enh -O -Wl -D,__EXEHDR__=0 -o HELLO.BIN hello.c
```

**Caractéristiques:**
- Adresse de chargement par défaut: `$0803`
- Point d'entrée: `$0803` (décimal: 2051)
- Taille typique: ~2.3 KB
- Compatible: ProDOS 8, DOS 3.3

### Option 2 : Format AppleSingle (nécessite AppleCommander)
Génère un fichier AppleSingle avec métadonnées:

```bash
cl65 -t apple2enh -O -o HELLO.BIN hello.c
```

**Caractéristiques:**
- Contient un en-tête AppleSingle (~58 octets)
- Nécessite AppleCommander 1.4.0+ avec option `-as` pour l'import
- Préserve automatiquement le type et l'adresse de chargement

## Import sur disque ProDOS

### Avec binaire brut (Option 1)
Utilisez AppleCommander pour créer/modifier une image disque:

```bash
# Créer une nouvelle image ProDOS
ac -pro140 MYDISK.PO MYDISK

# Importer le binaire (type BIN, adresse auxiliaire $0803)
ac -p MYDISK.PO HELLO BIN 0x0803 < HELLO.BIN
```

### Avec AppleSingle (Option 2)
```bash
# AppleCommander extrait automatiquement les métadonnées
ac -as MYDISK.PO HELLO < HELLO.BIN
```

## Exécution sur Apple II

### Depuis ProDOS / DOS 3.3

**Méthode 1 - BRUN (la plus simple):**
```
]BRUN HELLO
```
Charge ET exécute automatiquement le programme.

**Méthode 2 - BLOAD + CALL:**
```
]BLOAD HELLO
]CALL 2051
```
Charge le binaire puis saute au point d'entrée ($0803 = 2051 décimal).

### Depuis le moniteur
```
*803G
```
Saute directement à l'adresse $0803.

## Types de fichiers ProDOS

Pour ce programme:
- **Type principal:** `PRODOS_T_BIN` ($06)
- **Type auxiliaire:** `$0803` (adresse de chargement)

Pour créer d'autres types de fichiers en C (via `fopen()`/`open()`), utilisez les variables globales définies dans `<apple2.h>`:

```c
#include <apple2.h>

// Exemple: créer un fichier texte
_filetype = PRODOS_T_TXT;        // Type texte
_auxtype  = PRODOS_AUX_T_TXT_SEQ; // Fichier texte séquentiel (=0)

FILE *f = fopen("MONFICHIER.TXT", "w");
// ...
```

## Paramètres de compilation avancés

### Adresse de chargement personnalisée
```bash
cl65 -t apple2enh -O -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 -o HELLO.BIN hello.c
```
(Charge à $4000 au lieu de $0803)

### Taille de pile personnalisée
```bash
cl65 -t apple2enh -O -Wl -D,__EXEHDR__=0 -Wl -D,__STACKSIZE__=0x400 -o HELLO.BIN hello.c
```
(Pile de $400 octets au lieu de $800)

### Optimisation maximale
```bash
cl65 -t apple2enh -Or -Cl -Wl -D,__EXEHDR__=0 -o HELLO.BIN hello.c
```
- `-Or`: Register variables
- `-Cl`: Static locals

## Structure mémoire

**Configuration standard (apple2enh):**
- Adresse de départ: `$0803`
- Mémoire disponible: `$0803` → `$95FF` (35.5 KB)
- Pile C: située à HIMEM, croît vers le bas
- Tas C: situé après le programme, croît vers la pile

**Language Card:**
- Disponible pour code additionnel via `#pragma code-name (push, "LC")`
- Par défaut: `$D400` → `$DFFF` (3 KB)

## Dépannage

### Erreur "0805- ..." ou "0808- ..." dans le moniteur
**Cause:** Mauvaise adresse d'exécution ou fichier AppleSingle chargé directement.

**Solution:**
1. Recompiler avec `-Wl -D,__EXEHDR__=0` pour un binaire brut
2. Exécuter avec `CALL 2051` (pas un autre nombre)
3. Vérifier que le fichier a été importé avec le bon type auxiliaire ($0803)

### Programme plante au démarrage
**Vérifications:**
1. Cible correcte: `-t apple2enh` (nécessite 65C02) ou `-t apple2` (6502 standard)
2. Binaire chargé à la bonne adresse
3. Suffisamment de mémoire disponible

### "PATH NOT FOUND"
Le fichier n'est pas sur le disque ou le nom est incorrect. Utilisez `CAT` pour lister les fichiers.

## Ressources

- [Documentation cc65 Apple II](../DOCS/cc65/apple2.html)
- [Documentation cc65 Apple IIenh](../DOCS/cc65/apple2enh.html)
- [AppleCommander](https://applecommander.github.io/)
- [Référence des fonctions cc65](../DOCS/cc65/funcref.html)

## Notes

- Les programmes Apple IIenh nécessitent un 65C02 ou 65816 (Apple //e Enhanced, //c, //gs)
- Pour un Apple ][ ou ][+ original, utilisez `-t apple2` au lieu de `-t apple2enh`
- La cible `apple2enh` offre des optimisations et instructions supplémentaires du 65C02

