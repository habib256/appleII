; main.s - Point d'entrée SPACETRIP (pur assembleur 6502, ca65)
;
; Architecture identique à la version C :
;   - Écran de sélection de langue (F / E)
;   - Écran-titre
;   - Boucle principale : ESPACE bascule texte/HGR, A-Z choix, Q quitte
;
; La scène courante est chargée depuis les fichiers ProDOS :
;   - IMG/N###.HGR  (8 Ko → HGR page 1 à $2000)
;   - TXTFR/N### ou TXTEN/N### (texte + choix)

.include "apple2.inc"
.include "zp.inc"

.import enable_text_mode, enable_hgr_full, clear_text, init_80col
.import print_char, print_cr, print_str, read_key
.import file_open, file_read, file_close
.import build_img_path, img_path
.import display_scene_text, num_choices, choices_id, file_buffer

.export io_buffer               ; utilisé par mli.s

;-------------------------------------------------------------------
; Point d'entrée en tête du binaire ($4000)
;-------------------------------------------------------------------
.segment "STARTUP"
        jmp     main

.segment "CODE"

;-------------------------------------------------------------------
; main : point d'entrée
;-------------------------------------------------------------------
.proc main
        ; Sauvegarde de la stack (utile si on sort proprement)
        tsx
        stx     saved_stack

        ; Initialiser 80 colonnes + mode texte
        jsr     init_80col
        jsr     enable_text_mode
        jsr     clear_text

        ; ----- Écran de sélection de langue -----
        lda     #<lang_screen
        ldx     #>lang_screen
        sta     zp_ptr1
        stx     zp_ptr1+1
        jsr     print_str

        ; Attendre F ou E
wait_lang:
        jsr     read_key
        cmp     #'F'
        beq     @fr
        cmp     #'f'
        beq     @fr
        cmp     #'E'
        beq     @en
        cmp     #'e'
        beq     @en
        jmp     wait_lang
@fr:    lda     #0
        sta     language
        jmp     lang_ok
@en:    lda     #1
        sta     language

lang_ok:
        ; ----- Écran-titre -----
        jsr     clear_text
        lda     language
        bne     @title_en
        lda     #<title_fr
        ldx     #>title_fr
        jmp     @title_print
@title_en:
        lda     #<title_en
        ldx     #>title_en
@title_print:
        sta     zp_ptr1
        stx     zp_ptr1+1
        jsr     print_str
        jsr     read_key        ; attend une touche pour démarrer

        ; ----- Charger la scène 1 -----
        lda     #1
        sta     current_scene
        lda     #0
        sta     current_scene+1
        lda     #0
        sta     video_mode
        jsr     load_scene

        ; ----- Boucle principale -----
main_loop:
        jsr     read_key

        cmp     #' '
        bne     @not_space
        jsr     cycle_video
        jmp     main_loop
@not_space:
        cmp     #'Q'
        beq     quit_game
        cmp     #'q'
        beq     quit_game
        cmp     #'A'
        bcc     @maybe_lower
        cmp     #'Z'+1
        bcc     @upper
@maybe_lower:
        cmp     #'a'
        bcc     main_loop
        cmp     #'z'+1
        bcs     main_loop
        sec
        sbc     #'a'
        jmp     @choice
@upper:
        sec
        sbc     #'A'
@choice:
        tax                     ; X = index de choix
        cpx     num_choices
        bcs     main_loop       ; >= num_choices : ignorer
        lda     choices_id,x    ; lo
        sta     current_scene
        lda     #0
        sta     current_scene+1
        jsr     load_scene
        jmp     main_loop

quit_game:
        jsr     enable_text_mode
        jsr     clear_text
        lda     language
        bne     @bye_en
        lda     #<bye_fr
        ldx     #>bye_fr
        jmp     @bye_print
@bye_en:
        lda     #<bye_en
        ldx     #>bye_en
@bye_print:
        sta     zp_ptr1
        stx     zp_ptr1+1
        jsr     print_str
        jsr     print_cr

        ; Retour à ProDOS : via MLI QUIT
        jsr     MLI
        .byte   MLI_QUIT
        .word   quit_pb
        ; Si QUIT échoue (ne devrait pas), boucle
        jmp     *
.endproc

;-------------------------------------------------------------------
; load_scene : charge l'image HGR puis affiche la scène selon
;              video_mode (0 = texte, 1 = HGR).
;              Entrée : current_scene (16 bits).
;-------------------------------------------------------------------
.proc load_scene
        ; Charger l'image HGR
        jsr     load_hgr_image
        ; Afficher selon mode
        lda     video_mode
        beq     @text
        jsr     enable_hgr_full
        rts
@text:
        jsr     show_text
        rts
.endproc

