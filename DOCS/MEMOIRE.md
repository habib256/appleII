# Mémoire sur Apple IIe Enhanced

Comment le projet occupe la mémoire, ce qui reste disponible, et ce qu'il en
coûte de le récupérer. Toutes les valeurs ont été mesurées avec cc65 2.19.

---

## Carte mémoire

```
$0000-$01FF  Page zéro + pile 6502 (système)
$0200-$03FF  Buffer d'entrée, vecteurs
$0400-$07FF  Page texte 1  ← utilisée, sauvegardée par memory_swap.c
$0800-$1FFF  LIBRE (6 Ko)  ← voir « Zones récupérables », piège du tas
$2000-$3FFF  HGR page 1 (8 Ko)  ← images des scènes
$4000-....   Moteur : CODE, RODATA, DATA, BSS
     ....    Tas C (buffers ProDOS, 1 Ko par fichier ouvert)
     ....    Pile C (2 Ko, __STACKSIZE__)
$9600-$BEFF  BASIC.SYSTEM  ← récupérable (10,25 Ko), voir plus bas
$BF00-$BFFF  Page globale ProDOS 8 — JAMAIS disponible
$C000-$CFFF  Espace d'E/S
$D000-$FFFF  ROM / Language Card (banques commutées)
```

Le moteur charge à `$4000` et non à l'adresse cc65 par défaut `$0803`, afin de
préserver HGR page 1. Conséquence : `$0800-$1FFF` reste inutilisé.

---

## Les deux plafonds

Ne pas confondre la taille du fichier et l'empreinte réelle.

| Contrainte | Ce qu'elle limite | Vérifiée par |
|------------|-------------------|--------------|
| Taille du `.BIN` | CODE + RODATA + DATA + INIT + ONCE | `check-project.sh` |
| Empreinte exécution | + BSS + tas + pile | `check-memory.sh` (lit le `.map`) |

Le `.BIN` **ne contient pas la BSS** : les variables non initialisées sont
allouées au lancement, juste après DATA. Un binaire de taille acceptable peut
donc parfaitement déborder à l'exécution.

### Le piège `ld65`

La zone BSS est définie ainsi dans les configs cc65 :

```
BSS: start = __ONCE_RUN__, size = __HIMEM__ - __STACKSIZE__ - __ONCE_RUN__;
```

Si `__ONCE_RUN__` dépasse déjà le plafond, la taille se calcule **en négatif**,
déborde en non signé vers ~4 Go, et le contrôle d'overflow est neutralisé :
**le link réussit sans le moindre avertissement**, et la BSS écrase ProDOS.

Le contrôle fonctionne normalement dans les autres cas — un tableau de 30 Ko
produit bien `Segment 'BSS' overflows memory area 'BSS' by 10284 bytes`. Le
piège ne se déclenche que lorsque la BSS démarre du mauvais côté du plafond,
c'est-à-dire exactement quand on en aurait le plus besoin.

**Ne jamais conclure d'un link réussi que le binaire tient.** Produire le `.map`
et le vérifier :

```bash
cl65 ... -Wl -m,build.map -o PROG.BIN ...
./tools/check-memory.sh build.map            # config standard
./tools/check-memory.sh build.map --himem 0xBF00   # config étendue
```

---

## Configuration standard vs étendue

| | `apple2enh.cfg` (cc65) | `SRC/apple2enh-game.cfg` |
|---|---|---|
| Adresse de chargement | `$0803` (forcée à `$4000` par `-Wl -S`) | `$4000` (dans la config) |
| `__HIMEM__` | `$9600` | `$BF00` |
| Plafond BSS + tas | `$8E00` | `$B700` |
| **Utilisable depuis `$4000`** | **19 968 o** | **30 464 o** |
| BASIC.SYSTEM | préservé | **détruit** |
| Sortie du programme | `exit()` | `prodos_quit()` **obligatoire** |

Le gain est de **10 496 octets**.

`$9600` est la valeur prudente de cc65 (« presumed RAM end ») : elle suppose
BASIC.SYSTEM résident en `$9600-$BEFF`, ce qu'implique un lancement par `]BRUN`.
Un programme qui renonce à revenir au BASIC peut occuper cette zone. La limite
absolue reste `$BF00`, début de la page globale ProDOS.

### Contrepartie : la sortie

Avec la config étendue, la BSS et le tas s'étendent au-dessus de `$9600` et
détruisent BASIC.SYSTEM **en cours de partie**. Un `exit()` rendrait la main à
un programme qui n'existe plus.

Il faut sortir par l'appel MLI QUIT — voir `SRC/prodos_quit.asm` :

```c
#include "prodos_quit.h"
...
} else if (key == 'Q' || key == 'q') {
    set_video_mode(0);
    videomode(VIDEOMODE_40COL);
    clrscr();
    cprintf("Au revoir!\r\n");
    prodos_quit();          /* et non exit(0) */
}
```

