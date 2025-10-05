#!/bin/bash
# Script de compilation rapide pour Le Marais aux Scorpions
# Usage: ./build.sh [clean|rebuild|info]

set -e  # Arrêter en cas d'erreur

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$SCRIPT_DIR"

case "${1:-build}" in
    clean)
        echo "==> Nettoyage des fichiers intermédiaires..."
        rm -f *.o *.s
        echo "==> Terminé"
        ;;
    
    distclean)
        echo "==> Nettoyage complet..."
        rm -f *.o *.s ../SCOSWAMP.BIN
        echo "==> Terminé"
        ;;
    
    rebuild)
        echo "==> Reconstruction complète..."
        rm -f *.o *.s ../SCOSWAMP.BIN
        make
        ;;
    
    info)
        echo "Configuration du projet :"
        echo "  Cible         : apple2enh (Apple IIe Enhanced)"
        echo "  Programme     : SCOSWAMP.BIN"
        echo "  Sources       : scoswamp.c paths.c"
        echo "  Sortie        : ../"
        echo "  Adresse start : \$4000 (HGR Page 1 à \$2000-\$3FFF préservé)"
        ;;
    
    build|*)
        echo "==> Compilation de Le Marais aux Scorpions..."
        
        # Vérifier que cc65 est installé
        if ! command -v cl65 &> /dev/null; then
            echo "ERREUR: cc65 n'est pas installé ou pas dans le PATH"
            echo "Installation: https://cc65.github.io/"
            exit 1
        fi
        
        # Compiler avec cl65 (méthode simple)
        echo "    Compilation de scoswamp.c et paths.c..."
        cl65 -t apple2enh -O -Oirs \
             -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 \
             -o ../SCOSWAMP.BIN scoswamp.c paths.c
        
        echo "==> Compilation réussie : ../SCOSWAMP.BIN"
        echo "    Adresse de démarrage : \$4000 (HGR Page 1 à \$2000-\$3FFF préservé)"
        echo ""
        echo "Pour tester :"
        echo "  - Copier SCOSWAMP.BIN sur une image ProDOS"
        echo "  - Lancer depuis le répertoire contenant IMG/, TEXTFR/, TEXTEN/"
        ;;
esac
