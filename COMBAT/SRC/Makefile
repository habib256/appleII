# Makefile pour le système de combat Apple II
# Compilateur: cc65
# Cible: Apple II Enhanced

CC = cc65
AS = ca65
LD = cl65

# Options de compilation
CFLAGS = -t apple2enh -O -Oirs
ASFLAGS = -t apple2enh
LDFLAGS = -t apple2enh -O -Oirs -Wl -D,__EXEHDR__=0 -Wl -S,0x4000

# Fichiers sources
SOURCES = combat.c
OBJECTS = $(SOURCES:.c=.o)
ASSEMBLY = $(SOURCES:.c=.s)

# Fichier de sortie
TARGET = ../COMBAT.BIN

# Règle par défaut
all: $(TARGET)

# Compilation directe avec cl65
$(TARGET): $(SOURCES)
	$(LD) $(LDFLAGS) -o $@ $^
	@echo "==> Compilation terminée : $(TARGET)"

# Nettoyage
clean:
	rm -f *.o *.s
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

.PHONY: all clean install help
