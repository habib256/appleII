# SPACETRIP - Version 100 % Assembleur 6502

Ré-implémentation du jeu **Space Explorer Trip** entièrement en assembleur
pour Apple IIe Enhanced, sans une seule ligne de C. Seul l'outil **ca65**
(et le linker **ld65**) de la suite **cc65** est utilisé.

## Pourquoi ?

La version originale (`SPACETRIP/spacetrip.c`) passe par le runtime C de
cc65 : `printf`, `fopen`, `videomode`, `cgetc`, etc. Cela coûte plusieurs
kilo-octets de code et dépend du startup C.

Cette version parle directement au matériel :

- **Soft-switches** vidéo Apple II (`$C050-$C057`) pour le mode HGR/texte
- **Firmware 80 colonnes** (entrée `$C300`) pour l'affichage
- **ROM monitor** (`COUT`, `RDKEY`, `HOME`) pour I/O caractère
- **ProDOS Machine Language Interface** (`$BF00`) pour les fichiers

Résultat : un binaire de **~2,5 Ko** au lieu de ~13 Ko, et l'occasion
d'explorer l'Apple IIe au plus bas niveau.

## Organisation

```
SPACETRIP.ASM/
├── Makefile                # Compilation (ca65 + ld65)
├── README.md
├── link/
│   └── apple2-asm.cfg      # Config linker : BIN ProDOS chargé à $4000
└── src/
    ├── apple2.inc          # Soft-switches, ROM routines, MLI
    ├── zp.inc / zp.s       # Variables zero-page ($80-$8B)
    ├── header.s            # En-tête fichier (load addr + longueur)
    ├── main.s              # Entrée + boucle principale + écrans
    ├── video.s             # Modes texte / HGR / 80 col
    ├── io.s                # print_char / print_str / read_key
    ├── mli.s               # Wrappers ProDOS OPEN / READ / CLOSE
    ├── paths.s             # Construction chemins IMG/N###.HGR etc.
    └── parser.s            # Affichage scène + parsing des choix "C N"
```

## Carte mémoire

```
$0000-$00FF : zero-page (ProDOS + variables $80-$8B)
$0100-$01FF : pile 6502
$0400-$07FF : page texte
$0800-$1FFF : ProDOS + tampons système
$2000-$3FFF : HGR page 1  (image chargée par load_hgr_image)
$4000-$7FFF : programme (code + données + BSS)
$8000-$BEFF : libre (1 Ko aligné pour io_buffer MLI)
$BF00-$BFFF : entrée ProDOS MLI
$C000-$CFFF : soft-switches & ROM slot
$D000-$FFFF : ROM Applesoft / Monitor
```

Le programme démarre par `JMP main` placé précisément à `$4000` (segment
`STARTUP`), ce qui permet à `]BRUN SPACETRIP.ASM.BIN` de lancer le jeu.

## Compilation

### Prérequis

- **cc65** ≥ 2.19 : `brew install cc65` (macOS) / `apt install cc65` (Debian)

### Commandes

```bash
cd SPACETRIP.ASM
make                 # -> SPACETRIP.ASM.BIN (~2,5 Ko)
make clean           # supprime build/
make distclean       # + supprime le binaire
```

Le Makefile assemble chaque `.s` en `.o`, puis édite les liens avec
`link/apple2-asm.cfg` pour produire un binaire ProDOS brut avec en-tête
4 octets (adresse de chargement + longueur).

## Utilisation

1. Copier les ressources du jeu original à côté du binaire :
   ```
   SPACETRIP.ASM.BIN
   IMG/       (N001.HGR ... N014.HGR)
   TXTFR/     (N001 ... N014)
   TXTEN/     (N001 ... N014)
   PRODOS.SYS
   BASIC.SYSTEM.SYS
   STARTUP.BAS
   ```

2. Monter le dossier comme disque ProDOS dans Virtual ][ ou AppleWin.

3. À l'invite BASIC :
   ```
   ]BRUN SPACETRIP.ASM.BIN
   ```

### Contrôles

| Touche   | Action                                       |
|----------|----------------------------------------------|
| `F`/`E`  | Choix de langue (Français / English)         |
| `ESPACE` | Basculer entre mode texte 80 col. et HGR     |
| `A`-`Z`  | Sélectionner un choix                         |
| `Q`      | Quitter (retour à ProDOS via MLI_QUIT)       |

## Détails techniques

### Chargement d'une image HGR

```asm
; Construire "IMG/N001.HGR" (Pascal string)
lda current_scene
ldx current_scene+1
jsr build_img_path

; OPEN via MLI
lda #<img_path
sta zp_ptr1
lda #>img_path
sta zp_ptr1+1
jsr file_open        ; -> A = ref_num, C=1 si erreur

; READ 8192 octets directement en $2000
lda #$00 / sta zp_ptr1
lda #$20 / sta zp_ptr1+1
lda #$00 / sta zp_len
lda #$20 / sta zp_tmp1      ; 8192 = $2000
jsr file_read

; CLOSE
lda zp_idx
jsr file_close
```

Le tampon `io_buffer` requis par ProDOS (1 Ko aligné sur une page) est
alloué dans `main.s` via `.align 256` dans le segment BSS, lui-même aligné
sur 256 par la config linker.

### Parsing des scènes

Chaque ligne du fichier `TXTFR/N###` est examinée :

- Ligne commençant par `C ` → extraire l'ID (3 chiffres), stocker dans
  la table `choices_id[]` (jusqu'à 10 choix)
- Sinon, imprimer la ligne telle quelle via COUT

Limitation actuelle (vs. version C) : seul l'ID des choix est affiché
(`A) Scene 002`) au lieu du titre complet, pour garder le parseur simple.
Améliorer `display_scene_text` pour capturer et réimprimer le titre
depuis le buffer est un exercice simple laissé au lecteur.

### Retour à ProDOS

```asm
jsr MLI
.byte $65            ; MLI_QUIT
.word quit_pb
quit_pb: .byte 4, 0, 0, 0, 0, 0, 0   ; type=0 → QUIT classique
```

## Extensions possibles

- Imprimer le titre réel des choix (pointeurs vers le buffer)
- Accents IIe via ALTCHAR (certains caractères du MouseText)
- Préchargement asynchrone de la scène suivante pendant lecture texte
- Sauvegarde / chargement via MLI WRITE + CREATE
- Ajout de musique via le haut-parleur ($C030) en tâche de fond

## Licence

GNU GPL v3.0, identique au projet parent. Jeu original par **Arnaud
VERHILLE** (`gist974@gmail.com`). Portage assembleur : démonstration
pédagogique.
