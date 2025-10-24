# Fichiers texte - Le Marais aux Scorpions

## 📊 Vue d'ensemble

- **Total de scènes** : 401 scènes de jeu
- **Fichiers français** : 401 fichiers .TXT (TEXTFR/) ✓ 100% complet
- **Fichiers anglais** : 401 fichiers .TXT (TEXTEN/) ✓ 100% complet
- **Support bilingue** : Français et Anglais intégralement traduits
- **Organisation** : Par tranches de 50 (N000/, N050/, N100/, etc.)
- **Conformité** : 100% des fichiers ≤18 lignes ✓

## 📐 Contraintes d'affichage

### Apple IIe Enhanced - Mode 80 colonnes

L'écran dispose de **24 lignes** totales :

```
Ligne 1    : Titre (ex: "T 001  Le chemin vers le Marais")
Ligne 3    : Ligne vide
Lignes 4-21: Texte de la scène (≤18 lignes)
Ligne 22   : Ligne vide
Ligne 23   : "--- Choix ---"
Lignes 24  : Choix (ex: "A) Tirer votre épée")
```

### Règle de limite

**Maximum 18 lignes de texte** (hors lignes de choix commençant par "C ")

Cette limite garantit :
- Affichage correct sans défilement
- Place pour les choix (2-3 lignes)
- Place pour les commandes (1 ligne)

## 📝 Format des fichiers

### Structure d'un fichier .TXT

```
001 : Titre de la scène
----------------------

Texte de description de la scène.
Plusieurs paragraphes possibles.

C 048 Choix numéro 1 (texte du choix)
C 095 Choix numéro 2 (texte du choix)
```

### Balises

- **Titre** : Numéro de scène suivi du titre
- **Séparateur** : Ligne de tirets
- **Texte** : Paragraphes de description
- **Choix** : Lignes commençant par `C` suivi de l'ID de scène et du texte

## 🔧 Optimisation effectuée

### Fichiers optimisés (9 au total)

| Fichier | Avant | Après | Gain | Réduction |
|---------|-------|-------|------|-----------|
| N001.TXT | 27 lignes | 16 lignes | -11 | -41% |
| N009.TXT | 22 lignes | 16 lignes | -6 | -27% |
| N048.TXT | 25 lignes | 15 lignes | -10 | -40% |
| N058.TXT | 19 lignes | 13 lignes | -6 | -32% |
| N095.TXT | 25 lignes | 16 lignes | -9 | -36% |
| N155.TXT | 21 lignes | 16 lignes | -5 | -24% |
| N240.TXT | 24 lignes | 16 lignes | -8 | -33% |
| N335.TXT | 23 lignes | 17 lignes | -6 | -26% |
| N371.TXT | 22 lignes | 18 lignes | -4 | -18% |

**Total** : 65 lignes supprimées, 30% de réduction moyenne

### Méthode d'optimisation

1. **Conservation totale** :
   - Histoire principale
   - Choix de jeu
   - Tests (CHANCE, ENDURANCE)
   - Informations critiques

2. **Condensation** :
   - Descriptions atmosphériques
   - Dialogues trop verbeux
   - Répétitions
   - Détails secondaires

3. **Qualité** :
   - Cohérence narrative préservée
   - Aucune information de jeu perdue
   - Style maintenu

## 📁 Organisation des dossiers

### Structure complète bilingue

