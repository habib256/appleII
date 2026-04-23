; parser.s - Affichage et analyse du texte d'une scène
;
; display_scene_text :
;   Lit TXT??/N### depuis ProDOS, imprime chaque ligne.
;   Les lignes débutant par "C " sont interprétées comme choix et
;   enregistrées dans la table choices[] (scene_id + lettre).
;   Entrée : scene_id dans zp_ptr2 (lo/hi), langue dans zp_tmp2.

.include "apple2.inc"
.include "zp.inc"

.export display_scene_text
.export num_choices
.export choices_id
.export file_buffer

.import build_txt_path
.import txt_path
.import file_open, file_read, file_close
.import print_char, print_cr, print_str

.segment "CODE"

FILE_BUFFER_SIZE = 2048

;-------------------------------------------------------------------
; display_scene_text
;-------------------------------------------------------------------
.proc display_scene_text
        ; Construire le chemin TXT
        lda     zp_ptr2
        ldx     zp_ptr2+1
        ldy     zp_tmp2
        jsr     build_txt_path

        ; Ouvrir le fichier
        lda     #<txt_path
        sta     zp_ptr1
        lda     #>txt_path
        sta     zp_ptr1+1
        jsr     file_open
        bcc     :+
        jmp     err_open
:       sta     zp_idx          ; ref_num

        ; Lire jusqu'à FILE_BUFFER_SIZE-1 octets
        lda     #<file_buffer
        sta     zp_ptr1
        lda     #>file_buffer
        sta     zp_ptr1+1
        lda     #<(FILE_BUFFER_SIZE-1)
        sta     zp_len
        lda     #>(FILE_BUFFER_SIZE-1)
        sta     zp_tmp1
        jsr     file_read
        ; Même si EOF, on affiche ce qui a été lu

        ; Fermer
        lda     zp_idx
        jsr     file_close

        ; Réinitialiser la liste des choix
        lda     #0
        sta     num_choices

        ; Parcourir le buffer, ligne par ligne.
        ; Stratégie : on stocke en zp_ptr1 l'adresse de début de la
        ; ligne courante, et on scanne jusqu'à CR/LF/NUL.
        lda     #<file_buffer
        sta     zp_ptr1
        lda     #>file_buffer
        sta     zp_ptr1+1

parse_lines:
        ldy     #0
        lda     (zp_ptr1),y
        beq     done_parse      ; NUL = fin

        ; Si ligne commence par "C " : l'enregistrer comme choix
        cmp     #'C'
        bne     print_line
        ldy     #1
        lda     (zp_ptr1),y
        cmp     #' '
        bne     print_line
        jsr     add_choice
        jmp     skip_line

print_line:
        ; Imprimer les octets jusqu'à CR/LF/NUL
        ldy     #0
ploop:
        lda     (zp_ptr1),y
        beq     line_done
        cmp     #$0D
        beq     line_done
        cmp     #$0A
        beq     line_done
        ora     #$80
        jsr     COUT
        iny
        bne     ploop
line_done:
        jsr     print_cr

skip_line:
        ; Avancer zp_ptr1 jusqu'après le prochain CR/LF/NUL
        ldy     #0
scan:
        lda     (zp_ptr1),y
        beq     done_parse
        iny
        cmp     #$0D
        beq     check_lf
        cmp     #$0A
        beq     advance
        cpy     #0
        bne     scan
        ; Y a débordé : avancer zp_ptr1 de 256
        inc     zp_ptr1+1
        jmp     scan

check_lf:
        lda     (zp_ptr1),y
        cmp     #$0A
        bne     advance
        iny                     ; sauter le LF
advance:
        ; zp_ptr1 += Y
        tya
        clc
        adc     zp_ptr1
        sta     zp_ptr1
        bcc     :+
        inc     zp_ptr1+1
:       jmp     parse_lines

done_parse:
        ; Afficher les choix
        lda     num_choices
        beq     no_choices
        jsr     print_cr
        ; "--- Choix ---" (FR) ou "--- Choices ---" (EN)
        lda     zp_tmp2
        beq     @fr_hdr
        lda     #<hdr_choices_en
        ldx     #>hdr_choices_en
        jmp     @print_hdr
@fr_hdr:
        lda     #<hdr_choices_fr
        ldx     #>hdr_choices_fr
@print_hdr:
        sta     zp_ptr1
        stx     zp_ptr1+1
        jsr     print_str
        jsr     print_cr

        ; Liste : A) titre1\r\n B) titre2...
        ldx     #0
