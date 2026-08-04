#!/usr/bin/env bash
#
# check-memory.sh - Vérifie qu'un binaire cc65 tient réellement en mémoire
#
# Un link réussi ne prouve PAS qu'un binaire tient. Le segment BSS (variables
# non initialisées) n'est pas dans le .BIN : il est alloué au lancement, juste
# après DATA. Un binaire de taille acceptable peut donc déborder à l'exécution.
#
# Pire, ld65 peut ne rien signaler. La zone BSS est définie ainsi :
#     BSS: start = __ONCE_RUN__, size = __HIMEM__ - __STACKSIZE__ - __ONCE_RUN__
# Si __ONCE_RUN__ dépasse déjà le plafond, la taille se calcule en négatif,
# déborde en non signé vers ~4 Go, et le contrôle d'overflow est neutralisé :
# le link réussit en silence et la BSS écrase ProDOS 8.
#
# Ce script lit le fichier .map et tranche.
#
# Usage :
#   ./tools/check-memory.sh build.map
#
# Code de sortie : 0 = tient en mémoire, 1 = déborde.
#
# Auteur  : Arnaud VERHILLE (gist974@gmail.com)
# Licence : GNU GPL v3.0

set -uo pipefail

MAP="${1:-}"

if [ -z "$MAP" ] || [ ! -f "$MAP" ]; then
    echo "Usage : $0 <fichier.map>" >&2
    echo "" >&2
    echo "Produire le .map avec :  cl65 ... -Wl -m,build.map -o PROG.BIN ..." >&2
    exit 2
fi

# Cible apple2enh sous ProDOS 8 (valeurs de /usr/share/cc65/cfg/apple2enh.cfg).
# $9600-$BFFF appartient à ProDOS : MLI, page globale ($BF00), buffers fichier.
readonly HIMEM=0x9600        # "presumed RAM end" cc65
readonly STACKSIZE=0x0800    # pile C, 2 Ko
readonly LOAD_ADDR=0x4000    # -Wl -S,0x4000, préserve HGR page 1
readonly CEILING=$((HIMEM - STACKSIZE))   # $8E00

# Fin du segment BSS = point le plus haut occupé à l'exécution.
bss_line=$(grep -E '^BSS ' "$MAP" | head -1)
if [ -z "$bss_line" ]; then
    echo "ERREUR : segment BSS introuvable dans $MAP" >&2
    echo "Le fichier est-il bien un .map produit par ld65 ?" >&2
    exit 2
fi

bss_start=$((16#$(echo "$bss_line" | awk '{print $2}')))
bss_end=$((16#$(echo "$bss_line" | awk '{print $3}')))

footprint=$((bss_end - LOAD_ADDR))
available=$((CEILING - LOAD_ADDR))

printf 'Analyse mémoire : %s\n' "$MAP"
printf '  Chargement    : $%04X\n' "$LOAD_ADDR"
printf '  BSS           : $%04X - $%04X\n' "$bss_start" "$bss_end"
printf '  Plafond       : $%04X  (__HIMEM__ $%04X moins %d o de pile C)\n' \
       "$CEILING" "$HIMEM" "$STACKSIZE"
printf '  Empreinte     : %d o sur %d o disponibles\n' "$footprint" "$available"

# Détection du piège : la BSS démarre-t-elle déjà au-delà du plafond ?
# Dans ce cas ld65 n'a rien pu signaler, quel que soit le résultat.
if [ "$bss_start" -ge "$CEILING" ]; then
    printf '\n'
    printf 'ERREUR : la BSS démarre à $%04X, au-delà du plafond $%04X.\n' \
           "$bss_start" "$CEILING"
    printf 'ld65 a calculé une taille de zone négative et son contrôle\n'
    printf "d'overflow a été neutralisé : le link a réussi à tort.\n"
    printf 'La BSS écraserait ProDOS 8 dès la première ouverture de fichier.\n'
    exit 1
fi

if [ "$bss_end" -gt "$CEILING" ]; then
    printf '\n'
    printf 'ERREUR : dépassement de %d octets.\n' "$((bss_end - CEILING))"
    printf 'Réduire le code/les données, ou passer en overlay\n'
    printf '(voir /usr/share/cc65/cfg/apple2enh-overlay.cfg).\n'
    exit 1
fi

printf '\n'
printf 'OK : tient en mémoire, marge de %d octets.\n' "$((CEILING - bss_end))"
exit 0