```
TEXTFR/ (Version française - 401 fichiers)
├── N000/  (scènes 0-49)    → 50 fichiers
│   ├── N000.TXT (titre du jeu)
│   ├── N001.TXT
│   └── ...
├── N050/  (scènes 50-99)   → 50 fichiers
├── N100/  (scènes 100-149) → 50 fichiers
├── N150/  (scènes 150-199) → 50 fichiers
├── N200/  (scènes 200-249) → 50 fichiers
├── N250/  (scènes 250-299) → 50 fichiers
├── N300/  (scènes 300-349) → 50 fichiers
├── N350/  (scènes 350-399) → 50 fichiers
└── N400/  (scène 400)      → 1 fichier

TEXTEN/ (Version anglaise - 401 fichiers)
├── N000/  (scenes 0-49)    → 50 fichiers
│   ├── N000.TXT (game title)
│   ├── N001.TXT
│   └── ...
├── N050/  (scenes 50-99)   → 50 fichiers
├── N100/  (scenes 100-149) → 50 fichiers
├── N150/  (scenes 150-199) → 50 fichiers
├── N200/  (scenes 200-249) → 50 fichiers
├── N250/  (scenes 250-299) → 50 fichiers
├── N300/  (scenes 300-349) → 50 fichiers
├── N350/  (scenes 350-399) → 50 fichiers
└── N400/  (scene 400)      → 1 fichier
```

### Correspondance des fichiers

Chaque fichier français a son équivalent anglais :
- `TEXTFR/N000/N001.TXT` ↔ `TEXTEN/N000/N001.TXT`
- Les numéros de scène sont identiques
- La structure et les choix (C xxx) sont préservés
- Seul le texte narratif est traduit

## 🌍 Traduction anglaise

### Statut : 100% complète ✓

- **Date de traduction** : Octobre 2024
- **Fichiers traduits** : 401 fichiers (100%)
- **Méthode** : Traduction manuelle préservant :
  - Les numéros de scène
  - La structure des choix (C xxx)
  - Le gameplay et les références
  - L'atmosphère narrative

### Particularités

- Adaptation au contexte anglophone (gamebook genre)
- Respect des contraintes d'affichage (≤18 lignes)
- Terminologie cohérente :
  - `HABILETE` → `SKILL`
  - `ENDURANCE` → `STAMINA`
  - `CHANCE` → `LUCK`

## 📚 Documentation

- `OPTIMISATION-RAPPORT.txt` : Rapport détaillé de l'optimisation
- `FICHIERS-OPTIMISES.txt` : Liste rapide des fichiers modifiés
- `README-TEXTES.md` : Ce fichier

## ✅ Vérification

### Vérifier les limites de lignes (18 max)

Pour la version **française** :
```bash
for file in TEXTFR/*/*.TXT; do
    lignes=$(grep -v "^C " "$file" | grep -v "^$" | wc -l)
    if [ $lignes -gt 18 ]; then
        echo "$(basename $file): $lignes lignes (TROP LONG)"
    fi
done
```

Pour la version **anglaise** :
```bash
for file in TEXTEN/*/*.TXT; do
    lignes=$(grep -v "^C " "$file" | grep -v "^$" | wc -l)
    if [ $lignes -gt 18 ]; then
        echo "$(basename $file): $lignes lignes (TOO LONG)"
    fi
done
```

**Résultat actuel** : 
- Français : 0 fichiers trop longs ✓
- Anglais : 0 fichiers trop longs ✓

### Vérifier la correspondance FR ↔ EN

```bash
# Compter les fichiers
echo "Fichiers FR: $(find TEXTFR -name "*.TXT" -o -name "N168TXT" | wc -l)"
echo "Fichiers EN: $(find TEXTEN -name "*.TXT" -o -name "N168TXT" | wc -l)"
```

**Résultat attendu** : 401 fichiers dans chaque langue

## 🎯 Recommandations

Lors de la création de nouveaux textes :

1. ✅ Respecter la limite de 18 lignes
2. ✅ Être concis et percutant
3. ✅ Éviter les répétitions
4. ✅ Privilégier l'action sur la description
5. ✅ Tester l'affichage sur écran 80 colonnes

## 👨‍💻 Auteur

VERHILLE Arnaud - gist974@gmail.com

**Dates importantes** :
- Optimisation française : 5 octobre 2024
- Traduction anglaise complète : 24 octobre 2024
- Statut : Version bilingue 100% opérationnelle ✓