;-------------------------------------------------------------------
; show_text : affiche le texte de la scène courante.
;-------------------------------------------------------------------
.proc show_text
        jsr     enable_text_mode
        jsr     clear_text
        ; Préparer paramètres pour display_scene_text
        lda     current_scene
        sta     zp_ptr2
        lda     current_scene+1
        sta     zp_ptr2+1
        lda     language
        sta     zp_tmp2
        jsr     display_scene_text
        rts
.endproc

;-------------------------------------------------------------------
; load_hgr_image : charge IMG/N###.HGR dans $2000-$3FFF.
;                  Retourne C=0 si OK, C=1 si échec.
;-------------------------------------------------------------------
.proc load_hgr_image
        ; Construire le chemin
        lda     current_scene
        ldx     current_scene+1
        jsr     build_img_path

        ; Ouvrir le fichier
        lda     #<img_path
        sta     zp_ptr1
        lda     #>img_path
        sta     zp_ptr1+1
        jsr     file_open
        bcs     fail
        sta     zp_idx

        ; Lire 8192 octets vers $2000
        lda     #$00
        sta     zp_ptr1
        lda     #$20
        sta     zp_ptr1+1
        lda     #$00            ; 8192 = $2000 (lo=0, hi=$20)
        sta     zp_len
        lda     #$20
        sta     zp_tmp1
        jsr     file_read

        ; Fermer
        lda     zp_idx
        jsr     file_close
        clc
        rts
fail:
        sec
        rts
.endproc

;-------------------------------------------------------------------
; cycle_video : bascule 0 <-> 1 et réaffiche.
;-------------------------------------------------------------------
.proc cycle_video
        lda     video_mode
        eor     #1
        sta     video_mode
        beq     @to_text
        jsr     enable_hgr_full
        rts
@to_text:
        jsr     show_text
        rts
.endproc

;-------------------------------------------------------------------
; Données : écran de sélection, titres, quitte
;-------------------------------------------------------------------
.segment "RODATA"

; Écran de sélection (bilingue, communs)
lang_screen:
        .byte $0D, $0D, $0D
        .byte "    ==============================================", $0D
        .byte "              SPACE EXPLORER TRIP", $0D
        .byte "    ==============================================", $0D, $0D
        .byte "         SELECT YOUR LANGUAGE / LANGUE", $0D, $0D
        .byte "              [F] - Francais", $0D
        .byte "              [E] - English", $0D, $0D
        .byte "    ==============================================", $0D, 0

title_fr:
        .byte $0D
        .byte "    ==============================================", $0D
        .byte "              SPACE EXPLORER TRIP", $0D
        .byte "        Une Odyssee Interactive Galactique", $0D
        .byte "    ==============================================", $0D, $0D
        .byte "  Embarquez pour un voyage extraordinaire", $0D
        .byte "  a travers les etoiles !", $0D, $0D
        .byte "  COMMANDES :", $0D
        .byte "    [ESPACE] Basculer texte / graphique", $0D
        .byte "    [A-Z]    Choisir une destination", $0D
        .byte "    [Q]      Quitter l aventure", $0D, $0D
        .byte "  VERHILLE Arnaud - gist974@gmail.com", $0D
        .byte "  Version Assembleur 6502 (ca65)", $0D, $0D
        .byte "    >>> Appuyez sur une touche pour decoller <<<", $0D, 0

title_en:
        .byte $0D
        .byte "    ==============================================", $0D
        .byte "              SPACE EXPLORER TRIP", $0D
        .byte "        An Interactive Galactic Odyssey", $0D
        .byte "    ==============================================", $0D, $0D
        .byte "  Embark on an extraordinary journey", $0D
        .byte "  through the stars !", $0D, $0D
        .byte "  COMMANDS :", $0D
        .byte "    [SPACE]  Toggle text / graphics", $0D
        .byte "    [A-Z]    Pick a destination", $0D
        .byte "    [Q]      Quit the adventure", $0D, $0D
        .byte "  By Arnaud VERHILLE - gist974@gmail.com", $0D
        .byte "  Pure 6502 Assembly Version (ca65)", $0D, $0D
        .byte "       >>> Press any key to launch <<<", $0D, 0

bye_fr: .byte "Au revoir !", 0
bye_en: .byte "Goodbye !", 0

;-------------------------------------------------------------------
; Paramètres pour MLI_QUIT
;-------------------------------------------------------------------
quit_pb:
        .byte   4
        .byte   0               ; quit_type
        .word   0               ; reserved
        .byte   0               ; reserved
        .word   0               ; reserved

;-------------------------------------------------------------------
; Variables
;-------------------------------------------------------------------
.segment "BSS"

language:       .res    1       ; 0 = FR, 1 = EN
video_mode:     .res    1       ; 0 = texte, 1 = HGR
current_scene:  .res    2       ; 16 bits
saved_stack:    .res    1

; io_buffer : 1 Ko aligné 256 pour ProDOS MLI
.align 256
io_buffer:      .res    1024

