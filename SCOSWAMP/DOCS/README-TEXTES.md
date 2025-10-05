# Fichiers texte - Le Marais aux Scorpions

## 📊 Vue d'ensemble

- **Total de fichiers** : 178 fichiers .TXT
- **Langues** : Français (TEXTFR/) et Anglais (TEXTEN/)
- **Organisation** : Par tranches de 50 (N000/, N050/, N100/, etc.)
- **Conformité** : 100% des fichiers ≤18 lignes ✓

## 📐 Contraintes d'affichage

### Apple IIe Enhanced - Mode 80 colonnes

L'écran dispose de **24 lignes** totales :

```
Ligne 1    : Titre (ex: "001 : Le chemin vers le Marais")
Ligne 2    : Séparateur (ex: "------------------------------")
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

```
TEXTFR/
├── N000/  (scènes 0-49)
│   ├── N000.TXT (titre du jeu)
│   ├── N001.TXT
│   └── ...
├── N050/  (scènes 50-99)
│   ├── N050.TXT
│   └── ...
├── N100/  (scènes 100-149)
├── N150/  (scènes 150-199)
├── N200/  (scènes 200-249)
├── N250/  (scènes 250-299)
├── N300/  (scènes 300-349)
└── N350/  (scènes 350-399)
```

## 📚 Documentation

- `OPTIMISATION-RAPPORT.txt` : Rapport détaillé de l'optimisation
- `FICHIERS-OPTIMISES.txt` : Liste rapide des fichiers modifiés
- `README-TEXTES.md` : Ce fichier

## ✅ Vérification

Pour vérifier qu'aucun fichier ne dépasse 18 lignes :

```bash
for file in TEXTFR/*/*.TXT; do
    lignes=$(grep -v "^C " "$file" | grep -v "^$" | wc -l)
    if [ $lignes -gt 18 ]; then
        echo "$(basename $file): $lignes lignes (TROP LONG)"
    fi
done
```

Résultat actuel : **0 fichiers trop longs** ✓

## 🎯 Recommandations

Lors de la création de nouveaux textes :

1. ✅ Respecter la limite de 18 lignes
2. ✅ Être concis et percutant
3. ✅ Éviter les répétitions
4. ✅ Privilégier l'action sur la description
5. ✅ Tester l'affichage sur écran 80 colonnes

## 👨‍💻 Auteur

VERHILLE Arnaud - gist974@gmail.com

Date d'optimisation : 5 octobre 2025