---

## Zones récupérables

### 1. `$9600-$BEFF` — BASIC.SYSTEM : **+10 496 o** ✅ retenu

Décrit ci-dessus. C'est le gain le plus important et le plus simple : un
changement de config plus un remplacement de `exit()`.

### 2. `$0800-$1FFF` — RAM basse : 6 144 o ⛔ inexploitable via le linker

Cette zone est réellement libre, puisque le chargement commence à `$4000`. Y
placer la BSS semble un gain facile. **C'en est un piège.**

Dans cc65, le tas n'est pas un segment. `_heap.o` n'importe que quatre symboles
— `sp`, `__STACKSIZE__`, `__BSS_SIZE__`, `__BSS_RUN__` — et calcule :

```
__heaporg = __BSS_RUN__ + __BSS_SIZE__     (juste après la BSS)
__heapend = sp - __STACKSIZE__
```

**Le tas suit donc la BSS, où qu'elle soit.** Relogée en `$0800`, elle finit
vers `$1B96`, et le tas part de là jusqu'à la pile — traversant HGR page 1
(`$2000-$3FFF`) puis la totalité du code. `fopen()` allouant 1 Ko par fichier
ouvert, l'image affichée puis le programme lui-même seraient écrasés, sans
aucun diagnostic.

Vérifié : le linker accepte cette configuration sans broncher.
`tools/check-memory.sh` la refuse.

Cette zone reste utilisable pour des **buffers gérés à la main** (adresses
codées en dur, hors du contrôle du linker et de `malloc`), par exemple un cache
d'image ou de texte. Pas pour de la BSS.

### 3. `$D400-$DFFF` — Language Card : 3 072 o ⚙️ disponible, sur demande

Les configs cc65 définissent déjà un segment `LC` à cette adresse (banque deux,
derrière le code quit). Il accueille du code **en lecture seule**, désigné
fonction par fonction :

```c
#pragma code-name(push, "LC")
void fonction_peu_appelee(void) { ... }
#pragma code-name(pop)
```

Utile si la config étendue ne suffisait plus. Attention : la commutation de
banque entre en conflit avec ProDOS, qui y réside également.

### 4. RAM auxiliaire — 64 Ko ⚙️ gros gain, gros travail

Un //e Enhanced avec carte 80 colonnes étendue dispose de 64 Ko auxiliaires.
cc65 ne les gère pas : il faut commuter les banques à la main (`$C002-$C005`,
`$C008-$C009`) et copier via `AUXMOVE` (`$C311`).

Piste sérieuse pour un cache d'images HGR — charger plusieurs scènes d'avance
en RAM auxiliaire et les basculer instantanément — mais sans rapport avec la
taille du moteur, que le linker ne saurait pas y placer.

---

## Empreinte mesurée

Mesures cc65 2.19, chargement à `$4000`, pile 2 Ko.

| Build | Fin de BSS | Empreinte | Config standard | Config étendue |
|-------|-----------|-----------|-----------------|----------------|
| SPACETRIP | `$79AC` | 14 764 o | ✅ | ✅ |
| COMBAT | `$7A3B` | 14 907 o | ✅ | ✅ |
| SCOSWAMP | `$8516` | 17 686 o | ✅ marge 2 282 o | ✅ marge 12 778 o |
| SCOSWAMP + COMBAT | `$A64B` | 26 187 o | ❌ dépasse de 6 219 o | ✅ marge 4 277 o |

La fusion SCOSWAMP + COMBAT **ne passe qu'avec la configuration étendue**, où
elle laisse 4 277 octets de tas — soit quatre buffers ProDOS, alors que le jeu
n'ouvre qu'un fichier à la fois.

À titre de comparaison, SCOSWAMP seul en configuration standard ne dispose
aujourd'hui que de 2 282 octets de tas : la fusion en config étendue est donc
**moins contrainte que la situation actuelle**.

---

## Validation restant à faire

Les mesures ci-dessus sont statiques, issues des fichiers `.map`. Elles
établissent que le binaire tient. Elles ne remplacent pas un essai réel :

- [ ] Lancer le binaire en configuration étendue sous Virtual ][ ou AppleWin
- [ ] Vérifier que `prodos_quit()` rend bien la main au sélecteur ProDOS
- [ ] Vérifier qu'ouvrir une scène après destruction de BASIC.SYSTEM fonctionne
      (ProDOS tient une carte d'occupation mémoire en `$BF58-$BF6F` ; il faut
      s'assurer que les buffers alloués par cc65 y sont correctement déclarés)
- [ ] Vérifier le comportement quand plusieurs fichiers sont ouverts simultanément

Le dernier point est le plus incertain et doit être testé avant de basculer
SCOSWAMP sur la configuration étendue.