list_loop:
        cpx     num_choices
        beq     no_choices
        txa
        clc
        adc     #'A'
        jsr     print_char
        lda     #')'
        jsr     print_char
        lda     #' '
        jsr     print_char
        ; Pour simplifier on ré-imprime depuis le buffer : on
        ; affiche "Scene ###" plutôt que le titre. Solution basique.
        ; (Le titre complet est dans la ligne C, on pourrait pointer
        ; vers le buffer mais on reste minimal.)
        lda     #'S'
        jsr     print_char
        lda     #'c'
        jsr     print_char
        lda     #'e'
        jsr     print_char
        lda     #'n'
        jsr     print_char
        lda     #'e'
        jsr     print_char
        lda     #' '
        jsr     print_char
        ; Imprimer le scene_id en décimal (3 chiffres)
        lda     choices_id,x
        sta     zp_tmp1
        lda     choices_id_hi,x
        sta     zp_tmp2         ; NB : écrase zp_tmp2, restauré ailleurs
        jsr     print_dec3
        jsr     print_cr
        inx
        jmp     list_loop

no_choices:
        jsr     print_cr
        ; Pied de page : commandes disponibles
        lda     #<footer_fr
        ldx     #>footer_fr
        sta     zp_ptr1
        stx     zp_ptr1+1
        jsr     print_str
        jsr     print_cr
        rts

err_open:
        lda     #<err_file
        ldx     #>err_file
        sta     zp_ptr1
        stx     zp_ptr1+1
        jsr     print_str
        jsr     print_cr
        rts
.endproc

;-------------------------------------------------------------------
; add_choice : extrait l'ID d'une ligne "C ### titre"
;              Consume la ligne pointée par zp_ptr1.
;-------------------------------------------------------------------
.proc add_choice
        ; On lit au maximum 3 chiffres à partir de l'offset 2
        ldy     #2
        lda     #0
        sta     zp_tmp1         ; lo
        sta     zp_tmp2         ; hi (inutilisé au-delà de 999)
@digit:
        lda     (zp_ptr1),y
        cmp     #'0'
        bcc     @done
        cmp     #':'            ; '9'+1
        bcs     @done
        sec
        sbc     #'0'
        pha
        ; tmp1 = tmp1 * 10
        lda     zp_tmp1
        asl     a
        asl     a
        clc
        adc     zp_tmp1
        asl     a
        sta     zp_tmp1
        pla
        clc
        adc     zp_tmp1
        sta     zp_tmp1
        iny
        bne     @digit
@done:
        ; Stocker l'ID dans la table des choix
        ldx     num_choices
        cpx     #MAX_CHOICES
        bcs     @skip
        lda     zp_tmp1
        sta     choices_id,x
        lda     #0
        sta     choices_id_hi,x
        inc     num_choices
@skip:
        rts
.endproc

;-------------------------------------------------------------------
; print_dec3 : imprime zp_tmp1 (0-255) ou zp_tmp1+zp_tmp2*256
;              en trois chiffres décimaux.
;-------------------------------------------------------------------
.proc print_dec3
        ; Centaines
        lda     #0
        sta     zp_len
@h:     lda     zp_tmp1
        cmp     #100
        lda     zp_tmp2
        sbc     #0
        bcc     @hd
        lda     zp_tmp1
        sec
        sbc     #100
        sta     zp_tmp1
        lda     zp_tmp2
        sbc     #0
        sta     zp_tmp2
        inc     zp_len
        bne     @h
@hd:    lda     zp_len
        clc
        adc     #'0'
        ora     #$80
        jsr     COUT
        ; Dizaines
        lda     #0
        sta     zp_len
@t:     lda     zp_tmp1
        cmp     #10
        bcc     @td
        sec
        sbc     #10
        sta     zp_tmp1
        inc     zp_len
        bne     @t
@td:    lda     zp_len
        clc
        adc     #'0'
        ora     #$80
        jsr     COUT
        ; Unités
        lda     zp_tmp1
        clc
        adc     #'0'
        ora     #$80
        jsr     COUT
        rts
.endproc

;-------------------------------------------------------------------
; Constantes
;-------------------------------------------------------------------
MAX_CHOICES     = 10

.segment "RODATA"
hdr_choices_fr: .byte "--- Choix ---", 0
hdr_choices_en: .byte "--- Choices ---", 0
footer_fr:      .byte "[ESPACE]=Graphique  [A-Z]=Choix  [Q]=Quitter", 0
err_file:       .byte "Erreur: fichier texte introuvable.", 0

.segment "BSS"
num_choices:    .res    1
choices_id:     .res    MAX_CHOICES
choices_id_hi:  .res    MAX_CHOICES
file_buffer:    .res    FILE_BUFFER_SIZE
