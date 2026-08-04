# Makefile pour le système de combat Apple II
# Compilateur: cc65
# Cible: Apple II Enhanced

CC = cc65
AS = ca65
LD = cl65

# Options de compilation
CFLAGS = -t apple2enh -O -Oirs
ASFLAGS = -t apple2enh
# -Wl -m,$(MAPFILE) : produit la carte mémoire, indispensable pour vérifier
#                     la BSS (absente du .BIN, allouée au lancement)
LDFLAGS = -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000 -Wl -m,$(MAPFILE)

MAPFILE = build.map

# Fichiers sources
SOURCES = combat.c
OBJECTS = $(SOURCES:.c=.o)
ASSEMBLY = $(SOURCES:.c=.s)

# Fichier de sortie
TARGET = ../COMBAT.BIN

# Règle par défaut
all: $(TARGET)

# Compilation directe avec cl65
# Le contrôle mémoire est systématique : un link réussi ne prouve pas que le
# binaire tient (ld65 peut manquer un débordement BSS, voir tools/check-memory.sh).
# Point de vigilance pour ce module : son intégration à SCOSWAMP déborde
# actuellement de 6204 octets — voir la feuille de route dans ../README.md.
$(TARGET): $(SOURCES)
	$(LD) $(LDFLAGS) -o $@ $^
	@echo "==> Compilation terminée : $(TARGET)"
	@echo ""
	@../../tools/check-memory.sh $(MAPFILE)

# Contrôle mémoire seul (nécessite une compilation préalable)
check: $(MAPFILE)
	@../../tools/check-memory.sh $(MAPFILE)

# Nettoyage
clean:
	rm -f *.o *.s $(MAPFILE)
	@echo "==> Fichiers intermédiaires supprimés"

# Installation
install: $(TARGET)
	@echo "==> Installation terminée"

# Aide
help:
	@echo "Commandes disponibles:"
	@echo "  make        - Compiler le programme"
	@echo "  make clean  - Nettoyer les fichiers temporaires"
	@echo "  make help   - Afficher cette aide"

.PHONY: all check clean install help
