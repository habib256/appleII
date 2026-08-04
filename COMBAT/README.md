# Système de Combat Apple II

Un système de combat RPG complet pour Apple II, inspiré du document d'améliorations SPACETRIP.

---

## ⚠️ État actuel : prototype autonome

**Ce module fonctionne, mais n'est intégré à aucun des deux jeux.**

`combat.c` possède son propre `main()` et se compile en un exécutable séparé
(`COMBAT.BIN`, 14 490 octets). Ni SCOSWAMP ni SPACETRIP ne l'appellent : dans
`scoswamp.c`, seul un emplacement est réservé (mode vidéo `2`, « mode mixte »,
lignes 27 et 248), sans code d'appel.

C'est une **étape assumée** du projet. La feuille de route d'intégration est en
bas de ce document. Tant qu'elle n'est pas achevée, le module reste jouable
isolément via `]BRUN COMBAT`.

---

## Fonctionnalités

### Système de Joueur
- **Points de Vie (HP)** : 20 au départ, augmentent avec les niveaux
- **Attaque** : Force d'attaque, augmente avec les niveaux
- **Défense** : Protection contre les dégâts
- **Niveau** : Progression du joueur (1-5)
- **Expérience (XP)** : Points gagnés en combattant

### Système de Monstres
- **5 types de monstres** avec difficultés croissantes :
  1. **Spore Cosmique** (Facile) - HP:8, ATK:3, DEF:1, XP:10
  2. **Alien Vortex** (Moyen) - HP:18, ATK:6, DEF:3, XP:25
  3. **Robot Sentinel** (Moyen) - HP:22, ATK:7, DEF:5, XP:30
  4. **Baleine Celeste** (Difficile) - HP:30, ATK:10, DEF:6, XP:50
  5. **Guardian Magnetar** (BOSS) - HP:50, ATK:15, DEF:10, XP:100

### Mécaniques de Combat
- **Attaque** : Calcul des dégâts basé sur ATK - DEF/2 + random(0-3)
- **Défense** : Double la défense pour 1 tour
- **Fuite** : Chance de 50% + (niveau × 5)%
- **Montée de niveau** : HP max +5, ATK +2, DEF +1

### Interface
- **Mode HGR** : Affichage des images de monstres en haute résolution
- **Mode Texte** : Interface de combat avec barres de vie
- **Barre de statut** : HP, niveau, XP, stats en temps réel
- **Multilingue** : Français et Anglais

### Effets Sonores
- **Bip simple** : Actions de combat
- **Son de victoire** : Trio de bips pour les victoires
- **Son de défaite** : Bip grave pour les défaites

## Compilation

```bash
cd COMBAT/SRC
make
```

Le programme sera compilé dans `COMBAT.BIN` à l'adresse `$4000`.

## Utilisation

1. **Lancer le programme** : Le système de combat démarre automatiquement
2. **Choisir un monstre** : Sélectionner 1-5 pour combattre différents monstres
3. **Combat** :
   - `[A]` Attaquer
   - `[D]` Défendre (défense ×2 pour 1 tour)
   - `[F]` Fuir
   - `[Q]` Quitter
4. **Statistiques** : `[S]` pour voir les stats du joueur
5. **Langue** : `[L]` pour changer la langue

## Structure des Fichiers

```
COMBAT/
├── SRC/
│   ├── combat.c      # Code source principal
│   └── Makefile      # Configuration de compilation
├── IMG/
│   └── MONSTERS/     # Images HGR des monstres
│       ├── SPORE01.HGR
│       ├── ALIEN01.HGR
│       ├── ROBOT01.HGR
│       ├── SPACE01.HGR
│       └── BOSS01.HGR
└── README.md         # Ce fichier
```

## Images de Monstres

Les images HGR doivent être placées dans `IMG/MONSTERS/` :
- Format : HGR standard (8192 octets)
- Résolution : 280×192 pixels
- Nommage : Selon les noms définis dans le code

## Formules Techniques

### Dégâts de Combat
```
dégâts = max(1, ATK_attaquant - (DEF_défenseur / 2) + random(0,3))
```

### Chance de Fuite
```
chance = min(95, 50 + (niveau × 5))
```

### XP Requis pour Niveau
```
XP_requis(n) = 50 × n × (n-1) / 2
```

### Montée de Niveau
- **Niveau 1** : 0 XP (HP:20, ATK:5, DEF:3)
- **Niveau 2** : 50 XP (HP:25, ATK:6, DEF:4)
- **Niveau 3** : 120 XP (HP:30, ATK:8, DEF:5)
- **Niveau 4** : 220 XP (HP:35, ATK:10, DEF:6)
- **Niveau 5** : 350 XP (HP:40, ATK:12, DEF:8)

## Compatibilité

- **Apple IIe Enhanced** ou ultérieur
- **64 KB RAM** minimum
- **ProDOS** requis
- **Carte 80 colonnes** recommandée
- **cc65 compiler** pour la compilation

## Développement

Le code est structuré de manière modulaire :
- `init_player()` : Initialisation du joueur
- `init_monsters()` : Configuration des monstres
- `combat_loop()` : Boucle principale de combat
- `display_combat_screen()` : Interface de combat
- `calculate_damage()` : Calcul des dégâts
- `check_level_up()` : Vérification de montée de niveau

---

## 🗺️ Feuille de route d'intégration

Cinq obstacles séparent le prototype d'un système de combat jouable depuis
SCOSWAMP. Ils sont ordonnés : chacun dépend du précédent.

