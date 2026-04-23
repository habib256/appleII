; paths.s - Construction des chemins ProDOS pour une scène
;
; build_img_path : crée "IMG/N###.HGR" dans img_path (Pascal string)
;                  scene_id (0-999) passé en A (lo) et X (hi)
; build_txt_path : crée "TXTFR/N###" ou "TXTEN/N###" dans txt_path
;                  scene_id en A/X, langue en Y (0=FR, 1=EN)
;
; Les chemins sont au format Pascal (premier octet = longueur) pour
; passer directement à ProDOS MLI.

.include "zp.inc"

.export build_img_path
.export build_txt_path
.export img_path
.export txt_path

.segment "CODE"

;-------------------------------------------------------------------
; itoa3 : convertit l'entier (A=lo, X=hi) en trois chiffres ASCII
;         stockés dans (zp_ptr1)+Y, Y étant incrémenté de 3.
;         Gère valeurs 0-999.
;-------------------------------------------------------------------
.proc itoa3
        sta     zp_tmp1         ; lo
        stx     zp_tmp2         ; hi

        ; Centaines : diviser par 100
        lda     #0
        sta     zp_len          ; résultat centaines
@hundred:
        lda     zp_tmp1
        cmp     #100
        lda     zp_tmp2
        sbc     #0
        bcc     @h_done
        ; Soustraire 100 de (tmp2:tmp1)
        lda     zp_tmp1
        sec
        sbc     #100
        sta     zp_tmp1
        lda     zp_tmp2
        sbc     #0
        sta     zp_tmp2
        inc     zp_len
        bne     @hundred
@h_done:
        lda     zp_len
        clc
        adc     #'0'
        sta     (zp_ptr1),y
        iny

        ; Dizaines
        lda     #0
        sta     zp_len
@ten:
        lda     zp_tmp1
        cmp     #10
        bcc     @t_done
        sec
        sbc     #10
        sta     zp_tmp1
        inc     zp_len
        bne     @ten
@t_done:
        lda     zp_len
        clc
        adc     #'0'
        sta     (zp_ptr1),y
        iny

        ; Unités
        lda     zp_tmp1
        clc
        adc     #'0'
        sta     (zp_ptr1),y
        iny
        rts
.endproc

;-------------------------------------------------------------------
; build_img_path
;   Entrée : scene_id en A (lo) et X (hi)
;   Sortie : img_path rempli avec "IMG/N###.HGR" au format Pascal
;-------------------------------------------------------------------
.proc build_img_path
        pha                     ; sauvegarder lo
        txa
        pha                     ; sauvegarder hi

        ; Pointeur d'écriture = img_path
        lda     #<img_path
        sta     zp_ptr1
        lda     #>img_path
        sta     zp_ptr1+1

        ; Longueur fixe : 12 ("IMG/N###.HGR")
        ldy     #0
        lda     #12
        sta     (zp_ptr1),y
        iny

        ; Copier "IMG/N"
        ldx     #0
@copy:
        lda     prefix_img,x
        sta     (zp_ptr1),y
        iny
        inx
        cpx     #5
        bne     @copy

        ; Insérer les 3 chiffres
        pla                     ; restaurer hi
        tax
        pla                     ; restaurer lo
        jsr     itoa3

        ; Copier ".HGR"
        ldx     #0
@copy2:
        lda     suffix_hgr,x
        sta     (zp_ptr1),y
        iny
        inx
        cpx     #4
        bne     @copy2

        rts
.endproc

;-------------------------------------------------------------------
; build_txt_path
;   Entrée : scene_id en A (lo) et X (hi), langue en Y (0=FR, 1=EN)
;   Sortie : txt_path rempli avec "TXT??/N###" (format Pascal)
;            longueur = 10
;-------------------------------------------------------------------
.proc build_txt_path
        pha                     ; lo
        txa
        pha                     ; hi
        tya                     ; langue
        pha

        lda     #<txt_path
        sta     zp_ptr1
        lda     #>txt_path
        sta     zp_ptr1+1

        ldy     #0
        lda     #10             ; "TXTFR/N###" = 10 caractères
        sta     (zp_ptr1),y
        iny

        ; Copier "TXT"
        ldx     #0
@copy_txt:
        lda     prefix_txt,x
        sta     (zp_ptr1),y
        iny
        inx
        cpx     #3
        bne     @copy_txt

        ; Choisir la langue
        pla                     ; lang
        beq     @fr
        ; EN
        lda     #'E'
        sta     (zp_ptr1),y
        iny
        lda     #'N'
        jmp     @slash
@fr:
        lda     #'F'
        sta     (zp_ptr1),y
        iny
        lda     #'R'
@slash:
        sta     (zp_ptr1),y
        iny

        ; "/N"
        lda     #'/'
        sta     (zp_ptr1),y
        iny
        lda     #'N'
        sta     (zp_ptr1),y
        iny

        ; Chiffres
        pla                     ; hi
        tax
        pla                     ; lo
        jsr     itoa3

        rts
.endproc

;-------------------------------------------------------------------
; Tables et tampons
;-------------------------------------------------------------------
.segment "RODATA"
prefix_img:     .byte   "IMG/N"
suffix_hgr:     .byte   ".HGR"
prefix_txt:     .byte   "TXT"

.segment "BSS"
img_path:       .res    24
txt_path:       .res    24
