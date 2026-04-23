; video.s - Gestion des modes vidéo Apple IIe Enhanced
;
; enable_text_mode : mode texte 80 colonnes
; enable_hgr_full  : HGR page 1 plein écran
; clear_text       : efface l'écran texte (HOME)
; init_80col       : active la carte 80 colonnes (équivalent de PR#3)

.include "apple2.inc"

.export enable_text_mode
.export enable_hgr_full
.export clear_text
.export init_80col

.segment "CODE"

;-------------------------------------------------------------------
; init_80col
;   Active le mode 80 colonnes en appelant le firmware slot 3.
;   Équivalent de PR#3 depuis BASIC.
;-------------------------------------------------------------------
.proc init_80col
        lda     #$95            ; Ctrl-U pour basculer en 80 col via COUT
        ; Séquence courante : écrire $00 dans $C001, puis utiliser
        ; la routine firmware. Plus sûr : STA SET80COL + STA SET80VID.
        sta     SET80COL        ; 80 store
        sta     ALTCHAR         ; charset alterné (minuscules)
        ; Activer l'affichage 80 colonnes via SETVID ($FE93) + ^Q/^R ?
        ; Le plus simple : JSR $C300 pour initialiser le firmware 80col.
        jsr     $C300           ; entrée ROM carte 80 colonnes
        rts
.endproc

;-------------------------------------------------------------------
; enable_text_mode
;   Bascule en mode texte (toutes les lignes en texte).
;-------------------------------------------------------------------
.proc enable_text_mode
        sta     TXTSET          ; texte ON
        rts
.endproc

;-------------------------------------------------------------------
; enable_hgr_full
;   Bascule en HGR page 1 plein écran.
;-------------------------------------------------------------------
.proc enable_hgr_full
        sta     TXTCLR          ; graphisme
        sta     HIRES           ; haute résolution
        sta     LOWSCR          ; page 1
        sta     MIXCLR          ; plein écran (pas de texte)
        rts
.endproc

;-------------------------------------------------------------------
; clear_text
;   Équivalent de HOME : efface l'écran texte + curseur en haut.
;-------------------------------------------------------------------
.proc clear_text
        jsr     HOME
        rts
.endproc
