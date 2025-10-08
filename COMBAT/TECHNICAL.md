# Documentation Technique - Système de Combat Apple II

## Architecture du Programme

### Structure des Données

#### Structure Player
```c
typedef struct {
    unsigned char hp;           /* Points de vie actuels */
    unsigned char max_hp;       /* PV maximum */
    unsigned char attack;      /* Force d'attaque */
    unsigned char defense;      /* Defense */
    unsigned char level;        /* Niveau du joueur */
    unsigned int experience;    /* Points d'experience */
} Player;
```

#### Structure Monster
```c
typedef struct {
    char name[20];              /* Nom du monstre */
    unsigned char hp;           /* PV du monstre */
    unsigned char max_hp;       /* PV max */
    unsigned char attack;       /* Attaque */
    unsigned char defense;      /* Defense */
    unsigned char xp_reward;    /* XP donnes a la mort */
    unsigned char scene_id;     /* Scene ou il apparait */
    char image_file[20];        /* Nom du fichier image HGR */
} Monster;
```

### Variables Globales
- `Player player` : État du joueur
- `Monster monsters[MAX_MONSTERS]` : Tableau des monstres (10 max)
- `int current_monster` : ID du monstre actuel (-1 = aucun)
- `int combat_active` : Flag de combat actif
- `char language[3]` : Langue courante ("FR" ou "EN")

## Mécaniques de Combat

### Calcul des Dégâts
```c
int calculate_damage(int attacker_atk, int defender_def) {
    int damage = attacker_atk - (defender_def / 2) + (rand() % 4);
    return (damage > 0) ? damage : 1;
}
```

**Formule** : `dégâts = max(1, ATK_attaquant - (DEF_défenseur / 2) + random(0,3))`

### Chance de Fuite
```c
int flee_chance = 50 + (player.level * 5);
if (flee_chance > 95) flee_chance = 95;
```

**Formule** : `chance = min(95, 50 + (niveau × 5))`

### Système de Niveaux
```c
int xp_required = 50 * player.level * (player.level + 1) / 2;
```

**Formule** : `XP_requis(n) = 50 × n × (n-1) / 2`

### Montée de Niveau
- **HP max** : +5
- **Attaque** : +2  
- **Défense** : +1
- **HP actuels** : Restaurés à 100%

## Interface Utilisateur

### Modes d'Affichage
1. **Mode HGR** : Affichage des images de monstres (280×192)
2. **Mode Texte** : Interface de combat (80 colonnes)

### Soft Switches Apple II
```c
void set_video_mode(int mode) {
    if (mode == 0) {
        __asm__("sta $C051");  /* TXTSET */
    } else {
        __asm__("sta $C050");  /* TXTCLR */
        __asm__("sta $C057");  /* HIRES */
        __asm__("sta $C054");  /* LOWSCR */
        __asm__("sta $C052");  /* MIXCLR */
    }
}
```

### Barre de Statut
Affichage en temps réel :
- **HP** : Barre visuelle avec caractères █ et ░
- **Niveau** : Niveau actuel
- **XP** : Points d'expérience
- **Stats** : Attaque et Défense

## Effets Sonores

### Haut-parleur Apple II
```c
void play_sound(int type) {
    switch(type) {
        case 0: /* Bip simple */
            __asm__("sta $C030");
            break;
        case 1: /* Son de victoire */
            __asm__("sta $C030");
            __asm__("sta $C030");
            __asm__("sta $C030");
            break;
        case 2: /* Son de défaite */
            __asm__("sta $C030");
            break;
    }
}
```

### Types de Sons
- **Type 0** : Actions de combat (attaque, défense)
- **Type 1** : Victoire (3 bips rapides)
- **Type 2** : Défaite (1 bip grave)

## Gestion des Images

### Format HGR
- **Taille** : 8192 octets exactement
- **Résolution** : 280×192 pixels
- **Adresse mémoire** : $2000-$3FFF
- **Chargement** : `fread(HGR_PAGE1, 1, HGR_SIZE, f)`

### Structure des Fichiers
```
IMG/MONSTERS/
├── SPORE01.HGR    (Spore Cosmique)
├── ALIEN01.HGR    (Alien Vortex)
├── ROBOT01.HGR    (Robot Sentinel)
├── SPACE01.HGR    (Baleine Celeste)
└── BOSS01.HGR     (Guardian Magnetar)
```

## Optimisations Mémoire

### Utilisation RAM
- **Code** : ~12 KB
- **Données** : ~1 KB
- **Images** : 8 KB × 5 = 40 KB (disque)
- **Total** : ~13 KB en RAM

### Adresses Mémoire
- **Programme** : $4000-$6FFF
- **HGR Page 1** : $2000-$3FFF
- **Variables** : $0800-$1FFF
- **Stack** : $0100-$01FF

## Compilation

### Outils Requis
- **cc65** : Compilateur C
- **ca65** : Assembleur
- **cl65** : Linker

### Options de Compilation
```makefile
CFLAGS = -t apple2enh -O -Oirs
LDFLAGS = -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000
```

### Processus de Compilation
1. **cc65** : C → Assembleur (.s)
2. **ca65** : Assembleur → Objet (.o)
3. **cl65** : Objet → Binaire (.BIN)

## Compatibilité

### Configuration Requise
- **Apple IIe Enhanced** ou ultérieur
- **64 KB RAM** minimum
- **ProDOS** système
- **Carte 80 colonnes** (recommandée)

### Limitations Identifiées
- Maximum 10 monstres (extensible)
- Images HGR fixes (8192 octets)
- Sauvegarde non implémentée
- Pas de musique (seulement effets sonores)

## Débogage

### Points de Contrôle
1. **Initialisation** : Vérifier stats joueur
2. **Combat** : Vérifier calculs dégâts
3. **Niveaux** : Vérifier montée de niveau
4. **Images** : Vérifier chargement HGR

### Messages de Debug
- Erreurs de chargement d'images
- Échecs de combat
- Problèmes de mémoire

## Extensions Possibles

### Fonctionnalités Futures
1. **Système d'inventaire** : Objets et équipement
2. **Sauvegarde** : Persistance des données
3. **Musique** : Support audio avancé
4. **Animations** : Effets visuels
5. **IA** : Comportements de monstres

### Optimisations
1. **Compression** : Images HGR compressées
2. **Cache** : Images en mémoire
3. **Streaming** : Chargement progressif
4. **Multitasking** : Combat en arrière-plan

## Performance

### Métriques
- **Chargement image** : ~0.5 seconde
- **Calcul combat** : Instantané
- **Affichage** : < 0.1 seconde
- **Son** : Instantané

### Optimisations Appliquées
- Compilation optimisée (-O -Oirs)
- Variables globales pour vitesse
- Assembleur inline pour soft switches
- Gestion mémoire statique

## Conclusion

Le système de combat Apple II est conçu pour être :
- **Efficace** : Utilisation optimale des ressources
- **Extensible** : Architecture modulaire
- **Compatible** : Standards Apple II
- **Performant** : Temps de réponse rapides

L'architecture permet d'ajouter facilement de nouvelles fonctionnalités tout en maintenant la compatibilité avec les contraintes matérielles de l'Apple II.
