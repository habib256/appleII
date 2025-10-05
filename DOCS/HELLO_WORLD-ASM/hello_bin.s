; Hello World BIN (BRUN) pour Apple II / ProDOS
; Chargé et exécuté à $0803, retourne au BASIC avec RTS

        .export start

start:
        jsr $FC58          ; HOME
        ldy #$00
@loop:  lda message,y
        beq @done
        jsr $FDED          ; COUT (affiche A)
        iny
        bne @loop
@done:  rts

; Chaîne en texte Apple (bit 7 à 1) + CR + fin 0
message:
        .byte $C8,$E5,$EC,$EC,$EF,$A0,$D7,$EF,$F2,$EC,$E4,$A1,$8D,0
