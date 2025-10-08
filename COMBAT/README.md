# Système de Combat Apple II

Un système de combat RPG complet pour Apple II, inspiré du document d'améliorations SPACETRIP.

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

## Auteur

**Arnaud VERHILLE** - gist974@gmail.com
Port Apple II - 2025

Inspiré du document d'améliorations SPACETRIP et du code source spacetrip.c
