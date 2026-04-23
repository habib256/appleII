; header.s - ProDOS BIN file header (load address + length)
;
; Format attendu par ProDOS pour un fichier de type BIN :
;   offset 0-1 : adresse de chargement (little-endian)
;   offset 2-3 : taille du binaire (little-endian)
;
; Le lineur calcule __MAIN_START__ et __MAIN_LAST__ depuis apple2-asm.cfg.

.import __MAIN_START__, __MAIN_LAST__

.segment "HEADER"

        .word   __MAIN_START__
        .word   __MAIN_LAST__ - __MAIN_START__
