# Makefile - SPACETRIP version 100% assembleur 6502
#
# Utilise la suite cc65 (ca65 + ld65), mais aucune ligne de C :
#   ca65 : assembleur 6502 / 65C02
#   ld65 : éditeur de liens (configuré pour un BIN ProDOS à $4000)
#
# Usage :
#   make           -> produit ../SPACETRIP.ASM.BIN
#   make clean     -> supprime les .o
#   make distclean -> supprime aussi le binaire final
#   make run       -> affiche la commande pour lancer l'émulateur

TARGET  = apple2enh
CPU     = 65C02
AS      = ca65
LD      = ld65

SRCDIR  = src
OUTDIR  = .
OBJDIR  = build

CFG     = link/apple2-asm.cfg
PROGRAM = SPACETRIP.ASM.BIN

# L'ordre est important : header puis main (qui contient le STARTUP)
# puis les modules auxiliaires.
SRCS = \
	$(SRCDIR)/header.s \
	$(SRCDIR)/zp.s \
	$(SRCDIR)/main.s \
	$(SRCDIR)/video.s \
	$(SRCDIR)/io.s \
	$(SRCDIR)/mli.s \
	$(SRCDIR)/paths.s \
	$(SRCDIR)/parser.s

OBJS = $(patsubst $(SRCDIR)/%.s,$(OBJDIR)/%.o,$(SRCS))

ASFLAGS = --cpu $(CPU) -I $(SRCDIR)

# -- Règles --

all: $(OUTDIR)/$(PROGRAM)

$(OBJDIR):
	@mkdir -p $(OBJDIR)

$(OBJDIR)/%.o: $(SRCDIR)/%.s | $(OBJDIR)
	$(AS) $(ASFLAGS) -o $@ $<

$(OUTDIR)/$(PROGRAM): $(OBJS) $(CFG)
	$(LD) -C $(CFG) -o $@ $(OBJS)
	@echo "==> $(PROGRAM) généré (adresse de chargement : \$$4000)"
	@ls -l $@

clean:
	rm -rf $(OBJDIR)
	@echo "==> objets supprimés"

distclean: clean
	rm -f $(OUTDIR)/$(PROGRAM)
	@echo "==> nettoyage complet"

run:
	@echo "Montez ce dossier en disque ProDOS dans Virtual ][ / AppleWin,"
	@echo "puis à l'invite BASIC : ]BRUN $(PROGRAM)"

.PHONY: all clean distclean run