### Étape 1 — Mesurer le budget mémoire *(bloquant, à faire en premier)*

Le moteur dispose de la zone `$4000-$9FFF`, soit **24 576 octets**.

```
SCOSWAMP.BIN   13 322 o
COMBAT.BIN     14 490 o
somme brute    27 812 o   ← dépasse de 3 236 o
```

Cette somme est **trompeuse** : chaque binaire embarque sa propre copie du
runtime cc65 (`stdio`, `conio`, `apple2enh`), comptée deux fois. La taille réelle
d'un binaire fusionné sera nettement inférieure — mais elle est inconnue tant
qu'on ne l'a pas mesurée.

**Action** : retirer le `main()` de `combat.c`, exposer `start_combat()` dans un
`combat.h`, compiler `scoswamp.c + combat.c + paths.c` ensemble et relever la
taille obtenue.

```bash
cl65 -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
     -o /tmp/MERGED.BIN scoswamp.c combat.c paths.c memory_swap.c
ls -l /tmp/MERGED.BIN   # doit rester < 24576
```

**Si le seuil est dépassé** : charger `COMBAT.BIN` en overlay depuis SCOSWAMP
via `MLI` au moment de la rencontre, plutôt que de tout lier statiquement.
C'est cohérent avec l'architecture pilotée par données du projet.

`./tools/check-project.sh` échoue automatiquement si un moteur dépasse la limite.

### Étape 2 — Éliminer les duplications

`combat.c` et `scoswamp.c` redéfinissent chacun de leur côté :

| Symbole | `scoswamp.c` | `combat.c` |
|---------|--------------|------------|
| `HGR_PAGE1` | ligne 12 | ligne 9 |
| `HGR_SIZE` | ligne 13 | ligne 10 |
| `MAX_LINE` | ligne 14 | ligne 11 |
| `MAX_PATH` | ligne 16 | ligne 14 |
| `set_video_mode()` | ligne 69 | ligne 127 |

Ces doublons provoqueront des erreurs de redéfinition à l'édition de liens.

**Action** : extraire un module commun (`SRC/apple2_video.c` / `.h`) contenant
les constantes HGR et `set_video_mode()`, puis l'inclure depuis les trois moteurs.

### Étape 3 — Externaliser les données monstres

`init_monsters()` (lignes 180-227) code en dur les 5 monstres. C'est contraire à
la philosophie du projet : ajouter un monstre impose aujourd'hui une recompilation.

**Action** : créer `MONSTERS.DAT`, un fichier texte lu au chargement, sur le
modèle des fichiers de scènes :

```
M 01 Spore Cosmique|8|3|1|10|SPORE01.HGR
M 02 Alien Vortex|18|6|3|25|ALIEN01.HGR
    ^  ^            ^  ^ ^  ^  ^
    |  nom          HP | |  XP image
    id                ATK DEF
```

### Étape 4 — Créer un bestiaire médiéval-fantastique

Les 5 monstres actuels (Spore Cosmique, Alien Vortex, Robot Sentinel, Baleine
Céleste, Guardian Magnetar) viennent de l'univers SPACETRIP. **Aucun ne convient
au Marais aux Scorpions**, qui est médiéval-fantastique.

**Action** : définir un bestiaire tiré du livre-jeu (scorpions géants, hommes-lézards,
sangsues, gobelins des marais…), avec ses images HGR. Une fois l'étape 3 faite,
c'est du contenu pur, sans recompilation.

**Bonus** : SPACETRIP, qui est complet et dont les monstres actuels correspondent
déjà à l'univers, est la cible d'intégration la plus simple. **Intégrer COMBAT à
SPACETRIP d'abord** valide toute la chaîne technique (étapes 1 à 3) sans avoir à
produire de contenu neuf.

### Étape 5 — Persister l'état du joueur

`init_player()` réinitialise HP/XP/niveau à chaque combat. Dans un livre-jeu, la
progression doit survivre d'une scène à l'autre, et les blessures se cumuler.

**Action** : déplacer la structure `player` dans l'état global du moteur, et
l'initialiser une seule fois au démarrage de la partie. Prévoir la sauvegarde
sur disque (voir « Évolutions futures » du README principal).

### Point ouvert : doublons d'images monstres

`IMG/MONSTERS/` contient deux jeux de fichiers **au contenu différent** :

| Fichier | Référencé par `combat.c` |
|---------|--------------------------|
| `SPORE01.HGR`, `ALIEN01.HGR`, `ROBOT01.HGR`, `SPACE01.HGR`, `BOSS01.HGR` | ✅ oui (lignes 188-224) |
| `SPORE01.HGR.BIN`, `SPACE01.HGR.BIN`, `BOSS01.HGR.BIN` | ❌ non |

Les `.HGR.BIN` sont orphelins et ne sont pas de simples copies : leur contenu
diffère de celui des `.HGR` correspondants (`ALIEN01` et `ROBOT01` n'ont d'ailleurs
pas de variante `.BIN`). Il s'agit vraisemblablement de deux passes de conversion
différentes. **À trancher avant l'étape 3** : déterminer quelle version est la
bonne, supprimer l'autre, et uniformiser le nommage avec le reste du projet
(`.HGR.BIN` dans SCOSWAMP et SPACETRIP, `.HGR` ici).

---

## Auteur

**Arnaud VERHILLE** - gist974@gmail.com
Port Apple II - 2025

Inspiré du document d'améliorations SPACETRIP et du code source spacetrip.c
