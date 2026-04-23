; io.s - Entrées / sorties texte
;
; print_char  : imprime le caractère en A (MSB mis à 1 pour COUT)
; print_cr    : imprime CR
; print_str   : imprime une chaîne zero-terminée dont l'adresse est en
;               zp_ptr1 (lo) / zp_ptr1+1 (hi)
; print_pstr  : imprime une chaîne précédée d'un octet de longueur
;               (adresse en zp_ptr1)
; read_key    : lit une touche (blocant), retour en A, MSB nettoyé
;
; Remarque : COUT ($FDED) attend le bit 7 du code ASCII mis à 1.
; On fait donc ORA #$80 avant d'appeler COUT.

.include "apple2.inc"
.include "zp.inc"

.export print_char
.export print_cr
.export print_str
.export print_pstr
.export read_key

.segment "CODE"

;-------------------------------------------------------------------
; print_char : imprime le caractère en A via COUT.
;-------------------------------------------------------------------
.proc print_char
        ora     #$80
        jmp     COUT
.endproc

;-------------------------------------------------------------------
; print_cr : imprime un retour chariot.
;-------------------------------------------------------------------
.proc print_cr
        lda     #$0D
        ora     #$80
        jmp     COUT
.endproc

;-------------------------------------------------------------------
; print_str : imprime la chaîne zero-terminée pointée par zp_ptr1.
;             Détruit A, Y ; préserve X.
;-------------------------------------------------------------------
.proc print_str
        ldy     #0
loop:
        lda     (zp_ptr1),y
        beq     done
        ora     #$80
        jsr     COUT
        iny
        bne     loop            ; chaînes < 256 octets
done:
        rts
.endproc

;-------------------------------------------------------------------
; print_pstr : imprime une chaîne Pascal (longueur + octets).
;              Adresse en zp_ptr1.
;-------------------------------------------------------------------
.proc print_pstr
        ldy     #0
        lda     (zp_ptr1),y     ; longueur
        beq     done
        sta     zp_len
        ldy     #1
loop:
        lda     (zp_ptr1),y
        ora     #$80
        jsr     COUT
        iny
        cpy     zp_len
        bcc     loop
        beq     loop            ; inclut le dernier octet
done:
        rts
.endproc

;-------------------------------------------------------------------
; read_key : lit une touche via RDKEY, nettoie le MSB.
;-------------------------------------------------------------------
.proc read_key
        jsr     RDKEY
        and     #$7F
        rts
.endproc
